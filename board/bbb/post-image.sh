#!/bin/sh
# post-image.sh for BeagleBone
# 2014, Marcin Jabrzyk <marcin.jabrzyk@gmail.com>

# copy the uEnv.txt to the output/images directory
cp $(dirname $0)/uEnv_mmc.txt $BINARIES_DIR/uEnv.txt
