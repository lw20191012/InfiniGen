FLEXGEN_PATH=$PWD/../../flexgen # 从当前目录向上两层再进入 flexgen 目录
# add path，增加了本地模型路径
# MODEL_PATH="/home/onceas/liuwang/Models/opt-1.3b"
# MODEL_PATH="/home/onceas/liuwang/Models/opt-13b"
# MODEL_PATH="/home/liuwang/Models/opt-1.3b"
# MODEL_PATH="/home/liuwang/Models/opt-6.7b"
# MODEL_PATH="/home/liuwang/Models/opt-13b"
MODEL_PATH="/home/liuwang/Models/opt-30b"


for SCHEME in "original" "int4" "h2o" "infinigen"
do
  rm $FLEXGEN_PATH/flexgen/flex_opt.py
  rm $FLEXGEN_PATH/flexgen/pytorch_backend.py
  if [ "$SCHEME" = "int4" ] # int4对应的是original文件夹的代码
  then
    ln -s ../original/flex_opt.py $FLEXGEN_PATH/flexgen/flex_opt.py
    ln -s ../original/pytorch_backend.py $FLEXGEN_PATH/flexgen/pytorch_backend.py
  else
    ln -s ../$SCHEME/flex_opt.py $FLEXGEN_PATH/flexgen/flex_opt.py
    ln -s ../$SCHEME/pytorch_backend.py $FLEXGEN_PATH/flexgen/pytorch_backend.py
  fi

  for PROMPT_LEN in 384 896 1408 1920
  # for PROMPT_LEN in 2432 2944 3456 3968
  do
    # CMD="--model huggingface/opt-13b --percent 100 0 0 100 100 0 --overlap false --gpu-batch-size 8 --num-gpu-batches 1 --prompt-len $PROMPT_LEN --gen-len 128 --warmup-input-path pg19_firstbook.txt --test-input-path pg19_firstbook.txt"
    
    # add model, add path
    CMD="--model $MODEL_PATH --path /home/liuwang/opt_weights --path /home/liuwang/flexgen_offload_dir --percent 100 0 0 100 100 0 --overlap false --gpu-batch-size 8 --num-gpu-batches 1 --prompt-len $PROMPT_LEN --gen-len 128 --warmup-input-path pg19_firstbook.txt --test-input-path pg19_firstbook.txt"
    # CMD="--model $MODEL_PATH --path /home/onceas/liuwang/opt_weights --path /home/onceas/liuwang/flexgen_offload_dir --percent 100 0 0 100 100 0 --overlap false --gpu-batch-size 8 --num-gpu-batches 1 --prompt-len $PROMPT_LEN --gen-len 128 --warmup-input-path pg19_firstbook.txt --test-input-path pg19_firstbook.txt"
    # # 修改
    # CMD="--model $MODEL_PATH --path /opt/lw/InfiniGen/opt_weights --percent 100 0 100 0 100 0 --overlap false --gpu-batch-size 8 --num-gpu-batches 1 --prompt-len $PROMPT_LEN --gen-len 128 --warmup-input-path pg19_firstbook.txt --test-input-path pg19_firstbook.txt"

    if [ "$SCHEME" = "int4" ]
    then
      CMD=$CMD" --compress-cache"
    elif [ "$SCHEME" = "h2o" ]
    then
      CMD=$CMD" --max-num-kv `expr \( $PROMPT_LEN + 128 \) / 5` --hh-ratio 0.1 --hh-all"
    elif [ "$SCHEME" = "infinigen" ]
    then
      CMD=$CMD" --alpha 4 --partial-weight-ratio 0.2 --max-num-kv `expr \( $PROMPT_LEN + 128 \) / 5`"
    fi
    CUDA_VISIBLE_DEVICES=0,1 python -m flexgen.flex_opt $CMD
  done
done
