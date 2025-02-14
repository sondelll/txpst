FROM docker.io/golang:1.24-bookworm AS build

WORKDIR /app/build

RUN wget https://github.com/typst/typst/releases/download/v0.12.0/typst-x86_64-unknown-linux-musl.tar.xz
RUN tar -xJf ./typst-x86_64-unknown-linux-musl.tar.xz
RUN cp build/typst-x86_64-unknown-linux-musl/typst /app/typst

WORKDIR /app

COPY server .

RUN go build -o ./txpst .

FROM docker.io/alpine:latest

WORKDIR /app

COPY --from=build /app/txpst /usr/bin/txpst
COPY --from=build /app/typst /usr/bin/typst

COPY ./build/typst /usr/bin/typst
COPY ./typ/doc.typ /app/doc.typ
COPY ./typ/template.typ /app/template.typ
COPY ./ostp_black.svg /app/ostp_black.svg

COPY ./Arial.ttf /usr/fonts/Arial.ttf

ENTRYPOINT [ "txpst" ]
