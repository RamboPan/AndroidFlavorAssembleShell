# git 更新文件

function funUpdateProject {
    # 拉取更新
    git fetch $remote
    if [ $? -ne 0 ];then
        funLogInfo "git update error"
        exit $?
    fi

    # 切换分支
    git checkout $remote/$branch
    if [ $? -ne 0 ];then
        funLogInfo "git update error"
        exit $?
    fi
}