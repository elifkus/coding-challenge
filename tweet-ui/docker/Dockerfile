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

#horrible workaround for post url not being replaced with $BASE_URL (even though $BASE_URL gets picked up by the application)
RUN sed -i "s|http://localhost:8080|$base_url|g" dist/bundle.js

FROM node:13-slim

USER node

COPY --from=builder /app /app

WORKDIR /app

ENTRYPOINT [ "npm", "run", "serve"]

