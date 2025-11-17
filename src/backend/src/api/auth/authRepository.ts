import { pool } from "@/common/utils/database";
import bcrypt from "bcryptjs";
import type { User } from "@/common/types";

export interface UserWithPassword extends User {
  password_hash: string;
}

export class AuthRepository {
  async createUser(
    name: string,
    passwordHash: string,
    isChild: boolean
  ): Promise<Omit<User, "password_hash">> {
    const client = await pool.connect();
    try {
      const result = await client.query(
        `INSERT INTO users (name, password_hash, is_child) 
         VALUES ($1, $2, $3) 
         RETURNING id, name, is_child, created_at, updated_at`,
        [name, passwordHash, isChild]
      );
      return result.rows[0];
    } finally {
      client.release();
    }
  }

  async findByName(name: string): Promise<UserWithPassword | null> {
    const client = await pool.connect();
    try {
      const result = await client.query(
        `SELECT id, name, password_hash, is_child, created_at, updated_at 
         FROM users WHERE name = $1`,
        [name]
      );
      return result.rows[0] || null;
    } finally {
      client.release();
    }
  }

  async verifyPassword(
    plainPassword: string,
    hashedPassword: string
  ): Promise<boolean> {
    return bcrypt.compare(plainPassword, hashedPassword);
  }
}

export const authRepository = new AuthRepository();
