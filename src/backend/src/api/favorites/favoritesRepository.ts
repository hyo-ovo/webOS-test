import { query } from "@/common/utils/database";

class FavoritesRepository {
	async getFavoritesByUserId(userId: number) {
		const result = await query("SELECT app_id FROM favorites WHERE user_id = $1 ORDER BY created_at", [userId]);
		return result.rows;
	}

	async getFavoritesCount(userId: number): Promise<number> {
		const result = await query("SELECT COUNT(*) as count FROM favorites WHERE user_id = $1", [userId]);
		return Number.parseInt(result.rows[0].count);
	}

	async addFavorite(userId: number, appId: string) {
		try {
			const result = await query("INSERT INTO favorites (user_id, app_id) VALUES ($1, $2) RETURNING *", [
				userId,
				appId,
			]);
			return result.rows[0];
		} catch (error: unknown) {
			// Unique constraint violation (이미 존재)
			if (error && typeof error === "object" && "code" in error && error.code === "23505") {
				return null;
			}
			throw error;
		}
	}

	async removeFavorite(userId: number, appId: string) {
		const result = await query("DELETE FROM favorites WHERE user_id = $1 AND app_id = $2 RETURNING id", [
			userId,
			appId,
		]);
		return result.rows.length > 0;
	}
}

export const favoritesRepository = new FavoritesRepository();
