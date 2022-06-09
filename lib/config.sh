# 所需变量

# 这里是需要配置的信息，可以不用修改
# module名称，一般为 app
module="app"
# 当前路径
curDir=$(pwd -P)
# 最终输出目录文件夹名
apkOutput="apkOutput"
# 输出临时存放的目录名
apkTemp="apkTemp"
# 打包命令
am="assemble"
# mac/linux gradle 脚本
gradleCmd="./gradlew"
# 最后输出绝对路径
finalApkDir="$curDir/$apkOutput/"
# 临时输出目录（方便打包后进行加固或者多渠道操作）
tempApkDir="$curDir/$apkTemp/"
# as 输出的默认目录
asOutDir="$module/build/outputs/apk/"
# 配置文件
jsonFile="config.json"
# 当前用户 
user=$(whoami)
# json 配置
configJson=$(cat $jsonFile)
# 未上传完成标记
unUploadTagName="unUploadTag"
# 上传压缩文件的服务器地址
uploadZipUrl=$(echo $configJson | jq ".uploadZipUrl" | sed "s/\"//g")
# 项目地址
projectDir=$(echo $configJson | jq ".projectDir" | sed "s/\"//g")
# 远程仓库
remote=$(echo $configJson | jq ".gitRemote" | sed "s/\"//g")
# 当前分支
branch=$(echo $configJson | jq ".gitBranch"  | sed "s/\"//g")
# 通知地址
notifyUrl=$(echo $configJson | jq ".notifyUrl" | sed "s/\"//g")
# 找到base渠道第一个标记名,可能为空字符
baseChannels=($(echo $configJson | jq ".baseChannel" | sed "s/\"//g"))
firstBaseChannel=${baseChannels[0]}

# 蒲公英配置
pgyConfig=$(echo $configJson | jq ".pugongying")
pgyUrl=$(echo $pgyConfig | jq ".url" | sed "s/\"//g")
pgyUKey=$(echo $pgyConfig | jq ".uKey" | sed "s/\"//g")
pgyApiKey=$(echo $pgyConfig | jq ".apiKey" | sed "s/\"//g")