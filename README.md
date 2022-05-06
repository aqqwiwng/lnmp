## 使用教程

### 下载

```
## CentOS7 + Nginx + php-^7.4 + php5.6.40 + Redis + phpMyAdmin-5.1.3
docker pull aqqwiwng/lnmp
```

### 配置

```
# 配置文件路径
# Nginx
/usr/local/nginx/conf/nginx.conf

# MySQL
/etc/my.cnf

# Redis
/usr/local/redis/redis.conf

# php
/usr/local/php/lib/php.ini
/usr/local/php/etc/php-fpm.conf
/usr/local/php/etc/php-fpm.d/www.conf
```

### 启动

```
# 端口映射自行指定,容器名称自行指定为lnmp
docker run -dit --privileged=true --name=lnmp aqqwiwng/lnmp

# 高级用法
docker run -dit \
-p 80:80 \
-p 443:443 \
-p 3306:3306 \
-p 8080:8080 \
-v /宿主机自定义目录/www:/www \
-v /宿主机自定义目录/mysql:/data/mysql \
--privileged=true \
--name=lnmp \
aqqwiwng/lnmp

# 如对配置文件比较熟悉，也可以通过宿主机挂载使用自定义的配置文件
```

### 连接

```
# 容器名称与上一步保持一致
docker exec -it lnmp /bin/bash
```

### 状态

```
ps aux|grep nginx
ps aux|grep mysql
ps aux|grep php
ps aux|grep redis
# 或者(Or)
systemctl status nginx
systemctl status mysqld
systemctl status php
systemctl status redis
```

### 查看MySql初始密码

```
cat /var/log/mysqld.log|grep 'A temporary password'
```

### 初始化

```
初次使用MySql会提示密码已过期，需要使用 mysql_init 脚本将数据库密码初始化为：root。
#或 
`mysql_init xxx`  xxx为你的密码
#注意：mysql_init脚本只能使用一次，用完就自动删除自身
```

### PHP扩展

```
# 默认已安装部分扩展在目录：/usr/local/php/lib/php/extensions/no-debug-non-zts-20190902/
# 如果要启用指定扩展，则需要修改php.ini，加上
extension=xxx.so
# xxx为PHP扩展的文件名，然后重启php
systemctl restart php
```

