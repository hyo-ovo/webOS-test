import { StatusCodes } from "http-status-codes";
import jwt from "jsonwebtoken";
import { ServiceResponse } from "@/common/models/serviceResponse";
import type { AuthResponse } from "@/common/types";
import { env } from "@/common/utils/envConfig";
import { extractFaceDescriptor, isSamePerson, loadModels } from "@/common/utils/faceRecognition";
import { authRepository } from "./authRepository";

class AuthService {
	/**
	 * 얼굴 인식 로그인
	 * 1. 이미지에서 얼굴 특징 추출
	 * 2. DB의 모든 사용자와 비교
	 * 3. 매칭되면 JWT 토큰 발급
	 */
	async faceLogin(imageBuffer: Buffer): Promise<ServiceResponse<AuthResponse | null>> {
		try {
			// 1. Face Recognition 모델 로드
			await loadModels();

			// 2. 업로드된 이미지에서 얼굴 특징 추출
			const uploadedDescriptor = await extractFaceDescriptor(imageBuffer);
			if (!uploadedDescriptor) {
				return ServiceResponse.failure(
					"얼굴을 감지할 수 없습니다. 정면을 바라보고 충분한 조명 아래에서 촬영해주세요",
					null,
					StatusCodes.BAD_REQUEST,
				);
			}

			// 3. DB에서 모든 사용자 얼굴 데이터 가져오기
			const users = await authRepository.getAllUsers();

			if (users.length === 0) {
				return ServiceResponse.failure(
					"등록된 사용자가 없습니다. 먼저 얼굴을 등록해주세요",
					null,
					StatusCodes.NOT_FOUND,
				);
			}

			// 4. 각 사용자와 비교
			for (const user of users) {
				try {
					const storedDescriptor = new Float32Array(JSON.parse(user.face_encoding));

					if (isSamePerson(uploadedDescriptor, storedDescriptor)) {
						// 5. 매칭 성공 → JWT 발급
						const token = jwt.sign({ userId: user.id, username: user.username }, env.JWT_SECRET, {
							expiresIn: env.JWT_EXPIRES_IN,
						});

						return ServiceResponse.success<AuthResponse>("로그인 성공", {
							token,
							user_info: {
								id: user.id,
								username: user.username,
							},
						});
					}
				} catch (error) {
					// 개별 사용자 비교 실패 시 다음 사용자로 계속
					console.error(`Failed to compare with user ${user.id}:`, error);
					continue;
				}
			}

			return ServiceResponse.failure(
				"등록된 사용자를 찾을 수 없습니다. 다시 시도하거나 얼굴을 재등록해주세요",
				null,
				StatusCodes.UNAUTHORIZED,
			);
		} catch (error: any) {
			console.error("Face login error:", error);
			return ServiceResponse.failure(
				`얼굴 인식 중 오류가 발생했습니다: ${error.message}`,
				null,
				StatusCodes.INTERNAL_SERVER_ERROR,
			);
		}
	}

	/**
	 * 얼굴 등록
	 * 1. 이미지에서 얼굴 특징 추출
	 * 2. Float32Array를 JSON으로 직렬화
	 * 3. DB에 저장
	 */
	async registerFace(
		username: string,
		imageBuffer: Buffer,
	): Promise<ServiceResponse<{ userId: number; username: string } | null>> {
		try {
			// 1. Face Recognition 모델 로드
			await loadModels();

			// 2. 사용자 이름 중복 체크
			const existingUser = await authRepository.findUserByUsername(username);
			if (existingUser) {
				return ServiceResponse.failure(
					"이미 존재하는 사용자 이름입니다",
					null,
					StatusCodes.CONFLICT,
				);
			}

			// 3. 이미지에서 얼굴 특징 추출
			const descriptor = await extractFaceDescriptor(imageBuffer);
			if (!descriptor) {
				return ServiceResponse.failure(
					"얼굴을 감지할 수 없습니다. 정면을 바라보고 충분한 조명 아래에서 촬영해주세요",
					null,
					StatusCodes.BAD_REQUEST,
				);
			}

			// 4. Float32Array를 JSON으로 직렬화
			const faceEncoding = JSON.stringify(Array.from(descriptor));

			// 5. DB에 저장
			const userId = await authRepository.createUser(username, faceEncoding);

			return ServiceResponse.success(
				"얼굴 등록 성공",
				{
					userId,
					username,
				},
				StatusCodes.CREATED,
			);
		} catch (error: any) {
			console.error("Face registration error:", error);
			return ServiceResponse.failure(
				`얼굴 등록 중 오류가 발생했습니다: ${error.message}`,
				null,
				StatusCodes.INTERNAL_SERVER_ERROR,
			);
		}
	}
}

export const authService = new AuthService();
