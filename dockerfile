# pipeline image for Python 3.7 based services
FROM python:3.7-alpine
# https://github.com/gliderlabs/docker-alpine/issues/184
RUN sed -i 's/http\:\/\/dl-cdn.alpinelinux.org/https\:\/\/alpine.global.ssl.fastly.net/g' /etc/apk/repositories
ARG KUSTOMIZE2_VER=2.0.3
ARG KUSTOMIZE3_VER=3.2.3
RUN apk --update-cache --no-cache add \
    bash \
    tzdata \
    coreutils \
    curl \
    rsync \
    jq \
    git \
    openssh \
    socat \
    gettext \
    make \
    gcc \
    openssl \
    linux-headers \
    musl-dev \
    libffi-dev \
    openssl-dev \
    postgresql-dev \
    pcre-dev \
    tree \
    pigz \
    tar \
    shellcheck \
    docker \
    docker-cli-buildx \
    libxml2-utils \
    && mkdir /lib64 \
    && ln -s /lib/libc.musl-x86_64.so.1 /lib64/ld-linux-x86-64.so.2 \
    && pip3 install docker-compose flake8 yq pytest pytest-xdist \
    && curl -fLO https://storage.googleapis.com/kubernetes-release/release/v1.15.0/bin/linux/amd64/kubectl \
    && mv kubectl /usr/local/bin/kubectl \
    && chmod +x /usr/local/bin/kubectl \
    && curl -fLO https://github.com/kubernetes-sigs/kustomize/releases/download/v${KUSTOMIZE2_VER}/kustomize_${KUSTOMIZE2_VER}_linux_amd64 \
    && mv kustomize_${KUSTOMIZE2_VER}_linux_amd64 /usr/local/bin/kustomize \
    && chmod +x /usr/local/bin/kustomize \
    && curl -fLO https://github.com/kubernetes-sigs/kustomize/releases/download/kustomize%2Fv${KUSTOMIZE3_VER}/kustomize_kustomize.v${KUSTOMIZE3_VER}_linux_amd64 \
    && mv kustomize_kustomize.v${KUSTOMIZE3_VER}_linux_amd64 /usr/local/bin/kustomize3 \
    && chmod +x /usr/local/bin/kustomize3

