# Data Science Platform Script

A script of setting the jupyterlab, you can use this script by the following code. Please make sure you are not in **root**.

- This script has been tested on the Ubuntu 20+, Debian 11+.

## Tutorial

### Jupyterlab Platform

Please run the following command firstly

```shell
sudo apt update
sudo apt install wget -y
```
To make sure the necessary software is existed.

```shell
wget https://raw.githubusercontent.com/wanghui5801/Jupyterlab-Script/main/jupyterlab.sh
chmod -x jupyterlab.sh
source jupyterlab.sh
```

### Rstudio Platform

Please run the below code to use this script, Please **note**, this script is just fit for the **Debian 11+**, and don't fit for the other systems.

```shell
wget https://raw.githubusercontent.com/wanghui5801/Jupyterlab-Script/main/rstudio.sh
chmod -x rstudio.sh
bash rstudio.sh
```

