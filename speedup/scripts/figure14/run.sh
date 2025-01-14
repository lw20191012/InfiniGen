UVM_PATH=$PWD/../../uvm
# add path，增加了本地模型路径
# MODEL_PATH="/home/liuwang/Models/opt-1.3b"
MODEL_PATH="/home/liuwang/Models"
MODEL="opt-13b" # 1.3b, 6.7b, 13b, 30b
USER_PATH="/home/liuwang"

export LD_LIBRARY_PATH=$PWD:$LD_LIBRARY_PATH
for SCHEME in "uvm" "uvm_h2o"
do
  g++ $UVM_PATH/allocate.cpp -o allocate.so --shared -fPIC -I$CUDA_HOME/include
  CMD="--embed_dim 5120 --ffn_dim 20480 --enable_bias --n_head 40 --do_layer_norm_before --n_layer 40 --bsz 20 --prompt_len 1920 --gen_len 128 --runs 1"
  
  if [ "$SCHEME" = "uvm_h2o" ]
  then 
    CMD=$CMD" --is_h2o --h2o_ratio 0.2"
  fi
  python $UVM_PATH/transformer.py $CMD
  rm allocate.so
done

FLEXGEN_PATH=$PWD/../../flexgen
for SCHEME in "original" "int4" "h2o" "infinigen"
do
  rm $FLEXGEN_PATH/flexgen/flex_opt.py
  rm $FLEXGEN_PATH/flexgen/pytorch_backend.py
  if [ "$SCHEME" = "int4" ]
  then
    ln -s ../original/flex_opt.py $FLEXGEN_PATH/flexgen/flex_opt.py
    ln -s ../original/pytorch_backend.py $FLEXGEN_PATH/flexgen/pytorch_backend.py
  else
    ln -s ../$SCHEME/flex_opt.py $FLEXGEN_PATH/flexgen/flex_opt.py
    ln -s ../$SCHEME/pytorch_backend.py $FLEXGEN_PATH/flexgen/pytorch_backend.py
  fi

  # CMD="--model huggingface/opt-13b --percent 100 0 0 100 100 0 --overlap false --gpu-batch-size 20 --num-gpu-batches 1 --prompt-len 1920 --gen-len 128 --warmup-input-path pg19_firstbook.txt --test-input-path pg19_firstbook.txt"
  CMD="--model $MODEL_PATH/$MODEL --path $USER_PATH/opt_weights --offload-dir $USER_PATH/flexgen_offload_dir --percent 100 0 0 100 100 0 --overlap false --gpu-batch-size 20 --num-gpu-batches 1 --prompt-len 1920 --gen-len 128 --warmup-input-path pg19_firstbook.txt --test-input-path pg19_firstbook.txt"
  if [ "$SCHEME" = "int4" ]
  then
    CMD=$CMD" --compress-cache"
  elif [ "$SCHEME" = "h2o" ]
  then
    CMD=$CMD" --max-num-kv 415 --hh-ratio 0.1 --hh-all"
  elif [ "$SCHEME" = "infinigen" ]
  then
    CMD=$CMD" --alpha 4 --partial-weight-ratio 0.2 --max-num-kv 400"
  fi
  python -m flexgen.flex_opt $CMD
done
