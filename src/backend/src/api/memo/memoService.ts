import { StatusCodes } from "http-status-codes";
import { ServiceResponse } from "@/common/models/serviceResponse";
import { logger } from "@/server";
import { memoRepository } from "./memoRepository";
import type {
  Memo,
  MemoResponse,
  CreateMemoRequest,
  UpdateMemoRequest,
} from "@/common/types";

class MemoService {
  async getMemos(
    userId: number,
    memoType?: 1 | 2
  ): Promise<ServiceResponse<MemoResponse[] | null>> {
    try {
      const memos = await memoRepository.getMemosByUserId(userId, memoType);
      const response: MemoResponse[] = memos.map((memo) => ({
        id: memo.id,
        memoType: memo.memo_type,
        title: memo.title,
        subtitle: memo.subtitle,
        createdAt: memo.created_at.toISOString(),
        updatedAt: memo.updated_at.toISOString(),
      }));
      return ServiceResponse.success("Memos retrieved successfully", response);
    } catch (error) {
      logger.error({ error }, "Get memos error");
      return ServiceResponse.failure(
        "Failed to retrieve memos",
        null,
        StatusCodes.INTERNAL_SERVER_ERROR
      );
    }
  }

  async getMemoById(
    userId: number,
    memoId: number
  ): Promise<ServiceResponse<MemoResponse | null>> {
    try {
      const memo = await memoRepository.getMemoById(userId, memoId);
      if (!memo) {
        return ServiceResponse.failure(
          "Memo not found",
          null,
          StatusCodes.NOT_FOUND
        );
      }
      const response: MemoResponse = {
        id: memo.id,
        memoType: memo.memo_type,
        title: memo.title,
        subtitle: memo.subtitle,
        createdAt: memo.created_at.toISOString(),
        updatedAt: memo.updated_at.toISOString(),
      };
      return ServiceResponse.success("Memo retrieved successfully", response);
    } catch (error) {
      logger.error({ error }, "Get memo error");
      return ServiceResponse.failure(
        "Failed to retrieve memo",
        null,
        StatusCodes.INTERNAL_SERVER_ERROR
      );
    }
  }

  async createMemo(
    userId: number,
    data: CreateMemoRequest
  ): Promise<ServiceResponse<MemoResponse | null>> {
    try {
      const { memoType, title, subtitle } = data;

      if (memoType !== 1 && memoType !== 2) {
        return ServiceResponse.failure(
          "memoType must be 1 or 2",
          null,
          StatusCodes.BAD_REQUEST
        );
      }

      const memo = await memoRepository.createMemo(
        userId,
        memoType,
        title,
        subtitle
      );

      const response: MemoResponse = {
        id: memo.id,
        memoType: memo.memo_type,
        title: memo.title,
        subtitle: memo.subtitle,
        createdAt: memo.created_at.toISOString(),
        updatedAt: memo.updated_at.toISOString(),
      };

      return ServiceResponse.success(
        "Memo created successfully",
        response,
        StatusCodes.CREATED
      );
    } catch (error) {
      logger.error({ error }, "Create memo error");
      return ServiceResponse.failure(
        "Failed to create memo",
        null,
        StatusCodes.INTERNAL_SERVER_ERROR
      );
    }
  }

  async updateMemo(
    userId: number,
    memoId: number,
    data: UpdateMemoRequest
  ): Promise<ServiceResponse<MemoResponse | null>> {
    try {
      const { title, subtitle } = data;

      const memo = await memoRepository.updateMemo(
        userId,
        memoId,
        title,
        subtitle
      );

      if (!memo) {
        return ServiceResponse.failure(
          "Memo not found",
          null,
          StatusCodes.NOT_FOUND
        );
      }

      const response: MemoResponse = {
        id: memo.id,
        memoType: memo.memo_type,
        title: memo.title,
        subtitle: memo.subtitle,
        createdAt: memo.created_at.toISOString(),
        updatedAt: memo.updated_at.toISOString(),
      };

      return ServiceResponse.success("Memo updated successfully", response);
    } catch (error) {
      logger.error({ error }, "Update memo error");
      return ServiceResponse.failure(
        "Failed to update memo",
        null,
        StatusCodes.INTERNAL_SERVER_ERROR
      );
    }
  }

  async deleteMemo(
    userId: number,
    memoId: number
  ): Promise<ServiceResponse<{ success: boolean } | null>> {
    try {
      const deleted = await memoRepository.deleteMemo(userId, memoId);

      if (!deleted) {
        return ServiceResponse.failure(
          "Memo not found",
          null,
          StatusCodes.NOT_FOUND
        );
      }

      return ServiceResponse.success("Memo deleted successfully", {
        success: true,
      });
    } catch (error) {
      logger.error({ error }, "Delete memo error");
      return ServiceResponse.failure(
        "Failed to delete memo",
        null,
        StatusCodes.INTERNAL_SERVER_ERROR
      );
    }
  }
}

export const memoService = new MemoService();
