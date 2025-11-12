import cors from "cors";
import express, { type Express } from "express";
import helmet from "helmet";
import { pino } from "pino";

import { openAPIRouter } from "@/api-docs/openAPIRouter";
import { appsRouter } from "@/api/apps/appsRouter";
import { authRouter } from "@/api/auth/authRouter";
import { favoritesRouter } from "@/api/favorites/favoritesRouter";
import { memoRouter } from "@/api/memo/memoRouter";
import errorHandler from "@/common/middleware/errorHandler";
import rateLimiter from "@/common/middleware/rateLimiter";
import requestLogger from "@/common/middleware/requestLogger";
import { env } from "@/common/utils/envConfig";

export const logger = pino({ name: "server" });

const app: Express = express();

app.set("trust proxy", 1);

app.use(helmet());
app.use(cors({ origin: env.CORS_ORIGIN, credentials: true }));
app.use(rateLimiter);
app.use(express.json({ limit: "10mb" }));
app.use(express.urlencoded({ extended: true, limit: "10mb" }));
app.use(requestLogger);

app.get("/health", (req, res) => {
  res.status(200).json({ 
    status: "ok", 
    timestamp: new Date().toISOString(),
    uptime: process.uptime(),
    environment: env.NODE_ENV
  });
});

app.use("/swagger", openAPIRouter);
app.use("/auth", authRouter);
app.use("/apps", appsRouter);
app.use("/favorites", favoritesRouter);
app.use("/memo", memoRouter);

app.use((req, res) => {
  res.status(404).json({
    success: false,
    message: "Route not found",
    path: req.path,
    statusCode: 404,
  });
});

app.use(errorHandler());

export { app };
