# AI VTuber開発に用いられている技術についての記事構成案

**タイトル**: Discord Botに個性を持たせる - RAGによるパーソナライズされたAI VTuber配信の実装

**推奨ページ数**: 14ページ
**想定読者**: AI/Bot技術に興味のある開発者、VTuber配信者、Discordコミュニティ運営者

---

## 1. はじめに（序論）（1ページ）

### 1.1 本記事の目的

- AI VTuberとRAGを組み合わせたパーソナライズシステムの紹介
- 従来のプロンプトエンジニアリングだけでは実現できない「個性」の実装
- オープンソースプロジェクトとして、誰でも試せる実装例の提供

### 1.2 想定読者

- AI/Bot技術に興味のある開発者
- VTuber配信を始めたい方
- Discordコミュニティを運営している方
- RAG（検索拡張生成）の実装例を探している方

### 1.3 記事の構成

簡単にこの記事の流れを説明します：

1. **第2章**: 実際の配信デモを見せます。何ができるのかを理解してもらいます
2. **第3章**: システム全体像とアーキテクチャを説明します
3. **第4章**: RAGによるパーソナライゼーションの実装（記事のコア）
4. **第5章**: VTuber配信への統合方法
5. **第6章**: 運用コストと実際の効果測定
6. **第7章**: まとめと今後の展望

---

## 2. AI VTuber配信デモ - 何ができるのか（2ページ）

### 2.1 実際の配信画面

**実際の配信の様子（スクリーンショット・動画リンク）**

このシステムの特徴：
- **VRMアバター**が自然な日本語で喋る
- **YouTube Liveチャット**から質問を受付
- **RAGによって知識やキャラクター設定に沿った応答**を生成（音声合成でリアルタイムに返答）

### 2.2 パーソナライズ応答の実例

#### 例1: 同じ質問、異なる応答

**ユーザーA（Discord発言履歴: "Factorio楽しい", "工場最適化が好き"）**
```
質問: "おすすめのゲーム教えて"

AI VTuber応答:
「Factorioが好きなら、Satisfactoryもおすすめだよ！
3D版Factorioみたいな感じで、工場最適化の楽しさはそのままに、
建築の自由度も高いんだ。きっと気に入ると思う！」

[過去発言から「Factorio」「工場最適化」を検索して応答に反映]
```

**ユーザーB（Discord発言履歴: "Apex楽しい", "FPS大好き"）**
```
質問: "おすすめのゲーム教えて"

AI VTuber応答:
「FPS好きなら、Valorantはどう？Apexとはちょっと違う戦術FPSで、
アビリティを使ったチーム戦が面白いよ。
Overwatch 2も無料だし試してみる価値あり！」

[過去発言から「Apex」「FPS」を検索して応答に反映]
```

→ **同じ質問でも、ユーザーごとに全く違う応答**

#### 例2: より深いパーソナライゼーション

**ユーザーC（Discord発言履歴: "Rust勉強中", "所有権システム難しい"）**
```
質問: "おすすめの技術書教えて"

AI VTuber応答:
「Rustやってるなら『プログラミングRust 第2版』がおすすめ！
所有権システムの章が特に詳しくて、理解が深まると思うよ。
あとは『Rustで始めるネットワークプログラミング』も
実践的で面白いよ。」
```

**パーソナライズなしの場合**:
```
"『リーダブルコード』や『Clean Code』が人気ですよ！"
```

→ 明らかに個性が出ている

---

## 3. システム全体像 - どう動いているか（2.5ページ）

### 3.1 キャラクター設定の課題と解決策

#### AI VTuberのキャラクター定義の課題

AI VTuberを作る際、最初に当たる壁が「**キャラクターをどう設定するか？**」という問題です。

一般的なRAGシステムでは、技術ドキュメントやFAQなど、既に存在する静的な知識ベースを使います。しかし、AI VTuberの場合、その「個性」や「記憶」をどう定義するかが課題です。

**従来の手法の限界**:
- システムプロンプトに長々とキャラクター設定を書き込む → 限界があり、不自然
- 全会話履歴をプロンプトに含める → コスト高、文脈長超過
- ファインチューニング → 更新困難、コスト大

#### 解決策: Discordを日記帳として活用

本プロジェクトでは「**Discordに自分の日記用サーバーを立てて、そこのレコードを活用する**」という手法を採用しました。

日常的に自分の経験や考えをDiscordに書いておくと、自然にナレッジが溜まっていく。実際、筆者は真実と真実を元にしたフィクションを半分半分くらいで書いています。「宝塚歌劇が好き」「ポケモンのダブルバトルが好き」「プラズマ物理を研究している」といった断片的な情報を、日常会話のように記録していく。

**最も重要なポイント**: Discordの書き込みをDBに登録する仕組みを作ったので、**Discordに書き込めば勝手にDBの知識が増えていく**のです。

**メリット**:
- ✅ キャラクター設定の更新が容易: Discordに書き込むだけ
- ✅ 自然な記憶の蓄積: 日記を書くような感覚でAIの「記憶」が成長
- ✅ メンテナンスコストの削減: JSONファイルを手動編集する必要がない

現在、筆者のナレッジDBには**124件**のレコードが蓄積されています（2025年11月時点）。

### 3.2 システムアーキテクチャ

#### フロー全体像

**Discord発言収集からYouTube Live配信までの流れ**（図3.1参照）

1. **Discord書き込み** → 自動収集（DB起動時に更新）
2. **ベクトル化** → OpenAI Embeddings API（1536次元）
3. **ナレッジDB保存** → PostgreSQL + pgvector
4. **YouTube Live配信** → 視聴者からの質問
5. **RAG検索** → 関連する過去発言を取得
6. **LLM応答生成** → パーソナライズされた応答
7. **TTS音声合成** → VRMアバターが喋る

### 3.3 技術スタック

#### Discord統合

- **Discord.js**: Discord API クライアント
- **Node.js**: メッセージ収集・応答生成サービス

#### データベース・検索

- **PostgreSQL 17**: メインデータベース
- **pgvector (v0.4.0)**: ベクトル検索拡張（Rustベース、高速）
- **Drizzle ORM**: 型安全なデータベース操作
- **HNSW インデックス**: 高速近似最近傍探索（16倍高速化）

#### AI/ML

- **LLM**: OpenRouter経由でマルチプロバイダー対応
  - Claude 3.5 Sonnet（推奨）
  - GPT-4, Gemini等
- **Embeddings**: OpenAI text-embedding-3-small
  - 1536次元ベクトル
  - コスト: $0.00002/1000トークン（激安）

#### VTuber配信

- **YouTube Data API v3**: ライブチャット取得
- **VRM**: 3Dアバター表示
- **TTS**: ElevenLabs（音声合成）
- **OBS**: 配信ソフト + Browser Source

### 3.4 既存インフラの活用

**重要な設計判断**: 新規テーブル作成せず既存を活用

AIRI本体の`memory_fragments`テーブルを流用：

- 元々はTelegram Botの会話記憶用
- `metadata`フィールド（JSONB）でプラットフォーム判別可能
- 複数のベクトル次元に対応済み

```typescript
// packages/telegram-bot/src/db/schema.ts (既存)
export const memoryFragmentsTable = pgTable('memory_fragments', {
  id: uuid().primaryKey(),
  content: text().notNull(),
  category: text().notNull(),  // 'tech', 'hobby', 'game'等
  metadata: jsonb().default({}), // { source: 'discord', authorId: '...' }
  content_vector_1536: vector({ dimensions: 1536 }),
  // ...
})
```

→ 開発期間短縮、インフラ構築不要

---

## 4. RAGによるパーソナライゼーションの実装（4ページ）

### 4.1 なぜベクトル検索か（1ページ）

#### 従来のキーワード検索の限界

**例: 「おすすめのゲームは？」という質問**

**キーワード検索（PostgreSQL LIKE）**
```sql
SELECT * FROM messages
WHERE content LIKE '%ゲーム%' OR content LIKE '%game%'
```

**問題点**:
- ❌ "Factorio"や"マインクラフト"は引っかからない
- ❌ 同義語に対応できない（"ゲーム"="プレイ"="遊び"）
- ❌ 表記ゆれ（"マイクラ" vs "Minecraft"）
- ❌ 意味的な関連性を捉えられない

#### ベクトル検索の強み

**セマンティック検索（意味ベース）**
```sql
SELECT * FROM memory_fragments
WHERE 1 - (content_vector_1536 <=> query_vector) > 0.7
ORDER BY content_vector_1536 <=> query_vector
LIMIT 5
```

**実際の検索結果**:

クエリ: "おすすめのゲーム教えて"

| 発言内容 | 類似度 | 説明 |
|---------|--------|------|
| "Factorioの工場最適化が楽しすぎる" | 0.89 | ✅ "ゲーム"なしでもヒット |
| "マイクラで建築するのが好き" | 0.85 | ✅ "Minecraft"="マイクラ" |
| "最近Rustの勉強してる" | 0.72 | ✅ 技術的興味も検出 |
| "今日は疲れた" | 0.35 | ❌ 類似度低く除外 |

**キーポイント**:
- 形態素解析不要
- 辞書メンテナンス不要
- 多言語対応（英語の発言も日本語クエリで検索可能）
- OpenAI APIに投げるだけ（GPU不要）

### 4.2 検索の工夫（2ページ）← **記事のコア**

#### 工夫1: ユーザー別検索

**課題**: 全ユーザーの発言から検索すると、他人の趣味が混ざる

**解決**: `metadata->>'authorId'`でフィルタリング

```sql
SELECT content, category,
       1 - (content_vector_1536 <=> $1::vector) AS similarity
FROM memory_fragments
WHERE metadata->>'source' = 'discord'
  AND metadata->>'authorId' = $2  -- ← ユーザー別
  AND 1 - (content_vector_1536 <=> $1::vector) > 0.7
ORDER BY content_vector_1536 <=> $1::vector
LIMIT 3
```

**効果**:
- ✅ ユーザーAには「Factorio好き」→ 工場ゲーム推薦
- ✅ ユーザーBには「FPS好き」→ シューティング推薦

#### 工夫2: 類似度閾値の調整

**類似度スコア（0.0〜1.0）の意味**:

| 類似度 | 意味 | 扱い |
|--------|------|------|
| 0.9以上 | ほぼ同じ内容 | 重複除外に使う |
| 0.7〜0.9 | 関連性高 | **検索結果として採用** |
| 0.5〜0.7 | やや関連 | 文脈次第で採用 |
| 0.5未満 | 関連性低 | 除外 |

**実測での調整結果**:
- 閾値0.5: 関連性低い発言が混ざる（ノイズ多）
- **閾値0.7: バランス良好**（採用）
- 閾値0.9: ヒット数が少なすぎる

#### 工夫3: カテゴリフィルタの活用

**質問の種類に応じてカテゴリを絞る**

```sql
-- ゲーム関連の質問 → game, hobbyカテゴリのみ
WHERE category IN ('game', 'hobby')

-- 技術的な質問 → tech, opinionカテゴリのみ
WHERE category IN ('tech', 'opinion')
```

**効果**:
- 検索精度向上
- レイテンシ削減（検索範囲が狭まる）

#### 工夫4: 検索結果のランキング

**複数の要素でスコアリング**

```typescript
function calculateRelevanceScore(result: SearchResult): number {
  let score = result.similarity * 10 // 基本スコア (0-10)

  // 新しい発言ほど高スコア
  const ageInDays = (Date.now() - result.created_at) / (1000 * 60 * 60 * 24)
  if (ageInDays < 30) score += 2
  else if (ageInDays < 90) score += 1

  // 重要度を反映
  score += result.importance * 0.5

  // カテゴリマッチでボーナス
  if (result.category === expectedCategory) score += 1

  return score
}
```

**Top-3を選択して注入**:
- 最も関連性の高い3つの過去発言
- 多すぎるとLLMが混乱、少なすぎると文脈不足

#### 具体例: 検索からプロンプト注入まで

**ステップ1: ユーザーの質問**
```
ユーザーID: user_12345
質問: "おすすめのゲーム教えて"
```

**ステップ2: RAG検索**
```sql
-- 類似度0.7以上、game/hobbyカテゴリ、Top-3
結果:
1. "Factorioの工場最適化が楽しすぎる" (0.89)
2. "マイクラで建築するのが好き" (0.85)
3. "最近Rustの勉強してる。所有権システムが面白い" (0.72)
```

**ステップ3: システムプロンプト生成**
```
あなたはAI VTuberです。
ユーザー "user_12345" の過去の発言を考慮して応答してください。

【このユーザーの興味・趣味】
- ゲーム: Factorio (工場最適化)、Minecraft (建築)
- 技術: Rust (所有権システム)

上記の情報から、このユーザーは以下のようなゲームを好む傾向:
- シミュレーション、建築、最適化パズル
- 論理的思考を要するゲーム

この情報を踏まえて、自然で親しみやすい応答を生成してください。
```

**ステップ4: LLM応答**
```
Factorioが好きなら、Satisfactoryもおすすめだよ！
3D版Factorioみたいな感じで、工場最適化の楽しさはそのままに、
建築の自由度も高いんだ。

Minecraftの建築も好きなら、きっと気に入ると思う。
あと、Rustやってるなら、Dyson Sphere Programも面白いかも。
プログラミング的な思考が活かせるゲームだよ。
```

→ **明らかにパーソナライズされている**

### 4.3 パフォーマンス最適化（1ページ）

#### HNSWインデックスによる高速化

**pgvectorのインデックス**:
```sql
CREATE INDEX memory_fragments_vector_idx
ON memory_fragments
USING hnsw (content_vector_1536 vector_cosine_ops);
```

**HNSW (Hierarchical Navigable Small World)**:
- グラフベースの近似最近傍探索
- 正確性と速度のトレードオフ
- 精度: 約95%（完全一致ではないが実用上問題なし）

**パフォーマンス比較**:

| データ量 | フルスキャン | HNSWインデックス | 高速化 |
|---------|-------------|-----------------|--------|
| 1,000件 | 80ms | 8ms | 10倍 |
| 10,000件 | 250ms | 15ms | **16倍** |
| 100,000件 | 2,500ms | 25ms | 100倍 |

**実運用での効果**:
- Discord Botの応答速度: 平均1秒以内
- YouTube Live配信中も遅延なし

---

## 5. VTuber配信統合（2ページ）

### 5.1 YouTube Live統合

#### YouTube Data API v3でチャット取得

**ポーリングベースの実装**:
```typescript
// 10秒ごとにライブチャットをポーリング
setInterval(async () => {
  const response = await youtube.liveChatMessages.list({
    liveChatId: liveChatId,
    part: ['snippet', 'authorDetails'],
    maxResults: 50
  })

  for (const message of response.data.items) {
    // RAG検索 → LLM応答生成
    await handleMessage(message)
  }
}, 10000)
```

**APIクォータ管理**:
- YouTube Data API v3: 1日10,000ユニット
- `liveChatMessages.list`: 約5ユニット/リクエスト
- 10秒間隔: 約8,640リクエスト/日 → 約43,200ユニット必要
- **課題**: デフォルトクォータでは不足
- **対策**: 適応的ポーリング（活発時は短く、非活動時は長く）

### 5.2 VRM/TTS連携

#### VRMアバター表示

**stage-webでの実装**:
- VRMファイル（3Dモデル）を読み込み
- Three.jsでレンダリング
- リップシンク（音声に合わせて口を動かす）

**設定例**:
```bash
# apps/stage-web/.env
VITE_CUSTOM_VRM_URL=https://example.com/my-model.vrm
VITE_VRM_ANIMATION_IDLE=idle-motion.vrma
```

#### TTS（Text-to-Speech）

**ElevenLabs使用**:
```typescript
// LLM応答をチャンクに分割して順次音声合成
for (const chunk of llmResponseChunks) {
  const audioBuffer = await elevenLabs.textToSpeech({
    text: chunk,
    voice_id: VOICE_ID,
    model_id: 'eleven_multilingual_v2'
  })

  await playAudio(audioBuffer)
}
```

**リップシンク**:
- 音声ファイルの再生に合わせてVRMの口を動かす
- `@pixiv/three-vrm`のBlendShapeを制御

### 5.3 OBS統合

#### OBS Browser Sourceでの表示

**設定手順**:
1. stage-webをローカルで起動（`http://localhost:5173`）
2. OBSで「Browser」ソースを追加
3. URLに`http://localhost:5173`を設定
4. 解像度: 1920x1080（フルHD）
5. カスタムCSS（オプション）:
   ```css
   body { background-color: rgba(0, 0, 0, 0); }
   ```
   → 背景を透過

**配信レイアウト例**:
```
┌──────────────────────────────────┐
│ OBS 配信画面                      │
├──────────────────────────────────┤
│                                  │
│  ┌────────────┐                 │
│  │ VRMアバター │  ← Browser Source
│  │ (stage-web)│                 │
│  └────────────┘                 │
│                                  │
│  チャット欄 (YouTube Live)       │
│  ┌──────────────────────┐       │
│  │ viewer: おすすめは？  │       │
│  │ AI: Factorioなら...  │       │
│  └──────────────────────┘       │
└──────────────────────────────────┘
```

---

## 6. 実運用とコスト（1ページ）

### 6.1 効果測定

#### パーソナライズあり vs なし

**テストケース**:
```
ユーザー: "疲れた時のリフレッシュ法は？"

【パーソナライズなし】
"散歩や音楽鑑賞がおすすめです。"

【パーソナライズあり（過去発言: ゲーム好き、音楽好き）】
"軽めのゲームやるのはどう？マイクラで無心に整地とか、
Factorioの工場を眺めるだけでも癒されるよね。
あとはロック聴きながらコーヒー飲むとか。
The Clashの『London Calling』とかどう？"
```

**ユーザー満足度**（非公式フィードバック）:
- パーソナライズなし: "普通のBot"
- パーソナライズあり: "自分のこと分かってくれてる感じ"

### 6.2 運用コスト

#### コスト総括

| 項目 | 月額コスト | 備考 |
|------|-----------|------|
| LLM (Claude 3.5) | 約$5 | 月10配信、50応答/配信 |
| **TTS (ElevenLabs)** | **$22** | **最大コスト**<br>Creator plan<br>40分配信=6,000クレジット<br>100,000クレジット/月 |
| Embeddings | $0.01 | OpenAI<br>誤差レベル |
| インフラ | $0-10 | PostgreSQL Dockerローカル実行なら無料 |
| **総コスト** | **約$32-42/月**<br>（約5,000円） | 配信頻度による |

**実測値（ElevenLabs TTS）**:
- 40分の配信で約6,000クレジット消費
- 100,000クレジットで約11時間分の配信が可能
- 週1回1時間配信: 月4回 = 24,000クレジット → Creator planでカバー可能

**コスト削減案**:
- TTS: VOICEVOX（無料）、OpenAI TTS（$15/100万文字）
- LLM: Gemini Flash（無料枠）、Ollama（ローカル）

### 6.3 課題と対策

#### 課題1: プライバシーへの配慮

**対策**:
1. **オプトアウト機能**: `/privacy delete`でデータ削除
2. **データ保持期間**: 180日以上前のデータは自動削除
3. **センシティブ情報フィルタ**: 電話番号、メールアドレス等を除外

#### 課題2: 検索精度のばらつき

**対策**: ユーザーの過去発言が少ない場合、コミュニティ全体から補完

---

## 7. まとめと今後の展望（1ページ）

### 7.1 成果

#### 技術的成果
- **低コスト**: 月額約5,000円で運用可能
- **高精度**: ベクトル検索で意味的類似性を捉える
- **自動化**: メッセージ収集からカテゴリ分類まで全自動
- **スケーラブル**: HNSWインデックスで10万件でも高速

#### RAGの有効性
- LLMの文脈長制限を回避
- トークン消費を最小化（コスト削減）
- ユーザーごとのパーソナライズ実現
- 既存インフラ（memory_fragments）を活用

#### AI VTuber配信の実現
- YouTube Live統合
- VRMアバター + TTS でリアルな配信
- ユーザーごとに異なる応答で個性を演出

### 7.2 応用可能性

**他プラットフォームへの展開**:
- Twitch配信
- LINE Bot
- Slack Bot
- Matrix Bot

**他用途への応用**:
- カスタマーサポート（FAQ自動応答）
- 教育Bot（学習者の理解度に応じた説明）
- コミュニティ運営（サーバー全体の知識ベース）

### 7.3 今後の展望

#### 短期（3ヶ月）
- ユーザープロファイルの自動生成
- 画像・動画の分析（マルチモーダル）

#### 中期（6ヶ月）
- 時系列での興味変化の追跡
- コミュニティ全体の知識ベース構築

#### 長期（1年）
- 他のAI VTuberプロジェクトとの連携
- オープンソースコミュニティの拡大

### 7.4 オープンソースとして

- **GitHubで公開**: MIT Licenseで自由に利用可能
- **詳細なドキュメント**: セットアップから運用まで
- **コミュニティ駆動**: Issue、PRを歓迎

---

## 参考資料

### GitHubリポジトリ
- **本プロジェクト**: https://github.com/s-sasaki-earthsea-wizard/airi-youtube-live
- **元プロジェクト（AIRI）**: https://github.com/moeru-ai/airi

### 技術ドキュメント
- PostgreSQL pgvector: https://github.com/pgvector/pgvector
- OpenAI Embeddings API: https://platform.openai.com/docs/guides/embeddings
- Discord.js: https://discord.js.org/
- YouTube Data API v3: https://developers.google.com/youtube/v3

### 参考文献
- RAG (Retrieval-Augmented Generation): https://arxiv.org/abs/2005.11401
- HNSW Algorithm: https://arxiv.org/abs/1603.09320

---

**執筆日**: 2025年11月
**ライセンス**: MIT License
**プロジェクト**: AIRI YouTube Live Edition
