# 技術同人誌原稿執筆リファレンス

このドキュメントは、技術同人誌原稿執筆時に必要な情報を素早く検索できるようにまとめたリファレンスです。

---

## プロジェクト構成

```
vrc-cs-meetup-C107/
├── tech-article-outline.md          # 記事全体の構成案
├── articles/                         # 原稿ドラフト（セクションごと）
│   ├── 1-introduction.md            # 1章: はじめに（序論）
│   └── 2-1-actual-streaming-screen.md  # 2.1: 実際の配信画面
├── assets/                          # 画像・図表
│   └── aivtuber-streaming-screenshot.png
├── airi-youtube-live/               # 実装プロジェクト（サブモジュール）
│   ├── exports/                     # ナレッジDBエクスポート
│   │   └── knowledge-db-2025-11-04T11-12-38.json
│   ├── services/
│   │   ├── discord-bot/            # Discord Bot実装
│   │   ├── youtube-bot/            # YouTube Bot実装
│   │   └── knowledge-db/           # ナレッジDB実装
│   ├── apps/
│   │   └── stage-web/              # VRMアバター表示・TTS
│   └── .claude-notes/              # 開発セッションノート
│       └── sessions/
│           ├── 2025-10-10-youtube-integration.md
│           ├── 2025-10-17-youtube-bot-stage-web-integration.md
│           ├── 2025-10-17-knowledge-db-persistent-hooks.md
│           ├── 2025-10-22-knowledge-query-expansion.md
│           └── ...
└── .claude-notes/                   # 原稿執筆セッションノート
    └── sessions/
```

---

## 重要な参照ファイル

### 記事構成

- **`tech-article-outline.md`**: 記事全体の構成案（14ページ想定、8章構成）

### 実装の詳細

#### ナレッジDB

- **場所**: `airi-youtube-live/exports/knowledge-db-2025-11-04T11-12-38.json`
- **内容**: 実際のナレッジDBレコード（宝塚、Factorio、月村了衛等の発言）
- **レコード数**: 約520件
- **用途**: パーソナライズ応答の実例を書く際に参照

#### スキーマ定義

- **場所**: `airi-youtube-live/services/knowledge-db/src/db/schema.ts`
- **テーブル**: `memory_fragments`
  - `id` (UUID)
  - `content` (発言内容)
  - `category` (tech/hobby/game等)
  - `metadata` (JSONB: authorId, source等)
  - `content_vector_1536` (ベクトル)

#### 実装コード

| 機能 | ファイルパス |
|------|------------|
| YouTube Live統合 | `airi-youtube-live/services/youtube-bot/` |
| Discord Bot | `airi-youtube-live/services/discord-bot/` |
| ナレッジDB検索 | `airi-youtube-live/services/knowledge-db/` |
| VRM + TTS | `airi-youtube-live/apps/stage-web/` |

### 開発セッションノート

- **場所**: `airi-youtube-live/.claude-notes/sessions/`
- **主要セッション**:
  - `2025-10-10-youtube-integration.md`: YouTube Live統合の経緯
  - `2025-10-17-youtube-bot-stage-web-integration.md`: YouTube BotとStage-Webの統合
  - `2025-10-17-knowledge-db-persistent-hooks.md`: ナレッジDB永続化フック
  - `2025-10-22-knowledge-query-expansion.md`: クエリ拡張とリランキング

---

## 技術スタック

### データベース・検索

- **PostgreSQL 17**: メインデータベース
- **pgvector (v0.4.0)**: ベクトル検索拡張（Rustベース）
- **Drizzle ORM**: 型安全なデータベース操作
- **HNSW インデックス**: 高速近似最近傍探索

### AI/ML

- **LLM**: OpenRouter経由
  - Claude 3.5 Sonnet（推奨）
  - GPT-4, Gemini等
- **Embeddings**: OpenAI text-embedding-3-small (1536次元)
- **TTS**: ElevenLabs

### VTuber配信

- **YouTube Data API v3**: ライブチャット取得
- **VRM**: 3Dアバター表示（Three.js）
- **OBS**: 配信ソフト + Browser Source

### プラットフォーム統合

- **Discord.js**: Discord API クライアント
- **Node.js**: メッセージ収集・応答生成

---

## ナレッジDB検索方法（参考）

### 検索クエリ例

```bash
# ナレッジDBから「宝塚」関連のレコードを検索
grep -i "宝塚\|takarazuka\|ミュージカル\|舞台" \
  airi-youtube-live/exports/knowledge-db-2025-11-04T11-12-38.json
```

### 検索の工夫（第5章で詳述予定）

1. **ユーザー別検索**: `metadata->>'authorId'`でフィルタリング
2. **類似度閾値調整**: 0.7が最適（実測結果）
3. **カテゴリフィルタ**: tech/hobby/game等で絞り込み
4. **HNSWインデックス**: 16倍高速化

---

## コミットログの参照

```bash
# airi-youtube-liveの開発履歴を確認
cd airi-youtube-live
git log --oneline --all -30

# 特定機能の実装を検索
git log --grep="knowledge" --oneline
git log --grep="youtube" --oneline
```

---

## 先行事例・参考文献

### AI VTuber

- **Neuro-sama**: https://www.twitch.tv/vedal987
- **書籍**: [『AITuberを作ってみたらプロンプトエンジニアリングがよくわかった件』](https://bookplus.nikkei.com/atcl/catalog/24/11/07/01683/)

### ベースプロジェクト

- **AIRI**: https://github.com/moeru-ai/airi
  - 3DアバターとDiscord/Telegram/ブラウザで会話
  - 既にRAGによるナレッジDB検索機能が実装済み

### フォークプロジェクト

- **本プロジェクト**: https://github.com/s-sasaki-earthsea-wizard/airi-youtube-live
  - YouTube Live配信対応
  - Discordユーザー履歴のナレッジDB化

### 技術資料

- **PostgreSQL pgvector**: https://github.com/pgvector/pgvector
- **OpenAI Embeddings API**: https://platform.openai.com/docs/guides/embeddings
- **Discord.js**: https://discord.js.org/
- **YouTube Data API v3**: https://developers.google.com/youtube/v3
- **RAG論文**: https://arxiv.org/abs/2005.11401
- **HNSW論文**: https://arxiv.org/abs/1603.09320

---

## 画像・図表

### 既存の画像

- `assets/aivtuber-streaming-screenshot.png`: 実際の配信画面

### 今後作成予定の図表

- システムアーキテクチャ図（第4章）
- RAG検索フロー図（第5章）
- YouTube Live統合フロー図（第6章）

---

## 執筆時のポイント

### 文体

- 砕けた調子（技術同人誌向け）
- 技術的正確性は維持
- 具体例を活用（実データ参照）

### 先行事例へのリスペクト

- Neuro-samaへの言及
- 既存のRAG実装（AIRI等）の紹介
- プロンプトエンジニアリング手法の評価

### 本プロジェクトのユニークさ

- Discordユーザー履歴のナレッジDB化
- 「その人っぽさ」の実現
- RAG検索の工夫と最適化

---

**更新日**: 2025-11-14
**執筆支援**: Claude Code (Sonnet 4.5)
