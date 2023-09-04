# ビルド イメージを設定
FROM node:18.12-alpine AS base

# 作業ディレクトリを設定
WORKDIR /app

# 依存関係をコピーしてインストール
COPY package.json package-lock.json ./
RUN npm install

# アプリケーションのソースコードをコピー
COPY . .
RUN npm run build

# dev ステージを追加
FROM node:18.12-alpine AS dev

# 作業ディレクトリを設定
WORKDIR /app

# 依存関係をコピー
COPY package.json package-lock.json ./
RUN npm install

# アプリケーションのソースコードとビルドアーティファクトをコピー
COPY --from=base /app/.next ./.next
COPY --from=base /app/public ./public

# アプリケーションを開発モードで実行
CMD ["npm", "run", "dev"]

# 本番用のイメージを作成
FROM node:18.12-alpine AS prod

# 作業ディレクトリを設定
WORKDIR /app

# 依存関係をコピー
COPY package.json package-lock.json ./
RUN npm ci --only=production

# アプリケーションのソースコードとビルドアーティファクトをコピー
COPY --from=base /app/package.json package.json
COPY --from=base /app/.next ./.next
COPY --from=base /app/next.config.js next.config.js
COPY --from=base /app/node_modules node_modules
COPY --from=base /app/public ./public

# アプリケーションを本番モードで実行
CMD ["npm", "run", "start"]

