import { OpenAPIRegistry } from "@asteasolutions/zod-to-openapi";
import express, { type Router } from "express";
import { z } from "zod";
import { authController } from "./authController";
import { createApiResponse } from "@/api-docs/openAPIResponseBuilders";

export const authRegistry = new OpenAPIRegistry();
export const authRouter: Router = express.Router();

const SignupRequestSchema = z.object({
  name: z.string().min(1, "Name is required"),
  password: z.string().min(4, "Password must be at least 4 characters"),
  isChild: z.boolean().default(false),
});

const SignupResponseSchema = z.object({
  id: z.number(),
  name: z.string(),
  isChild: z.boolean(),
  createdAt: z.string(),
});

const LoginRequestSchema = z.object({
  name: z.string().min(1, "Name is required"),
  password: z.string().min(1, "Password is required"),
});

const LoginResponseSchema = z.object({
  token: z.string(),
  user: z.object({
    id: z.number(),
    name: z.string(),
    isChild: z.boolean(),
  }),
});

authRegistry.registerPath({
  method: "post",
  path: "/auth/signup",
  tags: ["Auth"],
  summary: "Register a new user",
  request: {
    body: {
      content: {
        "application/json": {
          schema: SignupRequestSchema,
        },
      },
    },
  },
  responses: createApiResponse(SignupResponseSchema, "User created successfully", 201),
});

authRegistry.registerPath({
  method: "post",
  path: "/auth/login",
  tags: ["Auth"],
  summary: "Login with name and password",
  request: {
    body: {
      content: {
        "application/json": {
          schema: LoginRequestSchema,
        },
      },
    },
  },
  responses: createApiResponse(LoginResponseSchema, "Login successful"),
});

authRouter.post("/signup", authController.signup);
authRouter.post("/login", authController.login);
