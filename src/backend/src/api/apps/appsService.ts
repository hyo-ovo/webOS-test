import { StatusCodes } from "http-status-codes";
import { ServiceResponse } from "@/common/models/serviceResponse";
import { logger } from "@/server";
import { appsRepository } from "./appsRepository";
import type { UserAppResponse, UpdateAppOrderRequest } from "@/common/types";

class AppsService {
  async getUserApps(
    userId: number
  ): Promise<ServiceResponse<UserAppResponse[] | null>> {
    try {
      const apps = await appsRepository.getUserApps(userId);
      return ServiceResponse.success("User apps retrieved successfully", apps);
    } catch (error) {
      logger.error({ error }, "Get user apps error");
      return ServiceResponse.failure(
        "Failed to retrieve user apps",
        null,
        StatusCodes.INTERNAL_SERVER_ERROR
      );
    }
  }

  async updateUserAppOrder(
    userId: number,
    data: UpdateAppOrderRequest
  ): Promise<ServiceResponse<{ success: boolean } | null>> {
    try {
      const { apps } = data;

      if (!Array.isArray(apps) || apps.length === 0) {
        return ServiceResponse.failure(
          "apps must be a non-empty array",
          null,
          StatusCodes.BAD_REQUEST
        );
      }

      // 각 앱 정보 검증
      for (const app of apps) {
        if (!app.name || !app.imgPath || !app.runPath) {
          return ServiceResponse.failure(
            "Each app must have name, imgPath, and runPath",
            null,
            StatusCodes.BAD_REQUEST
          );
        }
      }

      await appsRepository.updateUserAppOrder(userId, apps);

      return ServiceResponse.success("App order updated successfully", {
        success: true,
      });
    } catch (error) {
      const errorMessage =
        error instanceof Error ? error.message : "Unknown error";
      logger.error({ error }, "Update user app order error");
      return ServiceResponse.failure(
        errorMessage.includes("Failed to create")
          ? errorMessage
          : "Failed to update app order",
        null,
        StatusCodes.INTERNAL_SERVER_ERROR
      );
    }
  }
}

export const appsService = new AppsService();
