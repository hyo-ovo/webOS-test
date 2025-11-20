import type { Response } from "express";
import { StatusCodes } from "http-status-codes";
import type { AuthRequest } from "@/common/middleware/auth";
import { ServiceResponse } from "@/common/models/serviceResponse";
import { handleServiceResponse } from "@/common/utils/httpHandlers";
import { appsService } from "./appsService";

class AppsController {
	/**
	 * 사용자별 앱 순서 조회
	 * GET /api/apps/order
	 */
	public async getUserAppOrder(req: AuthRequest, res: Response) {
		const userId = req.userId;
		if (!userId) {
			const response = ServiceResponse.failure("인증이 필요합니다", null, StatusCodes.UNAUTHORIZED);
			return handleServiceResponse(response, res);
		}

		const serviceResponse = await appsService.getUserAppOrder(userId);
		return handleServiceResponse(serviceResponse, res);
	}

	/**
	 * 사용자별 앱 순서 저장
	 * PUT /api/apps/order
	 * Body: { order: ['com.webos.app.browser', 'com.webos.app.settings', ...] }
	 */
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

		if (order.some((item) => typeof item !== "string")) {
			const response = ServiceResponse.failure(
				"order 배열의 모든 요소는 문자열이어야 합니다",
				null,
				StatusCodes.BAD_REQUEST,
			);
			return handleServiceResponse(response, res);
		}

		const serviceResponse = await appsService.updateUserAppOrder(userId, order);
		return handleServiceResponse(serviceResponse, res);
	}
}

export const appsController = new AppsController();
