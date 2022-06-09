# 加固


function funShield {
    local shieldWay=$(echo $configJson | jq ".shield.target" | sed "s/\"//g")
    case $shieldWay in
        aijiami)
            funSheildFromAijiami $*;;
        jiagubao)
            funSheildFromJiagubao $*;;
        *);;
    esac
}