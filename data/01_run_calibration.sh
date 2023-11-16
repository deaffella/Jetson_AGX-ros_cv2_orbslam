#!/bin/bash

script_dir=$USER_PACKAGES/ORB_SLAM3/Examples/Calibration/
script_name=recorder_realsense_D435i

data_dir_path=/data/calib_data


rm -R $data_dir_path/

mkdir -p $data_dir_path/IMU
mkdir -p $data_dir_path/cam0

cd $script_dir && \
./$script_name \
$data_dir_path
