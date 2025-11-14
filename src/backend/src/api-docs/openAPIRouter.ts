import express, { type Request, type Response, type Router } from "express";
import swaggerUi from "swagger-ui-express";

import { generateOpenAPIDocument } from "@/api-docs/openAPIDocumentGenerator";

export const openAPIRouter: Router = express.Router();

// 요청마다 동적으로 서버 URL을 생성하여 문서 생성
openAPIRouter.get("/swagger.json", (req: Request, res: Response) => {
  // 요청의 프로토콜과 호스트를 기반으로 서버 URL 생성
  const protocol = req.protocol || (req.get("x-forwarded-proto") || "http");
  const host = req.get("host") || req.hostname;
  const baseUrl = `${protocol}://${host}`;
  
  const openAPIDocument = generateOpenAPIDocument(baseUrl);
  res.setHeader("Content-Type", "application/json");
  res.send(openAPIDocument);
});

openAPIRouter.use(
  "/",
  swaggerUi.serve,
  swaggerUi.setup(undefined, {
    swaggerOptions: {
      url: "/swagger/swagger.json", // 동적으로 생성된 JSON 사용
      persistAuthorization: true, // 페이지 새로고침 시에도 토큰 유지
    },
    customCss: ".swagger-ui .topbar { display: none }", // 상단 바 숨기기 (선택사항)
  })
);
