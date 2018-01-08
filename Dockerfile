FROM ruby:2.5

LABEL maintainer="lcdss@live.com"

ARG PUID=1000
ARG PGID=1000

ENV PUID ${PUID}
ENV PGID ${PGID}

RUN groupadd -g ${PGID} lcdss && \
    useradd -u ${PUID} -g lcdss -m lcdss && \
    mkdir -p /data/app && \
    curl -sL https://deb.nodesource.com/setup_9.x | bash - && \
    apt-get install -y nodejs && \
    npm i -g npm && \
    curl -o- -L https://yarnpkg.com/install.sh | bash

COPY . /data/app

USER lcdss

RUN gem install rails

WORKDIR /data/app

EXPOSE 3000
