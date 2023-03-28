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
echo -e "\033[34m欢迎使用Qexo-docker一键安装脚本v2.0.3，如果此脚本安装出现错误请进行手动部署\033[0m"
sleep 5s

echoinfo(){
    echo -e "\n\033[31m请使用ROOT权限运行此脚本\033[0m"
    echo "此脚本要做的事：对一些配置项进行设置->检测是否安装Docker及git->修改配置文件并按需运行Docker容器"
    echo -e "此脚本虽会询问你要使用的域名，但仅用于修改configs.py配置文件，\033[31m如需要进行反代请自行手动操作\033[0m"
    echo -e "\033[33m先休息10秒，如需停止运行此脚本请按 Ctrl + C 退出\033[0m"
    sleep 10s
    echo -e "\n\033[33m我们先来进行一些配置\033[0m"
    sleep 1s
}

checkport(){
    portwillbe="8000"
    portuse=`/usr/sbin/lsof -i :8000|grep -v "PID" | awk '{print $2}'`
    if [ "$portuse" != "" ];then
        echo -e "\033[31m检测到8000端口已被占用，将Qexo映射端口修改到18000\033[0m"
        portwillbe="18000"
    fi
}

basicinfo(){
    read -p " 请输入你要用来反代的域名，回车默认不使用域名反代Qexo" domain
        if [ -z "$domain" ];then
            domain="yoursite.com"
        fi
    echo -e "\033[31m再次提示此脚本不负责配置反代，如需要进行反代请自行手动操作\033[0m"    
    read -p " 如果你的博客部署在本地，那么请输入你博客源码的绝对路径，留空则视为博客不在本地" hexofile
    read -p " 接下来的配置项非必须项，是否跳过它们？回车默认跳过以一键安装，输入任意字符串以继续配置" oneclick
        if [ "$oneclick" != "" ];then
            dbinfo
            qexoinfo
        else
            checkport
            whichdb="sqlite"
            qexoname="qexo"
            qexofile="/data/qexo"
            qexoport=$portwillbe
#             qexoimage="miaowmint/qexo-docker:lightweight1.2.1"
        fi
}

dbinfo(){
    read -p " 你要使用哪种数据库？回车默认或输入sqlite以使用sqlite，输入任意其他字符串以使用mysql " whichdb
        if [ -z "$whichdb" ];then
            whichdb="sqlite"
        fi
    if [ "$whichdb" != "sqlite" ];then
        read -p " 请输入Mysql容器的名称，回车默认 qexomysql " mysqlname
            if [ -z "$mysqlname" ];then
                mysqlname="qexomysql"
            fi
        read -p " 请输入Mysql容器数据持久化的文件储存位置，回车默认 /data/qexomysql " mysqlfile
            if [ -z "$mysqlfile" ];then
                mysqlfile="/data/qexomysql"
            fi
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
    checkport
    read -p " 请输入Qexo容器的映射端口，回车默认映射到宿主机$portwillbe端口 " qexoport
        if [ -z "$qexoport" ];then
            qexoport=$portwillbe
        fi
#     echo -e "\033[34m接下来选择Qexo使用的Docker镜像，有两个选项\033[0m"
#     echo -e "\033[34m轻量化镜像基于apline，大小只有200M，但能够直接在容器内终端使用的命令很少（不影响Qexo的使用）\033[0m"
#     echo -e "\033[34m非轻量化镜像基于Debian的bullseye，能够直接在容器内终端使用的命令很全面，但大小足有1G\033[0m"
#     read -p " 请选择Qexo使用的Docker镜像，回车默认轻量化镜像，输入任意字符使用非轻量化镜像 " whichimage
#         if [ -z "$whichimage" ];then
#             qexoimage="miaowmint/qexo-docker:lightweight1.2.1"
#         else
#             qexoimage="miaowmint/qexo-docker:1.2.5"
#         fi
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
        systype=`uname -a`
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

changeconfigfile(){
    echo -e "\033[33m接下来开始修改配置文件\033[0m"
    sleep 1s
    git clone https://ghproxy.com/https://github.com/miaowmint/Qexo-docker.git $qexofile
    if [ "$whichdb" != "sqlite" ];then
        cp $qexofile/configs.mysql.py $qexofile/configs.py
        mysqlip=`docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' $mysqlname`
        echo -e "获取到Mysql容器的IP为\033[32m$mysqlip\033[0m"
        sed -i "s|mysqlip|$mysqlip|g" $qexofile/configs.py
    else
        cp $qexofile/configs.sqlite.py $qexofile/configs.py
    fi
    serverip=`curl -L www.loliapi.com/getip/`
    echo -e "获取到服务器的IP为\033[32m$serverip\033[0m"
    sed -i "s|127.0.0.1|$serverip|g" $qexofile/configs.py
    sed -i "s|yoursite.com|$domain|g" $qexofile/configs.py
    echo -e "\033[33mconfigs.py配置文件修改完成，休息5秒钟\033[0m"
    sleep 5s
}

runcontainer(){
    if [ "$whichdb" != "sqlite" ];then
        echo -e "\033[33m接下来开始运行Mysql\033[0m"
        sleep 1s
        docker run -d --name $mysqlname --hostname $mysqlname --restart always -v $mysqlfile:/var/lib/mysql -e MYSQL_ROOT_PASSWORD=password -e MYSQL_DATABASE=qexo mysql:5.7 --character-set-server=utf8mb4 --collation-server=utf8mb4_unicode_ci
        echo -e "\033[33m完成，休息10秒\033[0m"
        sleep 10s
    fi
    changeconfigfile
    echo -e "\033[33m接下来开始运行Qexo\033[0m"
    sleep 1s
    docker run -dit --name $qexoname --hostname $qexoname --restart always -v $qexofile:/usr/local/qexo -v $hexofile:$hexofile -p $qexoport:8000 miaowmint/qexo-docker:1.2.5 # $qexoimage
    echo -e "\033[33m完成，休息5秒钟\033[0m"
    sleep 5s
}

echoendinfo(){
    echo -e "\n\033[34m====================================================================================================\033[0m"
    echo -e "\n\033[33m恭喜你，安装完成了！\033[0m"
    echo -e "\033[33m你现在可以访问 http://$serverip:$qexoport/ 进行初始化并愉快的使用Qexo了（记得在安全组/防火墙放通$qexoport端口）\033[0m"
    if [ "$domain" != "yoursite.com" ];then
        echo -e "\033[33m如果你已经设置反代到 http://127.0.0.1:$qexoport/ ，那么你就可以访问 http://$domain/ 进行初始化并愉快的使用Qexo了\033[0m"
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
