#!/bin/bash

script_dir=$USER_PACKAGES/ORB_SLAM3/Examples/Monocular-Inertial/
script_name=mono_inertial_realsense_D435i

data_dir_path=/data/

vocabulary=$USER_PACKAGES/ORB_SLAM3/Vocabulary/ORBvoc.txt
camera_yaml=$data_dir_path/RealSense_D435i.yaml


cd $script_dir && \
./$script_name \
$vocabulary \
$camera_yaml
