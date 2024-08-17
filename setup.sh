apt update && apt upgrade
# Adjust With The Minecraft Version
apt install openjdk-21-jre-headless
apt install screen

# Setup The Ports
iptables -A INPUT -p tcp --dport 25565 -j ACCEPT
iptables -A INPUT -p udp --dport 25565 -j ACCEPT

# Add Eula Acception
echo "eula=true" >> eula.txt

# Add Survival Plugin
mkdir plugins
cd plugins

curl https://plixhost-cdn.s3.ir-thr-at1.arvanstorage.ir/binaries%2FSurvival-1.0.jar >> Survival.jar

# Setup The Server
cd ..
# Replace With The Requested Version
curl https://api.papermc.io/v2/projects/paper/versions/1.21.1/builds/17/downloads/paper-1.21.1-17.jar >> server.jar

chmod +x run.sh
#* Next Steps
#* 1. Open A Screen Session
#* 2. Run!