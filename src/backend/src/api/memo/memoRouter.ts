import { OpenAPIRegistry } from "@asteasolutions/zod-to-openapi";
import { Router } from "express";
import { z } from "zod";
import { authenticate } from "@/common/middleware/auth";
import { memoController } from "./memoController";

export const memoRegistry = new OpenAPIRegistry();

// API 등록
memoRegistry.registerPath({
	method: "get",
	path: "/memo",
	tags: ["Memo"],
	summary: "메모 목록 조회",
	security: [{ bearerAuth: [] }],
	responses: {
		200: { description: "메모 목록" },
	},
});

memoRegistry.registerPath({
	method: "post",
	path: "/memo",
	tags: ["Memo"],
	summary: "메모 생성",
	security: [{ bearerAuth: [] }],
	request: {
		body: {
			content: {
				"application/json": {
					schema: z.object({
						content: z.string(),
					}),
				},
			},
		},
	},
	responses: {
		201: { description: "생성 성공" },
	},
});

export const memoRouter: Router = (() => {
	const router = Router();

	// 모든 라우트에 인증 필요
	router.use(authenticate);

	router.get("/", memoController.getMemos);
	router.post("/", memoController.createMemo);
	router.put("/:id", memoController.updateMemo);
	router.delete("/:id", memoController.deleteMemo);

	return router;
})();
