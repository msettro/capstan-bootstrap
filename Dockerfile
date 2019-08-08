FROM alpine:3.9
LABEL maintainer Monjay Settro <msettro@kenzan.com>

RUN apk update

#
# basics
#

RUN apk add bash curl ca-certificates gnupg libc6-compat make less openssh openssh-client openssl

#
# git
#

RUN apk add git

#
# python
#

RUN apk add python py-crcmod

#
# gcloud
#

ARG CLOUD_SDK_VERSION=256.0.0
ENV CLOUD_SDK_VERSION=$CLOUD_SDK_VERSION

ENV PATH /google-cloud-sdk/bin:$PATH
RUN curl -O https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-sdk-${CLOUD_SDK_VERSION}-linux-x86_64.tar.gz && \
    tar xzf google-cloud-sdk-${CLOUD_SDK_VERSION}-linux-x86_64.tar.gz && \
    rm google-cloud-sdk-${CLOUD_SDK_VERSION}-linux-x86_64.tar.gz && \
    gcloud config set core/disable_usage_reporting true && \
    gcloud config set component_manager/disable_update_check true && \
    gcloud config set metrics/environment github_docker_image && \
    gcloud --version

RUN gcloud components install kubectl && \
    gcloud components list

#
# terraform
#
#    v0.11.14 is terraform 1
#    v0.12.6 is terraform 2
#

ARG TERRAFORM_VERSION=0.11.14
ENV TERRAFORM_VERSION=$TERRAFORM_VERSION

RUN apk add wget unzip && \
    cd /tmp && \
    wget https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip && \
    unzip terraform_${TERRAFORM_VERSION}_linux_amd64.zip -d /usr/bin && \
       rm -Rf /tmp/terraform_${TERRAFORM_VERSION}_linux_amd64.zip

#
# APK: clean cache
#

RUN rm -Rf /var/lib/apt/lists/* && \
    rm -Rf /var/cache/apk/*

#
# workspace
#

VOLUME ["/root"]
WORKDIR /root
