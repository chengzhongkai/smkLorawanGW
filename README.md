# smkLorawanGW
SMK custom Lorawan gateway

## Download source
`sudo apt install git`  
`git clone https://github.com/chengzhongkai/smkLorawanGW.git`

## Install
`cd smkLorawanGW`  
`sudo ./install.sh`

## get log 
`sudo journalctl -u lora_pkt_fwd.service`

## SMK Lorawan Node
You can send uplink by script ./src/smkNodeAt.py
