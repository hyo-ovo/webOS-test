import type { Request, Response } from "express";
import { StatusCodes } from "http-status-codes";
import { ServiceResponse } from "@/common/models/serviceResponse";
import { handleServiceResponse } from "@/common/utils/httpHandlers";
import { authService } from "./authService";

class AuthController {
	public async faceLogin(req: Request, res: Response) {
		if (!req.file) {
			const response = ServiceResponse.failure("이미지 파일이 필요합니다", null, StatusCodes.BAD_REQUEST);
			return handleServiceResponse(response, res);
		}

		const imageBuffer = req.file.buffer;
		const serviceResponse = await authService.faceLogin(imageBuffer);
		return handleServiceResponse(serviceResponse, res);
	}

	public async registerFace(req: Request, res: Response) {
		if (!req.file) {
			const response = ServiceResponse.failure("이미지 파일이 필요합니다", null, StatusCodes.BAD_REQUEST);
			return handleServiceResponse(response, res);
		}

		const { username } = req.body;
		if (!username) {
			const response = ServiceResponse.failure("사용자 이름이 필요합니다", null, StatusCodes.BAD_REQUEST);
			return handleServiceResponse(response, res);
		}

		const imageBuffer = req.file.buffer;
		const serviceResponse = await authService.registerFace(username, imageBuffer);
		return handleServiceResponse(serviceResponse, res);
	}
}

export const authController = new AuthController();
