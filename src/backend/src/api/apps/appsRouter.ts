import { Router } from "express";
import { OpenAPIRegistry } from "@asteasolutions/zod-to-openapi";
import { z } from "zod";
import { appsController } from "./appsController";
import { authenticate } from "@/common/middleware/auth";

export const appsRegistry = new OpenAPIRegistry();

// Schema 정의
const AppSchema = z.object({
  id: z.number(),
  name: z.string(),
  icon_url: z.string().optional(),
  launch_command: z.string(),
});

// API 등록
appsRegistry.registerPath({
  method: "get",
  path: "/apps",
  tags: ["Apps"],
  summary: "모든 앱 목록 조회",
  responses: {
    200: {
      description: "앱 목록",
      content: {
        "application/json": {
          schema: z.array(AppSchema),
        },
      },
    },
  },
});

appsRegistry.registerPath({
  method: "get",
  path: "/apps/order",
  tags: ["Apps"],
  summary: "사용자별 앱 순서 조회",
  security: [{ bearerAuth: [] }],
  responses: {
    200: {
      description: "앱 순서 목록",
    },
  },
});

appsRegistry.registerPath({
  method: "put",
  path: "/apps/order",
  tags: ["Apps"],
  summary: "사용자별 앱 순서 저장",
  security: [{ bearerAuth: [] }],
  request: {
    body: {
      content: {
        "application/json": {
          schema: z.object({
            appIds: z.array(z.number()).describe("앱 ID 순서 배열"),
          }),
        },
      },
    },
  },
  responses: {
    200: {
      description: "저장 성공",
    },
  },
});

export const appsRouter: Router = (() => {
  const router = Router();

  // 모든 앱 목록 조회
  router.get("/", appsController.getApps);

  // 사용자별 앱 순서 조회 (인증 필요)
  router.get("/order", authenticate, appsController.getUserAppOrder);

  // 사용자별 앱 순서 저장 (인증 필요)
  router.put("/order", authenticate, appsController.updateUserAppOrder);

  return router;
})();
