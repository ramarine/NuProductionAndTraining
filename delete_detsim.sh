#!/bin/bash

DATA_DIR=$1

rm -rf $DATA_DIR/detsim
echo "Deleted generated event files in $DATA_DIR/detsim"
cd -