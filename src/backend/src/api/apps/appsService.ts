import { StatusCodes } from "http-status-codes";
import { ServiceResponse } from "@/common/models/serviceResponse";
import { appsRepository } from "./appsRepository";
import { logger } from "@/server";

class AppsService {
  async getAllApps(): Promise<ServiceResponse<any>> {
    try {
      const apps = await appsRepository.getAllApps();
      return ServiceResponse.success("앱 목록 조회 성공", apps);
    } catch (error) {
      logger.error("Get apps error:", error);
      return ServiceResponse.failure(
        "앱 목록 조회 실패",
        null,
        StatusCodes.INTERNAL_SERVER_ERROR
      );
    }
  }

  async getUserAppOrder(userId: number): Promise<ServiceResponse<any>> {
    try {
      const order = await appsRepository.getUserAppOrder(userId);
      return ServiceResponse.success(
        "앱 순서 조회 성공",
        order || { app_order: [] }
      );
    } catch (error) {
      logger.error("Get user app order error:", error);
      return ServiceResponse.failure(
        "앱 순서 조회 실패",
        null,
        StatusCodes.INTERNAL_SERVER_ERROR
      );
    }
  }

  async updateUserAppOrder(
    userId: number,
    order: string[]
  ): Promise<ServiceResponse<any>> {
    try {
      const result = await appsRepository.updateUserAppOrder(userId, order);
      return ServiceResponse.success("앱 순서 저장 성공", result);
    } catch (error) {
      logger.error("Update user app order error:", error);
      return ServiceResponse.failure(
        "앱 순서 저장 실패",
        null,
        StatusCodes.INTERNAL_SERVER_ERROR
      );
    }
  }
}

export const appsService = new AppsService();
