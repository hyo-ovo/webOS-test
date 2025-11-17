import * as faceapi from "face-api.js";
import * as canvas from "canvas";
import "@tensorflow/tfjs-node";
import path from "node:path";
import { fileURLToPath } from "node:url";

// Canvas 설정 (face-api.js가 브라우저 API 대신 사용)
const { Canvas, Image, ImageData } = canvas;
faceapi.env.monkeyPatch({ Canvas, Image, ImageData } as any);

// 모델 로드 여부
let modelsLoaded = false;

/**
 * Face Recognition 모델 로드
 * - SSD MobileNetV1: 얼굴 감지
 * - Face Landmark 68: 얼굴 랜드마크 감지
 * - Face Recognition: 얼굴 특징 추출
 */
export async function loadModels(): Promise<void> {
	if (modelsLoaded) return;

	const __filename = fileURLToPath(import.meta.url);
	const __dirname = path.dirname(__filename);
	const modelPath = path.join(__dirname, "../../../models");

	try {
		await Promise.all([
			faceapi.nets.ssdMobilenetv1.loadFromDisk(modelPath),
			faceapi.nets.faceLandmark68Net.loadFromDisk(modelPath),
			faceapi.nets.faceRecognitionNet.loadFromDisk(modelPath),
		]);

		modelsLoaded = true;
		console.log("✅ Face recognition models loaded successfully");
	} catch (error) {
		console.error("❌ Failed to load face recognition models:", error);
		throw new Error("Face recognition models not found. Please run ./download-models.sh");
	}
}

/**
 * 이미지에서 얼굴 특징 추출
 * @param imageBuffer - 이미지 버퍼 (JPEG, PNG 등)
 * @returns 128차원 얼굴 특징 벡터 또는 null (얼굴 감지 실패)
 */
export async function extractFaceDescriptor(imageBuffer: Buffer): Promise<Float32Array | null> {
	try {
		const img = await canvas.loadImage(imageBuffer);
		const detection = await faceapi
			.detectSingleFace(img as any)
			.withFaceLandmarks()
			.withFaceDescriptor();

		if (!detection) {
			return null; // 얼굴 감지 안됨
		}

		return detection.descriptor;
	} catch (error) {
		console.error("Error extracting face descriptor:", error);
		return null;
	}
}

/**
 * 두 얼굴 특징 비교 (유사도 계산)
 * @returns 유사도 (0~1, 높을수록 유사)
 */
export function compareFaces(descriptor1: Float32Array, descriptor2: Float32Array): number {
	const distance = faceapi.euclideanDistance(descriptor1, descriptor2);
	const similarity = 1 - distance; // 0~1 (높을수록 유사)
	return similarity;
}

/**
 * 얼굴 매칭 여부 판단
 * @param threshold - 임계값 (0.5~0.7 권장, 기본값 0.6)
 * @returns 동일인 여부
 */
export function isSamePerson(
	descriptor1: Float32Array,
	descriptor2: Float32Array,
	threshold: number = 0.6,
): boolean {
	const similarity = compareFaces(descriptor1, descriptor2);
	return similarity >= threshold;
}
