#!/usr/bin/env bash 

set -eu

PKT_FWD_USERNAME=lora-pkt-fwd

# ensure we're running with root permissions
if [ $(id -u) != 0 ]; then
    echo This script requires root privileges
    exit 1
fi

echo Creating non-login user

if [ -e $(id -u "$PKT_FWD_USERNAME" 2>/dev/null) ]; then
    useradd -M -s /bin/false "$PKT_FWD_USERNAME"
    usermod -aG dialout "$PKT_FWD_USERNAME" 
fi


# Install LoRaWAN packet forwarder repositories
INSTALL_DIR="./"
if [ ! -d "$INSTALL_DIR" ]; then mkdir $INSTALL_DIR; fi
pushd $INSTALL_DIR

# Build LoRa gateway app

if [ ! -d lora_gateway ]; then
    git clone https://github.com/Lora-net/lora_gateway.git
fi

pushd lora_gateway

make all

popd

# Build packet forwarder

if [ ! -d packet_forwarder ]; then
    git clone https://github.com/Lora-net/packet_forwarder.git
fi

pushd packet_forwarder

make all

popd

echo Installing configuration filel

mkdir -p /etc/lora_pkt_fwd
cp ./src/global_conf.json /etc/lora_pkt_fwd
chown -R "$PKT_FWD_USERNAME":"$PKT_FWD_USERNAME" /etc/lora_pkt_fwd

echo Copying binary
cp ./packet_forwarder/lora_pkt_fwd/lora_pkt_fwd /usr/bin/lora_pkt_fwd
cp ./src/lgw.sh /usr/bin/reset_lgw.sh
chown "$PKT_FWD_USERNAME":"$PKT_FWD_USERNAME" /usr/local/bin/lora_pkt_fwd


echo Setting gateawy ID
./packet_forwarder/lora_pkt_fwd/update_gwid.sh /etc/lora_pkt_fwd/global_conf.json

echo Installing systemd service file

cp -f ./src/lora_pkt_fwd.service /etc/systemd/system/lora_pkt_fwd.service
systemctl enable lora_pkt_fwd

echo Clear temp files
rm -rf packet_forwarder
rm -rf lora_gateway

echo "lora_pkt_fwd.service has been installed!"

echo
echo "You can start the service by running:"
echo
echo "    systemctl start lora_pkt_fwd.service"
echo
echo "as root."
