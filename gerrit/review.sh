#bin/bash

git_prefix=".git"

install_commit_msg(){ 
    if [ ! -f ".git/hooks/commit-msg" ]; then
        echo "请输入用户名(不需要加后缀)"
        read username
        gitdir=$(git rev-parse --git-dir); 
        scp -p -P 29418 ${username}@gerrit.zhuge.com:hooks/commit-msg ${gitdir}/hooks/
        if [ ! $? -eq 0 ]; then
            echo "commit-msg下载错误"
            exit 1
        fi
    fi
}

if [ ! -d "$git_prefix" ]; then
	echo "! [Illegal git repository directory]"
	echo "  移动脚本到git仓库根目录"
	exit 1
fi


if [ ! -d ".git/hooks" ]; then
    mkdir ".git/hooks"
	echo "mkdir successfull"
fi

while getopts "m:c" arg
do
	case $arg in
		m)
		  echo "git commit -a -m ..."
          install_commit_msg
          git commit -a -m "$OPTARG"
          ;;
		c)
		  echo "git commit -a --amend -C HEAD"
          install_commit_msg
          git commit -a --amend -C HEAD;
          ;;
	esac
done


if [ -f ".git/HEAD" ]; then
    head=$(< ".git/HEAD")
    if [[ $head = ref:\ refs/heads/* ]]; then
        git_branch="${head#*/*/}"
    else
        echo "无法获取当前分支"
	    exit 1
    fi

else
    echo "没有git中的HEAD文件"
	exit 1
fi


reviewers=("zhaoyali" "cuining" "zhangyunchao" "sunxianglong" "wangdongsheng" "gaoyu")

echo "当前分支为:$git_branch"

pushUrl="HEAD:refs/for/$git_branch%"
for reviewer in ${reviewers[@]}; do 

    echo "reviewer人员为${reviewer}"    
    pushUrl="${pushUrl}r=${reviewer},"
done
pushUrl="${pushUrl%,*}"
echo "pushUrl为:$pushUrl"
git push origin $pushUrl
if [ $? -eq 0 ]; then
	exit 0
else
	exit 1
fi
