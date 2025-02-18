#!/bin/bash

# export HF_ENDPOINT=https://hf-mirror.com

# # 模型名称列表和对应的本地目录
# MODELS=(
#     "facebook/opt-1.3b"
#     "facebook/opt-6.7b"
#     "facebook/opt-13b"
#     "facebook/opt-30b")

# # 循环遍历每个模型
# for MODEL_NAME in "${MODELS[@]}"; do
#     LOCAL_DIR=$(basename $MODEL_NAME) # 提取模型名称作为本地目录

#     # 循环直到成功下载当前模型
#     while true; do
#         echo "Starting or resuming download of $MODEL_NAME to $LOCAL_DIR..."

#         # 执行huggingface-cli的下载命令
#         huggingface-cli download --resume-download --local-dir $LOCAL_DIR --local-dir-use-symlinks False $MODEL_NAME --exclude "flax*" --exclude "tf*"
#         # huggingface-cli download --resume-download --local-dir $LOCAL_DIR --local-dir-use-symlinks False $MODEL_NAME

#         # 检查命令的返回值 $? 如果为 0 则表示成功
#         if [ $? -eq 0 ]; then
#             echo "Download of $MODEL_NAME completed successfully."
#             break
#         else
#             echo "Download of $MODEL_NAME interrupted or failed. Retrying..."
#         fi

#         # 休眠 10 秒后重试，以避免频繁的重试
#         sleep 10
#     done
# done



export HF_ENDPOINT=https://hf-mirror.com

# 模型名称列表和对应的本地目录
MODELS=(
    "facebook/opt-1.3b"
    "facebook/opt-6.7b"
    "facebook/opt-13b"
    "facebook/opt-30b")

# 日志文件路径
LOG_FILE="download_log.txt"

# 循环遍历每个模型
for MODEL_NAME in "${MODELS[@]}"; do
    LOCAL_DIR=$(basename $MODEL_NAME) # 提取模型名称作为本地目录

    # 循环直到成功下载当前模型
    while true; do
        echo "$(date): Starting or resuming download of $MODEL_NAME to $LOCAL_DIR..." | tee -a $LOG_FILE

        # 使用 timeout 命令限制单次下载时间为 30 分钟
        timeout 1800 huggingface-cli download \
            --resume-download \
            --local-dir $LOCAL_DIR \
            --local-dir-use-symlinks False \
            $MODEL_NAME \
            --exclude "flax*" "tf*"

        # 检查命令的返回值 $? 如果为 0 则表示成功
        if [ $? -eq 0 ]; then
            echo "$(date): Download of $MODEL_NAME completed successfully." | tee -a $LOG_FILE
            break
        else
            echo "$(date): Download of $MODEL_NAME interrupted or failed. Retrying..." | tee -a $LOG_FILE
        fi

        # 休眠 10 秒后重试，以避免频繁的重试
        sleep 10
    done
done
