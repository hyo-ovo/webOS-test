import { initDatabase } from "@/common/utils/database";
import { env } from "@/common/utils/envConfig";
import { app, logger } from "@/server";

// 데이터베이스 초기화
initDatabase()
	.then(() => {
		logger.info("✅ Database connection established");
	})
	.catch((error) => {
		logger.error("❌ Database initialization failed", error);
		process.exit(1);
	});

const server = app.listen(env.PORT, () => {
	const { NODE_ENV, HOST, PORT } = env;
	logger.info(`Server (${NODE_ENV}) running on port http://${HOST}:${PORT}`);
});

const onCloseSignal = () => {
	logger.info("sigint received, shutting down");
	server.close(() => {
		logger.info("server closed");
		process.exit();
	});
	setTimeout(() => process.exit(1), 10000).unref(); // Force shutdown after 10s
};

process.on("SIGINT", onCloseSignal);
process.on("SIGTERM", onCloseSignal);
