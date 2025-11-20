import { query } from "@/common/utils/database";

interface User {
	id: number;
	username: string;
	face_encoding: string;
	created_at: Date;
	updated_at: Date;
}

class AuthRepository {
	async findUserByFaceEncoding(faceEncoding: string): Promise<User | null> {
		// TODO: 실제로는 벡터 유사도 검색 필요 (pgvector 등)
		const result = await query("SELECT * FROM users WHERE face_encoding = $1 LIMIT 1", [faceEncoding]);

		if (result.rows.length === 0) {
			return null;
		}

		return result.rows[0] as User;
	}

	async findUserByUsername(username: string): Promise<User | null> {
		const result = await query("SELECT * FROM users WHERE username = $1 LIMIT 1", [username]);

		if (result.rows.length === 0) {
			return null;
		}

		return result.rows[0] as User;
	}

	async findUserById(userId: number): Promise<User | null> {
		const result = await query("SELECT * FROM users WHERE id = $1 LIMIT 1", [userId]);

		if (result.rows.length === 0) {
			return null;
		}

		return result.rows[0] as User;
	}

	async getAllUsers(): Promise<Array<{ id: number; username: string; face_encoding: string }>> {
		const result = await query("SELECT id, username, face_encoding FROM users");
		return result.rows;
	}

	async createUser(username: string, faceEncoding: string): Promise<number> {
		const result = await query("INSERT INTO users (username, face_encoding) VALUES ($1, $2) RETURNING id", [
			username,
			faceEncoding,
		]);
		return result.rows[0].id;
	}
}

export const authRepository = new AuthRepository();
