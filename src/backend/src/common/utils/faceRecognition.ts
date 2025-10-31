// 얼굴 인식 기능을 잠시 비활성화하기 위한 더미 유틸리티입니다.
// 재도입 시에는 face-api.js나 대체 솔루션으로 다시 구현하세요.

export async function loadModels(): Promise<void> {
  // no-op
}

export async function extractFaceDescriptor(
  _imageBuffer: Buffer
): Promise<Float32Array | null> {
  return null;
}

export function compareFaces(
  _descriptor1: Float32Array,
  _descriptor2: Float32Array
): number {
  return 0;
}

export function isSamePerson(
  _descriptor1: Float32Array,
  _descriptor2: Float32Array,
  _threshold: number = 0.6
): boolean {
  return false;
}
