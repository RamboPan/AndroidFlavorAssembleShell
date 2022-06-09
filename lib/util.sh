# 工具类

# 首字母大写
function funFirstUpper {
    echo $(echo ${1:0:1} | tr '[a-z]' '[A-Z]')${1:1}
}

# 首字母小写
function funFirstLower {
    echo $(echo ${1:0:1} | tr '[A-Z]' '[a-z]')${1:1}
}

# 数组拼接为一个字符串,逗号分割
function funArrayToString {
    local str=""
    for one in $@;do
        if [[ $str == "" ]];then
            str="$one"
        else
            str="$str,$one"
        fi
    done
    echo "$str"
}

# 全路径数组拼接名称为一个字符串,逗号分割
function funArrayPathToNameString {
    local str=""
    for one in $@;do
        if [[ $str == "" ]];then
            str=$(basename $one)
        else
            str=$str,$(basename $one)
        fi
    done
    echo "$str"
}