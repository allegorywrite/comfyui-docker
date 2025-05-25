# ComfyUI Docker Environment

このプロジェクトは、ComfyUIとカスタムノードを含むDocker環境を提供します。

## セットアップ

### 1. リポジトリのクローン

```bash
git clone --recursive git@github.com:allegorywrite/comfyui-docker.git
cd comfyui-docker
```

## 構成

- `Dockerfile`: ComfyUIとカスタムノードを含むDockerイメージの定義
- `docker-compose.yml`: Docker Composeの設定
- `custom_nodes.txt`: インストールするカスタムノードのリスト
- `workflow/`: ワークフローファイルを格納するディレクトリ

## 使用方法

### 2. カスタムノードの設定

`custom_nodes.txt`ファイルを編集して、インストールしたいカスタムノードのGitHubリポジトリURLを追加してください。

```
https://github.com/melMass/comfy_mtb.git
https://github.com/kijai/ComfyUI-KJNodes.git
# 新しいカスタムノードを追加する場合は、ここに追加
```

### 3. ビルドと起動

```bash
# Dockerイメージをビルド
docker compose build

# ComfyUIを起動
docker compose up
```

### 4. アクセス

ブラウザで `http://localhost:8188` にアクセスしてComfyUIを使用できます。

## ディレクトリ構成

- `input/`: 入力ファイル用（ホストとコンテナで共有）
- `output/`: 出力ファイル用（ホストとコンテナで共有）
- `models/`: モデルファイル用（ホストとコンテナで共有）
- `workflow/`: ワークフローファイル（ホストとコンテナで共有）

## デフォルトワークフロー

`workflow/steerable-motion_smooth-n-steady0525.json` がデフォルトワークフローとして設定されます。
ワークフローファイルはホスト側で編集でき、コンテナ再起動時に自動的に反映されます。

## ワークフローファイルの管理

- ワークフローファイルは `workflow/` ディレクトリに配置
- `workflow/steerable-motion_smooth-n-steady0525.json` が存在する場合、自動的にデフォルトワークフローとして設定
- ホスト側でワークフローファイルを編集後、コンテナを再起動すると変更が反映されます

## カスタムノードの追加

新しいカスタムノードを追加する場合：

1. `custom_nodes.txt`にリポジトリURLを追加
2. `docker compose build --no-cache` でイメージを再ビルド
3. `docker compose up` で起動
