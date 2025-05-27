# Get Typst
FROM docker.io/ubuntu:latest AS tbuild

WORKDIR /app

RUN apt-get -y update; apt-get -y install wget xz-utils

RUN wget https://github.com/typst/typst/releases/download/v0.13.1/typst-x86_64-unknown-linux-musl.tar.xz

RUN tar -xJf /app/typst-x86_64-unknown-linux-musl.tar.xz


# Build the server
FROM docker.io/golang:1.24-bookworm AS build

WORKDIR /app

COPY txpst .

RUN go build -o ./txpst-server ./app/txpst

# Prep for running
FROM docker.io/debian:bookworm-20250428-slim

COPY --from=tbuild /app/typst-x86_64-unknown-linux-musl/typst /usr/bin/typst
COPY --from=build /app/txpst-server /usr/bin/txpst-server

WORKDIR /app

#COPY ./typ/doc.typ /app/doc.typ
#COPY ./typ/template.typ /app/template.typ
#COPY ./ostp_black.svg /app/ostp_black.svg

#COPY ./typ/example.typ /app/example.typ

VOLUME [ "/typ" ]
VOLUME [ "/fonts" ]

ENTRYPOINT [ "txpst-server" ]
