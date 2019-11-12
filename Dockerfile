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
      build-base curl tar && \
      gem install cf-uaac -v ${UAAC_CLI_VERSION} -N && \
      curl -fsL -o /usr/local/bin/bosh "https://github.com/cloudfoundry/bosh-cli/releases/download/v${BOSH_CLI_VERSION}/bosh-cli-${BOSH_CLI_VERSION}-linux-amd64" && \
      chmod +x /usr/local/bin/bosh && \
      curl -fsL -o /usr/local/bin/om "https://github.com/pivotal-cf/om/releases/download/${OM_CLI_VERSION}/om-linux-${OM_CLI_VERSION}" && \
      chmod +x /usr/local/bin/om && \
      curl -fsL "https://github.com/concourse/concourse/releases/download/v${FLY_CLI_VERSION}/fly-${FLY_CLI_VERSION}-linux-amd64.tgz" | tar zx -C /usr/local/bin && \
      chmod +x /usr/local/bin/fly && \
      curl -fsL "https://packages.cloudfoundry.org/stable?release=linux64-binary&version=${CF_CLI_VERSION}&source=github-rel" | tar zx -C /usr/local/bin && \
      chmod +x /usr/local/bin/cf && \
      apk del build-base && \
      apk add --update-cache --no-cache libstdc++

COPY --from=builder /go/credhub /usr/local/bin/
COPY --from=builder /go/credhub1 /usr/local/bin/
