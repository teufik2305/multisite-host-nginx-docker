# Documentation Guide

Welcome to the multisite-host-nginx-docker documentation!

## 📖 Reading Order

Follow this sequence to learn from beginner to advanced:

### 1. **01-LEARNING_GUIDE.md** 📚
**Start here if you're new!**
- Step-by-step tutorials
- Hands-on exercises
- Prerequisites and setup
- Troubleshooting common issues

### 2. **02-ARCHITECTURE.md** 🏗️
**Understand how everything fits together**
- System architecture diagrams
- Component responsibilities
- Network flow
- Docker networking explained
- File structure

### 3. **03-ROUTING_MODES.md** 🔀
**Learn about the two routing modes**
- Path-based routing (localhost/app1)
- DNS-based routing (domains)
- How to switch between them
- Quick reference

### 4. **04-DNS_VS_PATH.md** ⚖️
**Detailed comparison**
- When to use each mode
- Pros and cons
- URL structure examples
- Real-world scenarios
- Cost considerations

### 5. **05-DNS_GUIDE.md** 🌐
**Complete DNS setup guide**
- How DNS works with Docker
- Local testing with /etc/hosts
- Production DNS setup
- SSL/HTTPS configuration
- Cloudflare setup examples

### 6. **06-CHEATSHEET.md** 📝
**Quick reference for experienced users**
- Docker commands
- Docker Compose commands
- Nginx commands
- Common troubleshooting
- Configuration snippets

---

## 🎯 Quick Paths

### **Absolute Beginner**
1. Read `01-LEARNING_GUIDE.md`
2. Follow the step-by-step tutorials
3. Check `06-CHEATSHEET.md` for commands

### **Have Docker Experience**
1. Skim `02-ARCHITECTURE.md`
2. Read `03-ROUTING_MODES.md`
3. Use `06-CHEATSHEET.md` as needed

### **Want Production Setup**
1. Read `03-ROUTING_MODES.md`
2. Study `04-DNS_VS_PATH.md`
3. Follow `05-DNS_GUIDE.md`

### **Just Need Commands**
Jump straight to `06-CHEATSHEET.md`

---

## 💡 Tips

- **Take your time** - Don't rush through the guides
- **Try the examples** - Run the commands yourself
- **Experiment** - Break things and learn from it
- **Ask questions** - Use the troubleshooting sections
- **Come back** - These docs are reference material

---

## 🔗 Related Files

- `../README.md` - Project overview (in root directory)
- `../docker-compose.yml` - Service configuration
- `../nginx/nginx-path.conf` - Path-based routing template
- `../nginx/nginx-dns.conf` - DNS-based routing template
- `../nginx/nginx.conf` - Active configuration (auto-generated)

---

## 📚 Additional Resources

### External Documentation
- [Docker Documentation](https://docs.docker.com)
- [Nginx Documentation](https://nginx.org/en/docs/)
- [Docker Compose Reference](https://docs.docker.com/compose/)

### Recommended Videos
Search YouTube for:
- "Docker basics tutorial"
- "Nginx reverse proxy explained"
- "Docker networking tutorial"

---

Happy learning! 🚀

If you find any errors or have suggestions, feel free to contribute!

