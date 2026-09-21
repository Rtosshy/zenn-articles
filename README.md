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

Zenn CLI に `pull` 相当のコマンドは無い。Zenn 側にしかない内容を手元へ持ってくるには
[投稿データのエクスポート](https://zenn.dev/settings/export)を使う（後述）。同じ slug の
ファイルがこのリポジトリにある限り、そちらが正本になる。

CI による frontmatter 検証も置いていない。`zenn list:articles` は不正な `type` や `emoji`
を素通りさせる（終了コード 0）ため検証に使えず、zenn-cli には lint コマンドが無い。
検証は `npx zenn preview` のブラウザ表示か、デプロイ後の Zenn ダッシュボードで行う。

## 既存記事の取り込み

Web エディタで書いた記事も、**同じ slug のファイルを push すれば上書きで引き継げる**。
Zenn 側を削除する必要は無く、URL・いいね・コメントはそのまま残る。上書き対象かどうかは
[slug](https://zenn.dev/zenn/articles/what-is-slug)（= ファイル名）が一致するかだけで決まる。

1. https://zenn.dev/settings/export から投稿データを zip でダウンロード
2. 中の `articles/` をこのリポジトリの `articles/` へ展開
3. push

連携前に書いた3記事（`d1479a207f8866`, `1260e2b6cd930a`, `1e86d28a41d738`）はこの手順で
取り込み済み。下書きのままだった記事はエクスポートした md に `type` が入っていなかったので、
push 前に frontmatter を確認すること。

本を取り込むときだけ、book ごとに `config.yaml` へ `allow_override: true` が要る。
scraps はエクスポートに含まれるが GitHub 連携の対象外（articles と books のみ）なので、
このリポジトリには置かない。

## 注意点

- **GitHub 連携中、Web エディタでの編集は一時的。** 同じ slug のファイルが push されるたびに
  リポジトリの内容で上書きされる。Web エディタの記事に出る「デプロイされるとこの画面での編集は
  上書きされます」のバナーはこの条件付きの警告で、リポジトリにそのファイルが実在することを
  意味しない。
- **デプロイは slug 一致の upsert のみ。** リポジトリに無い記事がデプロイで消えることはない。
  逆に Zenn 側で記事を削除してもリポジトリにファイルが残っていると次のデプロイで復活するので、
  消すときは両方から消す。
- **公開後にファイル名（slug）を変えない。** 旧 URL の記事が削除され、別記事として新規作成
  された扱いになる。
- 一度に3記事以上を公開しようとすると投稿レート制限に当たることがある。
