FLEXGEN_PATH=$PWD/../../flexgen
# add path，增加了本地模型路径
# MODEL_PATH="/home/liuwang/Models/opt-1.3b"
MODEL_PATH="/home/liuwang/Models"
MODEL="opt-13b" # 1.3b, 6.7b, 13b, 30b
USER_PATH="/home/liuwang"

rm $FLEXGEN_PATH/flexgen/flex_opt.py
rm $FLEXGEN_PATH/flexgen/pytorch_backend.py
ln -s ../infinigen/flex_opt.py $FLEXGEN_PATH/flexgen/flex_opt.py
ln -s ../infinigen/pytorch_backend.py $FLEXGEN_PATH/flexgen/pytorch_backend.py

for PARTIAL_WEIGHT_RATIO in 0.1 0.2 0.4 0.6 0.8 1.0
do
  # CMD="--model huggingface/opt-13b --percent 100 0 0 100 100 0 --overlap false --gpu-batch-size 8 --num-gpu-batches 1 --prompt-len 1920 --gen-len 128 --warmup-input-path pg19_firstbook.txt --test-input-path pg19_firstbook.txt"
  CMD="--model $MODEL_PATH/$MODEL --path $USER_PATH/opt_weights --offload-dir $USER_PATH/flexgen_offload_dir --percent 100 0 0 100 100 0 --overlap false --gpu-batch-size 8 --num-gpu-batches 1 --prompt-len 1920 --gen-len 128 --warmup-input-path pg19_firstbook.txt --test-input-path pg19_firstbook.txt"
  CMD=$CMD" --alpha 4 --partial-weight-ratio $PARTIAL_WEIGHT_RATIO --max-num-kv 409"
  python -m flexgen.flex_opt $CMD
done
