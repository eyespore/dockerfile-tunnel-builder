# dockerfile-tunnel-bulder

基于ssh端口转发+socat实现正向代理的敏感端口绕过，适用于解决IPv6下服务部署外部无法访问的情况

地方运营商存在对家用网络的`80/443`端口下行、`445`端口上行封锁的情况，前者会导致在家用网中部署的站点无法被外部访问，后者则会导致无法通过`445`端口访问外部SMB服务

本项目配置的出发点就是绕过445端口的封锁

# 如何运行

项目提供了两份入口点文件模板：

- entrypoint-ssh.sh.sample：SSH-Client入口点脚本模板，主要是通过`ssh -NL`这样的端口转发命令来建立SSH隧道，基于`kroniak/ssh-client`二次构建，加上了autossh提高连接的稳定性
- entrypoint-socat.sh.sample：Socat入口点脚本模板

以绕过445端口上行限制为例，思路为：

1. 使用autossh建立到目标SMB主机的隧道，并开启端口转发`-NL 4445:localhost:445`，即将本地的4445端口转发到目的地445端口
2. 使用socat将本地445端口流量重定向到4445端口上

通过上述两部，外部主机就可以通过连接本机的445端口来顺利绕过445上行限制，连接到远端SMB主机

> 如果当前主机支持通过非标端口（非445）连接SMB服务那么自然不需要这么麻烦，这里主要是为了解决Windows无法使用非标端口的问题

命令示例如下：

首相将仓库拷贝到本地：

```bash
git clone https://github.com/eyespore/dockerfile-tunnel-builder.git
cd dockerfile-tunnel-builder
```

拷贝入口点文件，并修改符合自己的要求：

```bash
cp entrypoint-ssh.sh.sample entrypoint-ssh.sh && chmod +x entrypoint-ssh.sh
cp entrypoint-socat.sh.sample entrypoint-socat.sh && chmod +x entrypoint-socat.sh
```

运行DockerCompose：

```bash
docker compose up -d
```

> ⚠注：`compose.yml`默认挂载当前用户的`$HOME/.ssh`到`/root/.ssh`，目的是使用当前用户的ssh配置、密钥以及连接模板，这种连接方式是为密钥连接准备的，如果你使用密码连接，你可以使用`sshpass`

# 注意事项

该方法仅适用于445端口可用的情况：

- 对于大多数Linux主机，监听低1024端口需要root权限
- 对于Windows主机，445端口无法被使用，如果你使用WSL，可以使用桥接/NAT网络来避免端口挤占问题
- 对于Android，除非有root，否则无法正常运行