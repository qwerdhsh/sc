#!/bin/bash
export PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
webPort=18080
errorMsg=反馈群t.me/Scoks55555
version=v3.0
downLoadUrl=https://github.com/qwerdhsh/sc/releases/download/
serverSoft=linux_amd64_server
clientSoft=linux_amd64_client
serverUrl=${downLoadUrl}${version}/${serverSoft}.tar.gz
clientUrl=${downLoadUrl}${version}/${clientSoft}.tar.gz
s5Path=/opt/nps-socks5/
ipAdd=检测失败

if [ -n "$(grep 'Aliyun Linux release' /etc/issue)" -o -e /etc/redhat-release ];then
    OS=CentOS
    [ -n "$(grep ' 7\.' /etc/redhat-release)" ] && CentOS_RHEL_version=7
    [ -n "$(grep ' 6\.' /etc/redhat-release)" -o -n "$(grep 'Aliyun Linux release6 15' /etc/issue)" ] && CentOS_RHEL_version=6
    [ -n "$(grep ' 5\.' /etc/redhat-release)" -o -n "$(grep 'Aliyun Linux release5' /etc/issue)" ] && CentOS_RHEL_version=5
elif [ -n "$(grep 'Amazon Linux AMI release' /etc/issue)" -o -e /etc/system-release ];then
    OS=CentOS
    CentOS_RHEL_version=6
elif [ -n "$(grep bian /etc/issue)" -o "$(lsb_release -is 2>/dev/null)" == 'Debian' ];then
    OS=Debian
    [ ! -e "$(which lsb_release)" ] && { apt-get -y update; apt-get -y install lsb-release; clear; }
    Debian_version=$(lsb_release -sr | awk -F. '{print $1}')
elif [ -n "$(grep Deepin /etc/issue)" -o "$(lsb_release -is 2>/dev/null)" == 'Deepin' ];then
    OS=Debian
    [ ! -e "$(which lsb_release)" ] && { apt-get -y update; apt-get -y install lsb-release; clear; }
    Debian_version=$(lsb_release -sr | awk -F. '{print $1}')
elif [ -n "$(grep Ubuntu /etc/issue)" -o "$(lsb_release -is 2>/dev/null)" == 'Ubuntu' -o -n "$(grep 'Linux Mint' /etc/issue)" ];then
    OS=Ubuntu
    [ ! -e "$(which lsb_release)" ] && { apt-get -y update; apt-get -y install lsb-release; clear; }
    Ubuntu_version=$(lsb_release -sr | awk -F. '{print $1}')
    [ -n "$(grep 'Linux Mint 18' /etc/issue)" ] && Ubuntu_version=16
else
    echo "Does not support this OS, Please contact the author! "
    kill -9 $$
fi

#Install Basic Tools
init(){
if [[ ${OS} == Ubuntu ]];then
	apt-get  install git unzip wget -y
	apt-get  install curl
fi
if [[ ${OS} == CentOS ]];then
	yum install git unzip wget -y
  yum -y install curl
fi
if [[ ${OS} == Debian ]];then
	apt-get install git unzip wget -y
	apt-get install curl
fi
}

unstallServer(){
	if [[ -d ${s5Path}${serverSoft} ]];then
      cd ${s5Path}${serverSoft} && nps stop && nps uninstall
      rm -rf /etc/nps
      rm -rf /usr/bin/nps
      rm -rf ${s5Path}${serverSoft}
	fi
	 echo "卸载服务端成功"
}

unstallClient(){
  if [[ -d ${s5Path}${clientSoft} ]];then
  	  cd ${s5Path}${clientSoft} && npc stop &&  ./npc uninstall
    	rm -rf ${s5Path}${clientSoft}
    	rm -rf ${s5Path}${clientSoft}.tar.gz
  fi
  echo "卸载客户端成功"
}

allUninstall(){
  unstallServer
  unstallClient
  #删除之前的
  if [[ -d ${s5Path} ]];then
	  rm -rf ${s5Path}
	fi
}

#2.下载服务端
DownloadServer()
{
echo "下载nps-socks5服务中请耐心等待..."
if [[ ! -d ${s5Path} ]];then
	mkdir -p ${s5Path}	
fi

#服务端
wget -P ${s5Path} --no-cookie --no-check-certificate ${serverUrl} 2>&1 | progressfilt


if [[ ! -f ${s5Path}${serverSoft}.tar.gz ]]; then
	echo "服务端文件下载失败"${errorMsg}
	exit 0
fi

}

DownloadClient()
{
echo "下载nps-socks5客户端中请耐心等待..."
if [[ ! -d ${s5Path} ]];then
	mkdir -p ${s5Path}	
fi


#客户端
wget -P ${s5Path} --no-cookie --no-check-certificate ${clientUrl} 2>&1 | progressfilt


if [[ ! -f ${s5Path}${clientSoft}.tar.gz ]]; then
	echo "客户端文件下载失败"${errorMsg}
	exit 0
fi
}

#3.安装Socks5服务端程序
InstallServer()
{
echo ""
echo "服务端文件解压中..."

tar zxvf ${s5Path}${serverSoft}.tar.gz -C ${s5Path}

cd ${s5Path}${serverSoft}
sudo  ./nps install && nps start
}

InstallClient()
{

echo ""
echo "客户端文件解压中..."
if [[ ! -d ${s5Path}${clientSoft} ]]; then
echo "-------------"${s5Path}${clientSoft}
mkdir -p ${s5Path}${clientSoft}
fi
tar zxvf ${s5Path}${clientSoft}.tar.gz -C ${s5Path}${clientSoft}

clear
echo "客户端文件安装中..."
cd ${s5Path}${clientSoft}
if [[ $menuChoice == 1 ]];then
./npc install  -server=${ipAdd}:8025 -vkey=ij7poeu2d9btjbd3 -type=tcp && npc start
else
echo "服务器参数在[服务端]->服务列表+号中"
echo "类似：./npc -server=xxx.xxx.xxx.172:8025 -vkey=ij7poeu2d9btjbd3 -type=tcp"
echo "只需要输入:-server=xxx.xxx.xxx.172:8025 -vkey=ij7poeu2d9btjbd3 -type=tcp 即可"
read -p "请输入服务端参数： " serverParam
./npc install ${serverParam} && npc start
fi
}



checkServer(){
#检查服务端是否安装成功
SPID=`ps -ef|grep nps |grep -v grep|awk '{print $2}'`
if [[ -z ${SPID} ]]; then
echo ${SPID}"SPID----------------------"
echo "服务端安装失败"${errorMsg}
unstallServer
exit 0
fi
}


checkClient(){

CPID=`ps -ef|grep npc |grep -v grep|awk '{print $2}'`
if [[ -z ${CPID} ]]; then
echo "客户端安装失败"${errorMsg}
unstallClient
exit 0
fi
}



progressfilt ()
{
    local flag=false c count cr=$'\r' nl=$'\n'
    while IFS='' read -d '' -rn 1 c
    do
        if $flag
        then
            printf '%s' "$c"
        else
            if [[ $c != $cr && $c != $nl ]]
            then
                count=0
            else
                ((count++))
                if ((count > 1))
                then
                    flag=true
                fi
            fi
        fi
    done
}
	#安装服务端
	init
	
	allUninstall
	DownloadServer
	DownloadClient
	InstallServer
	InstallClient
	checkServer
	checkClient
	clear
	echo "--安装成功------"${errorMsg}
	echo "--后台管理地址"${ipAdd}":"${webPort}
	echo "--登录账号admin"
	echo "--登录密码admin"
	echo "默认socks5账号信息:账号socks5 密码socks5 端口5555"
	echo "如需修改后台管理端口以及账号密码请看github"
