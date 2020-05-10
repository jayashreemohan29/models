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
num_gpu=8  
echo " Data dir is $DATA_DIR"   
echo " Out dir is $OUT_DIR" 

#GLobal values
for arch in 18; do 
       for workers in 24; do    
           for batch in 1024; do 	  
	      result_dir="${OUT_DIR}/${arch}_b${batch}_w${workers}_g${num_gpu}"
              echo "result dir is $result_dir" 
              mkdir -p $result_dir  
              mpstat -P ALL 1 > cpu_util.out 2>&1 &   
              ./free.sh & 
              dstat -cdnmgyr --output all-utils.csv 2>&1 & 	      
              python imagenet_main.py --data_dir=$DATA_DIR --num_gpus=$num_gpu --batch_size=$batch --resnet_size=$arch --train_epochs=2 --datasets_num_private_threads=$workers > stdout.out 2>&1 
	      pkill -f mpstat   
	      pkill -f dstat   
	      pkill -f free 
	      pkill -f imagenet_main
	      mv *.out  $result_dir/ 
	      mv *.log $result_dir/   
	      mv *.csv $result_dir/  
      done
   done
done
