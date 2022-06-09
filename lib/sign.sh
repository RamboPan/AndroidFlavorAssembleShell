# 签名

# sign apk
# $1 srouce file
# $2 output file
function funSign {
    # key 有关
    local apksignerPath="$curDir/assets/signer/apksigner.jar"

    local keyPath=$(find $curDir/assets/key -name "*.jks")
    local keyConfig=$(echo $configJson | jq ".key")
    local keyAlias=$(echo $keyConfig | jq ".keyAlias" | sed 's/\"//g')
    local keyPassword=$(echo $keyConfig | jq ".keyPassword" | sed 's/\"//g')
    local storePassword=$(echo $keyConfig | jq ".storePassword" | sed 's/\"//g')
    
    java -jar $apksignerPath sign --ks $keyPath --ks-key-alias $keyAlias --ks-pass pass:$storePassword --key-pass pass:$keyPassword --out $2 $1
    mv $2 $1
}