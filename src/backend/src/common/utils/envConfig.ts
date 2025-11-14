import { config } from "dotenv";
import { cleanEnv, host, num, port, str, testOnly } from "envalid";

config();

export const env = cleanEnv(process.env, {
	NODE_ENV: str({
		devDefault: testOnly("test"),
		choices: ["development", "production", "test"],
	}),
	HOST: host({ devDefault: testOnly("localhost") }),
	PORT: port({ devDefault: testOnly(8080) }),
	CORS_ORIGIN: str({ devDefault: testOnly("http://localhost:3000") }),
	COMMON_RATE_LIMIT_MAX_REQUESTS: num({ devDefault: testOnly(1000) }),
	COMMON_RATE_LIMIT_WINDOW_MS: num({ devDefault: testOnly(1000) }),
	// DATABASE_URL이 있으면 우선 사용, 없으면 개별 변수 사용
	DATABASE_URL: str({ 
		desc: "PostgreSQL connection string (optional)",
		default: "",
	}),
	DB_HOST: host({ devDefault: testOnly("localhost") }),
	DB_PORT: port({ devDefault: testOnly(5432) }),
	DB_NAME: str({ devDefault: testOnly("webos_homescreen") }),
	DB_USER: str({ devDefault: testOnly("postgres") }),
	DB_PASSWORD: str({ devDefault: testOnly("postgres") }),
	JWT_SECRET: str({
		devDefault: testOnly("your-secret-key-change-in-production"),
	}),
	JWT_EXPIRES_IN: str({ devDefault: testOnly("24h") }),
	LOG_FORMAT: str({
		devDefault: testOnly("pretty"),
		choices: ["pretty", "json"],
	}),
});
