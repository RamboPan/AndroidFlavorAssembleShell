# 上传文件

# 上传单个 apk 到蒲公英
# $1 为文件地址
function funUploadApk2Pugongying {
    local updaloadTimeS=$(funCurTimeSecond)
    funNotifyUploadStart $1
    local response=$(curl -F 'file=@'$1'' -F 'uKey='$pgyUKey'' -F '_api_key='$pgyApiKey'' $pgyUrl --progress-bar)
    local code=$(echo $response | jq ".code" | sed "s/\"//g")
    # 如果返回 0 代表上传成功
    if [ 0 -eq $code ];then
        local qrCodeUrl=$(echo $response | jq ".data.appQRCodeURL" | sed "s/\"//g")
        funNotifyUploadSuccess $updaloadTimeS $1 $qrCodeUrl
    else 
        funNotifyUploadFail $1
    fi
}

# 上传 apk 所有的压缩文件
# $1 为文件地址
# $2 为上传地址
# $3 versionStr
# $4 versionCode
function funUploadZipApksToServer() {
    # 需要测试一下
    "unfinish work" > $finalApkDir$unUploadTagName
    local response=$(curl -X POST -F 'meta={"version":"6.8.12", "appType":'$3', "code":'$4'}' -F 'file=@'$1'' $2 --progress-bar)
    local code=$(echo $response | jq ".code" | sed "s/\"//g")
    # 如果返回 0 代表上传成功
    if [ "A00000" == $code ];then
        local zipUrl=$(echo $response | jq ".data.information.url" | sed "s/\"//g")
        funNotifyUploadZipSuccess $updaloadTimeS $1 $zipUrl
    else 
        funNotifyUploadZipFail $1
    fi
}

function testUpload {
    funUploadApk2Pugongying "/Users/rambopan/Desktop/test3.apk"
}