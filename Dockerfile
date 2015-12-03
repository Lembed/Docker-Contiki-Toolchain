#base on https://raw.githubusercontent.com/Lembed/Contiki-os/master/.travis.yml
FROM ubuntu:13.04


RUN export DEBIAN_FRONTEND=noninteractive

# Tools
RUN dpkg --add-architecture i386

#https://github.com/contiki-os/contiki/wiki/Setup-contiki-toolchain-in-ubuntu-13.04
RUN sed -i -re 's/([a-z]{2}\.)?archive.ubuntu.com|security.ubuntu.com/old-releases.ubuntu.com/g' /etc/apt/sources.list
RUN apt-get update -y

# install add-apt-repository and etc
RUN apt-get install -y --no-install-recommends software-properties-common bzip2 wget multiarch-support git-core git make libncurses5-dev build-essential lrzsz

#https://launchpad.net/~terry.guo/+archive/ubuntu/gcc-arm-embedded
RUN add-apt-repository -y ppa:terry.guo/gcc-arm-embedded
RUN apt-get update -y

# Install doxygen
RUN apt-get --no-install-suggests --no-install-recommends -qq install doxygen  &&  doxygen --version

# Install msp430 toolchain
RUN apt-get install -y lib32z1
RUN wget http://simonduq.github.io/resources/mspgcc-4.7.2-compiled.tar.bz2 && \
    tar xjf mspgcc*.tar.bz2 -C /tmp/ && \
    cp -f -r /tmp/msp430/* /usr/local/ && \
    rm -rf /tmp/msp430 mspgcc*.tar.bz2 && \
    msp430-gcc --version

# Install avr toolchain
RUN apt-get -qq install binutils-avr gcc-avr gdb-avr avr-libc avrdude 

# Install 32-bit compatibility libraries
RUN apt-get -qq install \
  libc6:i386 \
  libgcc1:i386 \
  gcc-4.7-base:i386 \
  libstdc++5:i386 \
  libstdc++6:i386

# Install mainline ARM toolchain.
RUN apt-get -qq install \
  gcc-arm-none-eabi \
  srecord && \
  arm-none-eabi-gcc --version

# Install SDCC from a purpose-built bundle
RUN apt-get install -y lib32stdc++6
RUN wget https://raw.githubusercontent.com/wiki/g-oikonomou/contiki-sensinode/files/sdcc.tar.gz && \
    tar xzf sdcc.tar.gz -C /tmp/ && \
    cp -f -r /tmp/sdcc/* /usr/local/ && \
    rm -rf /tmp/sdcc sdcc.tar.gz && \
    sdcc --version

## Clone and build cc65 when testing 6502 ports
RUN git clone https://github.com/cc65/cc65 /tmp/cc65 && \
    make -C /tmp/cc65 bin apple2enh atarixl c64 c128 && \
    make -C /tmp/cc65 avail && \
    export CC65_HOME=/tmp/cc65/ && \
    cc65 --version

# Install RL78 GCC toolchain
RUN apt-get install -y libncurses5:i386 zlib1g:i386
RUN wget http://adamdunkels.github.io/contiki-fork/gnurl78-v13.02-elf_1-2_i386.deb && \
    dpkg -i gnurl78*.deb

# Install NXP toolchain
RUN wget http://simonduq.github.io/resources/ba-elf-gcc-4.7.4-part1.tar.bz2 && \
    wget http://simonduq.github.io/resources/ba-elf-gcc-4.7.4-part2.tar.bz2 && \
    wget http://simonduq.github.io/resources/jn516x-sdk-4163.tar.bz2 && \
    mkdir /tmp/jn516x-sdk /tmp/ba-elf-gcc && \
    tar xjf jn516x-sdk-*.tar.bz2 -C /tmp/jn516x-sdk && \
    tar xjf ba-elf-gcc-*part1.tar.bz2 -C /tmp/ba-elf-gcc && \
    tar xjf ba-elf-gcc-*part2.tar.bz2 -C /tmp/ba-elf-gcc && \
    cp -f -r /tmp/jn516x-sdk /usr/ && \
    cp -f -r /tmp/ba-elf-gcc /usr/ && \
    export PATH=/usr/ba-elf-gcc/bin:$PATH && \
    rm -rf /tmp/ba-elf-gcc* /tmp/jn516x-sdk* && \
    ba-elf-gcc --version

# Compile cooja.jar only when it's going to be needed
RUN apt-get install -y ant openjdk-7-jdk openjdk-7-jre
ENV JAVA_HOME /usr/lib/jvm/default-java
ENV JAVA_TOOL_OPTIONS -Dfile.encoding=UTF8

RUN git clone --recursive https://github.com/Lembed/Contiki/

WORKDIR Contiki
RUN ant -q -f tools/cooja/build.xml jar
