# syntax=docker/dockerfile:1.7
FROM ubuntu:24.04

ARG USER_UID=1000
ARG USER_GID=1000
ARG NODE_MAJOR=20

ENV DEBIAN_FRONTEND=noninteractive \
    LANG=C.UTF-8 \
    TZ=Etc/UTC \
    PATH=/home/dev/.local/bin:/home/dev/.npm-global/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

RUN apt-get update && apt-get install -y --no-install-recommends \
        ca-certificates curl git sudo build-essential \
        ripgrep jq less nano tini \
    && rm -rf /var/lib/apt/lists/*

RUN curl -fsSL https://deb.nodesource.com/setup_${NODE_MAJOR}.x | bash - \
    && apt-get install -y --no-install-recommends nodejs \
    && rm -rf /var/lib/apt/lists/*

RUN userdel -r ubuntu 2>/dev/null || true \
    && groupadd -g ${USER_GID} dev \
    && useradd -m -u ${USER_UID} -g ${USER_GID} -s /bin/bash dev \
    && echo "dev ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/dev \
    && chmod 0440 /etc/sudoers.d/dev

USER dev
WORKDIR /home/dev

RUN mkdir -p /home/dev/.npm-global \
    && npm config set prefix /home/dev/.npm-global

RUN npm install -g @anthropic-ai/claude-code

RUN curl -fsSL https://raw.githubusercontent.com/rtk-ai/rtk/refs/heads/master/install.sh | sh

RUN mkdir -p /home/dev/.claude && rtk init -g || true

USER root
COPY --chown=dev:dev --chmod=0755 entrypoint.sh /usr/local/bin/entrypoint.sh
USER dev

WORKDIR /workspace

ENTRYPOINT ["/usr/bin/tini", "--", "/usr/local/bin/entrypoint.sh"]
CMD ["bash"]
