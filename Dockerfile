#!/usr/bin/docker
# Title:            linux-binderash
# Author:           sickcodes <https://twitter.com/sickcodes>
# License:          A-GPLv3
# Repository:       https://github.com/sickcodes/linux-binderash
# Website:          https://sick.codes
# Based on:         https://github.com/zaoqi/github-actions-archlinux

FROM archlinux:base-devel

MAINTAINER 'https://twitter.com/sickcodes' <https://sick.codes>

SHELL ["/bin/bash", "-c"]

RUN useradd arch -p arch \
    && tee -a /etc/sudoers <<< 'arch ALL=(ALL) NOPASSWD: ALL' \
    && mkdir /home/arch \
    && chown arch:arch /home/arch

USER arch

ARG ARCH=x86_64
ARG CORES=
ARG KERNEL_CONFIG=https://raw.githubusercontent.com/archlinux/svntogit-packages/packages/linux/trunk/config
ARG RC

WORKDIR /home/arch

ENV PACKAGER="Sick Codes <info at sick dot codes>" 

RUN sudo tee -a /etc/makepkg.conf <<< "MAKEFLAGS=-j$(nproc)"

RUN sudo pacman -Syu --noconfirm \
    sed \
    git \
    tar \
    curl \
    wget \
    bash \
    gzip \
    sudo \
    file \
    gawk \
    grep \
    bzip2 \
    which \
    pacman \
    systemd \
    findutils \
    diffutils \
    coreutils \
    procps-ng \
    util-linux \
    linux \
    linux-headers \
    perl \
    bc \
    xmlto \
    python-sphinx \
    python-sphinx_rtd_theme \
    graphviz \
    imagemagick \
    && export KERNEL_MAINLINE="$(curl https://www.kernel.org/feeds/kdist.xml \
    | grep -m1 -Po '(?<=kernel.org,stable,)(.+?)(?=,20\d\d\-)')" \
    && RC="${RC:-${KERNEL_MAINLINE//\-/}}" \
    && echo "Building ${RC}" \
    && wget https://raw.githubusercontent.com/sickcodes/linux-binderash/master/linux-git/PKGBUILD \
    && sed -i -e "s/{{PKGVER}}/"${RC}"/" PKGBUILD \
    && wget -O ./config "${KERNEL_CONFIG}" \
    && tee -a ./config <<< 'CONFIG_ASHMEM=y' \
    && tee -a ./config <<< 'CONFIG_ANDROID=y' \
    && tee -a ./config <<< 'CONFIG_ANDROID_BINDER_IPC=y' \
    && tee -a ./config <<< 'CONFIG_ANDROID_BINDERFS=y' \
    && tee -a ./config <<< 'CONFIG_ANDROID_BINDER_DEVICES="binder,hwbinder,vndbinder"' \
    && tee -a ./config <<< 'CONFIG_SW_SYNC=y' \
    && tee -a ./config <<< 'CONFIG_UHID=m' \
    && makepkg -si --noconfirm --nosign \
    && yes | pacman -Scc && rm -fr /var/lib/pacman/sync/*