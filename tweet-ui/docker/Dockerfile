FROM node:13-buster

COPY . /app

WORKDIR /app

RUN apt update && apt install libncurses5 -y \
  && chown -R node /app

USER node

RUN npm install

RUN npm run webpack:bundle

ENTRYPOINT [ "npm", "run", "serve"]

