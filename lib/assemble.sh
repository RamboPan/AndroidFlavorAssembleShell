# 打包

# 开始打包
function funAssembleApk {
    # 这里的话只在执行前清除一次
    $gradleCmd $module:clean
    # 依次执行打包任务
    for cmd in ${selectCmdArray[@]};do         
        local exCmd=$(echo ${cmd} | sed "s/\_//g")
        local oneCmdStartTimes=$(funCurTimeSecond)
        funNotifyAssembleStart $oneCmdStartTimes $cmd
        $gradleCmd $module:$am$exCmd
        if [ 0 -eq $? ];then
            # 打包顺利，找到对应 apk 判断是否是 release 包，
            # 是的话进行 加固，对齐，再签名，加渠道
            local dirArray=($(echo $cmd | tr '\_' ' '))
            local blurFlavorDir=$(funFirstLower ${dirArray[0]})
            local blurTypeDir=$(funFirstLower ${dirArray[1]})
            local blurPath=$asOutDir$blurFlavorDir/$blurTypeDir
            apkPath=$(find $blurPath -name "*.apk")
            funNotifyAssembleSuccess $oneCmdStartTimes $cmd $apkPath
            {
            # release 包会进行加入渠道、加固等操作
            if [[ $blurTypeDir =~ "release" ]] ;then
                local releaseStartTimeS=$(funCurTimeSecond)
                funNotifyReleaseOperateStart $releaseStartTimeS $cmd $apkPath
                # 多进程的话，每个任务还是需要单独用一个文件夹
                local tempCmdPath="$tempApkDir$exCmd/"
                if [ ! -d $tempCmdPath ];then
                    mkdir $tempCmdPath
                fi
                cp $apkPath $tempCmdPath
                tempFileName=$(basename $apkPath)

                # 临时文件与最终文件
                local apkName=$tempCmdPath$tempFileName
                local apkTempName=$apkName.temp

                # shield(aijiami)
                funShield $apkName $tempCmdPath

                # align
                funAlign $apkName $apkTempName

                # resign
                funSign $apkName $apkTempName

                # add channel
                funAddChannel $apkName $tempCmdPath
                originApkPath=$apkPath
                apkPath=$(find $tempCmdPath -maxdepth 1 -name "*.apk")

                # notify release ok
                funNotifyReleaseOperateSucceess $oneCmdStartTimes $cmd $originApkPath $(funArrayPathToNameString $apkPath)
            fi

            # 判断下生成了几个文件，如果只有一个直接执行
            # 如果为多个，则为 base 多标记包情况，只上传第一个
            local totalCount=${#apkPath[*]}
            if [ 1 -eq $totalCount ];then
                funUploadApk2Pugongying ${apkPath[0]}
                mv ${apkPath[0]} $finalApkDir
            else
                # 上传第一个base标记文件，循环移动所有文件
                for oneApk in ${apkPath[@]};do
                    if [ $oneApk =~ $firstBaseChannel ];then
                        funUploadApk2Pugongying $oneApk
                    fi
                    mv $oneApk $finalApkDir
                done
            fi
            }&
        elif [ 1 -eq $? ];then
            echo "打包任务被取消"
            exit 2
        else 
            exit $?
        fi
    done
    wait
}
