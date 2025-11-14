import type { Request, RequestHandler, Response } from "express";
import { authService } from "./authService";
import { handleServiceResponse } from "@/common/utils/httpHandlers";
import type { SignupRequest, LoginRequest } from "@/common/types";

class AuthController {
  public signup: RequestHandler = async (req: Request, res: Response) => {
    const { name, password, isChild } = req.body as SignupRequest;
    const serviceResponse = await authService.signup({
      name,
      password,
      isChild: isChild ?? false,
    });
    return handleServiceResponse(serviceResponse, res);
  };

  public login: RequestHandler = async (req: Request, res: Response) => {
    const { name, password } = req.body as LoginRequest;
    const serviceResponse = await authService.login({ name, password });
    return handleServiceResponse(serviceResponse, res);
  };
}

export const authController = new AuthController();
