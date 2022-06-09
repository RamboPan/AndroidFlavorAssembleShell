# 加固-加固宝

function funSheildFromJiagubao {
    local jiagubaoConfig=$(echo $configJson | jq ".shield.jiagubao")
    local uName=$(echo $jiagubaoConfig | jq ".userName" | sed 's/\"//g')
    local uPswd=$(echo $jiagubaoConfig | jq ".password" | sed 's/\"//g')
    local jiagubaoPath="$curDir/assets/shield/jiagubao/jiagu.jar"
    java -jar $jiagubaoPath -login
    if [[ $? -eq 0 ]];then
        java -jar $jiagubaoPath -jiagu $1 $2 -autosign
    fi
    # todo 异常处理
    rm $apkName
    local tempShieldApk=$(find $2 -maxdepth 1 -name "*.apk")
    mv $tempShieldApk $apkName
}