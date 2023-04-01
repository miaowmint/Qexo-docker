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
echo -e "\033[34m欢迎使用Qexo-docker一键安装脚本v2.6.4.2(04.02)，如果此脚本安装出现错误请进行手动部署\033[0m"
sleep 5s

echoinfo(){
    echo -e "\n\033[31m如果出现权限问题，请使用ROOT权限运行此脚本\033[0m"
    echo "此脚本要做的事：对一些配置项进行设置->检测是否安装Docker及git->下载并修改所需文件并按需运行Docker容器"
    echo "此脚本中提到的 hexo 特指qexo支持的所有静态博客，不止局限于hexo"
    echo "此脚本中部分配置是固定的，如需修改请通过源码 otherinfo 处自行修改"
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
    # read -p " 你的hexo是否部署在本地？回车默认为部署在本地，输入任意字符视为部署在github等托管平台 " locally
    #     if [ -z "$locally" ];then
    #         locally="yes"
    #     fi
    echo -e "\n\033[31m此脚本默认你的hexo部署在本地，如果你的hexo部署在github等托管平台，建议你使用Vercel部署，参考 https://www.oplog.cn/qexo/start/build.html （其实是因为逻辑太麻烦我懒得写）\033[0m"
    echo -e "你是否需要镜像内置的nginx来反代qexo和hexo？（反代后可以通过域名访问qexo和hexo，\n但如果你的服务器已经安装了nginx等web服务端，或是后续有建其他网站的需求，建议你在服务器上自行反代而不是用镜像内置的nginx反代）"
    read -p " 请注意，回车默认为使用镜像内置的nginx反代，输入任意字符视为无需反代或自行反代 " useproxy
        if [ -z "$useproxy" ];then
            useproxy="yes"
        fi
    read -p " 请输入你的qexo使用的域名，回车默认为不需要使用域名反代Qexo " qexodomain
        if [ -z "$qexodomain" ];then
            qexodomain="yourqexo.com"
        fi 
    read -p " 请输入你hexo源码的绝对路径 " hexofile
        if [ -z "$hexofile" ];then
            hexofile="/www/site"
        fi 
    if [ "$useproxy" == "yes" ];then
        read -p " 请输入你的hexo使用的域名 " hexodomain
            if [ -z "$hexodomain" ];then
                hexodomain="yourhexo.com"
            fi 
        read -p " 请输入你的邮箱（用于申请ssl证书） " acmemail
            if [ -z "$acmemail" ];then
                acmemail="example@qexo.com"
            fi 
    fi
    otherinfo
}

otherinfo(){
    checkport
    qexoname="qexo"
    qexofile="/data/qexo"
    qexoport=$portwillbe
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
    cd $qexofile && wget https://ghproxy.com/https://github.com/miaowmint/Qexo-docker/releases/download/1.0.1/Qexo-docker1.0.1.tar.gz && tar zxvf Qexo-docker1.0.1.tar.gz && rm Qexo-docker1.0.1.tar.gz
    serverip=`curl -L www.loliapi.com/qexoip/`
    echo -e "获取到服务器的IP为\033[32m$serverip\033[0m"
    sed -i "s|127.0.0.1|$serverip|g" $qexofile/configs.py
    sed -i "s|yourqexo.com|$qexodomain|g" $qexofile/configs.py
    sed -i "s|yourqexo.com|$qexodomain|g" $qexofile/nginx1.conf
    sed -i "s|yourhexo.com|$hexodomain|g" $qexofile/nginx1.conf
    sed -i "s|/www/site|$hexofile|g" $qexofile/nginx1.conf
    sed -i "s|yourqexo.com|$qexodomain|g" $qexofile/nginx2.conf
    sed -i "s|yourhexo.com|$hexodomain|g" $qexofile/nginx2.conf
    sed -i "s|/www/site|$hexofile|g" $qexofile/nginx2.conf
    echo -e "\033[33m配置文件修改完成，休息5秒钟\033[0m"
    sleep 5s
}

runcontainer(){
    downloadandchangefile
    echo -e "\033[33m接下来开始运行Qexo\033[0m"
    sleep 1s
    if [ "$useproxy" == "yes" ];then
    docker run -dit --name $qexoname --hostname $qexoname --restart always -v $qexofile:/usr/local/qexo -v $hexofile:$hexofile -p 80:80 -p 443:443 -e USEPROXY=$useproxy -e QEXODOMAIN=$qexodomain -e HEXODOMAIN=$hexodomain -e ACMEMAIL=$acmemail miaowmint/qexo-docker:latest
    else
    docker run -dit --name $qexoname --hostname $qexoname --restart always -v $qexofile:/usr/local/qexo -v $hexofile:$hexofile -p $qexoport:8000 miaowmint/qexo-docker:latest
    fi
    echo -e "\033[33m完成，休息5秒钟\033[0m"
    sleep 5s
}

echoendinfo(){
    echo -e "\n\033[34m====================================================================================================\033[0m"
    echo -e "\n\033[33m恭喜你，安装完成了！\033[0m"
    echo -e "\033[33m你现在可以访问 http://$serverip:$qexoport/ 进行初始化并愉快的使用Qexo了（记得在安全组/防火墙放通$qexoport端口）\033[0m"
    if [ "$qexodomain" != "yourqexo.com" ];then
        sleep 5s
        echo -e "\033[33m如果你使用了镜像内置的nginx反代或已经自行设置域名反代到 http://127.0.0.1:$qexoport/ ，那么你就可以访问 http://$qexodomain/ 进行初始化并愉快的使用Qexo了\033[0m"
    fi
    if [ "$hexodomain" != "yourhexo.com" ];then
        sleep 5s
        echo -e "\033[33m如果你在 $hexofile 上传了hexo源码，那你现在就可以访问 http://$hexodomain/ 访问自己的博客了\033[0m"
    fi
    echo -e "\033[33m关于Qexo的初始化配置可参考 https://www.oplog.cn/qexo/configs/provider.html \033[0m"
    echo -e "\n\033[34m====================================================================================================\033[0m"
    sleep 2s
    echo -e "\n\033[33m你可以运行 docker logs $qexoname 以查看Qexo容器的运行日志\033[0m"
    echo -e "\n\033[33m如果Qexo使用有问题，请在此提交issue: https://github.com/Qexo/Qexo/issues/new/choose/ \033[0m"
    echo -e "\n\033[33m如果本一键脚本使用有问题，请在此提交issue: https://github.com/miaowmint/Qexo-docker/issues/new/ \033[0m"
}


echoinfo
basicinfo
chickandinstall
runcontainer
echoendinfo
