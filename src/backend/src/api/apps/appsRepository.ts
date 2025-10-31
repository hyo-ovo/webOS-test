import { query } from "@/common/utils/database";

class AppsRepository {
	async getAllApps() {
		const result = await query("SELECT * FROM apps ORDER BY name");
		return result.rows;
	}

	async getUserAppOrder(userId: number) {
		const result = await query("SELECT app_order FROM user_app_orders WHERE user_id = $1", [userId]);

		if (result.rows.length === 0) {
			return null;
		}

		return result.rows[0];
	}

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
