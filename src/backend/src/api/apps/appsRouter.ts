import { OpenAPIRegistry } from "@asteasolutions/zod-to-openapi";
import { Router } from "express";
import { z } from "zod";
import { authenticate } from "@/common/middleware/auth";
import { appsController } from "./appsController";
import { createApiResponse } from "@/api-docs/openAPIResponseBuilders";

export const appsRegistry = new OpenAPIRegistry();

const UserAppResponseSchema = z.object({
  appId: z.number(),
  name: z.string(),
  imgPath: z.string(),
  runPath: z.string(),
  order: z.number(),
});

const AppItemSchema = z.object({
  id: z.number().int().positive().optional(),
  name: z.string().min(1, "앱 이름은 필수입니다"),
  imgPath: z.string().min(1, "이미지 경로는 필수입니다"),
  runPath: z.string().min(1, "실행 경로는 필수입니다"),
});

const UpdateAppOrderRequestSchema = z.object({
  apps: z
    .array(AppItemSchema)
    .min(1, "apps 배열은 최소 1개 이상의 요소가 필요합니다"),
});

// GET /me/apps
appsRegistry.registerPath({
  method: "get",
  path: "/me/apps",
  tags: ["Apps"],
  summary: "Get user's app list with order",
  security: [{ bearerAuth: [] }],
  responses: createApiResponse(
    z.array(UserAppResponseSchema),
    "User apps retrieved successfully"
  ),
});

// PUT /me/apps/order
appsRegistry.registerPath({
  method: "put",
  path: "/me/apps/order",
  tags: ["Apps"],
  summary: "Update user's app order",
  description:
    "사용자의 앱 목록과 순서를 업데이트합니다. apps 배열의 순서대로 sort_order가 1, 2, 3... 으로 부여됩니다. id가 있으면 기존 앱을 사용하고, 없으면 새 앱을 생성합니다.",
  security: [{ bearerAuth: [] }],
  request: {
    body: {
      content: {
        "application/json": {
          schema: UpdateAppOrderRequestSchema,
          example: {
            apps: [
              {
                id: 3,
                name: "YouTube",
                imgPath: "/images/youtube.png",
                runPath: "app://youtube",
              },
              {
                id: 1,
                name: "Browser",
                imgPath: "/images/browser.png",
                runPath: "webos://browser/index",
              },
              {
                name: "New App",
                imgPath: "/images/newapp.png",
                runPath: "app://newapp",
              },
            ],
          },
        },
      },
      required: true,
    },
  },
  responses: createApiResponse(
    z.object({ success: z.boolean() }),
    "App order updated successfully"
  ),
});

export const appsRouter: Router = (() => {
  const router = Router();

  router.use(authenticate);

  router.get("/", appsController.getUserApps);
  router.put("/order", appsController.updateAppOrder);

  return router;
})();
