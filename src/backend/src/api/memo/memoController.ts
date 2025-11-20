import type { Response } from "express";
import { StatusCodes } from "http-status-codes";
import type { AuthRequest } from "@/common/middleware/auth";
import { ServiceResponse } from "@/common/models/serviceResponse";
import { handleServiceResponse } from "@/common/utils/httpHandlers";
import { memoService } from "./memoService";

class MemoController {
	public async getMemos(req: AuthRequest, res: Response) {
		const userId = req.userId;
		if (!userId) {
			return handleServiceResponse(
				ServiceResponse.failure("인증 정보가 없습니다", null, StatusCodes.UNAUTHORIZED),
				res,
			);
		}
		const serviceResponse = await memoService.getMemos(userId);
		return handleServiceResponse(serviceResponse, res);
	}

	public async createMemo(req: AuthRequest, res: Response) {
		const userId = req.userId;
		if (!userId) {
			return handleServiceResponse(
				ServiceResponse.failure("인증 정보가 없습니다", null, StatusCodes.UNAUTHORIZED),
				res,
			);
		}
		const { title, content } = req.body;

		if (!title || !content) {
			const response = ServiceResponse.failure("제목과 내용이 필요합니다", null, StatusCodes.BAD_REQUEST);
			return handleServiceResponse(response, res);
		}

		const serviceResponse = await memoService.createMemo(userId, title, content);
		return handleServiceResponse(serviceResponse, res);
	}

	public async updateMemo(req: AuthRequest, res: Response) {
		const userId = req.userId;
		if (!userId) {
			return handleServiceResponse(
				ServiceResponse.failure("인증 정보가 없습니다", null, StatusCodes.UNAUTHORIZED),
				res,
			);
		}
		const memoId = Number.parseInt(req.params.id);
		const { title, content } = req.body;

		if (!title || !content) {
			const response = ServiceResponse.failure("제목과 내용이 필요합니다", null, StatusCodes.BAD_REQUEST);
			return handleServiceResponse(response, res);
		}

		const serviceResponse = await memoService.updateMemo(userId, memoId, title, content);
		return handleServiceResponse(serviceResponse, res);
	}

	public async deleteMemo(req: AuthRequest, res: Response) {
		const userId = req.userId;
		if (!userId) {
			return handleServiceResponse(
				ServiceResponse.failure("인증 정보가 없습니다", null, StatusCodes.UNAUTHORIZED),
				res,
			);
		}
		const memoId = Number.parseInt(req.params.id);

		const serviceResponse = await memoService.deleteMemo(userId, memoId);
		return handleServiceResponse(serviceResponse, res);
	}
}

export const memoController = new MemoController();
