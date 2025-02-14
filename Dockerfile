FROM docker.io/ubuntu:latest AS tbuild

WORKDIR /app

RUN apt-get -y update; apt-get -y install wget xz-utils

RUN wget https://github.com/typst/typst/releases/download/v0.12.0/typst-x86_64-unknown-linux-musl.tar.xz

RUN tar -xJf /app/typst-x86_64-unknown-linux-musl.tar.xz


FROM docker.io/golang:1.24-bookworm

COPY --from=tbuild /app/typst-x86_64-unknown-linux-musl/typst /usr/bin/typst

WORKDIR /app/build

COPY server .

COPY ./typ/doc.typ /app/doc.typ
COPY ./typ/template.typ /app/template.typ
COPY ./ostp_black.svg /app/ostp_black.svg

RUN go build -o ./txpst .

RUN mv ./txpst /usr/bin/txpst

COPY ./Arial.ttf /usr/fonts/Arial.ttf

WORKDIR /app

ENTRYPOINT [ "txpst" ]
