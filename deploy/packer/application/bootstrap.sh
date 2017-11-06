# Set up directories the agent uses
sudo mkdir -p /var/log/ecs /etc/ecs /var/lib/ecs/data

# Copy the required files
sudo mv /tmp/ecs-agent.service /etc/systemd/system/
sudo mv /tmp/ecs.config /etc/ecs/ecs.config

# Set up necessary rules to enable IAM roles for tasks
sudo sysctl -w net.ipv4.conf.all.route_localnet=1
sudo iptables -t nat -A PREROUTING -p tcp -d 169.254.170.2 --dport 80 -j DNAT --to-destination 127.0.0.1:51679
sudo iptables -t nat -A OUTPUT -d 169.254.170.2 -p tcp -m tcp --dport 80 -j REDIRECT --to-ports 51679

# Run the agent
sudo yum-config-manager --enable extras
sudo yum-config-manager --enable rhui-REGION-rhel-server-extras
sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo

sudo yum install -y yum-utils \
  device-mapper-persistent-data \
  lvm2 \
  container-selinux \
  docker-ce \
  unzip

sudo systemctl start docker
sudo systemctl enable docker

sudo chmod 664 /etc/systemd/system/ecs-agent.service
sudo systemctl enable ecs-agent

curl "https://bootstrap.pypa.io/get-pip.py" -o "get-pip.py"
sudo python get-pip.py
sudo pip install awscli

sudo `aws ecr get-login --no-include-email --region eu-west-2`
