# Get Typst
FROM docker.io/ubuntu:latest AS tbuild

WORKDIR /app

RUN apt-get -y update; apt-get -y install wget xz-utils

RUN wget https://github.com/typst/typst/releases/download/v0.12.0/typst-aarch64-unknown-linux-musl.tar.xz

RUN tar -xJf /app/typst-aarch64-unknown-linux-musl.tar.xz


# Build the server
FROM docker.io/golang:1.24-bookworm AS build

WORKDIR /app

COPY server .

RUN go build -o ./txpst .

# Prep for running
FROM docker.io/debian:bookworm-slim

COPY --from=tbuild /app/typst-aarch64-unknown-linux-musl/typst /usr/bin/typst
COPY --from=build /app/txpst /usr/bin/txpst

WORKDIR /usr/fonts

COPY ./fonts/* ./


WORKDIR /app

COPY ./typ/doc.typ /app/doc.typ
COPY ./typ/template.typ /app/template.typ
COPY ./ostp_black.svg /app/ostp_black.svg


ENTRYPOINT [ "txpst" ]
