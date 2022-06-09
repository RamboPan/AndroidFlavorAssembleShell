# 对齐

# align apk
# $1 srouce file
# $2 output file
function funAlign {
    local zipalignPath="$curDir/assets/align/zipalign"
    $zipalignPath -v -p 4 $1 $2
    mv $2 $1
}