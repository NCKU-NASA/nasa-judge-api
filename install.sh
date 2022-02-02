#!/bin/bash

sudo systemctl stop nasajudgeserver.service

set -e
UBUNTU=false
DEBIAN=false
if [ "$(uname)" = "Linux" ]
then
	#LINUX=1
	if type apt-get
	then
		OS_ID=$(lsb_release -is)
		if [ "$OS_ID" = "Debian" ]; then
			DEBIAN=true
		else
			UBUNTU=true
		fi
	fi
fi

UBUNTU_PRE_2004=false
if $UBUNTU
then
	LSB_RELEASE=$(lsb_release -rs)
	# Mint 20.04 repsonds with 20 here so 20 instead of 20.04
	UBUNTU_PRE_2004=$(( $LSB_RELEASE<20 ))
	UBUNTU_2100=$(( $LSB_RELEASE>=21 ))
fi

if [ "$(uname)" = "Linux" ]
then
	#LINUX=1
	if [ "$UBUNTU" = "true" ] && [ "$UBUNTU_PRE_2004" = "1" ]
	then
		# Ubuntu
		echo "Installing on Ubuntu pre 20.04 LTS."
		set +e
		sudo apt-get update
		set -e
		sudo apt-get install -y python3.7-venv python3.7-distutils python3.7-dev
	elif [ "$UBUNTU" = "true" ] && [ "$UBUNTU_PRE_2004" = "0" ] && [ "$UBUNTU_2100" = "0" ]
	then
		echo "Installing on Ubuntu 20.04 LTS."
		set +e
		sudo apt-get update
		set -e
		sudo apt-get install -y python3.8-venv python3-distutils python3.8-dev
	elif [ "$UBUNTU" = "true" ] && [ "$UBUNTU_2100" = "1" ]
	then
		echo "Installing on Ubuntu 21.04 or newer."
		set +e
		sudo apt-get update
		set -e
		sudo apt-get install -y python3.9-venv python3-distutils python3.9-dev
	elif [ "$DEBIAN" = "true" ]
	then
		echo "Installing on Debian."
		set +e
		sudo apt-get update
		set -e
		sudo apt-get install -y python3-venv  python3-dev
	else
		echo "os not support"
		exit 0
	fi
else
	echo "os not support"
    exit 0
fi

find_python() {
	set +e
	unset BEST_VERSION
	for V in 39 3.9 38 3.8 37 3.7 3; do
		if which python$V >/dev/null; then
			if [ "$BEST_VERSION" = "" ]; then
				BEST_VERSION=$V
			fi
		fi
	done
	echo $BEST_VERSION
	set -e
}

if [ "$INSTALL_PYTHON_VERSION" = "" ]; then
	INSTALL_PYTHON_VERSION=$(find_python)
fi

INSTALL_PYTHON_PATH=python${INSTALL_PYTHON_VERSION:-3.7}

echo "Python version is $INSTALL_PYTHON_VERSION"

arch=$(dpkg --print-architecture)

wget https://github.com/mikefarah/yq/releases/download/v4.17.2/yq_linux_${arch}.tar.gz -O - | tar xz && sudo mv yq_linux_${arch} /usr/bin/yq

set +e
sudo mkdir /etc/nasajudgeserver 2> /dev/null
sudo mkdir /etc/lanloginserver/allowkey 2> /dev/null
set -e

for filename in judgescript lab.pdf node.conf requirements.txt server.py server.sh templates web
do
	sudo cp -r $filename /etc/nasajudgeserver/
done

for filename in node.conf
do
	if [ ! -f /etc/lanloginserver/$filename ]
	then
		sudo cp -r $filename /etc/lanloginserver/
	fi
done

for filename in server.sh
do
	sudo chmod +x /etc/lanloginserver/$filename
done
sudo cp  nasajudgeserver.service /lib/systemd/system/nasajudgeserver.service

cd /etc/nasajudgeserver

if [ ! -f server.key ] && [ ! -f server.crt ]
then
	sudo openssl req -x509 -new -nodes -days 3650 -newkey 2048 -keyout server.key -out server.crt -subj "/CN=$(hostname)"
fi

$INSTALL_PYTHON_PATH -m venv venv
. ./venv/bin/activate
python -m pip install --upgrade pip
python -m pip install wheel
python -m pip install -r requirements.txt
deactivate

echo ""
echo ""
echo "NASA Judge Server install.sh complete."
echo "please request your certificate from ca (or you can just use self signed certificate and put your server certificate and server private key in /etc/nasajudgeserver name to server.crt and server.key ."
echo "Then you can use systemctl start nasajudgeserver.service"
echo "If you want to auto run on boot please type 'systemctl enable nasajudgeserver.service'"
