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

checksystem() {
	if [ -f /etc/redhat-release ]; then
	    release="centos"
	elif cat /etc/issue | grep -Eqi "debian"; then
	    release="debian"
	elif cat /etc/issue | grep -Eqi "ubuntu"; then
	    release="ubuntu"
	elif cat /etc/issue | grep -Eqi "centos|red hat|redhat"; then
	    release="centos"
	elif cat /proc/version | grep -Eqi "debian"; then
	    release="debian"
	elif cat /proc/version | grep -Eqi "ubuntu"; then
	    release="ubuntu"
	elif cat /proc/version | grep -Eqi "centos|red hat|redhat"; then
	    release="centos"
	fi
}

checkcurl() {
	if  [ ! -e '/usr/bin/curl' ]; then
	        echo "Install Curl"
	            if [ "${release}" == "centos" ]; then
	                yum update > /dev/null 2>&1
	                yum -y install curl > /dev/null 2>&1
	            else
	                apt-get update > /dev/null 2>&1
	                apt-get -y install curl > /dev/null 2>&1
	            fi
	fi
}

checkwget() {
	if  [ ! -e '/usr/bin/wget' ]; then
	        echo "Install Wget"
	            if [ "${release}" == "centos" ]; then
	                yum update > /dev/null 2>&1
	                yum -y install wget > /dev/null 2>&1
	            else
	                apt-get update > /dev/null 2>&1
	                apt-get -y install wget > /dev/null 2>&1
	            fi
	fi
}

install_miniconda() {
	echo -e "${GREEN}Installing the Miniconda...${RESET}\n"
	sudo chmod 777 /root
	mkdir -p ~/miniconda3
	ARCH=$(arch)
	if [[ ${ARCH} == "aarch64" ]]; then
	    CONDA_URL="https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-aarch64.sh"
	else
	    CONDA_URL="https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh"
	fi
	wget ${CONDA_URL} -O ~/miniconda3/miniconda.sh >/dev/null 2>&1
	bash ~/miniconda3/miniconda.sh -b -u -p ~/miniconda3 >/dev/null 2>&1
	rm -rf ~/miniconda3/miniconda.sh

	~/miniconda3/bin/conda init bash >/dev/null 2>&1
	~/miniconda3/bin/conda init zsh >/dev/null 2>&1

	source ~/.bashrc
}

install_jupyterlab() {
	DIR=$(pwd)
	echo -e "${PURPLE}Installing the Jupyterlab...${RESET}\n"
	echo -e "${CYAN}Please wait 2/3 minutes...${RESET}\n"
	SYSTEMD_SERVICE_FILE="/lib/systemd/system/jupyterlab.service"
 	sudo chmod 777 /lib/systemd/system
	mkdir -p note
	#if [ ! -f "${DIR}/miniconda3/envs/jupyter" ]; then
	#	sudo rm -r ${DIR}/miniconda3/envs/jupyter
	#	conda create -n "jupyter" python=3.9 --yes
	#else
	#	conda create -n "jupyter" python=3.9 --yes
	#fi
	echo y|conda create -n "jupyter" python=3.9 --force >/dev/null 2>&1
	conda init >/dev/null 2>&1
	source ~/.bashrc
	source ${DIR}/miniconda3/bin/activate jupyter
	conda install -c conda-forge jupyterlab --yes >/dev/null 2>&1
	#echo y|jupyter server --generate-config >/dev/null 2>&1
	if [ ! -f "${DIR}/.jupyter/jupyter_server_config.py" ]; then
		jupyter server --generate-config >/dev/null 2>&1
	else
		#sudo rm ${DIR}/.jupyter/jupyter_server_config.py
		echo y|jupyter server --generate-config >/dev/null 2>&1
	fi
	echo -e "${RED}Please input the jupyter password${RESET}"
	jupyter server password >/dev/null 2>&1
	#echo y|jupyter server --generate-config >/dev/null 2>&1
	if [ ! -f "${DIR}/.jupyter/jupyter_lab_config.py" ]; then
		jupyter lab --generate-config >/dev/null 2>&1
	else
		#sudo rm ${DIR}/.jupyter/jupyter_lab_config.py
		echo y|jupyter lab --generate-config >/dev/null 2>&1
	fi
	cat > ${DIR}/.jupyter/jupyter_lab_config.py << EOF
c.ServerApp.ip = '0.0.0.0'
c.ServerApp.allow_origin = '*'
c.ServerApp.port = 8888
c.ServerApp.open_browser = False
c.ServerApp.allow_remote_access = True
c.ServerApp.trust_xheaders = True
c.ServerApp.quit_button = False
c.ServerApp.notebook_dir = '${DIR}/note'
EOF

	# Set the server
	NAME=$USER
	cat > ${SYSTEMD_SERVICE_FILE} << EOF
[Unit]
Description=JupyterLab Service
 
[Service]
Type=simple
PIDFile=/run/jupyter.pid
ExecStart=${DIR}/miniconda3/envs/jupyter/bin/jupyter lab
User=$USER
Group=$USER
WorkingDirectory=${DIR}/note
Restart=always
RestartSec=10
 
[Install]
WantedBy=multi-user.target
EOF

	sudo systemctl daemon-reload
	sudo systemctl enable jupyterlab
	sudo systemctl start jupyterlab
	echo -e "${YELLOW}Now everything is OK, please start your ${BLUE}Data Science!${RESET}"
 	source ${DIR}/miniconda3/bin/deactivate jupyter >/dev/null 2>&1
}

runall() {
	check_root;
	checksystem;
	checkcurl;
	checkwget;
	install_miniconda;
	install_jupyterlab
}

runall
