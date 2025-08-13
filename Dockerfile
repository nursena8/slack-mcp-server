FROM golang:1.23 AS build

ENV CGO_ENABLED=0
WORKDIR /src

# Preload modules for better caching
COPY go.mod go.sum ./
RUN go mod download

# Copy the rest and build
COPY . .
RUN go build -ldflags="-s -w" -o /out/mcp-server ./cmd/slack-mcp-server

# ---- Production stage ----
FROM alpine:3.20

# Certificates only; keep image small
RUN apk add --no-cache ca-certificates curl

# Copy binary
COPY --from=build /out/mcp-server /usr/local/bin/mcp-server

# Railway provides $PORT. Default to 3001 for local runs.
ENV PORT=3001
EXPOSE 3001

# IMPORTANT: bind to $PORT so Railway sees the service as healthy
CMD ["sh", "-c", "mcp-server --transport sse --port ${PORT}"]
