#!/bin/bash

DATA_DIR=$1

rm -rf $DATA_DIR/reco
echo "Deleted generated event files in $DATA_DIR/reco"
cd -