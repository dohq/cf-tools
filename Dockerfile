FROM ruby:2.5-alpine
MAINTAINER dohq <dorastone@gmail.com>

# bosh cli version
ENV BOSH_CLI_VERSION 5.3.1
# cf cli version
ENV CF_CLI_VERSION 6.42.0
# om cli version
ENV OM_CLI_VERSION 0.51.0
# credhub(v1) cli version
ENV CREDHUB_V1_CLI_VERSION 1.7.7
# credhub(v2) cli version
ENV CREDHUB_V2_CLI_VERSION 2.2.1
# fly cli version
ENV FLY_CLI_VERSION 4.2.2
# uaac cli version
ENV UAAC_CLI_VERSION 4.1.0

RUN apk add --update --no-cache --virtual .build-dependencies \
      build-base && \
    apk add --update --no-cache \
      bash \
      curl \
      wget \
      git \
      openssh \
      openssl \
      jq && \
    gem install cf-uaac -v ${UAAC_CLI_VERSION} -N && \
    wget "https://github.com/cloudfoundry/bosh-cli/releases/download/v${BOSH_CLI_VERSION}/bosh-cli-${BOSH_CLI_VERSION}-linux-amd64" -O /usr/local/bin/bosh && \
    chmod +x /usr/local/bin/bosh && \
    wget "https://github.com/concourse/concourse/releases/download/v${FLY_CLI_VERSION}/fly_linux_amd64" -O /usr/local/bin/fly && \
    chmod +x /usr/local/bin/fly && \
    wget "https://packages.cloudfoundry.org/stable?release=linux64-binary&version=${CF_CLI_VERSION}&source=github-rel" -O cf-${CF_CLI_VERSION}.tgz && \
    tar zxf cf-${CF_CLI_VERSION}.tgz cf && \
    rm -rf cf-${CF_CLI_VERSION}.tgz && \
    mv cf /usr/local/bin/cf && \
    chmod +x /usr/local/bin/cf && \
    wget "https://github.com/pivotal-cf/om/releases/download/${OM_CLI_VERSION}/om-linux" -O /usr/local/bin/om && \
    chmod +x /usr/local/bin/om && \
    apk del .build-dependencies

COPY ./credhub /usr/local/bin/.
COPY ./credhub1 /usr/local/bin/.
