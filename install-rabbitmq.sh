#!/bin/bash

echo "🟡 Starting RabbitMQ installation on AlmaLinux 8..."

# === 1. Ask for username and password ===
read -p "🧑 Enter a new RabbitMQ admin username: " RABBIT_USER
read -s -p "🔒 Enter the password: " RABBIT_PASS
echo ""

# === 2. Import GPG keys ===
echo "🔐 Importing GPG keys..."
rpm --import 'https://github.com/rabbitmq/signing-keys/releases/download/3.0/rabbitmq-release-signing-key.asc'
rpm --import 'https://github.com/rabbitmq/signing-keys/releases/download/3.0/cloudsmith.rabbitmq-erlang.E495BB49CC4BBE5B.key'
rpm --import 'https://github.com/rabbitmq/signing-keys/releases/download/3.0/cloudsmith.rabbitmq-server.9F4587F226208342.key'

# === 3. Add repository ===
echo "📦 Creating RabbitMQ repo file..."
cat > /etc/yum.repos.d/rabbitmq.repo << 'EOF'
[modern-erlang]
name=modern-erlang-el8
baseurl=https://yum1.rabbitmq.com/erlang/el/8/$basearch
        https://yum2.rabbitmq.com/erlang/el/8/$basearch
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://github.com/rabbitmq/signing-keys/releases/download/3.0/cloudsmith.rabbitmq-erlang.E495BB49CC4BBE5B.key

[rabbitmq-el8]
name=rabbitmq-el8
baseurl=https://yum1.rabbitmq.com/rabbitmq/el/8/$basearch
        https://yum2.rabbitmq.com/rabbitmq/el/8/$basearch
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://github.com/rabbitmq/signing-keys/releases/download/3.0/cloudsmith.rabbitmq-server.9F4587F226208342.key
EOF

# === 4. Install required packages ===
echo "📥 Installing packages..."
dnf clean all -y
dnf makecache
dnf install -y logrotate erlang rabbitmq-server

# === 5. Reset RabbitMQ database and logs ===
echo "🧹 Cleaning old RabbitMQ data and logs..."
systemctl stop rabbitmq-server
rm -rf /var/lib/rabbitmq/mnesia
rm -rf /var/log/rabbitmq/*

# === 6. Set required feature flag manually ===
echo "⚙️ Setting required feature flag (classic_mirrored_queue_version)..."
mkdir -p /var/lib/rabbitmq/mnesia
echo '{rabbitmq_feature_flags,[classic_mirrored_queue_version]}.' > /var/lib/rabbitmq/mnesia/feature_flags
chown -R rabbitmq:rabbitmq /var/lib/rabbitmq

# === 7. Enable and start the service ===
echo "🚀 Starting RabbitMQ server..."
systemctl enable rabbitmq-server
systemctl start rabbitmq-server

# === 8. Enable web management plugin ===
echo "🌐 Enabling web management plugin..."
rabbitmq-plugins enable rabbitmq_management

# === 9. Add admin user ===
echo "👤 Creating RabbitMQ admin user '$RABBIT_USER'..."
rabbitmqctl add_user "$RABBIT_USER" "$RABBIT_PASS"
rabbitmqctl set_user_tags "$RABBIT_USER" administrator
rabbitmqctl set_permissions -p / "$RABBIT_USER" ".*" ".*" ".*"

# === 10. Delete default guest user ===
echo "🗑️ Deleting insecure default 'guest' user..."
rabbitmqctl delete_user guest

# === 11. Open firewall ports if firewalld is running ===
echo "🔓 Opening firewall ports (15672 for web UI, 5672 for AMQP)..."
if firewall-cmd --state &> /dev/null; then
    firewall-cmd --permanent --add-port=15672/tcp
    firewall-cmd --permanent --add-port=5672/tcp
    firewall-cmd --reload
else
    echo "⚠️ FirewallD not active, skipping port configuration."
fi

# === Done ===
echo ""
echo "✅ RabbitMQ installation completed successfully!"
echo "🔗 Web UI: http://$(hostname -I | awk '{print $1}'):15672"
echo "👤 Username: $RABBIT_USER"
echo "🔒 Password: (as entered)"
