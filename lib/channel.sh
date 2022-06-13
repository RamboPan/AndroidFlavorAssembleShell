# 渠道标记

# 渠道(vasdolly)
# $1 srouce file
# $2 output dir
function funAddChannel {
    local vasdollyPath="$curDir/assets/channel/VasDolly.jar"

    local channelArray=()
    # 区分 主渠道 和 base 渠道，主渠道是从 mainChannel 中获取对应的，其他渠道从 baseChannel 中获取
    if [[ $blurFlavorDir  =~ "base" ]] ;then
        local channelText=$(echo $configJson | jq ".baseChannel" | sed "s/\"//g")
        channelArray=($(echo $channelText | tr '\ ' ' '))
    else
        local channels=$(echo $configJson | jq ".mainChannel" | jq keys | sed 's/\"//g' | sed 's/,//g')
        for oneChannel in ${channels[@]};do
            if [[ $blurFlavorDir =~ $oneChannel ]];then
                channelArray[0]=$(echo $configJson | jq ".mainChannel | .$oneChannel" | sed 's/\"//g')
                break
            fi
        done
    fi

    # 如果没有检测到风味设置，则不走 VasDolly
    if [[ ${channelArray[0]} != "" ]];then
        # 列表循环生成对应渠道包
        for oneChannel in ${channelArray[@]};do
            java -jar $vasdollyPath put -c $oneChannel $1 $2 
        done
        # 删除原包
        rm $apkName
    fi
}