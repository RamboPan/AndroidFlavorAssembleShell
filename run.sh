#!/bin/bash

# AndroidFlavorAssembleShell
# Android 风味打包脚本
# Author:RamboPan
# Version:2.0
# Github:https://github.com/RamboPan/AndroidFlavorAssembleShell

# 这里需要跳转下脚本目录，这里的示范是 mini 上位置。
# 脚本文件夹路径
# shDir="/Users/mac_mini/Desktop/AssembleShell"
# cd $shDir

# 加载文件
. ./lib/config.sh
. ./lib/log.sh
. ./lib/update.sh
. ./lib/flavor.sh
. ./lib/filter.sh
. ./lib/assemble.sh
. ./lib/util.sh
. ./lib/channel.sh
. ./lib/notify.sh
. ./lib/upload.sh
. ./lib/shield.sh
. ./lib/aijiami.sh
. ./lib/jiagubao.sh
. ./lib/align.sh
. ./lib/sign.sh

# >>>>>>>>>>>>>> 流程开始 >>>>>>>>>>>>>>>>

#Todo_RamboPan 增加未完成文件检测再次上传

# 删除之前的文件目录
if [ -e $finalApkDir ];then
    rm -r $finalApkDir
fi
mkdir $finalApkDir
if [ -e $tempApkDir ];then
    rm -r $tempApkDir
fi
mkdir $tempApkDir

# 输出配置的 json 
funLogConfig $configJson

# 跳转项目目录准备更新
cd $projectDir

# 用 git 更新工程 git
funUpdateProject $configJson

# 获取所有风味打包类型
list=$(funLoadFlavor $configJson)

# 输出选择
funLogInfo ">>> 检测到的可执行任务如下 >>> "
allIndex=0
for one in $list;do
    echo "$allIndex $one"
    let allIndex++
done
funLogInfo "* 检测到共 $allIndex 个可执行的任务.\n* 输入 d 选择所有 debug 任务.\n* 输入 r 选择所有 release 任务.\n* 输入需要的任务序号，并以空格分隔，可以执行所有对应序号任务，比如 0 2 4.\n* 输入一串字符会搜索所有符合的任务，比如 Ttest_Debug .\n* 直接回车选择所有任务."
read -p "请选择:" select

# 是否压缩所有 apk 并上传指定服务器，1 为否，0 为是。
funLogInfo "* 是否将所有生成 apk 压缩后上传指定服务器? \n* Y/y 为是，直接回车及其他为否."
read -p "请选择:" isUploadZipAll
if [[ "Y" == $(echo $isUploadZipAll | tr 'y' 'Y') ]];then
    isUploadZipAll=0
else
    isUploadZipAll=1
fi

# 过滤需要执行的任务
selectCmdArray=$(funFilterSelect)

# 输出需要打包的命令
exCmdCount=0
for oneCmd in ${selectCmdArray[@]};do
    if [[ oneCmd == "" ]];then
        break
    else
        if [ $exCmdCount -eq 0 ];then
            funLogInfo ">>>>>>>>>> 选择的任务如下 >>>>>>>>>>>>"
        fi
        funLogInfo $oneCmd
        let exCmdCount++
    fi
done

isUploadZipAllRet="否"
# 输出任务个数，是否开始执行
if [[ exCmdCount -eq 0 ]];then
    funLogInfo ">>>>>>>>>> 没有合适的任务,停止打包 >>>>>>>>>>"
    exit
else
    if [ 0 -eq $isUploadZipAll ];then
        isUploadZipAllRet="是"
    fi
    funLogInfo ">>>>>>>>>> 共【${exCmdCount}】个,是否上传全部压缩文件：【${isUploadZipAllRet}】,请确认,3 秒后开始打包 >>>>>>>>>"
    sleep 3
fi

# 开始打包，记录下开始时间，拼凑下所有任务名称
startTimeS=$(funCurTimeSecond)
arrayString=$(funArrayToString ${selectCmdArray[@]})
funNotifyRunStartInfo $startTimeS $arrayString $isUploadZipAllRet
funAssembleApk

# 结果通知
if [[ 0 -eq $? ]];then
    # 如果最后需要压缩上传，单独处理一下
    if [[ 0 -eq $isUploadZipAll ]];then
        zipName=$(echo $(funTimeStamp) | sed "s/\ /\_/g;s/\-//g;s/\://g;")_apks.zip
        zip -r $finalApkDir$zipName $finalApkDir -i *.apk
        #Todo_RamboPan 需要考虑如何把压缩的文件上传到指定位置,以及是否删除掉所有产生的 apk
        cd $finalApkDir
        funUploadZipApksToServer $zipName $uploadZipUrl "6.8.12" "135"
    fi
    
    # 处理下失败的情况
    funLogInfo ">>>>>>>>>>> 【通知】$user 于 $(funTimeStamp $startTimeS) 时发起打包任务,包括【${arrayString}】执行完成，共耗时 $(funIntervalFromSecondStamp $startTimeS). >>>>>>>>>>"
    funNotifyRunAllSuccess $startTimeS $arrayString
else 
    funLogInfo ">>>>>>>>>>> 【警告】$user 于 $(funTimeStamp $startTimeS) 时发起打包任务,包括【${arrayString}】执行失败，请检查. >>>>>>>>>>>"
    funNotifyRunAllFail $startTimeS $arrayString
fi