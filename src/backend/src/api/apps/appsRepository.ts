import { query, pool } from "@/common/utils/database";
import type { PoolClient } from "pg";
import type { App, UserAppResponse } from "@/common/types";

class AppsRepository {
  async getAllApps(): Promise<App[]> {
    const result = await query("SELECT * FROM apps ORDER BY id", []);
    return result.rows;
  }

  async getAppById(appId: number): Promise<App | null> {
    const result = await query("SELECT * FROM apps WHERE id = $1", [appId]);
    return result.rows[0] || null;
  }

  async getUserApps(userId: number): Promise<UserAppResponse[]> {
    const result = await query(
      `SELECT 
        ua.app_id as "appId",
        a.name,
        a.img_path as "imgPath",
        a.run_path as "runPath",
        ua.sort_order as "order"
      FROM user_apps ua
      INNER JOIN apps a ON ua.app_id = a.id
      WHERE ua.user_id = $1
      ORDER BY ua.sort_order ASC`,
      [userId]
    );
    return result.rows;
  }

  async createOrUpdateApp(
    client: PoolClient,
    appId: number | undefined,
    name: string,
    imgPath: string,
    runPath: string
  ): Promise<number> {
    if (appId) {
      // 기존 앱 확인
      const existingResult = await client.query(
        "SELECT id FROM apps WHERE id = $1",
        [appId]
      );

      if (existingResult.rows.length > 0) {
        // 기존 앱 업데이트
        await client.query(
          `UPDATE apps SET name = $1, img_path = $2, run_path = $3 WHERE id = $4`,
          [name, imgPath, runPath, appId]
        );
        return appId;
      }
    }

    // 새 앱 생성
    const result = await client.query(
      `INSERT INTO apps (name, img_path, run_path) 
       VALUES ($1, $2, $3) 
       RETURNING id`,
      [name, imgPath, runPath]
    );

    return result.rows[0].id;
  }

  async updateUserAppOrder(
    userId: number,
    apps: Array<{
      id?: number;
      name: string;
      imgPath: string;
      runPath: string;
    }>
  ): Promise<void> {
    const client = await pool.connect();
    try {
      await client.query("BEGIN");

      // 사용자 존재 확인
      const userCheck = await client.query(
        "SELECT id FROM users WHERE id = $1",
        [userId]
      );

      if (userCheck.rows.length === 0) {
        throw new Error(`User with id ${userId} does not exist`);
      }

      // 기존 사용자 앱 삭제
      await client.query("DELETE FROM user_apps WHERE user_id = $1", [userId]);

      // 새로운 앱 순서 삽입
      for (let i = 0; i < apps.length; i++) {
        const app = apps[i];

        // 앱 생성 또는 업데이트 (트랜잭션 내에서)
        const appId = await this.createOrUpdateApp(
          client,
          app.id,
          app.name,
          app.imgPath,
          app.runPath
        );

        // 사용자 앱 순서 설정
        await client.query(
          `INSERT INTO user_apps (user_id, app_id, sort_order) 
           VALUES ($1, $2, $3)`,
          [userId, appId, i + 1]
        );
      }

      await client.query("COMMIT");
    } catch (error) {
      await client.query("ROLLBACK");
      throw error;
    } finally {
      client.release();
    }
  }
}

export const appsRepository = new AppsRepository();
