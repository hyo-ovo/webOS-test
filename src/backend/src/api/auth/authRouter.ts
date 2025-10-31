import { OpenAPIRegistry } from "@asteasolutions/zod-to-openapi";
import { Router } from "express";
import multer from "multer";
import { z } from "zod";
import { env } from "@/common/utils/envConfig";
import { authController } from "./authController";

export const authRegistry = new OpenAPIRegistry();

// Schema 정의
const FaceLoginResponseSchema = z.object({
	token: z.string(),
	userId: z.number(),
	username: z.string(),
});

// API 등록
authRegistry.registerPath({
	method: "post",
	path: "/auth/face-login",
	tags: ["Auth"],
	summary: "얼굴인식 로그인",
	request: {
		body: {
			content: {
				"multipart/form-data": {
					schema: z.object({
						image: z.instanceof(File).describe("얼굴 사진"),
					}),
				},
			},
		},
	},
	responses: {
		200: {
			description: "로그인 성공",
			content: {
				"application/json": {
					schema: FaceLoginResponseSchema,
				},
			},
		},
		401: {
			description: "인증 실패",
		},
	},
});

authRegistry.registerPath({
	method: "post",
	path: "/auth/register-face",
	tags: ["Auth"],
	summary: "얼굴 등록 (개발용)",
	request: {
		body: {
			content: {
				"multipart/form-data": {
					schema: z.object({
						image: z.instanceof(File).describe("얼굴 사진"),
						username: z.string().optional().describe("사용자 이름"),
					}),
				},
			},
		},
	},
	responses: {
		201: {
			description: "등록 성공",
		},
	},
});

const upload = multer({
	storage: multer.memoryStorage(),
	limits: { fileSize: env.MAX_FILE_SIZE },
	fileFilter: (_req, file, cb) => {
		if (file.mimetype.startsWith("image/")) {
			cb(null, true);
		} else {
			cb(new Error("이미지 파일만 업로드 가능합니다"));
		}
	},
});

export const authRouter: Router = (() => {
	const router = Router();

	// 얼굴인식 로그인
	router.post("/face-login", upload.single("image"), authController.faceLogin);

	// 얼굴 등록 (개발용)
	router.post("/register-face", upload.single("image"), authController.registerFace);

	return router;
})();
