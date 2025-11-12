import type { Request, RequestHandler, Response } from "express";
import { authService } from "./authService";
import { handleServiceResponse } from "@/common/utils/httpHandlers";

class AuthController {
  public register: RequestHandler = async (req: Request, res: Response) => {
    const { username, password } = req.body;
    const serviceResponse = await authService.register(username, password);
    return handleServiceResponse(serviceResponse, res);
  };

  public login: RequestHandler = async (req: Request, res: Response) => {
    const { username, password } = req.body;
    const serviceResponse = await authService.login(username, password);
    return handleServiceResponse(serviceResponse, res);
  };
}

export const authController = new AuthController();
