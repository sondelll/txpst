# Get Typst
FROM docker.io/ubuntu:latest AS tbuild

WORKDIR /app

RUN apt-get -y update; apt-get -y install wget xz-utils

RUN wget https://github.com/typst/typst/releases/download/v0.13.1/typst-aarch64-unknown-linux-musl.tar.xz

RUN tar -xJf /app/typst-aarch64-unknown-linux-musl.tar.xz


# Build the server
FROM docker.io/golang:1.24-bookworm AS build

WORKDIR /app

COPY txpst .

RUN go build -o ./txpst-server ./app/txpst

# Prep for running
FROM docker.io/debian:bookworm-20250428-slim

COPY --from=tbuild /app/typst-aarch64-unknown-linux-musl/typst /usr/bin/typst

COPY --from=build /app/txpst-server /usr/bin/txpst-server


VOLUME [ "/typ" ]
VOLUME [ "/fonts" ]

WORKDIR /app

ENTRYPOINT [ "txpst-server" ]
