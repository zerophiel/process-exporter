# Start from a Debian image with the latest version of Go installed
# and a workspace (GOPATH) configured at /go.
FROM golang:1.15 AS build
#RUN curl -L -s https://github.com/golang/dep/releases/download/v0.5.0/dep-linux-amd64 -o $GOPATH/bin/dep
#RUN chmod +x $GOPATH/bin/dep
ENV GOOS=linux
ENV GOARCH=amd64
ENV CGO_ENABLED=0
RUN git config --global http.sslverify false
WORKDIR /go/src/github.com/ncabatoff/process-exporter
ADD . .
#RUN dep ensure

# Build the process-exporter command inside the container.
RUN make

FROM alpine
RUN apk update && apk add ca-certificates
COPY --from=build /go/src/github.com/ncabatoff/process-exporter/process-exporter /bin/process-exporter

# Run the process-exporter command by default when the container starts.
ENTRYPOINT ["/bin/process-exporter","-config.path","/config/config.yml"]

# Document that the service listens on port 9256.
EXPOSE 9256
