import type { Response } from "express";
import { StatusCodes } from "http-status-codes";
import type { AuthRequest } from "@/common/middleware/auth";
import { ServiceResponse } from "@/common/models/serviceResponse";
import { handleServiceResponse } from "@/common/utils/httpHandlers";
import { favoritesService } from "./favoritesService";

class FavoritesController {
	public async getFavorites(req: AuthRequest, res: Response) {
		const userId = req.userId;
		if (!userId) {
			return handleServiceResponse(
				ServiceResponse.failure("인증 정보가 없습니다", null, StatusCodes.UNAUTHORIZED),
				res,
			);
		}
		const serviceResponse = await favoritesService.getFavorites(userId);
		return handleServiceResponse(serviceResponse, res);
	}

	public async addFavorite(req: AuthRequest, res: Response) {
		const userId = req.userId;
		if (!userId) {
			return handleServiceResponse(
				ServiceResponse.failure("인증 정보가 없습니다", null, StatusCodes.UNAUTHORIZED),
				res,
			);
		}
		const { appId } = req.body;

		if (!appId) {
			const response = ServiceResponse.failure("appId가 필요합니다", null, StatusCodes.BAD_REQUEST);
			return handleServiceResponse(response, res);
		}

		const serviceResponse = await favoritesService.addFavorite(userId, appId);
		return handleServiceResponse(serviceResponse, res);
	}

	public async removeFavorite(req: AuthRequest, res: Response) {
		const userId = req.userId;
		if (!userId) {
			return handleServiceResponse(
				ServiceResponse.failure("인증 정보가 없습니다", null, StatusCodes.UNAUTHORIZED),
				res,
			);
		}
		const { appId } = req.params;

		const serviceResponse = await favoritesService.removeFavorite(userId, appId);
		return handleServiceResponse(serviceResponse, res);
	}
}

export const favoritesController = new FavoritesController();
