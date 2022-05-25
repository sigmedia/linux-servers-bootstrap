#!/bin/bash

# Dealing with arguments
if [ $# -lt 1 ]
then
    echo "$0 <prefix>"
    exit -1
fi
PREFIX=$1

DEST_DIR=$PREFIX/apps/matlab

# Define some helper directories and create them
TMP_DIR=$PWD/tmp
MNT_DIR=$PWD/mnt
mkdir -p $MNT_DIR $TMP_DIR

# Prepare mount dir
sudo mount R2022a_Update_1_Linux.iso $MNT_DIR


# prepare tmp_file
cp $PWD/license.lic $TMP_DIR
cat $PWD/installer_conf.conf | \
    sed "s%__LIC_PATH__%$TMP_DIR/license.lic%g" | \
    sed "s%__DEST_FOLDER__%$DEST_DIR%g" | \
    sed "s%__LOG_FILE__%$PWD/install.log%g" > $TMP_DIR/installer_conf.conf

# Run installation
(
    cd $MNT_DIR
    ./install -inputFile $TMP_DIR/installer_conf.conf
)

# Ensure that matlab is reachable
ln -s $DEST_DIR/bin/matlab $PREFIX/bin/matlab

# Clean everything
sudo umount $MNT_DIR
rm -rfv $TMP_DIR
