# =============================================================================
# 使用方法: make <target>
# ヘルプ:   make help
# =============================================================================

.PHONY: help install dev start build lint format typecheck clean \
        build-mac build-win

# デフォルトターゲット
.DEFAULT_GOAL := help

help: ## ヘルプを表示
	@echo "CyberCore - 利用可能なコマンド:"
	@echo ""
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-20s\033[0m %s\n", $$1, $$2}'
	@echo ""

# -----------------------------------------------------------------------------
# 開発
# -----------------------------------------------------------------------------
dev: ## 開発サーバーを起動（ホットリロード）
	npm run dev

start: ## ビルド済みアプリをプレビュー
	npm run start

# -----------------------------------------------------------------------------
# コード品質
# -----------------------------------------------------------------------------
lint: ## ESLintでコードをチェック
	npm run lint

format: ## Prettierでコードをフォーマット
	npm run format

typecheck: ## TypeScript型チェック（全体）
	npm run typecheck

typecheck-node: ## TypeScript型チェック（main/preload）
	npm run typecheck:node

typecheck-web: ## TypeScript型チェック（renderer）
	npm run typecheck:web

check: lint typecheck ## lint + typecheck を実行

# -----------------------------------------------------------------------------
# ビルド（ホストOS）
# -----------------------------------------------------------------------------
build: ## アプリケーションをビルド
	npm run build

build-mac: ## macOS用インストーラーをビルド
	npm run build:mac

build-win: ## Windows用インストーラーをビルド
	npm run build:win

build-unpack: ## パッケージング前の展開ビルド
	npm run build:unpack

# -----------------------------------------------------------------------------
# クリーンアップ
# -----------------------------------------------------------------------------
clean: ## ビルド成果物を削除
	rm -rf dist out .eslintcache

clean-all: clean ## ビルド成果物とnode_modulesを削除
	rm -rf node_modules