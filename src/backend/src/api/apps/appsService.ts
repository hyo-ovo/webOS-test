import { StatusCodes } from "http-status-codes";
import { ServiceResponse } from "@/common/models/serviceResponse";
import type { UserAppOrder } from "@/common/types";
import { logger } from "@/server";
import { appsRepository } from "./appsRepository";

class AppsService {
	/**
	 * 사용자별 앱 순서 조회
	 * @param userId 사용자 ID
	 * @returns 앱 ID 순서 배열 (예: ['com.webos.app.browser', 'com.webos.app.settings'])
	 */
	async getUserAppOrder(userId: number): Promise<ServiceResponse<Pick<UserAppOrder, "app_order"> | null>> {
		try {
			const order = await appsRepository.getUserAppOrder(userId);
			return ServiceResponse.success("앱 순서 조회 성공", order || { app_order: [] });
		} catch (error) {
			logger.error({ error }, "Get user app order error");
			return ServiceResponse.failure("앱 순서 조회 실패", null, StatusCodes.INTERNAL_SERVER_ERROR);
		}
	}

	/**
	 * 사용자별 앱 순서 저장
	 * @param userId 사용자 ID
	 * @param order 앱 ID 순서 배열 (예: ['com.webos.app.browser', 'com.webos.app.settings'])
	 */
	async updateUserAppOrder(userId: number, order: string[]): Promise<ServiceResponse<UserAppOrder | null>> {
		try {
			// 앱 ID 유효성 검사 (webOS 앱 ID 형식)
			const isValidAppId = (id: string) => /^[a-z][a-z0-9]*(\.[a-z][a-z0-9]*)+$/i.test(id);
			const invalidIds = order.filter((id) => !isValidAppId(id));

			if (invalidIds.length > 0) {
				logger.warn({ invalidIds }, "Invalid app IDs detected");
				return ServiceResponse.failure(
					`유효하지 않은 앱 ID: ${invalidIds.join(", ")}`,
					null,
					StatusCodes.BAD_REQUEST,
				);
			}

			const result = await appsRepository.updateUserAppOrder(userId, order);
			return ServiceResponse.success("앱 순서 저장 성공", result);
		} catch (error) {
			logger.error({ error }, "Update user app order error");
			return ServiceResponse.failure("앱 순서 저장 실패", null, StatusCodes.INTERNAL_SERVER_ERROR);
		}
	}
}

export const appsService = new AppsService();
