import {
  OpenAPIRegistry,
  OpenApiGeneratorV3,
} from "@asteasolutions/zod-to-openapi";
import { appsRegistry } from "@/api/apps/appsRouter";
import { authRegistry } from "@/api/auth/authRouter";
import { memoRegistry } from "@/api/memo/memoRouter";

export type OpenAPIDocument = ReturnType<
  OpenApiGeneratorV3["generateDocument"]
>;

export function generateOpenAPIDocument(): OpenAPIDocument {
  const registry = new OpenAPIRegistry([
    authRegistry,
    appsRegistry,
    memoRegistry,
  ]);

  const generator = new OpenApiGeneratorV3(registry.definitions);

  const document = generator.generateDocument({
    openapi: "3.0.0",
    info: {
      version: "1.0.0",
      title: "webOS Home Screen Backend API",
      description: "사용자별 로그인, 메모, 앱 리스트 관리 API",
    },
    servers: [
      {
        url: "http://localhost:8080",
        description: "Development server",
      },
    ],
    externalDocs: {
      description: "View the raw OpenAPI Specification in JSON format",
      url: "/swagger.json",
    },
  });

  // Security scheme을 문서에 직접 추가
  if (!document.components) {
    document.components = {};
  }
  document.components.securitySchemes = {
    bearerAuth: {
      type: "http",
      scheme: "bearer",
      bearerFormat: "JWT",
      description:
        "JWT 토큰을 입력하세요. 토큰만 입력하면 됩니다 (Bearer 접두사는 자동 추가됩니다)",
    },
  };

  return document;
}
