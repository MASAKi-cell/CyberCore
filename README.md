# CyberCore

## 技術スタック

- **フレームワーク**: Electron + React 19
- **言語**: TypeScript
- **ビルドツール**: electron-vite + Vite
- **パッケージング**: electron-builder

## 必要な環境

- Node.js 22+
- npm 10+

## セットアップ

```bash
# 依存関係をインストール
make install
# または
npm install
```

## 開発

```bash
# 開発サーバーを起動（ホットリロード）
make dev
```

## コマンド一覧

`make help` で全コマンドを確認できます。

### 開発

| コマンド     | 説明                                 |
| ------------ | ------------------------------------ |
| `make dev`   | 開発サーバーを起動（ホットリロード） |
| `make start` | ビルド済みアプリをプレビュー         |

### コード品質

| コマンド         | 説明                            |
| ---------------- | ------------------------------- |
| `make lint`      | ESLint でコードをチェック       |
| `make format`    | Prettier でコードをフォーマット |
| `make typecheck` | TypeScript 型チェック（全体）   |
| `make check`     | lint + typecheck を実行         |

### ビルド

| コマンド         | 説明                             |
| ---------------- | -------------------------------- |
| `make build`     | アプリケーションをビルド         |
| `make build-mac` | macOS 用インストーラーをビルド   |
| `make build-win` | Windows 用インストーラーをビルド |

### クリーンアップ

| コマンド         | 説明                               |
| ---------------- | ---------------------------------- |
| `make clean`     | ビルド成果物を削除                 |
| `make clean-all` | ビルド成果物と node_modules を削除 |

## プロジェクト構造

```
src/
├── main/           # Main プロセス（Node.js）
├── preload/        # Preload スクリプト
└── renderer/       # Renderer プロセス（React）
    └── src/
        ├── App.tsx
        └── main.tsx
```

## 推奨エディタ設定

- [VSCode](https://code.visualstudio.com/)
- [ESLint 拡張機能](https://marketplace.visualstudio.com/items?itemName=dbaeumer.vscode-eslint)
- [Prettier 拡張機能](https://marketplace.visualstudio.com/items?itemName=esbenp.prettier-vscode)
