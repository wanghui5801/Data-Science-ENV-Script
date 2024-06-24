#!/bin/bash
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
RESET='\033[0m'

check_root() {
    if [ "$(id -u)" == "0" ]; then
        echo -e "${RED}Please don't run it in root${RESET}"
        exit 1
    fi
}

check_port() {
	if netstat -an | grep 8787 | grep -i listen >/dev/null ; then
	    echo -e "${RED}The port 8787 is running, please stop this port.${RESET}"
	    exit 1
	fi
}


install_r() {
	echo -e "${BLUE}Installing R software, please wait...${RESET}\n"
	sudo apt install dirmngr apt-transport-https ca-certificates software-properties-common gnupg2 -y >/dev/null 2>&1
	sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys B8F25A8A73EACF41 > /dev/null 2>&1
	gpg --armor --export '95C0FAF38DB3CCAD0C080A7BDC78B2DDEABC47B7' > /dev/null 2>&1 |    sudo tee /etc/apt/trusted.gpg.d/cran_debian_key.asc > /dev/null 2>&1
	echo | sudo add-apt-repository 'deb http://cloud.r-project.org/bin/linux/debian bullseye-cran40/' >/dev/null 2>&1
	sudo apt update -y >/dev/null 2>&1
	sudo apt install r-base -y >/dev/null 2>&1
	sudo apt install build-essential -y >/dev/null 2>&1
}

install_rstudio() {
	echo -e "${PURPLE}Installing Rstudio Server, pease wait...${RESET}\n"
	sudo apt-get install gdebi-core -y > /dev/null 2>&1
	wget https://download2.rstudio.org/server/focal/amd64/rstudio-server-2024.04.2-764-amd64.deb > /dev/null 2>&1
	echo y|sudo gdebi rstudio-server-2024.04.2-764-amd64.deb > /dev/null 2>&1
}

set_user() {
	echo -e "${YELLOW}Please input your ${RED}user name${RESET}" 
	read -p "username:" user
	sudo useradd  -m  -s  /bin/bash $user > /dev/null 2>&1
	echo -e "${YELLOW}Please input your ${RED}password${RESET}" 
	read -s -p "passwd:" pw
	echo -e "${pw}\n${pw}" | sudo passwd $user >/dev/null 2>&1
	echo "${user} ALL=(ALL:ALL) NOPASSWD:ALL" | sudo tee /etc/sudoers -a > /dev/null 2>&1
}

show(){
	sudo apt install net-tools -y > /dev/null 2>&1
	ip=`ifconfig -a|grep inet|grep -v 127.0.0.1|grep -v inet6|grep -v docker|awk '{print $2}'|tr -d "addr:"| tail -n 1`
	echo -e "\n${YELLOW}Please visit the paltform by ${RED}http://$ip:8787${RESET}\n"
	echo -e "${GREEN}Your username is ${RED}$user\n${GREEN}your password is ${RED}$pw${RESET}\n"
	echo -e "${CYAN}Let's start the Data Science!${RESET}"
}

run() {
	check_root;
	check_port;
	install_r;
	install_rstudio;
	set_user;
	show;
}

run