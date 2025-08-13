# ---- Build stage ----
FROM golang:1.23-bullseye AS build
# (1) ensure git & certs exist for fetching modules
RUN apt-get update && apt-get install -y --no-install-recommends git ca-certificates \
  && rm -rf /var/lib/apt/lists/*

# (2) sane Go env; use proxy + verbose downloads
ENV CGO_ENABLED=0 \
    GO111MODULE=on \
    GOPROXY=https://proxy.golang.org,direct \
    GOSUMDB=sum.golang.org \
    GOTOOLCHAIN=auto

WORKDIR /src

# (3) copy mod files first for better caching
COPY go.mod go.sum ./

# (4) download modules *verbosely* so we can see the failing module
RUN go mod download -x

# (5) now copy sources and build
COPY . .
RUN go build -ldflags="-s -w" -o /out/mcp-server ./cmd/slack-mcp-server
