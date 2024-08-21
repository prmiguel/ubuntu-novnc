FROM ubuntu:focal-20240530

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get -qqy update && \
    apt dist-upgrade -y && \
    apt-get -qqy --no-install-recommends install \
    ca-certificates \
    curl \
    gnupg \
    libgconf-2-4 \
    libqt5webkit5 \
    sudo \
    tzdata \
    unzip \
    wget \
    xvfb \
    zip \
    ffmpeg \
  && rm -rf /var/lib/apt/lists/*

ENV TZ "UTC"
RUN echo "${TZ}" > /etc/timezone \
  && dpkg-reconfigure --frontend noninteractive tzdata

ARG USER_PASS=secret
RUN groupadd testusr \
         --gid 1301 \
  && useradd testusr \
         --uid 1300 \
         --gid 1301 \
         --create-home \
         --shell /bin/bash \
  && usermod -aG sudo testusr \
  && echo testusr:${USER_PASS} | chpasswd \
  && echo 'testusr ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers

WORKDIR /home/testusr

ENV NODE_VERSION=18
ENV APPIUM_VERSION=2.11.2
RUN curl -sL https://deb.nodesource.com/setup_${NODE_VERSION}.x | bash && \
    apt-get -qqy install nodejs && \
    npm install -g appium@${APPIUM_VERSION} && \
    exit 0 && \
    npm cache clean && \
    apt-get remove --purge -y npm && \
    apt-get autoremove --purge -y && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
    apt-get clean

RUN chown -R 1300:1301 /usr/lib/node_modules/appium

USER 1300:1301

EXPOSE 4723
