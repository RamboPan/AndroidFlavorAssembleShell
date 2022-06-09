# 日志

# 分隔符
arrowTag=">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"

# 时间戳
# 如果不传入参数，则默认取当前时间戳
# 如果传入的是 1 个参数(这里只支持传入秒)，则用第一个参数生成时间戳
# 如果传入的是 2 个参数(两个参数都传入秒)，则使用时间差生成时间戳，参数 2 晚于参数 1
function timeStamp {
    case $# in
        0)
            echo $(date '+%Y-%m-%d %H:%M:%S');;
        1)
            echo $(date -r $1 '+%Y-%m-%d %H:%M:%S');;
        2)
            local intervalS=`expr $2 - $1` 
            # 算出时分秒
            local h=$(( $intervalS / 3600 ))
            local m=$(( $intervalS % 3600 / 60))
            local s=$(( $intervalS % 3600 % 60))
            echo "${h} h ${m} m ${s} s"
            ;;
        *);;
    esac
}

# 当前时间秒
function curTimeSecond {
    echo `date '+%s'`
}

# 获取从上次时间(s)到现在时间的时间戳
function intervalFromSecondStamp {
    if [ $# -eq 1 ];then
        echo $(timeStamp $1 $(curTimeSecond))
    fi
}

# 分割线
function logDivide {
    echo $arrowTag
}

# 打印日志
function funLogInfo {
    echo -e "$(timeStamp); $*"
}

# 打印配置的信息
function funLogConfig {
    funLogInfo
    echo $* | jq .
    # 等待一下，方便确认信息
    sleep 3
    #Todo:RamboPan 打印更多的打包信息
}