import { rateLimit } from "express-rate-limit";
import { env } from "@/common/utils/envConfig";

const rateLimiter = rateLimit({
	legacyHeaders: true,
	limit: env.COMMON_RATE_LIMIT_MAX_REQUESTS,
	message: "Too many requests, please try again later.",
	standardHeaders: true,
	windowMs: env.COMMON_RATE_LIMIT_WINDOW_MS,
	// trust proxy 경고 해결: X-Forwarded-For 대신 실제 연결 IP 사용
	skipSuccessfulRequests: false,
	skip: (req) => {
		// Health check는 Rate Limiting 제외
		return req.path === '/health';
	},
	// Docker 환경에서 안전하게 IP 추출
	keyGenerator: (req) => {
		// Nginx/CloudFlare 등 신뢰할 수 있는 프록시만 X-Forwarded-For 허용
		const forwardedFor = req.headers['x-forwarded-for'];
		if (forwardedFor && typeof forwardedFor === 'string') {
			// 첫 번째 IP만 사용 (클라이언트 실제 IP)
			return forwardedFor.split(',')[0].trim();
		}
		// 프록시 없으면 직접 연결 IP 사용
		return req.ip || req.socket.remoteAddress || 'unknown';
	},
});

export default rateLimiter;
