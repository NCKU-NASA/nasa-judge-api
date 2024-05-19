FROM golang:1.20 as builder

RUN apt-get update && apt-get full-upgrade -y && apt-get install make -y

WORKDIR /src
COPY go.mod .
COPY go.sum .
ARG CACHE
RUN --mount=type=cache,target="$CACHE" go mod graph | awk '{if ($1 !~ "@") print $2}' | xargs go get
COPY . .
RUN --mount=type=cache,target="$CACHE" make clean && make

FROM debian:latest as release

RUN apt-get update && apt-get full-upgrade -y && apt-get install ca-certificates curl wget -y && update-ca-certificates

COPY --from=builder /src/bin /app
COPY docker-entrypoint.sh /app

RUN chmod +x /app/docker-entrypoint.sh && \
    mkdir /app/labs
#    useradd -m -s /bin/bash app && \
#    chown -R app:app /app

#USER app
WORKDIR /app

RUN touch .env
RUN touch init.sh

ENTRYPOINT ["./docker-entrypoint.sh"]
