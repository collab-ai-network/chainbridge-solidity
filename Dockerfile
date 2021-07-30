FROM ethereum/client-go:alltools-stable AS go-ethereum

FROM node:16-alpine

RUN apk add --no-cache bash make sudo

ADD . /app/chainbridge-solidity
COPY --from=go-ethereum /usr/local/bin/abigen /usr/local/bin/abigen

WORKDIR /app/chainbridge-solidity

RUN set -ex \
    && npm install . \
    && npx truffle compile