# 风味配置

# 打包类别目前就 Debug Release
buildType=(Debug Release)

function funLoadFavor {
    local favorArray=()
    # 处理 favor 为数组,最多支持 5 个维度，即 config.json/buildFavor[] <= 5
    for (( i = 0 ; i < 5 ; i ++));do
        local one=$(echo $* | jq ".buildFlavor | .[$i]")
        if [[ $one != null ]];then
            favorArray[$i]=$one
        else
            break
        fi
    done

    # 打包命令数组
    local favorCmdArray=()
    # 临时数组
    local temp=()
    # 命令序号
    local cmdIndex=0
    # 获取风味维度
    local favorArrayCount=${#favorArray[*]}
    # 拼装打包命令
    # 第一次是直接设置卫第一组风味，第二次开始从上一步存放的风味开始乘以新的一组风味
    for (( i = 0 ; i < $favorArrayCount ; i ++ ));do
        local isFirstArray=${#favorCmdArray[@]}
        for oneTempFavor in $(echo ${favorArray[$i]} | sed "s/\"//g");do
            local oneFavor=$(funFirstUpper $oneTempFavor)
            #如果是首次，则直接存放第一组风味
            if [ 0 -eq $isFirstArray ];then
                temp[$cmdIndex]=$oneFavor
                let cmdIndex++
            else 
                for lastFavor in $favorCmdArray;do
                    #如果不是首次，从之前存放的数组再叠加风味
                    temp[$cmdIndex]=$lastFavor$oneFavor
                    let cmdIndex++
                done
            fi
        done
        favorCmdArray=${temp[*]}
        let cmdIndex=0
    done

    # 再拼装一次打包类型（Debug 或者 Release）
    for cmd in $favorCmdArray;do
        for type in ${buildType[@]};do
            # 加入 _ 分隔符方便下一步操作
            temp[$cmdIndex]=$cmd\_$type
            let cmdIndex++            
        done
        favorCmdArray=${temp[*]}
    done
    
    echo ${favorCmdArray[*]}
}