#!/bin/bash

# echo "           _                               _       _   "
# echo " _ __ ___ (_) __ _  _____      ___ __ ___ (_)_ __ | |_ "
# echo "| '_ ` _ \| |/ _` |/ _ \ \ /\ / / '_ ` _ \| | '_ \| __|"
# echo "| | | | | | | (_| | (_) \ V  V /| | | | | | | | | | |_ "
# echo "|_| |_| |_|_|\__,_|\___/ \_/\_/ |_| |_| |_|_|_| |_|\__|"
# echo "                                                       "
echo '           _                               _       _   '
echo ' _ __ ___ (_) __ _  _____      ___ __ ___ (_)_ __ | |_ '
echo '| '"'"'_ ` _ \| |/ _` |/ _ \ \ /\ / / '"'"'_ ` _ \| | '"'"'_ \| __|'
echo '| | | | | | | (_| | (_) \ V  V /| | | | | | | | | | |_ '
echo '|_| |_| |_|_|\__,_|\___/ \_/\_/ |_| |_| |_|_|_| |_|\__|'
echo '                                                       '
echo -e "\033[34m欢迎使用Qexo-docker一键安装脚本v2.6.3.3，如果此脚本安装出现错误请进行手动部署\033[0m"
sleep 5s

echoinfo(){
    echo -e "\n\033[31m如果出现权限问题，请使用ROOT权限运行此脚本\033[0m"
    echo "此脚本要做的事：对一些配置项进行设置->检测是否安装Docker及git->下载并修改所需文件并按需运行Docker容器"
    echo -e "此脚本虽会询问你要使用的域名，但仅用于修改configs.py配置文件，\033[31m如需要进行反代请自行手动操作\033[0m"
    echo -e "\033[33m先休息10秒，如需停止运行此脚本请按 Ctrl + C 退出\033[0m"
    sleep 10s
    echo -e "\n\033[33m我们先来进行一些配置\033[0m"
    sleep 1s
}

checkport(){
    echo "检测8000端口是否被占用"
    sleep 1s
    portuse=`/usr/sbin/lsof -i :8000|grep -v "PID" | awk '{print $2}'`
    sleep 1s
    if [ $? -ne 0 ]; then
        if [ "$portuse" != "" ];then
            echo -e "\033[31m检测到8000端口已被占用，将Qexo映射端口修改到18000\033[0m"
            portwillbe="18000"
        else
            echo "检测到8000端口未被占用"
            portwillbe="8000"
        fi
    else
        echo -e "\n\033[31m占用情况检测失败，请确保8000端口未被其他应用占用\033[0m"
    fi
}

basicinfo(){
    read -p " 请输入你要用来反代的域名，回车默认为不使用域名反代Qexo" domain
        if [ -z "$domain" ];then
            domain="yoursite.com"
        fi
    echo -e "\033[31m再次提示此脚本不负责配置反代，如需要进行反代请自行手动操作\033[0m"    
    read -p " 如果你的博客部署在本地，那么请输入你博客源码的绝对路径，留空则视为博客部署在GithubPages等非本地位置" hexofile
    read -p " 接下来的配置项非必须项，是否跳过它们？回车默认跳过以一键安装，输入任意字符串以继续配置" oneclick
        if [ "$oneclick" != "" ];then
            qexoinfo
        else
            checkport
            qexoname="qexo"
            qexofile="/data/qexo"
            qexoport=$portwillbe
        fi
}

qexoinfo(){
    read -p " 请输入Qexo容器的名称，回车默认 qexo " qexoname
        if [ -z "$qexoname" ];then
            qexoname="qexo"
        fi
    read -p " 请输入Qexo容器文件的储存位置，回车默认 /data/qexo " qexofile
        if [ -z "$qexofile" ];then
            qexofile="/data/qexo"
        fi
    read -p " 请输入Qexo容器的映射端口，回车默认映射到宿主机 8000 端口，如果自定义端口请确保你填的端口没有被占用 " qexoport
        if [ -z "$qexoport" ];then
            checkport
            qexoport=$portwillbe
        fi
    echo -e "\033[33m配置完成了，休息10秒钟\033[0m"
    sleep 10s
}

chickandinstall(){
    echo -e "\033[33m接下来开始检测是否安装Docker及git\033[0m"
    sleep 1s
    echo "开始检测是否安装Docker......"
    sleep 1s
    docker -v
    if [ $? -eq  0 ]; then
        echo -e "\033[33m检测到Docker已安装，继续下一步\033[0m"
    else
        echo "Docker未安装，开始安装Docker环境..."
        curl -fsSL https://get.docker.com | bash -s docker --mirror Aliyun && systemctl enable docker && systemctl start docker
        echo -e "\033[33mDocker安装完成，继续下一步\033[0m"
    fi
    echo -e "\033[33m休息5秒钟\033[0m"
    sleep 5s
    echo "开始检测是否安装git......"
    sleep 1s
    git --version
    if [ $? -eq  0 ]; then
        echo -e "\033[33mgit已安装\033[0m"
    else
        echo "git未安装，开始安装git..."
        systype=`cat /etc/os-release`
        if [[ $systype =~ "centos" ]];then
            echo "判断为centos系统，使用yum安装git"
            yum -y update && yum -y install git
        else
            echo "判断为debian/ubuntu系统，使用apt安装git"
            apt -y update && apt -y install git
        fi
        echo -e "\033[33mgit安装完成，继续下一步\033[0m"
    fi
}

downloadandchangefile(){
    echo -e "\033[33m接下来开始修改配置文件\033[0m"
    sleep 1s
    git clone https://ghproxy.com/https://github.com/Qexo/Qexo.git $qexofile
    cd $qexofile && wget https://raw.githubusercontent.com/miaowmint/Qexo-docker/main/configs.py && mkdir -p $qexofile/db && cd db && wget https://raw.githubusercontent.com/miaowmint/Qexo-docker/main/db.sqlite3
    serverip=`curl -L www.loliapi.com/qexoip/`
    echo -e "获取到服务器的IP为\033[32m$serverip\033[0m"
    sed -i "s|127.0.0.1|$serverip|g" $qexofile/configs.py
    sed -i "s|yoursite.com|$domain|g" $qexofile/configs.py
    echo -e "\033[33mconfigs.py配置文件修改完成，休息5秒钟\033[0m"
    sleep 5s
}

runcontainer(){
    downloadandchangefile
    echo -e "\033[33m接下来开始运行Qexo\033[0m"
    sleep 1s
    docker run -dit --name $qexoname --hostname $qexoname --restart always -v $qexofile:/usr/local/qexo -v $hexofile:$hexofile -p $qexoport:8000 miaowmint/qexo-docker:2.6.3.1
    echo -e "\033[33m完成，休息5秒钟\033[0m"
    sleep 5s
}

echoendinfo(){
    echo -e "\n\033[34m====================================================================================================\033[0m"
    echo -e "\n\033[33m恭喜你，安装完成了！\033[0m"
    echo -e "\033[33m你现在可以访问 http://$serverip:$qexoport/ 进行初始化并愉快的使用Qexo了（记得在安全组/防火墙放通$qexoport端口）\033[0m"
    if [ "$domain" != "yoursite.com" ];then
        echo -e "\033[33m如果你已经设置域名反代到 http://127.0.0.1:$qexoport/ ，那么你就可以访问 http://$domain/ 进行初始化并愉快的使用Qexo了\033[0m"
    fi
    echo -e "\033[33m关于Qexo的初始化配置可参考 https://www.oplog.cn/qexo/configs/provider.html/ \033[0m"
    echo -e "\n\033[34m====================================================================================================\033[0m"
    sleep 2s
    echo -e "\n\033[33m你可以运行 docker logs $qexoname 以查看Qexo容器的运行日志\033[0m"
    echo -e "\033[33m如果日志末尾如下所示，则说明容器运行正常\033[0m"
    echo -e "\nSystem check identified no issues (0 silenced)."
    echo "February xx, 20xx - xx:xx:xx"
    echo "Django version 3.2.16, using settings 'core.settings'"
    echo "Starting development server at http://0.0.0.0:8000/"
    echo "Quit the server with CONTROL-C."
    echo -e "\n\033[33m如果Qexo使用有问题，请在此提交issue: https://github.com/Qexo/Qexo/issues/new/choose/ \033[0m"
    echo -e "\n\033[33m如果本一键脚本使用有问题，请在此提交issue: https://github.com/miaowmint/Qexo-docker/issues/new/ \033[0m"
}


echoinfo
basicinfo
chickandinstall
runcontainer
echoendinfo
