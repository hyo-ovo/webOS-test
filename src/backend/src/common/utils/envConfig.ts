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
	DB_HOST: host({ devDefault: testOnly("localhost") }),
	DB_PORT: port({ devDefault: testOnly(5432) }),
	DB_NAME: str({ devDefault: testOnly("webos_homescreen") }),
	DB_USER: str({ devDefault: testOnly("postgres") }),
	DB_PASSWORD: str({ devDefault: testOnly("postgres") }),
	JWT_SECRET: str({
		devDefault: testOnly("your-secret-key-change-in-production"),
	}),
	JWT_EXPIRES_IN: str({ devDefault: testOnly("24h") }),
});
