# credhub cli builder
FROM golang as builder

MAINTAINER dohq <dorastone@gmail.com>

# credhub(v1) cli version
ENV CREDHUB_V1_CLI_VERSION 1.7.7
# credhub(v2) cli version
ENV CREDHUB_V2_CLI_VERSION 2.5.2

RUN apt install git && \
    mkdir -p $GOPATH/src/code.cloudfoundry.org && \
    cd $GOPATH/src/code.cloudfoundry.org && \
    git clone https://github.com/cloudfoundry-incubator/credhub-cli && \
    cd credhub-cli && \
    git checkout ${CREDHUB_V2_CLI_VERSION} && \
    CGO_ENABLED=0 go build -o $GOPATH/credhub -ldflags "-X code.cloudfoundry.org/credhub-cli/version.Version=${CREDHUB_V2_CLI_VERSION}" && \
    git checkout ${CREDHUB_V1_CLI_VERSION} && \
    CGO_ENABLED=0 go build -o $GOPATH/credhub1 -ldflags "-X code.cloudfoundry.org/credhub-cli/version.Version=${CREDHUB_V1_CLI_VERSION}"


# base image
FROM ruby:2.4-alpine as cf-tools

# bosh cli version
ENV BOSH_CLI_VERSION 5.5.1
# cf cli version
ENV CF_CLI_VERSION 6.46.0
# om cli version
ENV OM_CLI_VERSION 3.0.0
# fly cli version
ENV FLY_CLI_VERSION 5.4.0
# uaac cli version
ENV UAAC_CLI_VERSION 4.1.0

RUN apk add --update-cache --no-cache \
      build-base && \
    gem install cf-uaac -v ${UAAC_CLI_VERSION} -N && \
    wget "https://github.com/cloudfoundry/bosh-cli/releases/download/v${BOSH_CLI_VERSION}/bosh-cli-${BOSH_CLI_VERSION}-linux-amd64" -O /usr/local/bin/bosh && \
    chmod +x /usr/local/bin/bosh && \
    wget "https://github.com/concourse/concourse/releases/download/v${FLY_CLI_VERSION}/fly-${FLY_CLI_VERSION}-linux-amd64.tgz" && \
    tar zxf fly-${FLY_CLI_VERSION}-linux-amd64.tgz fly && \
    rm -rf fly-${FLY_CLI_VERSION}-linux-amd64.tgz && \
    mv fly /usr/local/bin/fly && \
    chmod +x /usr/local/bin/fly && \
    wget "https://packages.cloudfoundry.org/stable?release=linux64-binary&version=${CF_CLI_VERSION}&source=github-rel" -O cf-${CF_CLI_VERSION}.tgz && \
    tar zxf cf-${CF_CLI_VERSION}.tgz cf && \
    rm -rf cf-${CF_CLI_VERSION}.tgz && \
    mv cf /usr/local/bin/cf && \
    chmod +x /usr/local/bin/cf && \
    wget "https://github.com/pivotal-cf/om/releases/download/${OM_CLI_VERSION}/om-linux-${OM_CLI_VERSION}" -O /usr/local/bin/om && \
    chmod +x /usr/local/bin/om && \
    apk del build-base

COPY --from=builder /go/credhub /usr/local/bin/
COPY --from=builder /go/credhub1 /usr/local/bin/
