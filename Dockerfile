FROM codercom/code-server:v2 as code-server

FROM ubuntu:bionic

RUN apt-get update && apt-get install -y \
  software-properties-common \
  openssl \
  net-tools \
  git \
  locales \
  sudo \
  dumb-init \
  vim \
  curl \
  wget \
  && rm -rf /var/lib/apt/lists/*

RUN add-apt-repository ppa:longsleep/golang-backports

RUN apt-get update && apt-get install -y golang-go

RUN locale-gen en_US.UTF-8

# We cannot use update-locale because docker will not use the env variables
# configured in /etc/default/locale so we need to set it manually.
ENV LC_ALL=en_US.UTF-8 \
  SHELL=/bin/bash

RUN adduser --gecos '' --disabled-password brunoabrantes && \
  echo "brunoabrantes ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers.d/nopasswd

USER brunoabrantes
# We create first instead of just using WORKDIR as when WORKDIR creates, the
# user is root.
RUN mkdir -p /home/brunoabrantes/code

WORKDIR /home/brunoabrantes/code

# This ensures we have a volume mounted even if the user forgot to do bind
# mount. So that they do not lose their data if they delete the container.
VOLUME [ "/home/brunoabrantes/project" ]

COPY --from=code-server /usr/local/bin/code-server /usr/local/bin/code-server

EXPOSE 8080

ENTRYPOINT ["dumb-init", "code-server", "--host", "0.0.0.0"]
