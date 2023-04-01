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

source /usr/local/qexo/shenv.sh
if [ "$WAS_EXECUTED" != "yes" ];then
    echo -e "\033[34m首次运行，开始配置nginx并使用acme.sh申请证书\033[0m"
    echo "export WAS_EXECUTED='yes'" > /usr/local/qexo/shenv.sh
    sleep 5s
    sudo cp -f /usr/local/qexo/nginx1.conf /etc/nginx/nginx.conf && sudo service nginx restart
    echo "ACCOUNT_EMAIL='$ACMEMAIL'" >> /root/.acme.sh/account.conf
    acme.sh --upgrade --auto-upgrade && acme.sh  --register-account  -m $ACMEMAIL
    # acme.sh --set-default-ca --server letsencrypt
    acme.sh  --issue  -d $QEXODOMAIN  --nginx /etc/nginx/nginx.conf
    acme.sh  --issue  -d $HEXODOMAIN  --nginx /etc/nginx/nginx.conf
    sudo cp -f /usr/local/qexo/nginx2.conf /etc/nginx/nginx.conf && sudo service nginx restart
    cd /usr/local/qexo && python manage.py makemigrations && python manage.py migrate && python manage.py runserver 0.0.0.0:8000 --noreload
else
    echo -e "\033[34m检测到配置已完成，开始重启nginx并运行qexo\033[0m"
    sleep 2s
    sudo service nginx restart
    cd /usr/local/qexo && python manage.py makemigrations && python manage.py migrate && python manage.py runserver 0.0.0.0:8000 --noreload
fi
