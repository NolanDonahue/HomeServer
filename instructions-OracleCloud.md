Use Oracle Cloud for an Always Free cloud based instance
https://cloud.oracle.com/

Remote in and Install Docker
```
for pkg in docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc; do sudo apt-get remove $pkg; done
# Add Docker's official GPG key:
sudo apt-get update
sudo apt-get install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
```

On VM2 - Install Node Exporter and cAdvisor using Docker Compose
```

```

Add the docker-compose.yml to your Oracle Instance
```
version: '3.8'
services:
  prometheus:
    image: prom/prometheus:v2.46.0
    container_name: prometheus
    ports:
      - "9090:9090"
    volumes:
      - ./prometheus.yml:/etc/prometheus/prometheus.yml
    command:
      - '--config.file=/etc/prometheus/prometheus.yml'
    restart: unless-stopped
  grafana:
    image: grafana/grafana:latest
    container_name: grafana
    ports:
      - "3000:3000"
    restart: unless-stopped
```

Prometheus Configurations in prometheus.yml (In Directory: /home/ubuntu/prometheus.yml)
```
global:
  scrape_interval: 15s

scrape_configs:
  - job_name: 'home_hardware_metrics'
    static_configs:
      - targets: ['<your_home_public_ip>:9100']
  - job_name: 'home_docker_metrics'
    static_configs:
      - targets: ['<your_home_public_ip>:8080']
```

Run Docker Compose
```
sudo docker compose up -d
```

Configure your security to allow connections to your service ports
  Navigate to your Virtual Cloud Network (VCN) in the Oracle Cloud Console.
  
  Go to Security Lists and select the security list associated with your VM.
  
  Add an Ingress Rule.
  
  Source Type: CIDR

  Source CIDR: 0.0.0.0/0 (This allows traffic from any IP address; for better security, use a specific IP or range if you know it).
  
  IP Protocol: Select TCP or UDP as needed.
  
  Source Port Range: Leave this blank.

  Destination Port Range: Enter the port number you want to open (e.g., 80 for HTTP, 443 for HTTPS, 9090 for Prometheus, 3000 for Grafana).

  Description: Add a brief description, like "Allow HTTP."

Configure your instance Fireall Security
```
sudo apt install ufw -y
sudo ufw status verbose
sudo ufw allow 22/tcp
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo ufw allow 9090/tcp
sudo ufw allow 3000/tcp

sudo ufw enable
```

Configure Grafana in browser: http://<google_cloud_vm_public_ip>:3000
Credentials: admin/admin
  Add Prometheus as a data source (Connections -> Data Source)
    http://prometheus:9090
  Hardware Monitoring: 
    Node Exporter Dashboard
      eg. 1860
  Docket Metrics: 
    cAdvisor Dashboard
      eg. 14283

Move the website dist folder to /var/www/website
Point caddy at the new website folder with the Caddyfile
```
# Caddyfile on your Home Server VM
yourwebsite.com {
  # This line tells Caddy to forward all traffic for your domain
  # to the specified IP address on the default HTTP/HTTPS ports
  reverse_proxy http://<oracle_cloud_vm_public_ip>
}
```

Change the A Record for your website to point to the public IP of the cloud instance
