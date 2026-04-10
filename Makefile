# =============================================================================
# 使用方法: make <target>
# ヘルプ:   make help
# =============================================================================

.PHONY: help install dev build preview lint format typecheck check \
        build-mac build-win build-linux clean clean-all

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
	npm run tauri dev

preview: ## フロントエンドのプレビューサーバーを起動
	npm run preview

# -----------------------------------------------------------------------------
# コード品質
# -----------------------------------------------------------------------------
lint: ## ESLintでコードをチェック
	npm run lint

format: ## Prettierでコードをフォーマット
	npm run format

typecheck: ## TypeScript型チェック
	npm run typecheck

check: lint typecheck ## lint + typecheck を実行

# -----------------------------------------------------------------------------
# ビルド
# -----------------------------------------------------------------------------
build: ## アプリケーションをビルド（全プラットフォーム）
	npm run tauri build

build-mac: ## macOS用インストーラーをビルド
	npm run tauri build -- --target universal-apple-darwin

build-win: ## Windows用インストーラーをビルド
	npm run tauri build -- --target x86_64-pc-windows-msvc

build-linux: ## Linux用パッケージをビルド
	npm run tauri build -- --target x86_64-unknown-linux-gnu

# -----------------------------------------------------------------------------
# クリーンアップ
# -----------------------------------------------------------------------------
clean: ## ビルド成果物を削除
	rm -rf dist src-tauri/target .eslintcache

clean-all: clean ## ビルド成果物とnode_modulesを削除
	rm -rf node_modules
