FROM golang:1.17

LABEL maintainer="malenelu@stud.ntnu.no"

WORKDIR /go/src/app
ARG dbsecret
ENV DBSECRET=$dbsecret

EXPOSE 8080


COPY ./admin /go/src/app/admin
COPY ./cmd /go/src/app/cmd
COPY ./consts /go/src/app/consts
COPY ./database /go/src/app/database
COPY ./frontend /go/src/app/frontend
COPY ./structs /go/src/app/structs
COPY ./userform /go/src/app/userform
COPY ./go.mod /go/src/app/go.mod

RUN go mod tidy
RUN CGO_ENABLED=0 GOOS=linux go build -a -ldflags '-extldflags "-static"' -o server svarteliste/cmd

CMD ["./server"]
