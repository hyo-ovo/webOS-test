import { OpenAPIRegistry } from "@asteasolutions/zod-to-openapi";
import { Router } from "express";
import { z } from "zod";
import { authenticate } from "@/common/middleware/auth";
import { appsController } from "./appsController";

export const appsRegistry = new OpenAPIRegistry();

// Schema 정의
const AppOrderResponseSchema = z.object({
  app_order: z
    .array(z.string())
    .describe(
      "앱 ID 순서 배열 (예: ['com.webos.app.browser', 'com.webos.app.settings'])"
    ),
});

// API 등록
appsRegistry.registerPath({
  method: "get",
  path: "/apps/order",
  tags: ["Apps"],
  summary: "사용자별 앱 순서 조회",
  description:
    "사용자가 설정한 앱 ID 순서를 반환합니다. 클라이언트는 Luna Service의 listLaunchPoints로 실제 앱 목록을 가져온 후, 이 순서 정보를 사용하여 정렬합니다.",
  security: [{ bearerAuth: [] }],
  responses: {
    200: {
      description: "앱 순서 목록",
      content: {
        "application/json": {
          schema: AppOrderResponseSchema,
        },
      },
    },
  },
});

appsRegistry.registerPath({
  method: "put",
  path: "/apps/order",
  tags: ["Apps"],
  summary: "사용자별 앱 순서 저장",
  description:
    "사용자가 설정한 앱 ID 순서를 저장합니다. 앱 ID는 webOS 앱 식별자 (예: 'com.webos.app.browser')입니다.",
  security: [{ bearerAuth: [] }],
  request: {
    body: {
      content: {
        "application/json": {
          schema: z.object({
            order: z
              .array(z.string())
              .describe(
                "앱 ID 순서 배열 (예: ['com.webos.app.browser', 'com.webos.app.settings'])"
              ),
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

  // 사용자별 앱 순서 조회 (인증 필요)
  router.get("/order", authenticate, appsController.getUserAppOrder);

  // 사용자별 앱 순서 저장 (인증 필요)
  router.put("/order", authenticate, appsController.updateUserAppOrder);

  return router;
})();
