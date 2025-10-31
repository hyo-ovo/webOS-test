import { query } from "@/common/utils/database";

class MemoRepository {
	async getMemosByUserId(userId: number) {
		const result = await query("SELECT * FROM memos WHERE user_id = $1 ORDER BY created_at DESC", [userId]);
		return result.rows;
	}

	async createMemo(userId: number, title: string, content: string) {
		const result = await query("INSERT INTO memos (user_id, title, content) VALUES ($1, $2, $3) RETURNING *", [
			userId,
			title,
			content,
		]);
		return result.rows[0];
	}

	async updateMemo(userId: number, memoId: number, title: string, content: string) {
		const result = await query(
			"UPDATE memos SET title = $1, content = $2, updated_at = CURRENT_TIMESTAMP WHERE id = $3 AND user_id = $4 RETURNING *",
			[title, content, memoId, userId],
		);

		if (result.rows.length === 0) {
			return null;
		}

		return result.rows[0];
	}

	async deleteMemo(userId: number, memoId: number) {
		const result = await query("DELETE FROM memos WHERE id = $1 AND user_id = $2 RETURNING id", [memoId, userId]);

		return result.rows.length > 0;
	}
}

export const memoRepository = new MemoRepository();
