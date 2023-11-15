#!/bin/bash

script_dir=$ROS_SOURCES/kalibr/aslam_offline_calibration/kalibr/python/
script_name=kalibr_bagcreater

data_dir_path=/data/calib_data
bag_path=$data_dir_path/recorder.bag


cd $script_dir && \
./$script_name \
--folder $data_dir_path \
--output-bag $bag_path