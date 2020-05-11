#!/bin/bash

if [ "$#" -ne 2 ]; then
   echo "Usage : ./run-all-workers <data-dir> <out-dir>"
   exit 1
fi
export PYTHONPATH=$PYTHONPATH:/datadrive/mnt2/jaya/models/
DATA_DIR=$1
OUT_DIR=$2
mkdir -p $OUT_DIR  

mkdir -p /dev/shm/cache  
chmod 777 /dev/shm/cache
echo " Data dir is $DATA_DIR"   
echo " Out dir is $OUT_DIR" 
rm ./model/*
model_dir="./model/" 
#GLobal values
arch=18 
workers=24
batch=128 	  
num_gpu=1
result_dir="${OUT_DIR}/${arch}_b${batch}_w${workers}_g${num_gpu}"
              echo "result dir is $result_dir" 
              mkdir -p $result_dir  
              mpstat -P ALL 1 > cpu_util.out 2>&1 &   
              ./free.sh & 
              dstat -cdnmgyr --output all-utils.csv 2>&1 & 	      
for gpu in 0; do
#for gpu in 0 1 2 3 4 5 6 7; do
	      outfile="stdout_${gpu}.out"
	      CUDA_VISIBLE_DEVICES=$gpu python imagenet_main.py --data_dir=$DATA_DIR --num_gpus=$num_gpu --batch_size=$batch --resnet_size=$arch --train_epochs=2 --datasets_num_private_threads=$workers --model_dir=$model_dir > $outfile 2>&1 & pids+=($!)
done 
wait "${pids[@]}" 
	      pkill -f mpstat   
	      pkill -f dstat   
	      pkill -f free 
	      pkill -f imagenet_main
	      mv *.out  $result_dir/ 
	      mv *.log $result_dir/   
	      mv *.csv $result_dir/  
