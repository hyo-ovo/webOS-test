import { rateLimit } from "express-rate-limit";

import { env } from "@/common/utils/envConfig";

const rateLimiter = rateLimit({
	legacyHeaders: true,
	limit: env.COMMON_RATE_LIMIT_MAX_REQUESTS,
	message: "Too many requests, please try again later.",
	standardHeaders: true,
	windowMs: 15 * 60 * env.COMMON_RATE_LIMIT_WINDOW_MS,
	// IPv6 호환 keyGenerator 제거 (기본값 사용)
});

export default rateLimiter;
