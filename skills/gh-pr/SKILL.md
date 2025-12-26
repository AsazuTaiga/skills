---
name: gh-pr
description: Create or update GitHub pull requests with gh CLI. Use when the user asks to 作成/更新 PR, draft PR, or PR本文生成. Generates Japanese PR title/body from git diffs, defaults base branch to next_release (configurable), detects UI changes for screenshots, extracts AME-XXXX tickets, and requires explicit user confirmation before any git push/gh pr create/edit.
---

# Gh Pr

GitHub PRの作成/更新を自動化する。現在ブランチの差分を分析し、日本語のPRタイトルと本文を生成して、ユーザー確認後にghで反映する。

## Workflow

### 1) 入力の解釈
以下の意図を抽出する：
- 新規作成 or 既存PR更新（`update <PR番号>`）
- `--base <branch>` 指定の有無（未指定なら `next_release`）
- `--draft` の有無

不明点があれば先に確認する（PR番号、ベースブランチなど）。

### 2) 事前チェック
最小限の安全確認を行う：
- gh認証状態（必要なら `gh auth status` を提案）
- ベースブランチの存在（`git show-ref --verify refs/heads/<base>` など）
- ローカルの変更がコミット済みか（`git status -sb`）

### 3) 差分情報の収集
以下を収集して要約する（大きい差分は要約・主要箇所に集中）：
- `git diff <base>...HEAD`
- `git diff <base>...HEAD --stat`
- `git log --oneline <base>..HEAD`
- 主要変更ファイルの内容（必要な範囲だけ読む）

除外推奨：バイナリ、自動生成、巨大ファイル。

### 4) 付加情報の抽出
- **チケット番号**: コミットメッセージから `AME-XXXX` を抽出
- **UI変更検出**: `*.tsx`、`components/`、スタイル関連ファイルの変更があればUI変更とみなす

UI変更があればスクリーンショット/動画の記載を促す。

### 5) PR本文の生成（日本語）
テンプレは以下を使用（必要に応じて簡潔化）：

```markdown
## 🎯 このPRの目的
[変更の主な目的を簡潔に記述]

## ✨ 主な変更点
- [技術的な変更内容を具体的に列挙]

## 🛠️ 補助的な作業
- [リファクタリング、型定義の追加など]

## 🤔 なぜこの変更が必要か？
[ビジネス価値や技術的な理由]

## ✅ レビュワーへのお願い
[特に注意して見てほしい箇所]

## 📝 関連ドキュメント
[AME-XXXX を列挙]

## 🖼️ スクリーンショット/動画
[UI変更時のみ]

## ❌ やらないこと
[今回のスコープ外の内容]
```

### 6) プレビューと修正
必ず以下を表示して確認を取る：
- ベースブランチ
- Draft/通常
- PRタイトル案
- PR本文全文
- 抽出したチケット番号
- UI変更検出結果

ユーザーの修正を反映し、最終版を確定する。

### 7) 実行前の明示確認（必須）
**グローバルポリシー準拠**で、実行前に以下を提示して「y/N」で確認する：
- リポジトリ絶対パス
- 現在ブランチ
- `git status -sb`
- `git diff --staged`
- `git diff`
- 実行予定コマンド（1行1コマンド）

ユーザーが明示的に「はい」するまで、git push / gh コマンドは**実行しない**。

### 8) 実行
承認後に“一度だけ”実行する（再試行やループは禁止）。

**新規作成**
- 必要なら `git push -u origin <branch>`
- `gh pr create --title "<タイトル>" --body "<本文>" --base <base>`
- Draftの場合は `--draft` を付与

**更新**
- `gh pr edit <PR番号> --body "<本文>"`

実行後は結果（成否、`gh pr view` の要約など）を簡潔に報告する。

## 出力の品質ガイド
- PR本文は日本語で、読みやすい箇条書きにする
- 変更点は「何を」「どう変えたか」が分かる具体性
- レビュアーへのお願いは1〜2点に絞る
- 余計な長文は避ける（要点重視）
