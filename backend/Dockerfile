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
FROM alpine:3.19

RUN apk --no-cache add sqlite-libs

WORKDIR /app

# Copy compiled binary
COPY --from=backend-build /app/bin/server ./
COPY --from=backend-build /app/.dart_tool/ ./

EXPOSE 8080

ENTRYPOINT ["./server"]
CMD ["--host", "0.0.0.0", "--port", "8080"]
