#$argo:{"is-tag":"prod","default":"dev"}
FROM node:18 AS install

ENV HOST=0.0.0.0 PORT=3000
ENV NEXT_PUBLIC_SITETITLE="FITL"
EXPOSE 3000

RUN mkdir -p /app
WORKDIR /app

COPY package.json pnpm-lock.yaml panda.config.ts ./
RUN npm install -g pnpm
RUN pnpm install

COPY . .

# Development Build
# `yarn dev` runs the dev server, which is why we can define the environment variables dynamically at runtime.
FROM install as dev
ENV NEXT_PUBLIC_APPID=FITL
ENV NEXT_PUBLIC_SERVER_URL=https://fitl-parse-server.ovhkube.intuitive-ai.de/graphql
RUN pnpm build
CMD ["pnpm","dev"]

# Production Build
# `yarn build` / `next build` runs the auto-optimization, resulting in the environment variable values
# being baked into the optimized build, which is why we need to define them here instead of at runtime.
FROM install as prod
ENV NEXT_PUBLIC_APPID=FITL
ENV NEXT_PUBLIC_SERVERNAME="https://fitl-parse-server.ovhkube.intuitive-ai.de/graphql"
ENV NEXT_PUBLIC_SERVER_URL=https://fitl-parse-server.ovhkube.intuitive-ai.de/graphql
RUN pnpm build
CMD ["pnpm","start"]
