import type { Response } from "express";
import { StatusCodes } from "http-status-codes";
import type { AuthRequest } from "@/common/middleware/auth";
import { ServiceResponse } from "@/common/models/serviceResponse";
import { handleServiceResponse } from "@/common/utils/httpHandlers";
import { memoService } from "./memoService";
import type { CreateMemoRequest, UpdateMemoRequest } from "@/common/types";

class MemoController {
  public async getMemos(req: AuthRequest, res: Response) {
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

    const memoType = req.query.memoType
      ? Number.parseInt(req.query.memoType as string)
      : undefined;

    if (memoType !== undefined && memoType !== 1 && memoType !== 2) {
      return handleServiceResponse(
        ServiceResponse.failure(
          "memoType must be 1 or 2",
          null,
          StatusCodes.BAD_REQUEST
        ),
        res
      );
    }

    const serviceResponse = await memoService.getMemos(
      userId,
      memoType as 1 | 2 | undefined
    );
    return handleServiceResponse(serviceResponse, res);
  }

  public async getMemoById(req: AuthRequest, res: Response) {
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

    const memoId = Number.parseInt(req.params.id);
    if (Number.isNaN(memoId)) {
      return handleServiceResponse(
        ServiceResponse.failure("Invalid memo ID", null, StatusCodes.BAD_REQUEST),
        res
      );
    }

    const serviceResponse = await memoService.getMemoById(userId, memoId);
    return handleServiceResponse(serviceResponse, res);
  }

  public async createMemo(req: AuthRequest, res: Response) {
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

    const data = req.body as CreateMemoRequest;
    const serviceResponse = await memoService.createMemo(userId, data);
    return handleServiceResponse(serviceResponse, res);
  }

  public async updateMemo(req: AuthRequest, res: Response) {
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

    const memoId = Number.parseInt(req.params.id);
    if (Number.isNaN(memoId)) {
      return handleServiceResponse(
        ServiceResponse.failure("Invalid memo ID", null, StatusCodes.BAD_REQUEST),
        res
      );
    }

    const data = req.body as UpdateMemoRequest;
    const serviceResponse = await memoService.updateMemo(userId, memoId, data);
    return handleServiceResponse(serviceResponse, res);
  }

  public async deleteMemo(req: AuthRequest, res: Response) {
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

    const memoId = Number.parseInt(req.params.id);
    if (Number.isNaN(memoId)) {
      return handleServiceResponse(
        ServiceResponse.failure("Invalid memo ID", null, StatusCodes.BAD_REQUEST),
        res
      );
    }

    const serviceResponse = await memoService.deleteMemo(userId, memoId);
    return handleServiceResponse(serviceResponse, res);
  }
}

export const memoController = new MemoController();
