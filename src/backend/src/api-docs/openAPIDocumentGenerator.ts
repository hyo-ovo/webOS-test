import { OpenAPIRegistry, OpenApiGeneratorV3 } from "@asteasolutions/zod-to-openapi";
import { appsRegistry } from "@/api/apps/appsRouter";
import { authRegistry } from "@/api/auth/authRouter";
import { favoritesRegistry } from "@/api/favorites/favoritesRouter";
import { memoRegistry } from "@/api/memo/memoRouter";

export type OpenAPIDocument = ReturnType<OpenApiGeneratorV3["generateDocument"]>;

export function generateOpenAPIDocument(): OpenAPIDocument {
	const registry = new OpenAPIRegistry([
		authRegistry,
		appsRegistry,
		favoritesRegistry,
		memoRegistry,
	]);
	const generator = new OpenApiGeneratorV3(registry.definitions);

	return generator.generateDocument({
		openapi: "3.0.0",
		info: {
			version: "1.0.0",
			title: "webOS Home Screen Backend API",
			description: "사용자별 로그인, 메모, 앱 리스트, 즐겨찾기 관리 API",
		},
		externalDocs: {
			description: "View the raw OpenAPI Specification in JSON format",
			url: "/swagger.json",
		},
	});
}
