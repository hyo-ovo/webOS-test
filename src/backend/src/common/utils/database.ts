import { Pool } from "pg";
import { env } from "./envConfig";
import { pino } from "pino";

const logger = pino({ name: "database" });

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

pool.on("error", (err: Error) => {
	logger.error(`Unexpected database error: ${err.message}`);
	process.exit(-1);
});

pool.on("connect", () => {
	logger.info("New database connection established");
});

// Query helper function (Repository에서 사용)
export const query = async (text: string, params?: any[]) => {
	const client = await pool.connect();
	try {
		const result = await client.query(text, params);
		return result;
	} finally {
		client.release();
	}
};

export async function initializeDatabase() {
	const client = await pool.connect();
	try {
		// 사용자 테이블 (Phase 1: password, Phase 2: face_encoding으로 마이그레이션 예정)
		await client.query(`
			CREATE TABLE IF NOT EXISTS users (
				id SERIAL PRIMARY KEY,
				username VARCHAR(50) UNIQUE NOT NULL,
				password VARCHAR(255) NOT NULL,  -- Phase 1: 기본 인증
				-- face_encoding TEXT,  -- Phase 2: 얼굴 벡터 (128차원 JSON)
				created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
				updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
			)
		`);

		// 앱 메타데이터 테이블 (Admin 페이지용, 제안서에는 없지만 필수)
		await client.query(`
			CREATE TABLE IF NOT EXISTS apps (
				app_id VARCHAR(100) PRIMARY KEY,
				name VARCHAR(100) NOT NULL,
				icon_url TEXT,
				created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
			)
		`);

		// 사용자별 앱 순서 테이블 (제안서 § 1.5)
		await client.query(`
			CREATE TABLE IF NOT EXISTS user_app_orders (
				id SERIAL PRIMARY KEY,
				user_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
				app_order JSONB NOT NULL,  -- webOS 앱 ID 배열
				updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
				UNIQUE(user_id)
			)
		`);

		// 메모 테이블 (제안서 § 1.5)
		await client.query(`
			CREATE TABLE IF NOT EXISTS memos (
				id SERIAL PRIMARY KEY,
				user_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
				title VARCHAR(255) NOT NULL,
				content TEXT NOT NULL,
				created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
				updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
			)
		`);

		// 즐겨찾기 테이블 (제안서 § 1.5)
		await client.query(`
			CREATE TABLE IF NOT EXISTS favorites (
				id SERIAL PRIMARY KEY,
				user_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
				app_id VARCHAR(100) NOT NULL,  -- webOS 앱 ID (예: "com.webos.app.browser")
				created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
				UNIQUE(user_id, app_id)
			)
		`);

		// 성능을 위한 인덱스 (제안서 § 1.5)
		await client.query(`CREATE INDEX IF NOT EXISTS idx_memos_user_id ON memos(user_id)`);
		await client.query(`CREATE INDEX IF NOT EXISTS idx_favorites_user_id ON favorites(user_id)`);
		await client.query(`CREATE INDEX IF NOT EXISTS idx_user_app_orders_user_id ON user_app_orders(user_id)`);

		logger.info("Database initialized successfully");
	} catch (error) {
		const errorMessage =
			error instanceof Error ? error.message : "Unknown error";
		logger.error(`Failed to initialize database: ${errorMessage}`);
		throw error;
	} finally {
		client.release();
	}
}
