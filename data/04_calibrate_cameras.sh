#!/bin/bash

script_dir=$ROS_SOURCES/kalibr/aslam_offline_calibration/kalibr/python/
script_name=kalibr_calibrate_cameras

data_dir_path=/data/calib_data
bag_path=$data_dir_path/recorder.bag

april_yaml_path=$data_dir_path/april_6x6_80x80cm_larues.yaml
#april_yaml_path=$data_dir_path/april_to_be_updated.yaml

topics=/cam0/image_raw
models=pinhole-radtan


cd $script_dir && \
python $script_name \
--bag $bag_path \
--topics $topics \
--models $models \
--target $april_yaml_path
