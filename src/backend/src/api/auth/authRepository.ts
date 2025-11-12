import { pool } from "@/common/utils/database";
import bcrypt from "bcryptjs";

export interface User {
	id: number;
	username: string;
	created_at: Date;
}

export interface UserWithPassword extends User {
	password: string;
}

export class AuthRepository {
	async createUser(username: string, password: string): Promise<User> {
		const hashedPassword = await bcrypt.hash(password, 10);
		const client = await pool.connect();
		try {
			const result = await client.query(
				"INSERT INTO users (username, password) VALUES ($1, $2) RETURNING id, username, created_at",
				[username, hashedPassword]
			);
			return result.rows[0];
		} finally {
			client.release();
		}
	}

	async findByUsername(username: string): Promise<UserWithPassword | null> {
		const client = await pool.connect();
		try {
			const result = await client.query(
				"SELECT id, username, password, created_at FROM users WHERE username = $1",
				[username]
			);
			return result.rows[0] || null;
		} finally {
			client.release();
		}
	}

	async verifyPassword(plainPassword: string, hashedPassword: string): Promise<boolean> {
		return bcrypt.compare(plainPassword, hashedPassword);
	}
}

export const authRepository = new AuthRepository();
