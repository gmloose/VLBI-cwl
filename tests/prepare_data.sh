#!/bin/sh

BASE_URL=https://support.astron.nl/software/ci_data/linc

mkdir -p data && cd data

wget -nv $BASE_URL/$TEST_HBA_DATASET_NAME \
    -O $TEST_HBA_DATASET_NAME \
    && tar xfz $TEST_HBA_DATASET_NAME \
    && rm -f $TEST_HBA_DATASET_NAME

wget -nv $BASE_URL/$TARGET_HBA_RESULTS_NAME \
    -O $TARGET_HBA_RESULTS_NAME \
    && tar xfz $TARGET_HBA_RESULTS_NAME \
    && rm -f $TARGET_HBA_RESULTS_NAME

ln -rsf L667520_SB000_uv.MS/ ILTJ140815.23+522952.0
