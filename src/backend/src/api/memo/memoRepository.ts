import { query } from "@/common/utils/database";
import type { Memo } from "@/common/types";

class MemoRepository {
  async getMemosByUserId(
    userId: number,
    memoType?: 1 | 2 | 3 | 4
  ): Promise<Memo[]> {
    let sql = "SELECT * FROM memos WHERE user_id = $1";
    const params: any[] = [userId];

    if (memoType !== undefined) {
      sql += " AND memo_type = $2";
      params.push(memoType);
    }

    sql += " ORDER BY created_at DESC";

    const result = await query(sql, params);
    return result.rows;
  }

  async getMemoById(userId: number, memoId: number): Promise<Memo | null> {
    const result = await query(
      "SELECT * FROM memos WHERE id = $1 AND user_id = $2",
      [memoId, userId]
    );
    return result.rows[0] || null;
  }

  async createMemo(
    userId: number,
    memoType: 1 | 2 | 3 | 4,
    title: string,
    subtitle: string
  ): Promise<Memo> {
    const result = await query(
      `INSERT INTO memos (user_id, memo_type, title, subtitle) 
       VALUES ($1, $2, $3, $4) 
       RETURNING *`,
      [userId, memoType, title, subtitle]
    );
    return result.rows[0];
  }

  async updateMemo(
    userId: number,
    memoId: number,
    title?: string,
    subtitle?: string
  ): Promise<Memo | null> {
    const updates: string[] = [];
    const params: any[] = [];
    let paramIndex = 1;

    if (title !== undefined) {
      updates.push(`title = $${paramIndex++}`);
      params.push(title);
    }
    if (subtitle !== undefined) {
      updates.push(`subtitle = $${paramIndex++}`);
      params.push(subtitle);
    }

    if (updates.length === 0) {
      return this.getMemoById(userId, memoId);
    }

    updates.push(`updated_at = CURRENT_TIMESTAMP`);
    params.push(memoId, userId);

    const result = await query(
      `UPDATE memos SET ${updates.join(", ")} 
       WHERE id = $${paramIndex++} AND user_id = $${paramIndex++} 
       RETURNING *`,
      params
    );

    return result.rows[0] || null;
  }

  async deleteMemo(userId: number, memoId: number): Promise<boolean> {
    const result = await query(
      "DELETE FROM memos WHERE id = $1 AND user_id = $2 RETURNING id",
      [memoId, userId]
    );
    return result.rows.length > 0;
  }
}

export const memoRepository = new MemoRepository();
