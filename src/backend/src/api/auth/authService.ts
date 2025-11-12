import { ServiceResponse } from "@/common/models/serviceResponse";
import { authRepository } from "./authRepository";
import { StatusCodes } from "http-status-codes";
import jwt from "jsonwebtoken";
import { env } from "@/common/utils/envConfig";
import { logger } from "@/server";

interface AuthResponse {
  user: { id: number; username: string };
  token: string;
}

export class AuthService {
	async register(username: string, password: string): Promise<ServiceResponse<AuthResponse | null>> {
		try {
			// 사용자명 중복 체크
			const existingUser = await authRepository.findByUsername(username);
			if (existingUser) {
				return ServiceResponse.failure(
					"Username already exists",
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

			const user = await authRepository.createUser(username, password);

			// JWT 토큰 생성
			const token = jwt.sign(
				{ userId: user.id, username: user.username },
				env.JWT_SECRET,
				{ expiresIn: env.JWT_EXPIRES_IN }
			);

			return ServiceResponse.success("User registered successfully", {
				user: { id: user.id, username: user.username },
				token,
			});
		} catch (error) {
			const errorMessage =
				error instanceof Error ? error.message : "Unknown error";
			logger.error(`Registration error: ${errorMessage}`);
			return ServiceResponse.failure(
				"Failed to register user",
				null,
				StatusCodes.INTERNAL_SERVER_ERROR
			);
		}
	}

	async login(username: string, password: string): Promise<ServiceResponse<AuthResponse | null>> {
		try {
			const user = await authRepository.findByUsername(username);

			if (!user) {
				return ServiceResponse.failure(
					"Invalid username or password",
					null,
					StatusCodes.UNAUTHORIZED
				);
			}

			const isPasswordValid = await authRepository.verifyPassword(
				password,
				user.password
			);

			if (!isPasswordValid) {
				return ServiceResponse.failure(
					"Invalid username or password",
					null,
					StatusCodes.UNAUTHORIZED
				);
			}

			// JWT 토큰 생성
			const token = jwt.sign(
				{ userId: user.id, username: user.username },
				env.JWT_SECRET,
				{ expiresIn: env.JWT_EXPIRES_IN }
			);

			return ServiceResponse.success("Login successful", {
				user: { id: user.id, username: user.username },
				token,
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
