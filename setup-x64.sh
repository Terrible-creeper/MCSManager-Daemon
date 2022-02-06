#!/bin/bash
printf "\033c"

mcsmanager_install_path="/opt/mcsmanager"
node_install_path="/opt/node-v14.17.6-linux-x64"

Red_Error() {
  echo '================================================='
  printf '\033[1;31;40m%b\033[0m\n' "$@"
  echo '================================================='
  exit 1
}
 
Install_Node() {
  echo "[x] rm -irf ${node_install_path}"
  rm -irf ${node_install_path}

  echo "[→] cd /opt || exit"
  cd /opt || exit

  echo "[↓] wget https://npm.taobao.org/mirrors/node/v14.17.6/node-v14.17.6-linux-x64.tar.gz"
  wget https://npm.taobao.org/mirrors/node/v14.17.6/node-v14.17.6-linux-x64.tar.gz

  echo "[↑] tar -zxf node-v14.17.6-linux-x64.tar.gz"
  tar -zxf node-v14.17.6-linux-x64.tar.gz

  echo "[x] rm -rf node-v14.17.6-linux-x64.tar.gz"
  rm -rf node-v14.17.6-linux-x64.tar.gz

  echo "[x] Delete the original Node link"
  rm -f /usr/bin/npm
  rm -f /usr/bin/node
  rm -f /usr/local/bin/npm
  rm -f /usr/local/bin/node

  echo "[+] Creating a Node link"
  ln -s ${node_install_path}/bin/npm /usr/bin/
  ln -s ${node_install_path}/bin/node /usr/bin/
  ln -s ${node_install_path}/bin/npm /usr/local/bin/
  ln -s ${node_install_path}/bin/node /usr/local/bin/

  echo "=============== Node Version ==============="
  echo " node: $(node -v)"
  echo " npm: $(npm -v)"
  echo "=============== Node Version ==============="
  echo
  echo "[-] Node Installed Successfully!"
  echo

  sleep 3
}

Install_MCSManager() {

  echo "[x] Delete the original MCSManager"
  rm -irf ${mcsmanager_install_path}

  echo "[+] mkdir -p ${mcsmanager_install_path}"
  mkdir -p ${mcsmanager_install_path} || exit

  echo "[→] cd ${mcsmanager_install_path}"
  cd ${mcsmanager_install_path} || exit

  echo "[↓] git clone MCSManager/MCSManager-Daemon-Production.git"
  git clone https://github.com.cnpmjs.org/MCSManager/MCSManager-Daemon-Production.git

  echo "[-] mv MCSManager-Daemon-Production daemon"
  mv MCSManager-Daemon-Production daemon

  echo "[→] cd daemon"
  cd daemon || exit

  echo "[+] npm install --registry=https://registry.npm.taobao.org"
  npm install --registry=https://registry.npm.taobao.org

  echo "=============== MCSManager ==============="
  echo " Daemon: ${mcsmanager_install_path}/daemon"
  echo "=============== MCSManager ==============="
  echo
  echo ""
  echo -e "\033[1;32m[ok] MCSManager installed successfully!!!\033[0m"
  echo "[ok] Location: ${mcsmanager_install_path}"
  echo
  sleep 3
}

Create_Service() {

  echo "[x] Initialize the service file"
  rm -f /etc/systemd/system/mcsm-daemon.service

  echo "[+] cat >>/etc/systemd/system/mcsm-daemon.service"
  cat >>/etc/systemd/system/mcsm-daemon.service <<'EOF'
[Unit]
Description=MCSManager Daemon

[Service]
WorkingDirectory=/opt/mcsmanager/daemon
ExecStart=/usr/bin/node app.js
ExecReload=/bin/kill -s HUP $MAINPID
ExecStop=/bin/kill -s QUIT $MAINPID

[Install]
WantedBy=multi-user.target
EOF

  echo "[-] systemctl daemon-reload"
  systemctl daemon-reload

  echo "[+] systemctl enable mcsm-daemon.service --now"
  systemctl enable mcsm-daemon.service --now

  sleep 4

  echo "=================================================================="
  echo -e "\033[1;32mWelcome to MCSManager-Daemon\033[0m"
  echo "=================================================================="
  echo "Daemon Service Address: http://localhost:24444"
  echo -e "\033[33mDone\033[0m"
  echo ""
  echo "=================================================================="
  echo "systemctl restart mcsm-daemon.service"
  echo "systemctl disable mcsm-daemon.service"
  echo "systemctl enable mcsm-daemon.service"
  echo "systemctl start mcsm-daemon.service"
  echo "systemctl stop mcsm-daemon.service"
  echo "=================================================================="

}

# ----------------- Program start ----------------- 

# rm -f "$0"

if [ $(whoami) != "root" ]; then
  Red_Error "[x] Please use Root!"
fi

is64bit=$(getconf LONG_BIT)
if [ "${is64bit}" != '64' ]; then
  Red_Error "[x] Please use 64-bit system!"
fi


echo "+----------------------------------------------------------------------
| MCSManager Installer
+----------------------------------------------------------------------
| Copyright © 2021 Suwings All rights reserved.
+----------------------------------------------------------------------
| Shell Install Script by Nuomiaa
+----------------------------------------------------------------------
"

echo "[+] Installing dependent software... (git,tar)"
yum install -y git tar
apt install -y git tar
pacman -Syu --noconfirm git tar

Install_Node
Install_MCSManager
Create_Service
