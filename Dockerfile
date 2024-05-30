FROM golang:1.20-alpine as builder

RUN apk add --no-cache make build-base

WORKDIR /src
COPY go.mod .
COPY go.sum .
ARG CACHE
RUN --mount=type=cache,target="$CACHE" go mod graph | awk '{if ($1 !~ "@") print $2}' | xargs go get
COPY . .
RUN --mount=type=cache,target="$CACHE" make clean && make

FROM docker:dind as release
RUN apk add --no-cache bash ca-certificates curl wget tzdata bind-tools && update-ca-certificates

COPY --from=builder /src/bin /app
COPY docker-entrypoint.sh /app
COPY file/global /app/global

RUN chmod +x /app/docker-entrypoint.sh && \
    mkdir /app/labs
#    useradd -m -s /bin/bash app && \
#    chown -R app:app /app

#USER app
WORKDIR /app

RUN touch .env
RUN touch init.sh

ENTRYPOINT ["./docker-entrypoint.sh"]
