FROM node:13-buster AS builder

ARG base_url
RUN test -n "$base_url" || (echo "Please provide a build-argument 'base_url'" && false)

RUN apt update && apt install libncurses5 -y

COPY . /app

WORKDIR /app

RUN chown -R node /app

USER node

RUN npm install

ENV BASE_URL $base_url

RUN npm run webpack:bundle


FROM node:13-slim

USER node

COPY --from=builder /app /app

WORKDIR /app

ENTRYPOINT [ "npm", "run", "serve"]

