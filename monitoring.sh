#!/bin/bash
sudo apt update
sudo apt-get install -y apt-transport-https software-properties-common wget
sudo mkdir -p /etc/apt/keyrings/
sudo wget -q -O - https://apt.grafana.com/gpg.key | gpg --dearmor | sudo tee /etc/apt/keyrings/grafana.gpg > /dev/null
echo "deb [signed-by=/etc/apt/keyrings/grafana.gpg] https://apt.grafana.com stable main" | sudo tee -a /etc/apt/sources.list.d/grafana.list
echo "deb [signed-by=/etc/apt/keyrings/grafana.gpg] https://apt.grafana.com beta main" | sudo tee -a /etc/apt/sources.list.d/grafana.list
sudo apt-get update
sudo apt-get install grafana
sudo apt-get install grafana-enterprise
sudo systemctl start grafana-server
sudo systemctl enable grafana-server
sudp curl -L --output cloudflared.deb https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64.deb 
sudo dpkg -i cloudflared.deb 
sudo cloudflared service install eyJhIjoiNjZkNDdjMjZhODk4ZWJkNmU5MDBhN2RhNDJkMzE5NTgiLCJ0IjoiYzllOTZhMTItYTM5NS00ZDkwLWFhNDgtZjM5N2VmZWJiOTJiIiwicyI6IllqQXlaVE01WXpJdFpUVTRZaTAwT0dZMkxXSXhaVFV0TldWbVlqa3lOalZsWVRReiJ9
sudo wget https://github.com/prometheus/prometheus/releases/download/v3.2.1/prometheus-3.2.1.linux-386.tar.gz
sudo tar -xzf prometheus-3.2.1.linux-386.tar.gz
sudo rm ./prometheus-3.2.1.linux-386/prometheus.yml
sudo wget https://oksesaneka22.github.io/script/prometheus.yml
sudo groupadd --system prometheus
sudo useradd -s /sbin/nologin --system -g prometheus prometheus
sudo mv ./prometheus-3.2.1.linux-386/prometheus /usr/local/bin
sudo mv ./prometheus-3.2.1.linux-386/promtool /usr/local/bin
sudo chown prometheus:prometheus /usr/local/bin/prometheus
sudo chown prometheus:prometheus /usr/local/bin/promtool
sudo mkdir /etc/prometheus
sudo mkdir /var/lib/prometheus
sudo mv consoles /etc/prometheus
sudo mv prometheus.yml /etc/prometheus
sudo chown prometheus:prometheus /etc/prometheus
sudo chown -R prometheus:prometheus /var/lib/prometheus
sudo tee /etc/systemd/system/prometheus.service > /dev/null <<EOF
[Unit]
Description=Prometheus
Wants=network-online.target
After=network-online.target

[Service]
User=prometheus
Group=prometheus
Type=simple
ExecStart=/usr/local/bin/prometheus \\
    --config.file=/etc/prometheus/prometheus.yml \\
    --storage.tsdb.path=/var/lib/prometheus

[Install]
WantedBy=multi-user.target
EOF
sudo systemctl daemon-reload
sudo systemctl enable prometheus
sudo systemctl start prometheus
sudo wget https://github.com/prometheus/blackbox_exporter/releases/download/v0.14.0/blackbox_exporter-0.14.0.linux-amd64.tar.gz
sudo tar xvzf blackbox_exporter-0.14.0.linux-amd64.tar.gz
sudo mv ./blackbox_exporter-0.14.0.linux-amd64/blackbox_exporter /usr/local/bin
sudo mkdir -p /etc/blackbox
sudo mv ./blackbox_exporter-0.14.0.linux-amd64/blackbox.yml /etc/blackbox
sudo sudo useradd -rs /bin/false blackbox
sudo chown blackbox:blackbox /usr/local/bin/blackbox_exporter
sudo chown -R blackbox:blackbox /etc/blackbox/*
sudo tee /etc/systemd/system/blackbox.service > /dev/null <<EOF
[Unit]
Description=Blackbox Exporter Service
Wants=network-online.target
After=network-online.target

[Service]
Type=simple
User=blackbox
Group=blackbox
ExecStart=/usr/local/bin/blackbox_exporter \
  --config.file=/etc/blackbox/blackbox.yml \
  --web.listen-address=":9115"

Restart=always

[Install]
WantedBy=multi-user.target
EOF
sudo systemctl enable blackbox.service
sudo systemctl start blackbox.service
