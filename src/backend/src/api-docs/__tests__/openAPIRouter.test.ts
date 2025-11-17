import { StatusCodes } from "http-status-codes";
import request from "supertest";

import { app } from "@/server";

import { generateOpenAPIDocument } from "../openAPIDocumentGenerator";

describe("OpenAPI Router", () => {
	describe("Swagger JSON route", () => {
		it("should return Swagger JSON content", async () => {
			// Act
			const response = await request(app).get("/swagger.json");

			// Assert
			expect(response.status).toBe(StatusCodes.OK);
			expect(response.type).toBe("application/json");
			expect(response.body).toHaveProperty("openapi", "3.0.0");
			expect(response.body).toHaveProperty("info");
			expect(response.body).toHaveProperty("servers");
			expect(Array.isArray(response.body.servers)).toBe(true);
			expect(response.body.servers.length).toBeGreaterThan(0);
		});

		it("should serve the Swagger UI", async () => {
			// Act
			const response = await request(app).get("/");

			// Assert
			expect(response.status).toBe(StatusCodes.OK);
			expect(response.text).toContain("swagger-ui");
		});
	});
});
