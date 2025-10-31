import type { Response } from "express";
import { StatusCodes } from "http-status-codes";
import type { AuthRequest } from "@/common/middleware/auth";
import { ServiceResponse } from "@/common/models/serviceResponse";
import { handleServiceResponse } from "@/common/utils/httpHandlers";
import { appsService } from "./appsService";

class AppsController {
	public async getApps(_req: AuthRequest, res: Response) {
		const serviceResponse = await appsService.getAllApps();
		return handleServiceResponse(serviceResponse, res);
	}

	public async getUserAppOrder(req: AuthRequest, res: Response) {
		const userId = req.userId;
		if (!userId) {
			const response = ServiceResponse.failure("인증이 필요합니다", null, StatusCodes.UNAUTHORIZED);
			return handleServiceResponse(response, res);
		}

		const serviceResponse = await appsService.getUserAppOrder(userId);
		return handleServiceResponse(serviceResponse, res);
	}

	public async updateUserAppOrder(req: AuthRequest, res: Response) {
		const userId = req.userId;
		if (!userId) {
			const response = ServiceResponse.failure("인증이 필요합니다", null, StatusCodes.UNAUTHORIZED);
			return handleServiceResponse(response, res);
		}

		const { order } = req.body;
		if (!Array.isArray(order)) {
			const response = ServiceResponse.failure("order는 배열이어야 합니다", null, StatusCodes.BAD_REQUEST);
			return handleServiceResponse(response, res);
		}

		const serviceResponse = await appsService.updateUserAppOrder(userId, order);
		return handleServiceResponse(serviceResponse, res);
	}
}

export const appsController = new AppsController();
