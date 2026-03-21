# Combined Dockerfile for Flutter Web + Dart Backend
FROM dart:3.11-sdk as build

WORKDIR /build

# Install Flutter
RUN apt-get update && apt-get install -y \
    curl \
    git \
    unzip \
    xz-utils \
    zip \
    libsqlite3-dev \
    && rm -rf /var/lib/apt/lists/*

RUN git clone https://github.com/flutter/flutter.git /usr/local/flutter --depth 1 -b stable
ENV PATH="/usr/local/flutter/bin:/usr/local/flutter/bin/cache/dart-sdk/bin:${PATH}"
RUN flutter doctor
RUN flutter precache --web

# Build Flutter Web
COPY HACKATON/pubspec.yaml HACKATON/pubspec.lock ./HACKATON/
WORKDIR /build/HACKATON
RUN flutter pub get
COPY HACKATON/ ./
RUN flutter build web --release

# Build Backend
WORKDIR /build/backend
COPY backend/pubspec.yaml backend/pubspec.lock ./
RUN dart pub get
COPY backend/ ./
RUN dart compile exe bin/server.dart -o bin/server

# Runtime image
FROM alpine:3.19

RUN apk --no-cache add libsqlite3 nginx

# Setup nginx for static files
COPY --from=build /build/HACKATON/build/web /var/www/html
COPY <<EOF /etc/nginx/http.d/default.conf
server {
    listen 80;
    server_name localhost;
    root /var/www/html;
    index index.html;

    location / {
        try_files \$uri \$uri/ /index.html;
    }

    location /api {
        proxy_pass http://localhost:8080;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \$host;
        proxy_cache_bypass \$http_upgrade;
    }
}
EOF

# Copy backend binary
COPY --from=build /build/backend/bin/server /usr/local/bin/

WORKDIR /app

EXPOSE 80

# Start script
COPY <<'SCRIPT' /start.sh
#!/bin/sh
# Start backend in background
/usr/local/bin/server --host 127.0.0.1 --port 8080 &
# Start nginx in foreground
nginx -g 'daemon off;'
SCRIPT

RUN chmod +x /start.sh

ENTRYPOINT ["/start.sh"]
