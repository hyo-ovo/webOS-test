FROM node:20-alpine

# 빌드 도구 설치 (canvas, tensorflow 빌드용)
RUN apk add --no-cache \
    python3 \
    make \
    g++ \
    cairo-dev \
    jpeg-dev \
    pango-dev \
    giflib-dev \
    pixman-dev

# pnpm 설치
RUN npm install -g pnpm

WORKDIR /app

# 의존성 파일 복사
COPY package.json pnpm-lock.yaml* ./

# 의존성 설치
RUN pnpm install --frozen-lockfile || pnpm install

# 소스 코드 복사
COPY . .

# TypeScript 빌드
RUN pnpm build

# 빌드 결과 확인
RUN ls -la dist/

# models 폴더 확인
RUN ls -la models/ || echo "⚠️ Models folder not found"

# 포트 노출
EXPOSE 8080

# 헬스체크
HEALTHCHECK --interval=30s --timeout=3s --start-period=10s --retries=3 \
  CMD node -e "require('http').get('http://localhost:8080/health', (r) => {process.exit(r.statusCode === 200 ? 0 : 1)})"

# 애플리케이션 실행
CMD ["pnpm", "start:prod"]
