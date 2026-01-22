# CLAUDE.md

このファイルは、Claude Code (claude.ai/code) がこのリポジトリで作業する際のガイダンスを提供します。

## プロジェクト概要

CyberCoreは、electron-viteをビルドツールとして使用し、ReactとTypeScriptで構築されたElectronデスクトップアプリケーションです。

## 開発コマンド

```bash
# 依存関係のインストール
npm install

# ホットリロード付き開発サーバー起動
npm run dev

# 型チェック
npm run typecheck          # 全体の型チェック（node + web）
npm run typecheck:node     # main/preloadプロセスのみ
npm run typecheck:web      # rendererプロセスのみ

# リント・フォーマット
npm run lint               # ESLint（キャッシュ有効）
npm run format             # Prettierフォーマット

# アプリケーションビルド
npm run build              # 型チェック + ビルド

# プラットフォーム別インストーラー作成
npm run build:mac          # macOS DMG
npm run build:win          # Windows NSISインストーラー
npm run build:linux        # Linux AppImage/snap/deb
```

## アーキテクチャ

標準的なElectronマルチプロセスアーキテクチャで、3つの異なるコンテキストがあります。

### Mainプロセス (`src/main/`)
- `index.ts`で実行されるNode.js環境
- アプリケーションのライフサイクル、ウィンドウ作成、ネイティブOS操作を管理
- `ipcMain.on()`と`ipcMain.handle()`でrendererからのIPCメッセージを処理

### Preloadプロセス (`src/preload/`)
- コンテキスト分離によるmainとrendererの橋渡し
- `contextBridge.exposeInMainWorld()`で安全なAPIをrendererに公開
- `window.electron`と`window.api`オブジェクトはここで定義

### Rendererプロセス (`src/renderer/src/`)
- ブラウザコンテキストで実行されるReact 19アプリケーション
- エントリーポイント: `main.tsx` → `App.tsx`
- `window.electron.ipcRenderer`を通じてmainプロセスと通信
- パスエイリアス`@renderer`は`src/renderer/src`にマップ

## IPC通信パターン

```typescript
// Mainプロセス (src/main/index.ts)
ipcMain.on('channel-name', (event, ...args) => { /* 処理 */ })
ipcMain.handle('channel-name', async (event, ...args) => { /* 値を返す */ })

// Rendererプロセス (preloadブリッジ経由)
window.electron.ipcRenderer.send('channel-name', data)
window.electron.ipcRenderer.invoke('channel-name', data)
```

## TypeScript設定

プロジェクトはコンポジットTypeScript設定を使用:
- `tsconfig.node.json` - MainとPreloadプロセス（Node.js API）
- `tsconfig.web.json` - Rendererプロセス（DOM/React API）
- `tsconfig.json` - 両方を参照するルート設定

## コードスタイル

- Prettier: シングルクォート、セミコロンなし、100文字幅、末尾カンマなし
- ESLint: Electron toolkit設定 + React/hooksプラグイン
- 2スペースインデント（.editorconfigで定義）
