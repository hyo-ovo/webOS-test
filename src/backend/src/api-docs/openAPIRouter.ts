import express, { type Request, type Response, type Router } from "express";
import swaggerUi from "swagger-ui-express";

import { generateOpenAPIDocument } from "@/api-docs/openAPIDocumentGenerator";

export const openAPIRouter: Router = express.Router();
const openAPIDocument = generateOpenAPIDocument();

openAPIRouter.get("/swagger.json", (_req: Request, res: Response) => {
  res.setHeader("Content-Type", "application/json");
  res.send(openAPIDocument);
});

openAPIRouter.use(
  "/",
  swaggerUi.serve,
  swaggerUi.setup(openAPIDocument, {
    swaggerOptions: {
      persistAuthorization: true, // 페이지 새로고침 시에도 토큰 유지
    },
    customCss: ".swagger-ui .topbar { display: none }", // 상단 바 숨기기 (선택사항)
  })
);
