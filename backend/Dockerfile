# Backend Dockerfile
FROM dart:3.11-sdk as backend-build

WORKDIR /app

# Copy pubspec files
COPY pubspec.yaml pubspec.lock ./
RUN dart pub get

# Copy source code
COPY bin ./bin
COPY lib ./lib

# Compile for production
RUN dart compile exe bin/server.dart -o bin/server

# Runtime image
FROM debian:bookworm-slim

RUN apt-get update && apt-get install -y --no-install-recommends \
    libsqlite3-0 \
    libsqlite3-dev \
    && rm -rf /var/lib/apt/lists/* \
    && ln -sf /usr/lib/x86_64-linux-gnu/libsqlite3.so.0 /usr/lib/x86_64-linux-gnu/libsqlite3.so

WORKDIR /app

# Copy compiled binary
COPY --from=backend-build /app/bin/server ./bin/server

EXPOSE 8080

ENTRYPOINT ["./bin/server"]
CMD ["--host", "0.0.0.0", "--port", "8080"]
