import { query } from "@/common/utils/database";

class AppsRepository {
	/**
	 * 사용자별 앱 순서 조회
	 * @param userId 사용자 ID
	 * @returns { app_order: string[] } 또는 null
	 */
	async getUserAppOrder(userId: number) {
		const result = await query("SELECT app_order FROM user_app_orders WHERE user_id = $1", [userId]);

		if (result.rows.length === 0) {
			return null;
		}

		return result.rows[0];
	}

	/**
	 * 사용자별 앱 순서 저장/업데이트
	 * @param userId 사용자 ID
	 * @param order 앱 ID 순서 배열 (예: ['com.webos.app.browser', 'com.webos.app.settings'])
	 * @returns 저장된 레코드
	 */
	async updateUserAppOrder(userId: number, order: string[]) {
		const result = await query(
			`INSERT INTO user_app_orders (user_id, app_order) 
       VALUES ($1, $2) 
       ON CONFLICT (user_id) 
       DO UPDATE SET app_order = $2, updated_at = CURRENT_TIMESTAMP 
       RETURNING *`,
			[userId, JSON.stringify(order)],
		);

		return result.rows[0];
	}
}

export const appsRepository = new AppsRepository();
