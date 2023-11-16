#!/bin/bash

script_dir=$ROS_SOURCES/kalibr/aslam_offline_calibration/kalibr/python/
script_name=kalibr_calibrate_cameras

data_dir_path=/data/calib_data
bag_path=$data_dir_path/recorder.bag

april_yaml_path=$data_dir_path/april_6x6_80x80cm_larues.yaml

topics=/cam0/image_raw
models=pinhole-radtan

cp april_6x6_80x80cm_larues.yaml $data_dir_path/

cd $script_dir && \
python $script_name \
--bag $bag_path \
--topics $topics \
--models $models \
--target $april_yaml_path
