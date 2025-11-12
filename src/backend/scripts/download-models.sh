#!/bin/bash

# Face-api.js 모델 다운로드 스크립트

MODEL_DIR="models"
BASE_URL="https://raw.githubusercontent.com/justadudewhohacks/face-api.js/master/weights"

mkdir -p "$MODEL_DIR"
cd "$MODEL_DIR"

echo "📥 Downloading face recognition models..."

# SSD MobileNet V1 (얼굴 감지)
curl -O "$BASE_URL/ssd_mobilenetv1_model-weights_manifest.json"
curl -O "$BASE_URL/ssd_mobilenetv1_model-shard1"

# Face Landmark 68 (얼굴 랜드마크)
curl -O "$BASE_URL/face_landmark_68_model-weights_manifest.json"
curl -O "$BASE_URL/face_landmark_68_model-shard1"

# Face Recognition (얼굴 특징 추출)
curl -O "$BASE_URL/face_recognition_model-weights_manifest.json"
curl -O "$BASE_URL/face_recognition_model-shard1"
curl -O "$BASE_URL/face_recognition_model-shard2"

echo "✅ Models downloaded successfully!"
ls -lh
