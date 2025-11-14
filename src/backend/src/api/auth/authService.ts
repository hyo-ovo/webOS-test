import { StatusCodes } from "http-status-codes";
import jwt from "jsonwebtoken";
import bcrypt from "bcryptjs";
import { ServiceResponse } from "@/common/models/serviceResponse";
import { env } from "@/common/utils/envConfig";
import { logger } from "@/server";
import { authRepository } from "./authRepository";
import type {
  SignupRequest,
  SignupResponse,
  LoginRequest,
  LoginResponse,
} from "@/common/types";

export class AuthService {
  async signup(
    data: SignupRequest
  ): Promise<ServiceResponse<SignupResponse | null>> {
    try {
      const { name, password, isChild } = data;

      // 사용자명 중복 체크
      const existingUser = await authRepository.findByName(name);
      if (existingUser) {
        return ServiceResponse.failure(
          "Name already exists",
          null,
          StatusCodes.CONFLICT
        );
      }

      // 비밀번호 길이 검증
      if (password.length < 4) {
        return ServiceResponse.failure(
          "Password must be at least 4 characters",
          null,
          StatusCodes.BAD_REQUEST
        );
      }

      // 비밀번호 해시화
      const passwordHash = await bcrypt.hash(password, 10);

      const user = await authRepository.createUser(name, passwordHash, isChild);

      return ServiceResponse.success(
        "User created successfully",
        {
          id: user.id,
          name: user.name,
          isChild: user.is_child,
          createdAt: user.created_at.toISOString(),
        },
        StatusCodes.CREATED
      );
    } catch (error) {
      const errorMessage =
        error instanceof Error ? error.message : "Unknown error";
      logger.error(`Signup error: ${errorMessage}`);
      return ServiceResponse.failure(
        "Failed to create user",
        null,
        StatusCodes.INTERNAL_SERVER_ERROR
      );
    }
  }

  async login(
    data: LoginRequest
  ): Promise<ServiceResponse<LoginResponse | null>> {
    try {
      const { name, password } = data;

      const user = await authRepository.findByName(name);

      if (!user) {
        return ServiceResponse.failure(
          "Invalid name or password",
          null,
          StatusCodes.UNAUTHORIZED
        );
      }

      const isPasswordValid = await authRepository.verifyPassword(
        password,
        user.password_hash
      );

      if (!isPasswordValid) {
        return ServiceResponse.failure(
          "Invalid name or password",
          null,
          StatusCodes.UNAUTHORIZED
        );
      }

      // JWT 토큰 생성
      const token = jwt.sign(
        { userId: user.id, name: user.name },
        env.JWT_SECRET,
        { expiresIn: env.JWT_EXPIRES_IN }
      );

      return ServiceResponse.success("Login successful", {
        token,
        user: {
          id: user.id,
          name: user.name,
          isChild: user.is_child,
        },
      });
    } catch (error) {
      const errorMessage =
        error instanceof Error ? error.message : "Unknown error";
      logger.error(`Login error: ${errorMessage}`);
      return ServiceResponse.failure(
        "Failed to login",
        null,
        StatusCodes.INTERNAL_SERVER_ERROR
      );
    }
  }
}

export const authService = new AuthService();
