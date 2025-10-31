import type { NextFunction, Request, Response } from "express";
import jwt from "jsonwebtoken";
import { StatusCodes } from "http-status-codes";
import { env } from "@/common/utils/envConfig";
import { ServiceResponse } from "@/common/models/serviceResponse";

export interface AuthRequest extends Request {
  userId?: number;
  body: any;
  params: any;
}

export const authenticate = (
  req: Request,
  res: Response,
  next: NextFunction
) => {
  try {
    const authHeader = req.headers.authorization;

    if (!authHeader || !authHeader.startsWith("Bearer ")) {
      const response = ServiceResponse.failure(
        "인증 토큰이 필요합니다",
        null,
        StatusCodes.UNAUTHORIZED
      );
      return res.status(response.statusCode).json(response);
    }

    const token = authHeader.substring(7);

    const decoded = jwt.verify(token, env.JWT_SECRET) as { userId: number };
    (req as AuthRequest).userId = decoded.userId;

    next();
  } catch (error) {
    const response = ServiceResponse.failure(
      "유효하지 않은 토큰입니다",
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
