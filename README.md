# nasa-judge-api
NCKU NASA judge api service

- [Install](#Install)
- [Remove](#Remove)

## Install
1. clone this repo and cd into nasa-judge-api.

```bash
git clone https://github.com/NCKU-NASA/nasa-judge-api
cd nasa-judge-api
```

2. run ``install.sh``

```bash
sh install.sh
```

3. get judgeapi wireguard vpn from nasa-judge-backend and put in `/etc/wireguard/judgeapi.conf`
```
sudo systemctl stop wg-quick@judgeapi.service
sudo cp <judgeapi conf path> /etc/wireguard/judgeapi.conf
sudo systemctl start wg-quick@judgeapi.service
```

4. add smb mount point in fstab
```
sudo bash -c "echo \"//172.18.142.254/judgefiles /etc/nasajudgeapi/files  cifs    username=<smbusername>,password=<smbpasswd>   0   0\" >> /etc/fstab"
sudo mount -a
```

5. config sql info in `/etc/nasajudgeapi/db.conf` and restart service
```
sudo vi /etc/nasajudgeapi/db.conf
sudo systemctl restart nasajudgeapi.service
sudo systemctl restart nasasqlsshtunnel.service
```

6. rename your network wan interface to name `wan` and your workernode lan area to name `lan`.
![image](https://user-images.githubusercontent.com/57281249/157760749-37bbc2e8-d626-47cd-87ee-5d0a4658c07f.png)

7. change `iptablesconf.conf` lan ip from `192.168.123.0/24` to your lan ip's network id(it must be /24) and run `setupdefaultiptables.sh` to setup your iptables.
8. set all your worker allow ssh root login ther root `.ssh/id_rsa` and `.ssh/id_rsa.pub` must be same. get your worker's `.ssh/id_rsa.pub` send to frontend and send your nasajudgeapi host's root ssh pub key `.ssh/id_rsa.pub` to your all worker's `.ssh/authorized_keys`
9. use `setupnode.sh` to search and config your worker.
```
bash setupnode.sh <your workernode lan area interface ip> <min> <max>
# ex:
# bash setupnode.sh 192.168.123.254 100 200
```
10. add your student vpn config with `addvpnuser.sh`
```
bash /etc/nasajudgeserver/addvpnuser.sh <username>
```

## Remove
1. clone this repo and cd into nasa-judge-api than run remove.sh
```
git clone https://github.com/NCKU-NASA/nasa-judge-api
cd nasa-judge-api
sh remove.sh
```
