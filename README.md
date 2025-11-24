# 🚀 Easy AWS Auto Deployment Script

Deploy your Node.js or Python project on an AWS EC2 Linux server **automatically** with one script!

This script is created to **make deploying super easy**.

- ✅ No more long commands
- ✅ No more confusing tutorials
- ✅ Just **run one script**, answer a few simple questions, and your project goes live

Even a **complete beginner** can use it!

---

## 🌟 What This Script Does

- ✔️ Updates your entire server
- ✔️ Installs Node.js or Python automatically
- ✔️ Installs PM2 (for Node.js apps)
- ✔️ Clones your GitHub project
- ✔️ Installs all dependencies
- ✔️ Detects and runs build scripts
- ✔️ Creates `.env` automatically (from `.demo.env`)
- ✔️ Starts the app using PM2
- ✔️ Creates Nginx reverse-proxy config

---

## 🖥️ Supported Systems

| System | Status |
|--------|--------|
| 🟢 Ubuntu 20.04 / 22.04 | ✅ Supported |
| 🟢 AWS EC2 Linux | ✅ Supported |
| ❌ Windows | ❌ Not Supported |
| ❌ macOS | ❌ Not Supported |
| ❌ Shared Hosting | ❌ Not Supported |

---

## 📦 Installation — Super Easy Steps

### 1️⃣ Connect to Your AWS EC2 Server

```bash
ssh -i your-key.pem ubuntu@your-server-ip
```

### 2️⃣ Clone This Repository

```bash
git clone https://github.com/cyber-programer/AutoDeploy.git
cd AutoDeploy
```

### 3️⃣ Give Execute Permission

```bash
chmod +x setup.sh
```

### 4️⃣ Run the Script

```bash
sudo ./setup.sh
```

> ⚠️ **Important:** You MUST run it with `sudo`, otherwise it will not work.

---

## 🎤 What the Script Will Ask You

The script will ask you a few simple questions:

1. **Project type:** Node.js or Python
2. **GitHub repository link:** Your project's GitHub URL
3. **Domain name (optional):** If you don't have one, just press ENTER
4. **Port number:** Default is 3000. If unsure, press ENTER

### Example User Flow

```bash
Welcome to AWS Auto Setup Script
[?] Is your project made with Python or NodeJS?: nodejs
[?] Enter your GitHub project link: https://github.com/user/myapp.git
[?] Enter your domain name (optional): myapp.com
[?] Enter your app port (default 3000): 5000
```

---

## ⚙️ What Happens After Running the Script?

The script automatically:

1. ✅ Updates your server
2. ✅ Installs Node.js or Python
3. ✅ Installs PM2 (for Node.js apps)
4. ✅ Clones your GitHub project
5. ✅ Installs all dependencies
6. ✅ Runs `npm run build` if available
7. ✅ Creates a `.env` file if needed
8. ✅ Starts the application with PM2
9. ✅ Creates Nginx reverse proxy
10. ✅ Restarts Nginx

**Your website becomes LIVE! 🎉**

---

## 🌐 Auto-Generated Nginx Configuration

The script automatically creates an Nginx configuration like this:

```nginx
server {
    listen 80;
    server_name yourdomain.com www.yourdomain.com;
    
    location / {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
    }
}
```

> 💡 **You do NOT need to touch Nginx manually!**

---

## ❤️ Why This Script Was Made

Because:

- 😓 Deploying is confusing for beginners
- ⏰ AWS setup takes too long
- 📝 Too many commands
- 📚 Too many tutorials
- 🎯 I wanted something **FAST, EASY, and AUTOMATIC**

This script is **version 1**. Many more features are coming!

---

## 🔮 Future Improvements (Coming Soon)

- ✨ Automatic SSL (HTTPS with Certbot)
- ✨ Full Python deployment (Gunicorn + virtualenv)
- ✨ MongoDB / PostgreSQL auto-setup
- ✨ Auto-configure firewall
- ✨ Zero-downtime deployment
- ✨ Backup & restore features
- ✨ Deploy multiple apps
- ✨ Auto environment variable setup

---

## 🤝 Contribute

You can help by:

- 🐛 Reporting issues
- 💡 Suggesting new features
- 🔧 Sending pull requests

**Everyone is welcome!**

---

## 📝 License

This project is open source and available under the [MIT License](LICENSE).

---

## 💬 Support

If you have any questions or need help:

- 📧 Open an issue on GitHub
- ⭐ Star this repository if you find it useful!

---

<div align="center">
  
**Made with ❤️ for developers who want simple deployments**

[⬆ Back to top](#-easy-aws-auto-deployment-script)

</div>
