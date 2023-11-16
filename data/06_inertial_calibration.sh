#!/bin/bash

script_dir=$ROS_SOURCES/kalibr/aslam_offline_calibration/kalibr/python/
script_name=kalibr_calibrate_imu_camera

data_dir_path=/data/imu_calib_data
april_yaml_path=$data_dir_path/april_6x6_80x80cm_larues.yaml

bag_path=$data_dir_path/recorder.bag
#cam_path=$data_dir_path/camera_calibration.yaml
cam_path=$data_dir_path/recorder-camchain.yaml
#imu_path=$data_dir_path/imu_intrinsics.yaml
imu_path=$data_dir_path/imu_intrinsics.yaml


cd $script_dir && \
./$script_name \
--bag $bag_path \
--cam $cam_path \
--imu $imu_path \
--target $april_yaml_path

# camera_calibration.yaml
# imu_intrinsics.yaml