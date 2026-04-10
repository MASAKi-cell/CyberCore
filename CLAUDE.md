## プロジェクト概要

CyberCoreは、TauriをバックエンドとしてReactとTypeScriptで構築されたデスクトップアプリケーションです。フロントエンドはVite、バックエンドはRustで実装されています。

## 開発コマンド

```bash
# 依存関係のインストール
npm install

# ホットリロード付き開発サーバー起動
npm run tauri dev

# 型チェック
npm run typecheck

# リント・フォーマット
npm run lint
npm run format

# アプリケーションビルド
npm run tauri build
```

## アーキテクチャ

### フロントエンド (`src/`)

- Vite + React 19 + TypeScript
- エントリーポイント: `main.tsx` → `App.tsx`
- `@tauri-apps/api` を使ってバックエンドと通信

### バックエンド (`src-tauri/`)

- Rust製のネイティブバックエンド
- `#[tauri::command]` でフロントエンドから呼び出せる関数を定義
- `src-tauri/src/main.rs` または `lib.rs` がエントリーポイント
- `src-tauri/tauri.conf.json` でウィンドウ設定・権限を管理

## IPC通信パターン

```typescript
// フロントエンド (src/)
import { invoke } from '@tauri-apps/api/core'

const result = await invoke<string>('command_name', { arg: value })
```

```rust
// バックエンド (src-tauri/src/)
#[tauri::command]
fn command_name(arg: String) -> String {
    // 処理
    arg
}

// main.rs でコマンドを登録
tauri::Builder::default()
    .invoke_handler(tauri::generate_handler![command_name])
    .run(tauri::generate_context!())
    .expect("error while running tauri application");
```

## TypeScript設定

- `tsconfig.json` - 単一設定（DOM/React API）

## コードスタイル

- Prettier: シングルクォート、セミコロンなし、100文字幅、末尾カンマなし
- ESLint: typescript-eslint + React/hooksプラグイン
- 2スペースインデント（.editorconfigで定義）
- Rust: `cargo fmt` でフォーマット、`cargo clippy` でlint
