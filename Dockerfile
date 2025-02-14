FROM docker.io/debian:bookworm as tbuild

WORKDIR /app

RUN curl -fSsl https://github.com/typst/typst/releases/download/v0.12.0/typst-x86_64-unknown-linux-musl.tar.xz
RUN tar -xf /app/typst-x86_64-unknown-linux-musl.tar.xz


FROM docker.io/golang:1.24-bookworm AS build

WORKDIR /app

COPY server .

RUN go build -o ./txpst .

FROM docker.io/alpine:latest

WORKDIR /app

COPY --from=build /app/txpst /usr/bin/txpst
COPY --from=tbuild /app/typst-x86_64-unknown-linux-musl/typst /usr/bin/typst

COPY ./build/typst /usr/bin/typst
COPY ./typ/doc.typ /app/doc.typ
COPY ./typ/template.typ /app/template.typ
COPY ./ostp_black.svg /app/ostp_black.svg

COPY ./Arial.ttf /usr/fonts/Arial.ttf

ENTRYPOINT [ "txpst" ]
