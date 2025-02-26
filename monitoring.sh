#!/bin/bash
sudo apt update && echo "Updated package lists"
sudo apt-get install -y apt-transport-https software-properties-common wget && echo "Installed required packages"
sudo mkdir -p /etc/apt/keyrings/ && echo "Created /etc/apt/keyrings directory"
sudo wget -q -O - https://apt.grafana.com/gpg.key | gpg --dearmor | sudo tee /etc/apt/keyrings/grafana.gpg > /dev/null && echo "Downloaded and added Grafana GPG key"
echo "deb [signed-by=/etc/apt/keyrings/grafana.gpg] https://apt.grafana.com stable main" | sudo tee -a /etc/apt/sources.list.d/grafana.list && echo "Added Grafana stable repository"
echo "deb [signed-by=/etc/apt/keyrings/grafana.gpg] https://apt.grafana.com beta main" | sudo tee -a /etc/apt/sources.list.d/grafana.list && echo "Added Grafana beta repository"
sudo apt-get update && echo "Updated package lists after adding Grafana repository"
sudo apt-get install grafana -y && echo "Installed Grafana"
sudo apt-get install grafana-enterprise -y && echo "Installed Grafana Enterprise"
sudo systemctl start grafana-server && echo "Started Grafana service"
sudo systemctl enable grafana-server && echo "Enabled Grafana service to start on boot"


sudo curl -L --output cloudflared.deb https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64.deb && echo "Downloaded Cloudflared package"
sudo dpkg -i cloudflared.deb && echo "Installed Cloudflared"
sudo cloudflared service install eyJhIjoiNjZkNDdjMjZhODk4ZWJkNmU5MDBhN2RhNDJkMzE5NTgiLCJ0IjoiYzllOTZhMTItYTM5NS00ZDkwLWFhNDgtZjM5N2VmZWJiOTJiIiwicyI6IllqQXlaVE01WXpJdFpUVTRZaTAwT0dZMkxXSXhaVFV0TldWbVlqa3lOalZsWVRReiJ9 -y && echo "Configured Cloudflared tunnel service"



sudo wget https://github.com/prometheus/prometheus/releases/download/v3.2.1/prometheus-3.2.1.linux-386.tar.gz && echo "Downloaded Prometheus"
sudo tar -xzf prometheus-3.2.1.linux-386.tar.gz && echo "Extracted Prometheus"
sudo rm ./prometheus-3.2.1.linux-386/prometheus.yml && echo "Removed default Prometheus config"
sudo wget https://oksesaneka22.github.io/script/prometheus.yml && echo "Downloaded custom Prometheus config"
sudo groupadd --system prometheus && echo "Created Prometheus system group"
sudo useradd -s /sbin/nologin --system -g prometheus prometheus && echo "Created Prometheus user"
sudo mv ./prometheus-3.2.1.linux-386/prometheus /usr/local/bin && echo "Moved Prometheus binary"
sudo mv ./prometheus-3.2.1.linux-386/promtool /usr/local/bin && echo "Moved Promtool binary"
sudo chown prometheus:prometheus /usr/local/bin/prometheus && echo "Set ownership for Prometheus"
sudo chown prometheus:prometheus /usr/local/bin/promtool && echo "Set ownership for Promtool"
sudo mkdir /etc/prometheus && echo "Created /etc/prometheus directory"
sudo mkdir /var/lib/prometheus && echo "Created /var/lib/prometheus directory"
sudo mv ./prometheus.yml /etc/prometheus && echo "Moved Prometheus config"
sudo chown prometheus:prometheus /etc/prometheus && echo "Set ownership for /etc/prometheus"
sudo chown -R prometheus:prometheus /var/lib/prometheus && echo "Set ownership for /var/lib/prometheus"
sudo tee /etc/systemd/system/prometheus.service > /dev/null <<EOF && echo "Created Prometheus systemd service file"
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
sudo systemctl daemon-reload && echo "Reloaded systemd daemon"
sudo systemctl enable prometheus && echo "Enabled Prometheus service"
sudo systemctl start prometheus && echo "Started Prometheus service"


sudo wget https://github.com/prometheus/blackbox_exporter/releases/download/v0.14.0/blackbox_exporter-0.14.0.linux-amd64.tar.gz && echo "Downloaded Blackbox Exporter"
sudo tar xvzf blackbox_exporter-0.14.0.linux-amd64.tar.gz && echo "Extracted Blackbox Exporter"
sudo mv ./blackbox_exporter-0.14.0.linux-amd64/blackbox_exporter /usr/local/bin && echo "Moved Blackbox Exporter binary"
sudo mkdir -p /etc/blackbox && echo "Created /etc/blackbox directory"
sudo mv ./blackbox_exporter-0.14.0.linux-amd64/blackbox.yml /etc/blackbox && echo "Moved Blackbox Exporter config"
sudo useradd -rs /bin/false blackbox && echo "Created Blackbox system user"
sudo chown blackbox:blackbox /usr/local/bin/blackbox_exporter && echo "Set ownership for Blackbox Exporter"
sudo chown -R blackbox:blackbox /etc/blackbox/* && echo "Set ownership for /etc/blackbox"
sudo tee /etc/systemd/system/blackbox.service > /dev/null <<EOF && echo "Created Blackbox Exporter systemd service file"
[Unit]
Description=Blackbox Exporter Service
Wants=network-online.target
After=network-online.target

[Service]
Type=simple
User=blackbox
Group=blackbox
ExecStart=/usr/local/bin/blackbox_exporter \\
  --config.file=/etc/blackbox/blackbox.yml \\
  --web.listen-address=":9115"

Restart=always

[Install]
WantedBy=multi-user.target
EOF
sudo systemctl enable blackbox.service && echo "Enabled Blackbox Exporter service"
sudo systemctl start blackbox.service && echo "Started Blackbox Exporter service"
sudo systemctl restart prometheus
