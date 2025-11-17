import type { Response } from "express";
import { StatusCodes } from "http-status-codes";
import type { AuthRequest } from "@/common/middleware/auth";
import { ServiceResponse } from "@/common/models/serviceResponse";
import { handleServiceResponse } from "@/common/utils/httpHandlers";
import { appsService } from "./appsService";
import type { UpdateAppOrderRequest } from "@/common/types";

class AppsController {
  public async getUserApps(req: AuthRequest, res: Response) {
    const userId = req.userId;
    if (!userId) {
      return handleServiceResponse(
        ServiceResponse.failure(
          "Unauthorized",
          null,
          StatusCodes.UNAUTHORIZED
        ),
        res
      );
    }

    const serviceResponse = await appsService.getUserApps(userId);
    return handleServiceResponse(serviceResponse, res);
  }

  public async updateAppOrder(req: AuthRequest, res: Response) {
    const userId = req.userId;
    if (!userId) {
      return handleServiceResponse(
        ServiceResponse.failure(
          "Unauthorized",
          null,
          StatusCodes.UNAUTHORIZED
        ),
        res
      );
    }

    const data = req.body as UpdateAppOrderRequest;
    const serviceResponse = await appsService.updateUserAppOrder(userId, data);
    return handleServiceResponse(serviceResponse, res);
  }
}

export const appsController = new AppsController();
