FROM ubuntu:18.04

ARG CUDA_VERSION=cuda-11.2
ARG ROS_VERSION=melodic
ARG PYTHON_VERSION=python
ARG TZ=Asia/Tokyo

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ ${TZ}

RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

RUN apt update -y \
    && apt upgrade -y \
    && apt install -y --no-install-recommends \
    mesa-utils \
    x11-apps \
    git \
    vim \
    build-essential \
    curl \
    ca-certificates \
    wget \
    gnupg2 \
    lsb-release \ 
    mesa-utils \
    net-tools \
    iputils-ping \
    python-pip \
    && rm -rf /var/lib/apt/lists/*

RUN apt-get update -y \
    && apt-get upgrade -y \
    && apt-get install -y --no-install-recommends \
    libglvnd-dev libglvnd-dev \
    libgl1-mesa-dev \
    libegl1-mesa-dev \
    libgles2-mesa-dev \
    && rm -rf /var/lib/apt/lists/*

ENV PATH="/usr/local/${CUDA_VERSION}/bin:${PATH}"
ENV LD_LIBRARY_PATH="/usr/local/${CUDA_VERSION}/lib64:$LD_LIBRARY_PATH"

## Install ROS #################
ENV APT_KEY_DONT_WARN_ON_DANGEROUS_USAGE=1
RUN sh -c 'echo "deb http://packages.ros.org/ros/ubuntu $(lsb_release -sc) main" > /etc/apt/sources.list.d/ros-latest.list'
RUN curl -s https://raw.githubusercontent.com/ros/rosdistro/master/ros.asc | apt-key add -

SHELL ["/bin/bash", "-c"] 
RUN apt update -y \
    && apt install -y --no-install-recommends \
    ros-${ROS_VERSION}-desktop-full \
    ros-${ROS_VERSION}-image-* \
    ros-${ROS_VERSION}-vision-msgs \
    ros-${ROS_VERSION}-libuvc-camera \
    ros-${ROS_VERSION}-camera-calibration \
    ros-${ROS_VERSION}-ddynamic-reconfigure \
    ${PYTHON_VERSION}-rosdep \
    ${PYTHON_VERSION}-rosinstall \
    ${PYTHON_VERSION}-rosinstall-generator \
    ${PYTHON_VERSION}-wstool \
    && rm -rf /var/lib/apt/lists/*

RUN apt-get update && \
    cd /opt/ros/${ROS_VERSION}/share/ros && \
    rosdep init && \
    rosdep update && \
    rm -rf /var/lib/apt/lists/*

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    ${PYTHON_VERSION}-catkin-tools

RUN echo "source /opt/ros/${ROS_VERSION}/setup.bash" >> ~/.bashrc
###############################

RUN apt-get update -y \
    && apt-get install -y --no-install-recommends \
    usbutils \
    ros-${ROS_VERSION}-kobuki-* \
    ros-${ROS_VERSION}-ecl-streams \
    ros-${ROS_VERSION}-joy

RUN apt update -y \
    && apt upgrade -y \
    && apt install -y --no-install-recommends \
    software-properties-common \
    libssl-dev \
    && rm -rf /var/lib/apt/lists/*

RUN pip install rospkg
RUN pip uninstall -y  pillow
RUN pip install pillow
RUN pip install empy

## Setting working directry
WORKDIR /root/ros/
RUN git clone --recursive https://github.com/sarubito/kobuki.git
## ROS関係のパッケージに依存するパッケージのインストール
RUN apt update
RUN mv /bin/sh /bin/sh_tmp && ln -s /bin/bash /bin/sh
RUN source ~/.bashrc
RUN rosdep install -r --from-path kobuki/catkin_ws/src --ignore-src --rosdistro melodic
RUN rm /bin/sh &&mv /bin/sh_tmp /bin/sh
RUN rm -rf /vat/lib/apt/list/*
