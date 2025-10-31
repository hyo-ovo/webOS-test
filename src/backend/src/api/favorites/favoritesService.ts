import { StatusCodes } from "http-status-codes";
import { ServiceResponse } from "@/common/models/serviceResponse";
import type { Favorite } from "@/common/types";
import { logger } from "@/server";
import { favoritesRepository } from "./favoritesRepository";

class FavoritesService {
	async getFavorites(userId: number): Promise<ServiceResponse<Favorite[] | null>> {
		try {
			const favorites = await favoritesRepository.getFavoritesByUserId(userId);
			return ServiceResponse.success("즐겨찾기 조회 성공", favorites);
		} catch (error) {
			logger.error({ error }, "Get favorites error");
			return ServiceResponse.failure("즐겨찾기 조회 실패", null, StatusCodes.INTERNAL_SERVER_ERROR);
		}
	}

	async addFavorite(userId: number, appId: string): Promise<ServiceResponse<Favorite | null>> {
		try {
			const count = await favoritesRepository.getFavoritesCount(userId);

			if (count >= 10) {
				return ServiceResponse.failure("즐겨찾기는 최대 10개까지 가능합니다", null, StatusCodes.BAD_REQUEST);
			}

			const favorite = await favoritesRepository.addFavorite(userId, appId);

			if (!favorite) {
				return ServiceResponse.failure("이미 즐겨찾기에 추가되어 있습니다", null, StatusCodes.CONFLICT);
			}

			return ServiceResponse.success("즐겨찾기 추가 성공", favorite);
		} catch (error) {
			logger.error({ error }, "Add favorite error");
			return ServiceResponse.failure("즐겨찾기 추가 실패", null, StatusCodes.INTERNAL_SERVER_ERROR);
		}
	}

	async removeFavorite(userId: number, appId: string): Promise<ServiceResponse<{ appId: string } | null>> {
		try {
			const deleted = await favoritesRepository.removeFavorite(userId, appId);

			if (!deleted) {
				return ServiceResponse.failure("즐겨찾기를 찾을 수 없습니다", null, StatusCodes.NOT_FOUND);
			}

			return ServiceResponse.success("즐겨찾기 삭제 성공", { appId });
		} catch (error) {
			logger.error({ error }, "Remove favorite error");
			return ServiceResponse.failure("즐겨찾기 삭제 실패", null, StatusCodes.INTERNAL_SERVER_ERROR);
		}
	}
}

export const favoritesService = new FavoritesService();
