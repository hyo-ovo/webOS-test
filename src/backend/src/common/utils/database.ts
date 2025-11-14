import { Pool } from "pg";
import { env } from "./envConfig";
import pino from "pino";

const logger = pino({
  name: "database",
  level: env.isProduction ? "info" : "debug",
  transport:
    env.LOG_FORMAT === "pretty"
      ? {
          target: "pino-pretty",
          options: {
            colorize: true,
            translateTime: "HH:MM:ss Z",
            ignore: "pid,hostname",
          },
        }
      : undefined,
});

// DATABASE_URL이 있으면 우선 사용, 없으면 개별 환경 변수 사용
const poolConfig = env.DATABASE_URL && env.DATABASE_URL.trim() !== ""
  ? {
      connectionString: env.DATABASE_URL,
      max: 20,
      idleTimeoutMillis: 30000,
      connectionTimeoutMillis: 2000,
    }
  : {
      host: env.DB_HOST,
      port: env.DB_PORT,
      database: env.DB_NAME,
      user: env.DB_USER,
      password: env.DB_PASSWORD,
      max: 20,
      idleTimeoutMillis: 30000,
      connectionTimeoutMillis: 2000,
    };

export const pool = new Pool(poolConfig);

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
    // 기존 테이블 삭제 (외래키 제약 때문에 순서 중요)
    await client.query(`DROP TABLE IF EXISTS user_apps CASCADE`);
    await client.query(`DROP TABLE IF EXISTS memos CASCADE`);
    await client.query(`DROP TABLE IF EXISTS apps CASCADE`);
    await client.query(`DROP TABLE IF EXISTS users CASCADE`);

    // User 테이블
    await client.query(`
      CREATE TABLE users (
        id SERIAL PRIMARY KEY,
        name VARCHAR(50) UNIQUE NOT NULL,
        password_hash VARCHAR(255) NOT NULL,
        is_child BOOLEAN DEFAULT FALSE,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )
    `);

    // App 테이블
    await client.query(`
      CREATE TABLE apps (
        id SERIAL PRIMARY KEY,
        name VARCHAR(100) NOT NULL,
        img_path TEXT NOT NULL,
        run_path TEXT NOT NULL
      )
    `);

    // UserApp 테이블 (사용자별 앱 순서)
    await client.query(`
      CREATE TABLE user_apps (
        id SERIAL PRIMARY KEY,
        user_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
        app_id INTEGER REFERENCES apps(id) ON DELETE CASCADE,
        sort_order INTEGER NOT NULL,
        UNIQUE(user_id, app_id)
      )
    `);

    // Memo 테이블
    await client.query(`
      CREATE TABLE memos (
        id SERIAL PRIMARY KEY,
        user_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
        memo_type INTEGER NOT NULL CHECK (memo_type IN (1, 2)),
        title VARCHAR(255) NOT NULL,
        subtitle VARCHAR(255) NOT NULL,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )
    `);

    // 성능을 위한 인덱스
    await client.query(`CREATE INDEX idx_memos_user_id ON memos(user_id)`);
    await client.query(`CREATE INDEX idx_memos_memo_type ON memos(memo_type)`);
    await client.query(
      `CREATE INDEX idx_user_apps_user_id ON user_apps(user_id)`
    );
    await client.query(
      `CREATE INDEX idx_user_apps_app_id ON user_apps(app_id)`
    );

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
