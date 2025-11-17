import { defineConfig } from "tsup";

export default defineConfig({
  entry: ["src/index.ts"],
  format: ["cjs"], // ESM에서 CJS로 변경
  dts: false,
  splitting: false,
  sourcemap: true,
  clean: true,
  target: "node20",
  outDir: "dist",
  platform: "node",
  bundle: true,
  minify: false,
  outExtension: () => ({ js: ".js" }), // .mjs → .js로 변경
});
