# 过滤所选择的打包类型

# 字符匹配正则
strMatcher="[a-zA-Z]"

function funFilterSelect {
    local exCmdArray=()
    # 空格默认选择所有
    if [[ $select == "" ]];then
        exCmdArray=(${list[*]})
    elif [[ $(echo $select | tr 'd' 'D') == "D" ]];then
        # d / D 选择所有 Debug
        local index=0
        for oneCmd in ${list[@]};do
            if [[ $oneCmd =~ "Debug" ]] ;then
                exCmdArray[$index]=$oneCmd
                let index++
            fi
        done
    elif [[ $(echo $select | tr 'r' 'R') == "R" ]];then
        # r R 选择 Release
        local index=0
        for oneCmd in ${list[@]};do
            if [[ $oneCmd =~ "Release" ]] ;then
                exCmdArray[$index]=$oneCmd
                let index++
            fi
        done
    else 
        # 判断是否是单个词还是多个数字
        # 单个词判断是否包含，如 Ttest_Debug
        # 多个数字分割选择对应，如 1 3 5
        local index=0
        local splitList=(${list[*]})
        local selectCount=${#select[@]}
        # 正则过滤1组字符
        if [[ $selectCount -eq 1 ]] && [[ ${select[0]} =~ $strMatcher ]];then
            for splitOne in ${splitList[@]};do
                if [[ $splitOne =~ ${select[0]} ]] ;then
                    exCmdArray[$index]=$splitOne
                    let index++
                fi
            done
        else 
            # 其余情况按数字选择处理
            for selectOne in ${select[@]};do
                if [[ ${splitList[$selectOne]} != "" ]] ;then
                    exCmdArray[$index]=${splitList[$selectOne]}
                    let index++
                fi
            done
        fi

        # Todo_RamboPan 处理异常
        # 如果没有匹配的任务
        # if [ 0 -eq $index ];then
        #     echo ""
        # fi
    fi
    echo ${exCmdArray[@]}
}