# Electron メインプロセス コーディング規約

## 1. TypeScript

### any禁止
`any`型の使用を禁止し、適切な型定義を行う。

```typescript
// ❌ Bad
const getSystemInfo = async (): any => {
  // ...
}

// ✅ Good
interface SystemInfo {
  cpu: number
  memory: { used: number; total: number }
}

const getSystemInfo = async (): Promise<SystemInfo> => {
  // ...
}
```

### unknown + 型ガード
外部入力には`unknown`を使い、型ガードで安全に処理する。

```typescript
// ✅ Good
const handleExternalData = (data: unknown): string => {
  if (typeof data === 'string') {
    return data
  }
  throw new Error('Invalid data type')
}
```

---

## 2. 関数スタイル

### アロー関数で記述
すべての関数はアロー関数で記述する。

```typescript
// ❌ Bad
function createWindow() {
  // ...
}

// ✅ Good
const createWindow = (): void => {
  // ...
}
```

### 非同期関数
async/awaitを使用し、コールバックを避ける。

```typescript
// ❌ Bad
fs.readFile(path, (err, data) => {
  // ...
})

// ✅ Good
const data = await fs.promises.readFile(path)
```

---

## 3. セキュリティ

### BrowserWindow設定（必須）
以下の設定を必ず適用する。

```typescript
// ✅ Good
const mainWindow = new BrowserWindow({
  webPreferences: {
    nodeIntegration: false,        // 必須: Node.js APIを無効化
    contextIsolation: true,        // 必須: コンテキスト分離
    sandbox: true,                 // 推奨: サンドボックス有効化
    webSecurity: true,             // 必須: 同一オリジンポリシー有効
    allowRunningInsecureContent: false
  }
})
```

### shell.openExternal のURL検証
ユーザー入力URLを開く前に必ずプロトコルを検証する。

```typescript
// ❌ Bad
shell.openExternal(userProvidedUrl)

// ✅ Good
const ALLOWED_PROTOCOLS = ['https:', 'mailto:']

const safeOpenExternal = async (url: string): Promise<void> => {
  const parsed = new URL(url)
  if (!ALLOWED_PROTOCOLS.includes(parsed.protocol)) {
    throw new Error(`Blocked protocol: ${parsed.protocol}`)
  }
  await shell.openExternal(url)
}
```

### 危険なオプションの禁止

```typescript
// ❌ Bad - 絶対に使用しない
new BrowserWindow({
  webPreferences: {
    nodeIntegration: true,
    contextIsolation: false,
    enableRemoteModule: true
  }
})
```

---

## 4. IPC通信

### handle vs on の使い分け

```typescript
// 戻り値が必要な場合: handle + invoke
ipcMain.handle('system:get-cpu-usage', async () => {
  return await getCpuUsage()
})

// 戻り値が不要な場合: on + send
ipcMain.on('window:minimize', () => {
  mainWindow?.minimize()
})
```

### チャネル命名規則
`名前空間:アクション` 形式で命名する。

```typescript
// ✅ Good
'system:get-cpu-usage'
'system:get-memory-info'
'window:minimize'
'window:close'

// ❌ Bad
'getCpuUsage'
'cpu'
'minimize-window'
```

### 入力バリデーション
Rendererからの入力は常に信頼しない。

```typescript
// ❌ Bad
ipcMain.handle('file:read', async (_, path: string) => {
  return await fs.promises.readFile(path)
})

// ✅ Good
const ALLOWED_PATHS = [app.getPath('userData')]

ipcMain.handle('file:read', async (_, filePath: unknown) => {
  if (typeof filePath !== 'string') {
    throw new Error('Invalid path type')
  }

  const resolved = path.resolve(filePath)
  const isAllowed = ALLOWED_PATHS.some(allowed =>
    resolved.startsWith(allowed)
  )

  if (!isAllowed) {
    throw new Error('Access denied')
  }

  return await fs.promises.readFile(resolved)
})
```

### エラーハンドリング
IPC経由のエラーは構造化して返す。

```typescript
// ✅ Good
interface IpcResult<T> {
  success: boolean
  data?: T
  error?: { code: string; message: string }
}

ipcMain.handle('system:get-info', async (): Promise<IpcResult<SystemInfo>> => {
  try {
    const info = await getSystemInfo()
    return { success: true, data: info }
  } catch (err) {
    return {
      success: false,
      error: {
        code: 'SYSTEM_INFO_ERROR',
        message: err instanceof Error ? err.message : 'Unknown error'
      }
    }
  }
})
```

---

## 5. ウィンドウ・リソース管理

### ウィンドウ参照のクリーンアップ
メモリリークを防ぐため、closedイベントで参照をnull化する。

```typescript
// ✅ Good
let mainWindow: BrowserWindow | null = null

const createWindow = (): void => {
  mainWindow = new BrowserWindow({ /* ... */ })

  mainWindow.on('closed', () => {
    mainWindow = null  // 参照を解放
  })
}
```

### イベントリスナーのクリーンアップ

```typescript
// ✅ Good
const handlePowerMonitor = (): void => {
  // ...
}

powerMonitor.on('suspend', handlePowerMonitor)

app.on('before-quit', () => {
  powerMonitor.removeListener('suspend', handlePowerMonitor)
})
```

### app.getPath() の使用
ハードコードパスを避け、OS標準パスを使用する。

```typescript
// ❌ Bad
const configPath = '/Users/username/.config/myapp'

// ✅ Good
const configPath = path.join(app.getPath('userData'), 'config.json')
```

---

## 6. エラーハンドリング

### 非同期処理のtry-catch

```typescript
// ✅ Good
const loadConfig = async (): Promise<Config> => {
  try {
    const data = await fs.promises.readFile(configPath, 'utf-8')
    return JSON.parse(data) as Config
  } catch (err) {
    console.error('Failed to load config:', err)
    return defaultConfig
  }
}
```

### グローバルエラーハンドラー

```typescript
// ✅ Good - main/index.ts に設置
process.on('uncaughtException', (err) => {
  console.error('Uncaught Exception:', err)
  // ログ送信やクラッシュレポート
})

process.on('unhandledRejection', (reason) => {
  console.error('Unhandled Rejection:', reason)
})
```

---

## 7. コード構成

### ファイル分割の指針
機能ごとにモジュール化する。

```
src/main/
├── index.ts           # エントリーポイント（最小限）
├── window.ts          # BrowserWindow管理
├── tray.ts            # Tray管理
├── ipc/
│   ├── index.ts       # IPCハンドラー登録
│   ├── system.ts      # システム情報関連IPC
│   └── window.ts      # ウィンドウ操作関連IPC
└── services/
    ├── systemInfo.ts  # システム情報取得ロジック
    └── network.ts     # ネットワーク情報取得ロジック
```

### 単一責任の原則

```typescript
// ❌ Bad - 1つのファイルに複数の責務
// main/index.ts に全部書く

// ✅ Good - 責務を分離
// main/services/systemInfo.ts
export const getCpuUsage = async (): Promise<number> => { /* ... */ }
export const getMemoryInfo = async (): Promise<MemoryInfo> => { /* ... */ }

// main/ipc/system.ts
export const registerSystemHandlers = (): void => {
  ipcMain.handle('system:get-cpu-usage', getCpuUsage)
  ipcMain.handle('system:get-memory-info', getMemoryInfo)
}

// main/index.ts
registerSystemHandlers()
```

---

## 8. パフォーマンス

### 同期APIの使用制限
起動時以外は非同期APIを使用する。

```typescript
// ⚠️ 起動時のみ許容
const config = JSON.parse(fs.readFileSync(configPath, 'utf-8'))

// ✅ 通常時は非同期
const config = JSON.parse(await fs.promises.readFile(configPath, 'utf-8'))
```

### 重い処理のワーカー化
CPU負荷の高い処理はWorker Threadsで実行する。

```typescript
// ✅ Good
import { Worker } from 'worker_threads'

const runHeavyTask = (data: unknown): Promise<Result> => {
  return new Promise((resolve, reject) => {
    const worker = new Worker('./heavy-task-worker.js', {
      workerData: data
    })
    worker.on('message', resolve)
    worker.on('error', reject)
  })
}
```
