# 通知 post
#!/bin/bash

function funNotifyText {
    curl -X POST -H "Content-Type: application/json" \
        -d "{\"msg_type\":\"text\",\"content\":{\"text\":\"$*\"}}" \
   $notifyUrl
}

function funNotifyImage {
    curl -X POST -H "Content-Type: application/json" \
        -d "{\"msg_type\":\"image\",\"content\":{\"image_key\":\"$*\"}}" \
   $notifyUrl
}

# notify format ================

# 运行所有任务开始时一些信息描述
# $1 开始时间（秒）
# $2 打包任务信息
# $3 是否上传全部压缩文件结果,已经转成字符
function funNotifyRunStartInfo {
    #提交中可能有双引号，目前没有找到一个好的方案，所以先替换为空格
    local recentCommit=$(echo $(git log --pretty=format:"%h - %an, %ar : %s" -1) | sed "s/\"/ /g")
    local curBranch=$remote/$branch
    local msg="【通知】$user 于 $(timeStamp $1) 时发起打包任务.\n\n当前分支为:【${curBranch}】,项目最新的提交信息: 【${recentCommit}】.\n\n是否上传全部压缩文件:【$3】，执行任务包括【$2】将开始执行."
    funNotifyText $msg
}

# 运行所有任务完成
# $1 开始时间（秒）
# $2 所有任务名称
function funNotifyRunAllSuccess {
    local msg="【通知】$user 于 $(timeStamp $1) 时发起打包任务,包括【$2】执行完成，共耗时【$(intervalFromSecondStamp $1)】."
    funNotifyText $msg
}

# 运行所有任务遇到失败
# $1 开始时间（秒）
# $2 所有任务名称
function funNotifyRunAllFail {
    local msg="【警告】$user 于 $(timeStamp $1) 时发起打包任务,包括【$2】执行失败，请检查."
    funNotifyText $msg
}

# 单个任务打包开始
# $1 开始时间（秒）
# $2 打包任务名
function funNotifyAssembleStart {
    local msg="【通知】于 $(timeStamp $1) 开始执行打包命令【$2】..."
    funNotifyText $msg
}

# 单个任务打包完成
# $1 开始时间（秒）
# $2 打包任务名
# $3 生成的apk全路径
function funNotifyAssembleSuccess {
    local msg="【通知】打包命令【$2】打包完成，生成文件【$(basename $3)】，耗时 $(intervalFromSecondStamp $1),进行下一步操作."
    funNotifyText $msg
}

# 正式包操作开始
# $1 开始时间（秒）
# $2 打包任务名
# $3 生成的apk全路径
function funNotifyReleaseOperateStart {
    local msg="【通知】于 $(timeStamp $1) 开始对【$2】任务生成的【$(basename $3)】文件执行加固/多渠道/重签名 ..."
    funNotifyText $msg
}       

# 正式包操作完成
# $1 开始时间（秒）
# $2 打包任务名
# $3 原文件名
# $4 生成的 apk 所有文件字符串
function funNotifyReleaseOperateSucceess {
    local msg="【通知】对【$2】任务的【$(basename $3)】文件进行加固/多渠道/重签名完成。\n\n生成【$4】等文件，耗时 $(intervalFromSecondStamp $1)"
    funNotifyText $msg
}           

# 上传开始
# $1 上传文件名（可以传全路径）
function funNotifyUploadStart {
    local msg="【通知】【$(basename $1)】文件开始上传 ..."
    funNotifyText $msg
}

# 上传成功通知
# $1 开始时间（秒）
# $2 上传文件名（可以传全路径）
# $3 二维码地址
function funNotifyUploadSuccess {
    local msg="【提醒】【$(basename $2)】文件上传完成.\n\n二维码地址为: $3.\n\n耗时 $(intervalFromSecondStamp $1)."
    funNotifyText $msg
}

# 上传失败通知
# $1 上传文件名（可以传全路径）
function funNotifyUploadFail {
    local msg="【警告】【$(basename $1)】文件上传失败，请检查."
    funNotifyText $msg
}

# 上传压缩文件成功通知
# $1 开始时间（秒）
# $2 上传文件名（可以传全路径）
# $3 压缩文件地址
function funNotifyUploadZipSuccess {
    local msg="【提醒】全部文件压缩包【$(basename $2)】上传完成.\n\n地址为: $3.\n\n耗时 $(intervalFromSecondStamp $1)."
    funNotifyText $msg
}

# 上传压缩文件失败通知
# $1 上传文件名（可以传全路径）
function funNotifyUploadZipFail {
    local msg="【警告】全部文件压缩包【$(basename $1)】文件上传失败，请检查."
    funNotifyText $msg
}

#todo 待实现上传

# notify test ================

function testNotify {
    funNotifyText "Hello"
    funNotifyImage "img_ecffc3b9-8f14-400f-a014-05eca1a4310g"
}