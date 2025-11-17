#!/bin/bash

# Face Recognition 모델 다운로드 스크립트

MODELS_DIR="$(dirname "$0")/models"

echo "🔽 Downloading face-api.js models..."

# 디렉토리 생성
mkdir -p "$MODELS_DIR"
cd "$MODELS_DIR"

# SSD MobileNetV1 모델
echo "📦 Downloading SSD MobileNetV1..."
curl -LO https://raw.githubusercontent.com/justadudewhohacks/face-api.js/master/weights/ssd_mobilenetv1_model-weights_manifest.json
curl -LO https://raw.githubusercontent.com/justadudewhohacks/face-api.js/master/weights/ssd_mobilenetv1_model-shard1

# Face Landmark 68 모델
echo "📦 Downloading Face Landmark 68..."
curl -LO https://raw.githubusercontent.com/justadudewhohacks/face-api.js/master/weights/face_landmark_68_model-weights_manifest.json
curl -LO https://raw.githubusercontent.com/justadudewhohacks/face-api.js/master/weights/face_landmark_68_model-shard1

# Face Recognition 모델
echo "📦 Downloading Face Recognition..."
curl -LO https://raw.githubusercontent.com/justadudewhohacks/face-api.js/master/weights/face_recognition_model-weights_manifest.json
curl -LO https://raw.githubusercontent.com/justadudewhohacks/face-api.js/master/weights/face_recognition_model-shard1
curl -LO https://raw.githubusercontent.com/justadudewhohacks/face-api.js/master/weights/face_recognition_model-shard2

echo "✅ All models downloaded successfully!"
echo "📁 Models location: $MODELS_DIR"
