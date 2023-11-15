#!/bin/bash

script_dir=$USER_PACKAGES/ORB_SLAM3/Examples/Calibration/python_scripts
script_name=process_imu.py

data_dir_path=/data/calib_data


cd $script_dir && \
python3 $script_name \
$data_dir_path