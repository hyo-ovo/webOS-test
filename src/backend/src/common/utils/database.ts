import { Pool } from "pg";
import { env } from "@/common/utils/envConfig";
import { logger } from "@/server";

export const pool = new Pool({
	host: env.DB_HOST,
	port: env.DB_PORT,
	database: env.DB_NAME,
	user: env.DB_USER,
	password: env.DB_PASSWORD,
	max: 20,
	idleTimeoutMillis: 30000,
	connectionTimeoutMillis: 2000,
});

pool.on("error", (err) => {
	logger.error({ err }, "Unexpected database error");
	process.exit(-1);
});

export const query = async (text: string, params?: unknown[]) => {
	const start = Date.now();
	try {
		const res = await pool.query(text, params);
		const duration = Date.now() - start;
		logger.debug({ text, duration, rows: res.rowCount }, "Executed query");
		return res;
	} catch (error) {
		logger.error({ text, error }, "Query error");
		throw error;
	}
};

// 데이터베이스 초기화 (테이블 생성)
export const initDatabase = async () => {
	try {
		// Users 테이블
		await query(`
      CREATE TABLE IF NOT EXISTS users (
        id SERIAL PRIMARY KEY,
        username VARCHAR(50) UNIQUE NOT NULL,
        face_encoding TEXT NOT NULL,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )
    `);

		// Apps 테이블
		await query(`
      CREATE TABLE IF NOT EXISTS apps (
        id SERIAL PRIMARY KEY,
        app_id VARCHAR(100) UNIQUE NOT NULL,
        name VARCHAR(100) NOT NULL,
        icon_url TEXT,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )
    `);

		// User App Order 테이블
		await query(`
      CREATE TABLE IF NOT EXISTS user_app_orders (
        id SERIAL PRIMARY KEY,
        user_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
        app_order JSONB NOT NULL,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        UNIQUE(user_id)
      )
    `);

		// Memos 테이블
		await query(`
      CREATE TABLE IF NOT EXISTS memos (
        id SERIAL PRIMARY KEY,
        user_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
        title VARCHAR(255) NOT NULL,
        content TEXT NOT NULL,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )
    `);

		// Favorites 테이블
		await query(`
      CREATE TABLE IF NOT EXISTS favorites (
        id SERIAL PRIMARY KEY,
        user_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
        app_id VARCHAR(100) NOT NULL,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        UNIQUE(user_id, app_id)
      )
    `);

		// 인덱스 생성
		await query(`
      CREATE INDEX IF NOT EXISTS idx_memos_user_id ON memos(user_id);
      CREATE INDEX IF NOT EXISTS idx_favorites_user_id ON favorites(user_id);
    `);

		logger.info("✅ Database initialized successfully");
	} catch (error) {
		logger.error({ error }, "❌ Database initialization failed");
		throw error;
	}
};
