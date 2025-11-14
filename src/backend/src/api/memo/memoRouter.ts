import { OpenAPIRegistry } from "@asteasolutions/zod-to-openapi";
import { Router } from "express";
import { z } from "zod";
import { authenticate } from "@/common/middleware/auth";
import { memoController } from "./memoController";
import { createApiResponse } from "@/api-docs/openAPIResponseBuilders";

export const memoRegistry = new OpenAPIRegistry();

const MemoResponseSchema = z.object({
  id: z.number(),
  memoType: z.union([z.literal(1), z.literal(2)]),
  title: z.string(),
  subtitle: z.string(),
  createdAt: z.string(),
  updatedAt: z.string(),
});

const CreateMemoRequestSchema = z.object({
  memoType: z.union([z.literal(1), z.literal(2)]),
  title: z.string().min(1),
  subtitle: z.string().min(1),
});

const UpdateMemoRequestSchema = z.object({
  title: z.string().min(1).optional(),
  subtitle: z.string().min(1).optional(),
});

// GET /memos
memoRegistry.registerPath({
  method: "get",
  path: "/memos",
  tags: ["Memo"],
  summary: "Get all memos for the current user",
  security: [{ bearerAuth: [] }],
  responses: createApiResponse(
    z.array(MemoResponseSchema),
    "Memos retrieved successfully"
  ),
});

// GET /memos/:id
memoRegistry.registerPath({
  method: "get",
  path: "/memos/{id}",
  tags: ["Memo"],
  summary: "Get a memo by ID",
  security: [{ bearerAuth: [] }],
  responses: createApiResponse(MemoResponseSchema, "Memo retrieved successfully"),
});

// POST /memos
memoRegistry.registerPath({
  method: "post",
  path: "/memos",
  tags: ["Memo"],
  summary: "Create a new memo",
  security: [{ bearerAuth: [] }],
  request: {
    body: {
      content: {
        "application/json": {
          schema: CreateMemoRequestSchema,
        },
      },
    },
  },
  responses: createApiResponse(
    MemoResponseSchema,
    "Memo created successfully",
    201
  ),
});

// PATCH /memos/:id
memoRegistry.registerPath({
  method: "patch",
  path: "/memos/{id}",
  tags: ["Memo"],
  summary: "Update a memo",
  security: [{ bearerAuth: [] }],
  request: {
    body: {
      content: {
        "application/json": {
          schema: UpdateMemoRequestSchema,
        },
      },
    },
  },
  responses: createApiResponse(MemoResponseSchema, "Memo updated successfully"),
});

// DELETE /memos/:id
memoRegistry.registerPath({
  method: "delete",
  path: "/memos/{id}",
  tags: ["Memo"],
  summary: "Delete a memo",
  security: [{ bearerAuth: [] }],
  responses: createApiResponse(
    z.object({ success: z.boolean() }),
    "Memo deleted successfully"
  ),
});

export const memoRouter: Router = (() => {
  const router = Router();

  router.use(authenticate);

  router.get("/", memoController.getMemos);
  router.get("/:id", memoController.getMemoById);
  router.post("/", memoController.createMemo);
  router.patch("/:id", memoController.updateMemo);
  router.delete("/:id", memoController.deleteMemo);

  return router;
})();
