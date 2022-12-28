# Neurowolf Dockerfile 
# Designed to run neurowolf telegram

# run with 
# sudo docker run -it --mount src=/Users/dgusev/Projects/neurowolf/,target=/home/neurowolf/dev,type=bind --name neurowolf_dev --hostname neurowolf_dev neurowolf-arm64

# ubuntu:latest automatically selects architecture -> pulls 22.04
FROM ubuntu:latest
LABEL maintainer="Dmitrii<github.com/amidg>"

CMD ["bash"]

# DEVELOPMENT ENVIRONMENT
RUN apt-get update -y && apt-get install -y wget curl gpg-agent unzip sudo && \
    wget -q -O - https://dl.google.com/linux/linux_signing_key.pub | apt-key add - && \
    useradd --create-home --home-dir /home/neurowolf --shell /bin/bash --user-group --groups adm,sudo neurowolf && \
    echo neurowolf:neurowolf | chpasswd && \
    echo "neurowolf ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# setup locale
RUN apt update && sudo apt install locales && \
    locale-gen en_US en_US.UTF-8 && \ 
    update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8 && \
    export LANG=en_US.UTF-8

# do overall update
RUN apt-get update -y && apt-get upgrade -y && \
    apt-get install -y software-properties-common 

# setup repositories
RUN apt-get update -y && \
    add-apt-repository -y universe && \
    add-apt-repository -y multiverse && \
    apt-get update -y && \
    apt-get upgrade -y

# install common linux tools
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y \
    curl git gcc cmake make g++ gnupg2 lsb-release \
    build-essential vim nano sudo bash-completion \
    tzdata gosu terminator \
    htop inxi neofetch gdb xterm \
    libgtk2.0-dev pkg-config \
    libpython3-dev python3-pip python-is-python3 \
    binutils libboost-system-dev libssl-dev zlib1g-dev libcurl4-openssl-dev

# get latest release of OpenCV 4.6.0
RUN su neurowolf && \ 
    mkdir /home/neurowolf/Libraries && \
    wget https://github.com/opencv/opencv/archive/refs/tags/4.6.0.tar.gz -P /home/neurowolf/Libraries/ && \
    tar -xvzf /home/neurowolf/Libraries/4.6.0.tar.gz -C /home/neurowolf/Libraries/ && \
    cd /home/neurowolf/Libraries/opencv-4.6.0 && \
    mkdir -p build && cd build && \
    cmake .. && \
    make -j4 && \
    sudo make install

RUN apt-get update -y && \
    apt-get upgrade -y && \
    apt-get install libopencv-dev python3-opencv

# install tgbot-cpp library
RUN su neurowolf && \
    wget https://github.com/reo7sp/tgbot-cpp/archive/refs/tags/v1.5.tar.gz -P /home/neurowolf/Libraries/ && \
    tar -xvzf /home/neurowolf/Libraries/v1.5.tar.gz -C /home/neurowolf/Libraries/ && \
    cd /home/neurowolf/Libraries/tgbot-cpp-1.5 && \
    mkdir -p build && cd build && \
    cmake .. && \
    make -j4 && \
    sudo make install 

# get the telegram bot python library
RUN su neurowolf && \
    pip install python-telegram-bot --upgrade

# setup all the stuff needed for stable diffusion -> we work inside conda environment


# clean up downloaded folders
RUN rm -rf /home/neurowolf/Libraries

# RUNTIME ENVIRONMENT
# by default this project is expected to run in the native LXC container but docker runtime is possible as well! 

ENV USER neurowolf
