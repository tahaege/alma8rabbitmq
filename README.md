# 🐇 RabbitMQ Auto Installer Script (AlmaLinux 8)

This script provides a **fully automated** RabbitMQ installation for RPM-based distributions (tested on AlmaLinux 8), including:

- ✅ GPG key and repository setup
- ✅ Installation of RabbitMQ and Erlang
- ✅ Fix for required feature flag (`classic_mirrored_queue_version`)
- ✅ RabbitMQ Web Management UI (port `15672`)
- ✅ Admin user creation with custom username/password (prompted)
- ✅ Default `guest` user removal
- ✅ Optional firewall configuration for ports `15672` (HTTP) and `5672` (AMQP)

---

## 🚀 Quick Start

You don't need to do anything manually. Just run this in your terminal:

```
# 1. Install git (if not already installed)
sudo yum install -y git

# 2. Clone the installer repository
git clone https://github.com/tahaege/alma8rabbitmq.git

# 3. Run the installer
cd alma8rabbitmq
chmod +x install-rabbitmq.sh
sudo ./install-rabbitmq.sh
```
The script will prompt you to enter:
```
A RabbitMQ admin username

A secure password
```
After completion, the web interface will be available at:

```
http://<your-server-ip>:15672
```
# 🛠 Requirements
AlmaLinux 8 / RHEL 8 / Rocky Linux 8
Root or sudo access
Internet connection

# 📬 Contact
System Administrator: Taha Ege Aydın

📧 ege@gyro.cloud
 VPS Provider Company: https://gyrohosting.com/
 
🔗 LinkedIn Profile : https://www.linkedin.com/in/taha-ege-aydin/

# 📄 License
MIT License
