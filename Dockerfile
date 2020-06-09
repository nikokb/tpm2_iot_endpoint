FROM ubuntu:20.04

ENV DEBIAN_FRONTEND=noninteractive
ENV LD_LIBRARY_PATH=/usr/lib/x86_64-linux-gnu/engines-1.1

#ARG PROJECT_ID = project

RUN apt-get update && \
    apt-get install -y \
    autoconf-archive \
    curl \
    libcmocka0 \
    libcmocka-dev \
    net-tools \
    build-essential \
    vim \
    git \
    pkg-config \
    gcc \
    g++ \
    m4 \
    libtool \
    automake \
    libgcrypt20-dev \
    libssl-dev \
    autoconf \
    gnulib \
    wget \
    doxygen \
    libdbus-1-dev \
    libglib2.0-dev \
    clang-10 \
    clang-tools-10 \
    pandoc \
    lcov \
    libcurl4-openssl-dev \
    dbus-x11 \
    #python-yaml \
    python3-yaml \
    #vim-common \
    libsqlite3-dev \
    #python-cryptography \
    python3-cryptography \
    #iproute2 \
    libtasn1-6-dev \
    socat \
    libseccomp-dev \
    expect \
    gawk \
    libjson-c-dev \
    libengine-pkcs11-openssl \
    #default-jre \
    #default-jdk \
    #sqlite3 \
    libnss3-tools \
    python3-pip \
    libyaml-dev \
    uuid-dev \
    opensc \
    gnutls-bin 


WORKDIR /tmp
RUN git clone https://github.com/tpm2-software/tpm2-tss.git
RUN cd tpm2-tss \
	&& ./bootstrap \
	&& ./configure \
	&& make -j$(nproc) \
	&& make install \
	&& ldconfig

WORKDIR /tmp
RUN git clone https://github.com/tpm2-software/tpm2-tss-engine.git
RUN cd tpm2-tss-engine \
	&& ./bootstrap \
	&& ./configure \
	&& make -j$(nproc) \
	&& make install 

WORKDIR /tmp
RUN git clone https://github.com/tpm2-software/tpm2-tools.git
RUN cd tpm2-tools \
	&& ./bootstrap \
	&& ./configure \
	&& make -j$(nproc) \
	&& make install

#Clone JWT builder and build dependencies 
WORKDIR /tmp
RUN git clone https://github.com/DaveGamble/cJSON.git \
	&& cd cJSON \
	&& make \
	&& make install \
	&& cp -a . /usr/lib/x86_64-linux-gnu/engines-1.1/

WORKDIR /
RUN mkdir auth \
	&& cd auth \
	&& openssl genpkey -algorithm RSA -out private.pem -pkeyopt rsa_keygen_bits:2048 \
	&& openssl rsa -in private.pem -pubout -out public.pem 
	
WORKDIR /auth
RUN git clone https://github.com/nikokb/tpm2_iot_endpoint.git \
	&& cd tpm2_iot_endpoint \
	&& gcc gcs_auth.c -L/usr/lib/x86_64-linux-gnu/engines-1.1/ -lcrypto -ltpm2tss -lcjson -o gcs_auth \
	&& mv gcs_auth .. \
	&& mv tpm_persist_private.sh ..


WORKDIR /auth