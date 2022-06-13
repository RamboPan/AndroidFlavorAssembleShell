# 加固


function funShield {
    local shieldWay=$(echo $configJson | jq ".shield.target" | sed "s/\"//g")
    case $shieldWay in
        aijiami)
            funSheildFromAijiami $*;;
        jiagubao)
            funSheildFromJiagubao $*;;
        *)
            funLogInfo "【通知】未检测到加固方式，不进行应用加固";;
    esac
}