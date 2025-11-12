import { OpenAPIRegistry } from "@asteasolutions/zod-to-openapi";
import express, { type Router } from "express";
import { z } from "zod";
import { authController } from "./authController";
import { createApiResponse } from "@/api-docs/openAPIResponseBuilders";

export const authRegistry = new OpenAPIRegistry();
export const authRouter: Router = express.Router();

const AuthRequestSchema = z.object({
  username: z.string().min(1, "Username is required"),
  password: z.string().min(4, "Password must be at least 4 characters"),
});

const AuthResponseSchema = z.object({
  user: z.object({
    id: z.number(),
    username: z.string(),
  }),
  token: z.string(),
});

authRegistry.registerPath({
  method: "post",
  path: "/auth/register",
  tags: ["Auth"],
  summary: "Register a new user",
  request: {
    body: {
      content: {
        "application/json": {
          schema: AuthRequestSchema,
        },
      },
    },
  },
  responses: createApiResponse(AuthResponseSchema, "User registered successfully"),
});

authRegistry.registerPath({
  method: "post",
  path: "/auth/login",
  tags: ["Auth"],
  summary: "Login with username and password",
  request: {
    body: {
      content: {
        "application/json": {
          schema: AuthRequestSchema,
        },
      },
    },
  },
  responses: createApiResponse(AuthResponseSchema, "Login successful"),
});

authRouter.post("/register", authController.register);
authRouter.post("/login", authController.login);
