import { OpenAPIRegistry } from "@asteasolutions/zod-to-openapi";
import { Router } from "express";
import { z } from "zod";
import { authenticate } from "@/common/middleware/auth";
import { favoritesController } from "./favoritesController";

export const favoritesRegistry = new OpenAPIRegistry();

// API 등록
favoritesRegistry.registerPath({
	method: "get",
	path: "/favorites",
	tags: ["Favorites"],
	summary: "즐겨찾기 목록 조회",
	security: [{ bearerAuth: [] }],
	responses: {
		200: { description: "즐겨찾기 목록" },
	},
});

favoritesRegistry.registerPath({
	method: "post",
	path: "/favorites",
	tags: ["Favorites"],
	summary: "즐겨찾기 추가",
	security: [{ bearerAuth: [] }],
	request: {
		body: {
			content: {
				"application/json": {
					schema: z.object({
						appId: z.number(),
					}),
				},
			},
		},
	},
	responses: {
		201: { description: "추가 성공" },
	},
});

export const favoritesRouter: Router = (() => {
	const router = Router();

	router.use(authenticate);

	router.get("/", favoritesController.getFavorites);
	router.post("/", favoritesController.addFavorite);
	router.delete("/:appId", favoritesController.removeFavorite);

	return router;
})();
