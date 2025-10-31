import { StatusCodes } from "http-status-codes";
import { ServiceResponse } from "@/common/models/serviceResponse";
import type { AuthResponse } from "@/common/types";

class AuthService {
	async faceLogin(_imageBuffer: Buffer): Promise<ServiceResponse<AuthResponse | null>> {
		return ServiceResponse.failure(
			"얼굴 인식 로그인 기능이 현재 비활성화되어 있습니다",
			null,
			StatusCodes.SERVICE_UNAVAILABLE,
		);
	}

	async registerFace(
		_username: string,
		_imageBuffer: Buffer,
	): Promise<ServiceResponse<{ userId: number; username: string } | null>> {
		return ServiceResponse.failure(
			"얼굴 등록 기능이 현재 비활성화되어 있습니다",
			null,
			StatusCodes.SERVICE_UNAVAILABLE,
		);
	}
}

export const authService = new AuthService();
