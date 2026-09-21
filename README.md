# zenn-articles

Zenn の記事を [Zenn CLI](https://github.com/zenn-dev/zenn-editor) で管理するリポジトリ。

## セットアップ

Node は Nix の devShell（`nodejs_24`）から供給し、Zenn CLI 自体は `package-lock.json`
でバージョンを固定している。`direnv allow` すれば `node_modules/.bin` にも PATH が通る。

```sh
direnv allow      # もしくは nix develop
npm ci
```

Qiita CLI と違ってログインもトークンも不要。認証は Zenn 側の GitHub App 連携が持つ。

## 使い方

```sh
npx zenn new:article        # articles/<自動生成 slug>.md を作成
npx zenn preview            # localhost:8000 でプレビュー
npx zenn list:articles      # 記事一覧
```

ディレクトリ構成は Zenn 側で決まっている。

| パス | 用途 |
| --- | --- |
| `articles/<slug>.md` | 記事。ファイル名がそのまま slug になる |
| `books/<slug>/` | 本（`config.yaml` + チャプター） |
| `images/` | 画像。`![](/images/foo.png)` と**絶対パス**で参照する。3MB 以内、`.png .jpg .jpeg .gif .webp` のみ |

記事の frontmatter:

```yaml
---
title: ""
emoji: "😸"      # 1文字の絵文字のみ
type: "tech"     # tech（技術記事） or idea（アイデア記事）
topics: []       # 最大5個
published: true  # false なら下書き
---
```

## 公開の仕組み

**このリポジトリに publish 用の GitHub Actions は無い。** Qiita は CLI が API を叩いて
記事を送るのでトークンと workflow が要るが、Zenn は逆で、[Zenn 側に GitHub リポジトリを
連携する](https://zenn.dev/zenn/articles/connect-to-github)と Zenn が登録ブランチを見に来る。
push するだけでデプロイが走り、こちらから送るものは何も無い。

連携は https://zenn.dev/dashboard/deploys から行う。

Zenn CLI に `pull` 相当のコマンドは無い。GitHub 管理の記事についてはこのリポジトリが唯一の
正本で、Zenn 側に編集が戻ってくることはない。

CI による frontmatter 検証も置いていない。`zenn list:articles` は不正な `type` や `emoji`
を素通りさせる（終了コード 0）ため検証に使えず、zenn-cli には lint コマンドが無い。
検証は `npx zenn preview` のブラウザ表示か、デプロイ後の Zenn ダッシュボードで行う。

## 注意点

- **Web エディタで書いた記事とこのリポジトリの記事は別管理。** 既存記事を GitHub 管理へ
  移すには Zenn 側の記事を削除してから同じ slug で push する必要があり、いいね・閲覧数と
  URL の履歴は失われる。連携前に書いた2記事（`d1479a207f8866`, `1260e2b6cd930a`）は
  移行せず Web エディタ管理のまま残す方針。共存はできるので、このリポジトリは新規記事のみ扱う。
- **公開後にファイル名（slug）を変えない。** 旧 URL の記事が削除され、別記事として新規作成
  された扱いになる。
- 一度に3記事以上を公開しようとすると投稿レート制限に当たることがある。
