#!/bin/bash

DATA_DIR=$1

rm -rf $DATA_DIR/gen_evt
echo "Deleted generated event files in $DATA_DIR/gen_evt"
cd -