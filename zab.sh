#!/bin/bash

# Set up error handling and exit on failure
set -o errexit
set -o nounset
set -o pipefail

# Generates a random password, stores it in "db.pass" and retrieves the version of the Linux distribution.
pass=$(< /dev/urandom tr -dc _A-Z-a-z-0-9 | head -c${1:-32};echo;)
echo "$pass" > db.pass
ub=$(lsb_release -rs)

# Downloads and installs Zabbix repository for the specified Ubuntu version.
wget https://repo.zabbix.com/zabbix/6.4/ubuntu/pool/main/z/zabbix-release/zabbix-release_6.4-1+ubuntu${ub}_all.deb
sudo dpkg -i zabbix-release_6.4-1+ubuntu${ub}_all.deb
rm zabbix-release_6.4-1+ubuntu${ub}_all.deb

sudo apt update
sudo apt install zabbix-server-mysql zabbix-frontend-php zabbix-apache-conf zabbix-sql-scripts zabbix-agent mysql-server pv -y

# If a lock file "/tmp/db.lock" exists, it reads the password from "db.pass," otherwise it creates a MySQL database, user, and permissions, and creates the lock file.
if [ -e "/tmp/db.lock" ]; then
    pass=$(cat "db.pass")
else
    echo -e "\033[44m\033[30m Enter system password \033[0m"
    sudo mysql -uroot -p <<EOF
create database zabbix character set utf8mb4 collate utf8mb4_bin;
create user zabbix@localhost identified by '$pass';
grant all privileges on zabbix.* to zabbix@localhost;
set global log_bin_trust_function_creators = 1;
EOF
    touch "/tmp/db.lock"
fi

# Decompresses and streams Zabbix SQL script into MySQL with UTF-8 encoding using pv for progress visualization.
echo -e "\033[44m\033[30m Password: $pass \033[0m\n  \033[44m\033[30m The download will complete at 37.8MiB \033[0m"
zcat /usr/share/zabbix-sql-scripts/mysql/server.sql.gz | pv | mysql --default-character-set=utf8mb4 -uzabbix -p zabbix

# Disables the option "log_bin_trust_function_creators" in MySQL by running a command with root privileges.
echo -e "\033[44m\033[30m Enter system password \033[0m"
sudo mysql -uroot -p <<EOF
set global log_bin_trust_function_creators = 0;
EOF

# Appends the DB password variable to the Zabbix Server configuration file using the tee command with elevated privileges.
echo "DBPassword=$pass" | sudo tee -a /etc/zabbix/zabbix_server.conf

sudo systemctl restart zabbix-server zabbix-agent apache2
sudo systemctl enable zabbix-server zabbix-agent apache2

echo -e "\n=====================\nhttp://host/zabbix\nDB_NAME: zabbix\nDB_USER: zabbix\nDB_PASSWORD: $pass\nAdmin/zabbix\n=====================\n"
