# 加固-爱加密

# for test use
# curDir="/Users/rambopan/Projects/Project_Android/_Mine/AndroidFlavorAssembleShell"

# $1 为 apk 路径
# $2 为 apk 输出目录
function funSheildFromAijiami {
    local aijiamiConfig=$(echo $configJson | jq ".shield.aijiami")
    local uName=$(echo $aijiamiConfig | jq ".userName" | sed 's/\"//g')
    local type=$(echo $aijiamiConfig | jq ".type" | sed 's/\"//g')
    local so=$(echo $aijiamiConfig | jq ".so" | sed 's/\"//g')
    local aijiamiPath="$curDir/assets/shield/aijiami/encryptiontool-1.2_forsoapi_20180602.jar"
    java -jar $aijiamiPath $uName $1 $2 $so $type
    # 需要处理下，未加固成功的情况
    local tempShieldApk=$(find $2 -maxdepth 1 -name "*.apk")
    if [[ $(basename $tempShieldApk) == $(basename $apkName) ]];then
        funLogInfo "【警告】爱加密未调用成功，暂不进行应用加固"
    else 
        rm $apkName
        mv $tempShieldApk $apkName
    fi
}

function testShield {
    local file="/Users/rambopan/Desktop/test3.apk"
    local dir="/Users/rambopan/Desktop/"
    funSheildFromAijiami $file $dir
}

# testShield