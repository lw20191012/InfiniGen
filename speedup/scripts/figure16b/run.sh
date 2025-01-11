FLEXGEN_PATH=$PWD/../../flexgen
# add path，增加了本地模型路径
# MODEL_PATH="/home/onceas/liuwang/Models/opt-1.3b"
# MODEL_PATH="/home/onceas/liuwang/Models/opt-13b"
# MODEL_PATH="/home/liuwang/Models/opt-1.3b"
# MODEL_PATH="/home/liuwang/Models/opt-6.7b"
# MODEL_PATH="/home/liuwang/Models/opt-13b"
# MODEL_PATH="/home/liuwang/Models/opt-30b"

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

  # for MODEL in "opt-6.7b" "opt-13b" "opt-30b"
  for MODEL in "/home/liuwang/Models/opt-1.3b" "/home/liuwang/Models/opt-6.7b" "/home/liuwang/Models/opt-13b"
  do
    # CMD="--model huggingface/$MODEL"
    CMD="--model $MODEL"
    # if [ "$MODEL" = "opt-30b" ]
    if [ "$MODEL" = "/home/liuwang/Models/opt-13b" ]
    then
      CMD=$CMD" --percent 70 30 0 100 100 0"
    else
      CMD=$CMD" --percent 100 0 0 100 100 0"
    fi
    # CMD=$CMD" --overlap false --gpu-batch-size 4 --num-gpu-batches 1 --prompt-len 1920 --gen-len 128 --warmup-input-path pg19_firstbook.txt --test-input-path pg19_firstbook.txt"
    CMD=$CMD" --path /home/liuwang/opt_weights --offload-dir /home/liuwang/flexgen_offload_dir --overlap false --gpu-batch-size 4 --num-gpu-batches 1 --prompt-len 1920 --gen-len 128 --warmup-input-path pg19_firstbook.txt --test-input-path pg19_firstbook.txt"
    if [ "$SCHEME" = "int4" ]
    then
      CMD=$CMD" --compress-cache"
    elif [ "$SCHEME" = "h2o" ]
    then
      CMD=$CMD" --max-num-kv 409 --hh-ratio 0.1 --hh-all"
    elif [ "$SCHEME" = "infinigen" ]
    then
      CMD=$CMD" --alpha 4 --partial-weight-ratio 0.2 --max-num-kv 409"
    fi
    python -m flexgen.flex_opt $CMD
  done
done
