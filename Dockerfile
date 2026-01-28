# =============================================================================
# CyberCore Electron App - Multi-stage Dockerfile (Build Only)
# =============================================================================
# 用途: Linuxインストーラーのビルド
# 開発はホストOSで直接 npm run dev を実行してください
# =============================================================================

# -----------------------------------------------------------------------------
# Stage 1: Base - 共通のNode.js環境
# -----------------------------------------------------------------------------
FROM node:22-bookworm-slim AS base

# ビルドに必要なネイティブ依存関係
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    python3 \
    make \
    g++ \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# -----------------------------------------------------------------------------
# Stage 2: Dependencies - 依存関係のインストール
# -----------------------------------------------------------------------------
FROM base AS deps
COPY package*.json ./
RUN npm ci

# -----------------------------------------------------------------------------
# Stage 3: Builder - ビルド実行
# -----------------------------------------------------------------------------
FROM base AS builder

# Linuxビルドに必要な追加パッケージ
RUN apt-get update && apt-get install -y --no-install-recommends \
    rpm \
    fakeroot \
    dpkg \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY --from=deps /app/node_modules ./node_modules
COPY . .
RUN npm run build

# -----------------------------------------------------------------------------
# Stage 4: Build Linux - Linuxインストーラー生成
# -----------------------------------------------------------------------------
FROM builder AS build-linux
RUN npm run build:linux

# -----------------------------------------------------------------------------
# Stage 5: Artifacts - ビルド成果物のみを含む軽量イメージ
# -----------------------------------------------------------------------------
FROM alpine:3.20 AS artifacts
WORKDIR /artifacts
COPY --from=build-linux /app/dist ./dist
CMD ["ls", "-la", "dist"]
