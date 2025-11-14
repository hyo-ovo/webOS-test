import cors from "cors";
import express, { type Express } from "express";
import helmet from "helmet";
import pino from "pino";

import { openAPIRouter } from "@/api-docs/openAPIRouter";
import { appsRouter } from "@/api/apps/appsRouter";
import { authRouter } from "@/api/auth/authRouter";
import { memoRouter } from "@/api/memo/memoRouter";
import errorHandler from "@/common/middleware/errorHandler";
import rateLimiter from "@/common/middleware/rateLimiter";
import requestLogger from "@/common/middleware/requestLogger";
import { env } from "@/common/utils/envConfig";

export const logger = pino({
  name: "server",
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

const app: Express = express();

app.set("trust proxy", 1);

app.use(helmet());
app.use(cors({ origin: env.CORS_ORIGIN, credentials: true }));
app.use(rateLimiter);
app.use(express.json({ limit: "10mb" }));
app.use(express.urlencoded({ extended: true, limit: "10mb" }));
app.use(requestLogger);

app.use("/swagger", openAPIRouter);
app.use("/auth", authRouter);
app.use("/me/apps", appsRouter);
app.use("/memos", memoRouter);

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
