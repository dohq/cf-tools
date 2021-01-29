# credhub cli builder
FROM golang as builder

# credhub(v1) cli version
ENV CREDHUB_V1_CLI_VERSION 1.7.7
# credhub(v2) cli version
ENV CREDHUB_V2_CLI_VERSION 2.5.2

RUN apt-get install git \
    && mkdir -p $GOPATH/src/code.cloudfoundry.org \
    && cd $GOPATH/src/code.cloudfoundry.org \
    && git clone https://github.com/cloudfoundry-incubator/credhub-cli \
    && cd credhub-cli \
    && git checkout ${CREDHUB_V2_CLI_VERSION} \
    && CGO_ENABLED=0 go build -o $GOPATH/credhub -ldflags "-X code.cloudfoundry.org/credhub-cli/version.Version=${CREDHUB_V2_CLI_VERSION}" \
    && git checkout ${CREDHUB_V1_CLI_VERSION} \
    && CGO_ENABLED=0 go build -o $GOPATH/credhub1 -ldflags "-X code.cloudfoundry.org/credhub-cli/version.Version=${CREDHUB_V1_CLI_VERSION}"


# base image
FROM ruby:2.6-alpine as cf-tools
# cf cli version
ENV CF_CLI_VERSION 6.53.0
# om cli version
ENV OM_CLI_VERSION 7.2.0
# uaac cli version
ENV UAAC_CLI_VERSION 4.1.0
# bosh backup-and-restore cli version
ENV BBR_CLI_VERSION 1.9.1

# COPY credhub cli
COPY --from=builder /go/credhub /usr/local/bin/
COPY --from=builder /go/credhub1 /usr/local/bin/

# install uaac cli
RUN apk add --update-cache --no-cache build-base libstdc++ curl tar bash openssl ca-certificates \
    && update-ca-certificates \
    && gem install cf-uaac -v ${UAAC_CLI_VERSION} -N \
    && apk del build-base

# install other binary cli
RUN curl -fsL "https://packages.cloudfoundry.org/stable?release=linux64-binary&version=${CF_CLI_VERSION}&source=github-rel" \
    | tar zx -C /usr/local/bin \
    && chmod +x /usr/local/bin/cf \
    && curl -fsL -o /usr/local/bin/om "https://github.com/pivotal-cf/om/releases/download/${OM_CLI_VERSION}/om-linux-${OM_CLI_VERSION}" \
    && chmod +x /usr/local/bin/om \
    && curl -fsL -o /usr/local/bin/bbr "https://github.com/cloudfoundry-incubator/bosh-backup-and-restore/releases/download/v${BBR_CLI_VERSION}/bbr-${BBR_CLI_VERSION}-linux-amd64" \
    && chmod +x /usr/local/bin/bbr
