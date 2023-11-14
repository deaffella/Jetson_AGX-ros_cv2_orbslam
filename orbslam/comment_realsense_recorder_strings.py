# filename = '/root/Packages/ORB_SLAM3/Examples/Calibration/recorder_realsense_D435i.cc'
# target_line = '                sensor.set_option(RS2_OPTION_AUTO_EXPOSURE_LIMIT,5000);'

import argparse

def comment_line(filename, target_line):
    try:
        with open(filename, 'r', encoding='utf-8') as file:
            lines = file.readlines()
    except UnicodeDecodeError:
        with open(filename, 'r', encoding='latin-1') as file:
            lines = file.readlines()

    for i in range(len(lines)):
        if target_line.strip() in lines[i]:
            lines[i] = f'// {lines[i]}'

    with open(filename, 'w', encoding='utf-8') as file:
        file.writelines(lines)

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--filename', required=True)
    parser.add_argument('--target-line', required=True)

    args = parser.parse_args()

    comment_line(args.filename, args.target_line)

if __name__ == '__main__':
    main()

