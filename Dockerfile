FROM docker.io/golang:1.23.6-alpine3.21 AS build

WORKDIR /app

COPY server .

RUN go build -o ./txpst .

FROM docker.io/alpine:latest

WORKDIR /app

COPY --from=build /app/txpst /usr/bin/txpst

COPY ./build/typst /usr/bin/typst
COPY ./typ/doc.typ /app/doc.typ
COPY ./typ/template.typ /app/template.typ
COPY ./ostp_black.svg /app/ostp_black.svg

COPY ./Arial.ttf /usr/fonts/Arial.ttf

ENTRYPOINT [ "txpst" ]
