# git 更新文件

function funUpdateProject {
    if [[ $remote == "" ]] || [[ $branch == "" ]];then
        funLogInfo "【警告】未添加远程仓库或者分支，暂未更新代码"
    else 
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
    fi
}