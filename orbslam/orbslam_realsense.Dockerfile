FROM dustynv/ros:melodic-desktop-l4t-r32.7.1

MAINTAINER Letenkov Maksim <letenkovmaksim@yandex.ru>

ENV DEBIAN_FRONTEND=noninteractive

ENV HOME=/root
ENV USER_PACKAGES=${HOME}/Packages

ENV ROS_DISTRO=melodic

ENV ROS_WS=/opt/ros_ws
ENV ROS_SOURCES=${ROS_WS}/src
ENV ROS_INSTALL_PATH=/opt/ros/${ROS_DISTRO}

RUN mkdir -p $USER_PACKAGES $ROS_SOURCES ${ROS_WS}/devel ${ROS_WS}/build ${ROS_WS}/logs


# [ROS sources] - add sources and keys
RUN sh -c 'echo "deb http://packages.ros.org/ros/ubuntu $(lsb_release -sc) main" > /etc/apt/sources.list.d/ros-latest.list' && \
    curl -s https://raw.githubusercontent.com/ros/rosdistro/master/ros.asc | apt-key add - && \
    apt update
# [librealsense2] - add sources and keys
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-key F6E65AC044F831AC80A06380C8B3A55A6F3EFCDE || \
    apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-key F6E65AC044F831AC80A06380C8B3A55A6F3EFCDE && \
    add-apt-repository "deb https://librealsense.intel.com/Debian/apt-repo $(lsb_release -cs) main" -u

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
        software-properties-common apt-transport-https ca-certificates lsb-release gnupg zip \
        # OpenCV deps
        python3-numpy \
        python3-scipy python3-matplotlib ipython3 python3-wxgtk4.0 \
        python3-tk python3-igraph python3-pyx \
        libavcodec-dev libavformat-dev libswscale-dev \
        libgstreamer-plugins-base1.0-dev libgstreamer1.0-dev \
        # Pangolin deps
        libgl1-mesa-dev libwayland-dev libxkbcommon-dev wayland-protocols \
        libegl1-mesa-dev libc++-dev libglew-dev libeigen3-dev \
        ninja-build libjpeg-dev libpng-dev libavcodec-dev libavutil-dev \
        libavformat-dev libswscale-dev libavdevice-dev \
        # librealsense deps
        libssl-dev freeglut3-dev libusb-1.0-0-dev libgtk-3-dev libatomic-ops-dev \
        # other deps \
        python3-gnupg \
        # ROS
        ros-${ROS_DISTRO}-desktop-full python3-catkin-tools ros-${ROS_DISTRO}-catkin


RUN if [ $(lsb_release -cs) = "bionic" ];  \
      then \
        apt install -y --no-install-recommends python-dev python-pip python-numpy; \
      else \
        apt install -y --no-install-recommends python2-dev python-pip python-numpy; \
    fi

RUN apt update && apt install -y \
    python-opencv python-tk python-igraph


RUN which pip3 && pip3 --version && python3 -m pip install --upgrade pip && \
    which pip && pip --version && python -m pip install --upgrade pip

RUN pip install --no-cache-dir rospkg defusedxml netifaces
RUN pip3 install --upgrade --no-cache-dir setuptools packaging 'Cython<3' wheel
RUN pip3 install --no-cache-dir --verbose wget psutil pycryptodomex
RUN pip3 install --upgrade --force-reinstall --no-cache-dir --verbose cmake
RUN cmake --version && which cmake


# [Pangolin] - clone, build, install
RUN cd $USER_PACKAGES && \
    git clone https://github.com/stevenlovegrove/Pangolin -b v0.6 Pangolin && \
    cd Pangolin && \
    mkdir build && \
    cd build && \
    cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_CXX_FLAGS=-std=c++11 .. && \
    make -j${nproc} && \
    make install

# [pyrealsense2] - build
COPY build_pyrealsense2_and_SDK.sh $USER_PACKAGES/build_pyrealsense2_and_SDK.sh
RUN cd $USER_PACKAGES && \
    bash build_pyrealsense2_and_SDK.sh

# [OpenCV] - install
ENV OPENCV_DEB=OpenCV-4.5.0-aarch64.tar.gz
ENV OPENCV_URL=https://nvidia.box.com/shared/static/5v89u6g5rb62fpz4lh0rz531ajo2t5ef.gz
COPY opencv_install.sh $USER_PACKAGES/opencv_install.sh
RUN cd $USER_PACKAGES && \
    bash opencv_install.sh

# [ORB-SLAM3] - clone to $USER_PACKAGES, build
COPY comment_realsense_recorder_strings.py $USER_PACKAGES/comment_realsense_recorder_strings.py
RUN cd $USER_PACKAGES && \
    git clone https://github.com/UZ-SLAMLab/ORB_SLAM3.git ORB_SLAM3 && \
    python3 comment_realsense_recorder_strings.py \
            --filename='./ORB_SLAM3/Examples/Calibration/recorder_realsense_D435i.cc' \
            --target-line='sensor.set_option(RS2_OPTION_AUTO_EXPOSURE_LIMIT,5000);'  \
    && \
    python3 comment_realsense_recorder_strings.py \
            --filename='./ORB_SLAM3/Examples/Monocular-Inertial/mono_inertial_realsense_D435i.cc' \
            --target-line='sensor.set_option(RS2_OPTION_AUTO_EXPOSURE_LIMIT,5000);' \
    && \
    cd ORB_SLAM3 && \
    chmod +x build.sh && \
    bash build.sh


# [CV_BRIDGE] - clone and move to `src`
RUN cd $USER_PACKAGES && \
    git clone https://github.com/fizyr-forks/vision_opencv.git -b opencv4 && \
    mv vision_opencv/cv_bridge $ROS_SOURCES/ && \
    rm -rf $USER_PACKAGES/vision_opencv

# [KALIBR] - clone to `src`
RUN cd $ROS_SOURCES && \
    git clone https://github.com/ethz-asl/kalibr.git
#
# [ORB-SLAM3-WRAPPER] - clone to `src`
RUN cd $ROS_SOURCES && \
    git clone https://github.com/thien94/orb_slam3_ros_wrapper.git

##RUN rm /usr/bin/python && ln -s /usr/bin/python3.6 /usr/bin/python

# [ROSDEP] install ros package dependencies
RUN . ${ROS_INSTALL_PATH}/setup.sh && \
    rosdep update

# [CATKIN] - build all packages in `src`
RUN cd $ROS_WS && \
    . ${ROS_INSTALL_PATH}/setup.sh && \
    catkin build


RUN apt update && apt install -y \
    python-opencv python-tk python-igraph \
    python-scipy


RUN echo "export ROS_PACKAGE_PATH=${ROS_PACKAGE_PATH}:${USER_PACKAGES}/ORB_SLAM3/Examples/ROS" >> ~/.bashrc

# disable opencv warnings
ENV OPENCV_LOG_LEVEL=0

WORKDIR /
RUN echo 'source /opt/ros_ws/devel/setup.bash' >> ~/.bashrc
CMD ["/bin/bash"]