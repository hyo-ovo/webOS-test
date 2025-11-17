import { app, logger } from "@/server";
import { env } from "@/common/utils/envConfig";
import { initializeDatabase, pool } from "@/common/utils/database";

// 데이터베이스 초기화
initializeDatabase().catch((error) => {
  const errorMessage = error instanceof Error ? error.message : "Unknown error";
  logger.error(`Failed to initialize database: ${errorMessage}`);
  process.exit(1);
});

// 서버 시작
const server = app.listen(env.PORT, () => {
  const { NODE_ENV, HOST, PORT } = env;
  logger.info(`Server (${NODE_ENV}) running on http://${HOST}:${PORT}`);
});

// Graceful Shutdown
const onCloseSignal = async () => {
  logger.info("SIGINT/SIGTERM received, shutting down gracefully");
  
  server.close(async () => {
    logger.info("HTTP server closed");
    
    try {
      await pool.end();
      logger.info("Database connection pool closed");
    } catch (error) {
      const errorMessage = error instanceof Error ? error.message : "Unknown error";
      logger.error(`Failed to close database pool: ${errorMessage}`);
    }
    
    logger.info("Process exiting gracefully");
    process.exit(0);
  });
  
  setTimeout(() => {
    logger.error("Forced shutdown after 10 seconds timeout");
    process.exit(1);
  }, 10000).unref();
};

process.on("SIGINT", onCloseSignal);
process.on("SIGTERM", onCloseSignal);

process.on("unhandledRejection", (reason) => {
  logger.error(`Unhandled Rejection: ${reason}`);
  process.exit(1);
});

process.on("uncaughtException", (error) => {
  logger.error(`Uncaught Exception: ${error.message}`);
  process.exit(1);
});
