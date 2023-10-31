FROM dustynv/ros:melodic-desktop-l4t-r32.7.1
MAINTAINER Letenkov Maksim <letenkovmaksim@yandex.ru>

ENV DEBIAN_FRONTEND=noninteractive

ENV HOME=/root
ENV USER_PACKAGES=${HOME}/Packages
ENV ROS_WS=/opt/ros_ws
ENV ROS_SOURCES=${ROS_WS}/src
ENV ROS_INSTALL_PATH=/opt/ros/${ROS_DISTRO}

# set opencv version and link to sources
ENV OPENCV_DEB=OpenCV-4.5.0-aarch64.tar.gz
ENV OPENCV_URL=https://nvidia.box.com/shared/static/5v89u6g5rb62fpz4lh0rz531ajo2t5ef.gz

# disable opencv warnings
ENV OPENCV_LOG_LEVEL=0

RUN mkdir -p $USER_PACKAGES $ROS_SOURCES ${ROS_WS}/devel ${ROS_WS}/build ${ROS_WS}/logs


RUN apt update && \
    apt install -y \
        # Base deps
        locales locales-all  \
        build-essential pkg-config  \
        make gcc cmake apt-utils g++ \
        autoconf automake \
        git wget nano unzip \
        python3-dev python3-pip \
        libboost-all-dev libsuitesparse-dev doxygen \
        libpoco-dev libtbb-dev libblas-dev liblapack-dev libv4l-dev \
        # ROS \
        python3-catkin-tools ros-melodic-catkin \
        # OpenCV deps
        python3-numpy \
        python3-scipy python3-matplotlib ipython3 python3-wxgtk4.0 python3-tk python3-igraph python3-pyx \
        python-dev python-numpy \
        libavcodec-dev libavformat-dev libswscale-dev \
        libgstreamer-plugins-base1.0-dev libgstreamer1.0-dev \
        libgtk-3-dev \
        # Pangolin deps
        libgl1-mesa-dev libwayland-dev libxkbcommon-dev wayland-protocols \
        libegl1-mesa-dev libc++-dev libglew-dev libeigen3-dev \
        ninja-build libjpeg-dev libpng-dev libavcodec-dev libavutil-dev \
        libavformat-dev libswscale-dev libavdevice-dev

# [PIP] - upgrade pip
RUN pip install --upgrade pip && \
    pip3 install --upgrade pip

# [OpenCV] - install
COPY opencv_install.sh $USER_PACKAGES/opencv_install.sh
RUN cd $USER_PACKAGES && \
    bash opencv_install.sh

# [Pangolin] - clone, build, install
RUN rm /usr/bin/python && ln -s /usr/bin/python3.6 /usr/bin/python && \
    cd $USER_PACKAGES && \
    git clone https://github.com/stevenlovegrove/Pangolin -b v0.6 && \
    cd Pangolin && \
    mkdir build && \
    cd build && \
    cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_CXX_FLAGS=-std=c++11 .. && \
    make -j${nproc} && \
    make install && \
    cd $USER_PACKAGES && \
    rm -rf Pangolin


# [CV_BRIDGE] - clone and move to `src`
RUN cd $USER_PACKAGES && \
    git clone https://github.com/fizyr-forks/vision_opencv.git -b opencv4 && \
    mv vision_opencv/cv_bridge $ROS_SOURCES/ && \
    rm -rf $USER_PACKAGES/vision_opencv

# [KALIBR] - clone to `src`
RUN cd $ROS_SOURCES && \
    git clone https://github.com/ethz-asl/kalibr.git

# [ORB-SLAM3-WRAPPER] - clone to `src`
RUN cd $ROS_SOURCES && \
    git clone https://github.com/thien94/orb_slam3_ros_wrapper.git


# [ORB-SLAM3] - clone to `src`, build
RUN cd $USER_PACKAGES && \
    git clone https://github.com/UZ-SLAMLab/ORB_SLAM3.git && \
    cd ORB_SLAM3 && \
    chmod +x build.sh && \
    ./build.sh

# [ROSDEP] install ros package dependencies
RUN . ${ROS_INSTALL_PATH}/setup.sh && \
    rosdep update

# [CATKIN] - build all packages in `src`
RUN cd $ROS_WS && \
    . ${ROS_INSTALL_PATH}/setup.sh && \
    catkin build


RUN pip3 install --no-cache-dir \
        pip==21.3.1 \
        setuptools==59.6.0 \
        wheel==0.37.1
RUN pip install --no-cache-dir \
        rospkg defusedxml netifaces

WORKDIR /
RUN echo 'source /opt/ros_ws/devel/setup.bash' >> ~/.bashrc
CMD ["/bin/bash"]
