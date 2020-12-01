# Use builder image to build and do initial config
FROM golang:alpine as builder
ENV GOOS=linux GOARCH=amd64 CGO_ENABLED=0
ADD . /go
RUN apk add --no-cache git
RUN go get github.com/bwmarrin/discordgo
RUN go get github.com/go-sql-driver/mysql
RUN go get "4d63.com/tz"
RUN go get "golang.org/x/net/idna"
RUN go build -a -installsuffix cgo -o sweetie.out ./sweetie
RUN go build -a -installsuffix cgo -o updater.out ./updater

FROM alpine:latest
RUN apk add --no-cache ca-certificates
COPY --from=builder /go/sweetie.out /sweetie
COPY --from=builder /go/updater.out /updater
ADD selfhost.json /
ADD docs/sweetiebot.sql /
ADD docs/sweetiebot_tz.sql /
ADD docs/web.css /
ADD docs/web.html /
ADD docker_run.sh /
RUN ["chmod", "a=rwx", "docker_run.sh"]
EXPOSE 3010
EXPOSE 3011
CMD ["./docker_run.sh"]