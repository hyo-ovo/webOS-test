import type { NextFunction, Request, Response } from "express";
import { StatusCodes } from "http-status-codes";
import jwt from "jsonwebtoken";
import { ServiceResponse } from "@/common/models/serviceResponse";
import { env } from "@/common/utils/envConfig";

export interface AuthRequest extends Request {
	userId?: number;
}

export const authenticate = (req: Request, res: Response, next: NextFunction) => {
	try {
		const authHeader = req.headers.authorization;

		if (!authHeader || !authHeader.startsWith("Bearer ")) {
			const response = ServiceResponse.failure(
				"Authorization token required",
				null,
				StatusCodes.UNAUTHORIZED
			);
			return res.status(response.statusCode).json(response);
		}

		const token = authHeader.substring(7);

		const decoded = jwt.verify(token, env.JWT_SECRET) as { userId: number };
		(req as AuthRequest).userId = decoded.userId;

		next();
	} catch (_error) {
		const response = ServiceResponse.failure(
			"Invalid token",
			null,
			StatusCodes.UNAUTHORIZED
		);
		return res.status(response.statusCode).json(response);
	}
};

export const generateToken = (userId: number): string => {
	return jwt.sign({ userId }, env.JWT_SECRET, {
		expiresIn: env.JWT_EXPIRES_IN,
	});
};
