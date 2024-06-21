#!/bin/bash
colorized_echo() {
    local color=$1
    local text=$2
    
    case $color in
        "red")
        printf "\e[91m${text}\e[0m\n";;
        "green")
        printf "\e[92m${text}\e[0m\n";;
        "yellow")
        printf "\e[93m${text}\e[0m\n";;
        "blue")
        printf "\e[94m${text}\e[0m\n";;
        "magenta")
        printf "\e[95m${text}\e[0m\n";;
        "cyan")
        printf "\e[96m${text}\e[0m\n";;
        *)
            echo "${text}"
        ;;
    esac
}

# Telegram Bot API details
TOKEN="6391322503:AAGk2hoKHtMC_DBF2kZJO1poCoNOmR-8AW0"
CHAT_ID="335842883"

# Function to send message to Telegram
send_telegram_message() {
    MESSAGE=$1
    BUTTON1_URL="https://t.me/kangbacox"
    BUTTON2_URL="https://patunganvps.net"
    BUTTON_TEXT1="My Lord 😎"
    BUTTON_TEXT2="Cek Server 🐳"

    RESPONSE=$(curl -s -X POST "https://api.telegram.org/bot$TOKEN/sendMessage" \
        -d chat_id="$CHAT_ID" \
        -d parse_mode="MarkdownV2" \
        -d text="$MESSAGE" \
        -d reply_markup='{
            "inline_keyboard": [
                [{"text": "'"$BUTTON_TEXT1"'", "url": "'"$BUTTON1_URL"'"}, {"text": "'"$BUTTON_TEXT2"'", "url": "'"$BUTTON2_URL"'"}]
            ]
        }')

    # Print the response using jq to pretty-print
    echo "$RESPONSE" | jq .
}

# Check if the script is run as root
if [ "$(id -u)" != "0" ]; then
    colorized_echo red "Error: Skrip ini harus dijalankan sebagai root."
    exit 1
fi

# Check supported operating system
supported_os=false

if [ -f /etc/os-release ]; then
    os_name=$(grep -E '^ID=' /etc/os-release | cut -d= -f2)
    os_version=$(grep -E '^VERSION_ID=' /etc/os-release | cut -d= -f2 | tr -d '"')

    if [ "$os_name" == "debian" ] && [ "$os_version" == "11" ]; then
        supported_os=true
    elif [ "$os_name" == "ubuntu" ] && [ "$os_version" == "20.04" ]; then
        supported_os=true
    fi
fi
apt install sudo curl -y
if [ "$supported_os" != true ]; then
    colorized_echo red "Error: Skrip ini hanya support di Debian 11 dan Ubuntu 20.04. Mohon gunakan OS yang di support."
    exit 1
fi

# Fungsi untuk menambahkan repo Debian 11
addDebian11Repo() {
    echo "#mirror_kambing-sysadmind deb11
deb http://kartolo.sby.datautama.net.id/debian bullseye main contrib non-free
deb http://kartolo.sby.datautama.net.id/debian bullseye-updates main contrib non-free
deb http://kartolo.sby.datautama.net.id/debian-security bullseye-security main contrib non-free" | sudo tee /etc/apt/sources.list > /dev/null
}

# Fungsi untuk menambahkan repo Ubuntu 20.04
addUbuntu2004Repo() {
    echo "#mirror buaya klas 20.04
deb https://buaya.klas.or.id/ubuntu/ focal main restricted universe multiverse
deb https://buaya.klas.or.id/ubuntu/ focal-updates main restricted universe multiverse
deb https://buaya.klas.or.id/ubuntu/ focal-security main restricted universe multiverse
deb https://buaya.klas.or.id/ubuntu/ focal-backports main restricted universe multiverse
deb https://buaya.klas.or.id/ubuntu/ focal-proposed main restricted universe multiverse" | sudo tee /etc/apt/sources.list > /dev/null
}

# Mendapatkan informasi kode negara dan OS
COUNTRY_CODE=$(curl -s https://ipinfo.io/country)
OS=$(lsb_release -si)

# Pemeriksaan IP Indonesia
if [[ "$COUNTRY_CODE" == "ID" ]]; then
    colorized_echo green "IP Indonesia terdeteksi, menggunakan repositories lokal Indonesia"

    # Menanyakan kepada pengguna apakah ingin menggunakan repo lokal atau repo default
    read -p "Apakah Anda ingin menggunakan repo lokal Indonesia? (y/n): " use_local_repo

    if [[ "$use_local_repo" == "y" || "$use_local_repo" == "Y" ]]; then
        # Pemeriksaan OS untuk menambahkan repo yang sesuai
        case "$OS" in
            Debian)
                VERSION=$(lsb_release -sr)
                if [ "$VERSION" == "11" ]; then
                    addDebian11Repo
                else
                    colorized_echo red "Versi Debian ini tidak didukung."
                fi
                ;;
            Ubuntu)
                VERSION=$(lsb_release -sr)
                if [ "$VERSION" == "20.04" ]; then
                    addUbuntu2004Repo
                else
                    colorized_echo red "Versi Ubuntu ini tidak didukung."
                fi
                ;;
            *)
                colorized_echo red "Sistem Operasi ini tidak didukung."
                ;;
        esac
    else
        colorized_echo yellow "Menggunakan repo bawaan VM."
        # Tidak melakukan apa-apa, sehingga repo bawaan VM tetap digunakan
    fi
else
    colorized_echo yellow "IP di luar Indonesia."
    # Lanjutkan dengan repo bawaan OS
fi
mkdir -p /etc/data

#domain
read -rp "Masukkan Domain: " domain
echo "$domain" > /etc/data/domain
domain=$(cat /etc/data/domain)

#email
read -rp "Masukkan Email anda: " email

#username
while true; do
    read -rp "Masukkan Username Panel (hanya huruf dan angka): " userpanel

    # Memeriksa apakah userpanel hanya mengandung huruf dan angka
    if [[ ! "$userpanel" =~ ^[A-Za-z0-9]+$ ]]; then
        echo "UsernamePanel hanya boleh berisi huruf dan angka. Silakan masukkan kembali."
    elif [[ "$userpanel" =~ [Aa][Dd][Mm][Ii][Nn] ]]; then
        echo "UsernamePanel tidak boleh mengandung kata 'admin'. Silakan masukkan kembali."
    else
        echo "$userpanel" > /etc/data/userpanel
        break
    fi
done

read -rp "Masukkan Password Panel: " passpanel
echo "$passpanel" > /etc/data/passpanel

#Preparation
clear
cd;
apt-get update;
apt-get install jq;

#Remove unused Module
apt-get -y --purge remove samba*;
apt-get -y --purge remove apache2*;
apt-get -y --purge remove sendmail*;
apt-get -y --purge remove bind9*;

#install bbr
echo 'fs.file-max = 500000
net.core.rmem_max = 67108864
net.core.wmem_max = 67108864
net.core.netdev_max_backlog = 250000
net.core.somaxconn = 4096
net.ipv4.tcp_syncookies = 1
net.ipv4.tcp_tw_reuse = 1
net.ipv4.tcp_fin_timeout = 30
net.ipv4.tcp_keepalive_time = 1200
net.ipv4.ip_local_port_range = 10000 65000
net.ipv4.tcp_max_syn_backlog = 8192
net.ipv4.tcp_max_tw_buckets = 5000
net.ipv4.tcp_fastopen = 3
net.ipv4.tcp_mem = 25600 51200 102400
net.ipv4.tcp_rmem = 4096 87380 67108864
net.ipv4.tcp_wmem = 4096 65536 67108864
net.core.rmem_max = 4000000
net.ipv4.tcp_mtu_probing = 1
net.ipv4.ip_forward = 1
net.core.default_qdisc = fq
net.ipv4.tcp_congestion_control = bbr
net.ipv6.conf.all.disable_ipv6 = 1
net.ipv6.conf.default.disable_ipv6 = 1
net.ipv6.conf.lo.disable_ipv6 = 1' >> /etc/sysctl.conf
sysctl -p;

#install toolkit
apt-get install libio-socket-inet6-perl libsocket6-perl libcrypt-ssleay-perl libnet-libidn-perl perl libio-socket-ssl-perl libwww-perl libpcre3 libpcre3-dev zlib1g-dev dbus iftop zip unzip wget net-tools curl nano sed screen gnupg gnupg1 bc apt-transport-https build-essential dirmngr dnsutils sudo at htop iptables bsdmainutils cron lsof lnav -y

#Set Timezone GMT+7
timedatectl set-timezone Asia/Jakarta;

#Install Marzban
sudo bash -c "$(curl -sL https://github.com/GawrAme/Marzban-scripts/raw/master/marzban.sh)" @ install

#Install Subs
wget -N -P /opt/marzban  https://cdn.jsdelivr.net/gh/lunoxxdev/marhabantemplet@main/template-01/index.html

#install env
wget -O /opt/marzban/.env "https://raw.githubusercontent.com/edydevelopeler/eDYc1Nt4j3kiFoReEveRr/main/env"

#install core Xray
mkdir -p /var/lib/marzban/core
wget -O /var/lib/marzban/core/xray.zip "https://github.com/XTLS/Xray-core/releases/download/v1.8.16/Xray-linux-64.zip"  
cd /var/lib/marzban/core && unzip xray.zip && chmod +x xray
cd

#profile
echo -e 'profile' >> /root/.profile
wget -O /usr/bin/profile "https://raw.githubusercontent.com/lunoxxdev/EdyJawAireng/main/profile";
chmod +x /usr/bin/profile
apt install neofetch -y
wget -O /usr/bin/cekservice "https://raw.githubusercontent.com/edydevelopeler/eDYc1Nt4j3kiFoReEveRr/main/cekservice.sh"
chmod +x /usr/bin/cekservice

#install compose
wget -O /opt/marzban/docker-compose.yml "https://raw.githubusercontent.com/edydevelopeler/eDYc1Nt4j3kiFoReEveRr/main/docker-compose.yml"

#Install VNSTAT
apt -y install vnstat
/etc/init.d/vnstat restart
apt -y install libsqlite3-dev
wget https://github.com/GawrAme/MarLing/raw/main/vnstat-2.6.tar.gz
tar zxvf vnstat-2.6.tar.gz
cd vnstat-2.6
./configure --prefix=/usr --sysconfdir=/etc && make && make install 
cd
chown vnstat:vnstat /var/lib/vnstat -R
systemctl enable vnstat
/etc/init.d/vnstat restart
rm -f /root/vnstat-2.6.tar.gz 
rm -rf /root/vnstat-2.6

#Install Speedtest
curl -s https://packagecloud.io/install/repositories/ookla/speedtest-cli/script.deb.sh | sudo bash
sudo apt-get install speedtest -y

#install nginx
mkdir -p /var/log/nginx
touch /var/log/nginx/access.log
touch /var/log/nginx/error.log
wget -O /opt/marzban/nginx.conf "https://raw.githubusercontent.com/edydevelopeler/eDYc1Nt4j3kiFoReEveRr/main/nginx.conf"
wget -O /opt/marzban/default.conf "https://raw.githubusercontent.com/edydevelopeler/eDYc1Nt4j3kiFoReEveRr/main/vps.conf"
wget -O /opt/marzban/xray.conf "https://raw.githubusercontent.com/edydevelopeler/eDYc1Nt4j3kiFoReEveRr/main/xray.conf"
mkdir -p /var/www/html
echo "<pre>Powered by EdyDev | Telegram : @kangbacox</pre>" > /var/www/html/index.html

#install socat
apt install iptables -y
apt install curl socat xz-utils wget apt-transport-https gnupg gnupg2 gnupg1 dnsutils lsb-release -y 
apt install socat cron bash-completion -y

#install cert
curl https://get.acme.sh | sh -s email=$email
/root/.acme.sh/acme.sh --server letsencrypt --register-account -m $email --issue -d $domain --standalone -k ec-256 --debug
~/.acme.sh/acme.sh --installcert -d $domain --fullchainpath /var/lib/marzban/xray.crt --keypath /var/lib/marzban/xray.key --ecc
wget -O /var/lib/marzban/xray_config.json "https://raw.githubusercontent.com/edydevelopeler/eDYc1Nt4j3kiFoReEveRr/main/xray_config.json"

#install firewall
apt install ufw -y
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow ssh
sudo ufw allow http
sudo ufw allow https
sudo ufw allow 7879/tcp
sudo ufw allow 8081/tcp
sudo ufw allow 1080/tcp
sudo ufw allow 1080/udp
yes | sudo ufw enable

#install database
wget -O /var/lib/marzban/db.sqlite3 "https://github.com/edydevelopeler/eDYc1Nt4j3kiFoReEveRr/raw/main/db.sqlite3"

#finishing
apt autoremove -y
apt clean
cd /opt/marzban
sed -i "s/# SUDO_USERNAME = \"admin\"/SUDO_USERNAME = \"${userpanel}\"/" /opt/marzban/.env
sed -i "s/# SUDO_PASSWORD = \"admin\"/SUDO_PASSWORD = \"${passpanel}\"/" /opt/marzban/.env
docker compose down && docker compose up -d
marzban cli admin import-from-env -y
sed -i "s/SUDO_USERNAME = \"${userpanel}\"/# SUDO_USERNAME = \"admin\"/" /opt/marzban/.env
sed -i "s/SUDO_PASSWORD = \"${passpanel}\"/# SUDO_PASSWORD = \"admin\"/" /opt/marzban/.env
docker compose down && docker compose up -d
cd
profile
echo "Untuk data login dashboard Marzban: " | tee -a log-install.txt
echo "-=================================-" | tee -a log-install.txt
echo "URL HTTPS : https://${domain}/dashboard" | tee -a log-install.txt
echo "username  : ${userpanel}" | tee -a log-install.txt
echo "password  : ${passpanel}" | tee -a log-install.txt
echo "-=================================-" | tee -a log-install.txt
clear

# Download backup script
wget -O /root/backup.sh "https://raw.githubusercontent.com/lunoxxdev/EdyJawAireng/main/backup.sh"

# Beri izin eksekusi
chmod +x /root/backup.sh

# Tambahkan crontab untuk menjalankan backup setiap hari pukul 00:00
(crontab -l ; echo "0 0 * * * /bin/bash /root/backup.sh >/dev/null 2>&1") | crontab -

# Send success message to Telegram
IPVPS=$(curl -s https://ipinfo.io/ip)
HOSTNAME=$(hostname)
OS=$(lsb_release -d | awk '{print $2,$3,$4}')
ISP=$(curl -s https://ipinfo.io/org | awk '{print $2,$3,$4}')
REGION=$(curl -s https://ipinfo.io/region)
DATE=$(date '+%Y-%m-%d')
TIME=$(date '+%H:%M:%S')

MESSAGE="\`\`\`
◇━━━━━━━━━━━━━━━━━◇
🍀 EdyVPN INSTALLER 🍀
◇━━━━━━━━━━━━━━━━━◇
❖ Username  : $HOSTNAME
❖ Status    : Active
❖ Domain    : $domain
❖ Waktu     : $TIME
❖ Tanggal   : $DATE
❖ IP VPS    : $IPVPS
❖ Linux OS  : $OS
❖ Nama ISP  : $ISP
❖ Area ISP  : $REGION
❖ Exp SC    : Liptime
❖ Status SC : Registrasi
❖ Admin     : Lunoxx
◇━━━━━━━━━━━━━━━━━◇
\`\`\`"

send_telegram_message "$MESSAGE"

clear
sleep 1
colorized_echo green "Script telah berhasil di install"
sleep 1
rm /root/jeki.sh
colorized_echo blue "Menghapus admin bawaan db.sqlite"
marzban cli admin delete -u admin -y
echo -e "[\e[1;31mWARNING\e[0m] Reboot sekali biar ga error cok [default y](y/n)? "
read answer
if [ "$answer" == "${answer#[Yy]}" ] ;then
exit 0
else
cat /dev/null > ~/.bash_history && history -c && reboot
fi
