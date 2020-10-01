#!/usr/bin/env bash

set -e

echo $0
echo "Started"
date

source activate dagnn

PROJECT=$PWD
cd dvae/bayesian_optimization

export CUDA_VISIBLE_DEVICES=$1
export PYTHONPATH=$PYTHONPATH:$PROJECT:$PROJECT/dvae/bayesian_optimization/Theano-master/

echo "CUDA_VISIBLE_DEVICES ${CUDA_VISIBLE_DEVICES}"
echo "PYTHONPATH ${PYTHONPATH}"
echo MODEL $2

# TODO SET THIS
DATAD=../naresults/

MODEL=$2
NAME=$MODEL
CHECK=$3
RESULTS="${PROJECT}/naeval${CHECK}/"
mkdir -p $RESULTS

LAYERS=2
AGG_X=0
AGG=attn_h
OUT_WX=0
POOL_ALL=0
POOL=max
DROPOUT=0
BIDIR=0
CLIP=0.25


if [[ "$MODEL" = "DAGNN"* ]]; then
    NAME="${MODEL}_l${LAYERS}_b${BIDIR}_a${AGG}_owx${OUT_WX}_pa${POOL_ALL}_p${POOL}_c${CLIP}"
fi


python bo.py \
  --data-dir=$DATAD  \
  --data-name="final_structures6" \
  --save-appendix=$NAME --model=$MODEL \
  --checkpoint=$CHECK \
  --res-dir=$RESULTS &>> $RESULTS/"${NAME}.txt"

python summarize.py \
  --data-type=ENAS \
  --name=$NAME \
  --res-dir=$RESULTS &>> $RESULTS/"${NAME}.txt"

echo "Completed"
date