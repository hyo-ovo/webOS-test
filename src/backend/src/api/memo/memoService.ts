import { StatusCodes } from "http-status-codes";
import { ServiceResponse } from "@/common/models/serviceResponse";
import { memoRepository } from "./memoRepository";
import { logger } from "@/server";

class MemoService {
  async getMemos(userId: number): Promise<ServiceResponse<any>> {
    try {
      const memos = await memoRepository.getMemosByUserId(userId);
      return ServiceResponse.success("메모 조회 성공", memos);
    } catch (error) {
      logger.error("Get memos error:", error);
      return ServiceResponse.failure(
        "메모 조회 실패",
        null,
        StatusCodes.INTERNAL_SERVER_ERROR
      );
    }
  }

  async createMemo(
    userId: number,
    title: string,
    content: string
  ): Promise<ServiceResponse<any>> {
    try {
      if (content.length > 1024 * 1024) {
        // 1MB
        return ServiceResponse.failure(
          "메모 내용이 너무 큽니다 (최대 1MB)",
          null,
          StatusCodes.BAD_REQUEST
        );
      }

      const memo = await memoRepository.createMemo(userId, title, content);
      return ServiceResponse.success("메모 생성 성공", memo);
    } catch (error) {
      logger.error("Create memo error:", error);
      return ServiceResponse.failure(
        "메모 생성 실패",
        null,
        StatusCodes.INTERNAL_SERVER_ERROR
      );
    }
  }

  async updateMemo(
    userId: number,
    memoId: number,
    title: string,
    content: string
  ): Promise<ServiceResponse<any>> {
    try {
      if (content.length > 1024 * 1024) {
        return ServiceResponse.failure(
          "메모 내용이 너무 큽니다 (최대 1MB)",
          null,
          StatusCodes.BAD_REQUEST
        );
      }

      const memo = await memoRepository.updateMemo(
        userId,
        memoId,
        title,
        content
      );

      if (!memo) {
        return ServiceResponse.failure(
          "메모를 찾을 수 없습니다",
          null,
          StatusCodes.NOT_FOUND
        );
      }

      return ServiceResponse.success("메모 수정 성공", memo);
    } catch (error) {
      logger.error("Update memo error:", error);
      return ServiceResponse.failure(
        "메모 수정 실패",
        null,
        StatusCodes.INTERNAL_SERVER_ERROR
      );
    }
  }

  async deleteMemo(
    userId: number,
    memoId: number
  ): Promise<ServiceResponse<any>> {
    try {
      const deleted = await memoRepository.deleteMemo(userId, memoId);

      if (!deleted) {
        return ServiceResponse.failure(
          "메모를 찾을 수 없습니다",
          null,
          StatusCodes.NOT_FOUND
        );
      }

      return ServiceResponse.success("메모 삭제 성공", { id: memoId });
    } catch (error) {
      logger.error("Delete memo error:", error);
      return ServiceResponse.failure(
        "메모 삭제 실패",
        null,
        StatusCodes.INTERNAL_SERVER_ERROR
      );
    }
  }
}

export const memoService = new MemoService();
