FROM centos:7
ADD * /root/
RUN (cd /lib/systemd/system/sysinit.target.wants/; for i in *; do [ $i == systemd-tmpfiles-setup.service ] || rm -f $i; done);\
rm -f /etc/systemd/system/*.wants/*;\
rm -f /lib/systemd/system/basic.target.wants/*;\
rm -f /lib/systemd/system/anaconda.target.wants/*;\
rm -f /lib/systemd/system/local-fs.target.wants/*;\
rm -f /lib/systemd/system/multi-user.target.wants/*;\
rm -f /lib/systemd/system/sockets.target.wants/*udev*;\
rm -f /lib/systemd/system/sockets.target.wants/*initctl*;\
\cp -rfn /root/cgroup/* /sys/fs/cgroup/;\
ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime;\
\cp -f /root/Centos-7.repo /etc/yum.repos.d/CentOS-Base.repo;\
yum clean all ;\
yum makecache ;\
mkdir /www;\
mkdir /log;\
\cp /root/index.php /www/;\
\cp /root/index.html /www/;\
\mv /root/phpMyAdmin-5.1.3-all-languages /pma;\
mkdir /data;\
mkdir /data/mysql;\
useradd www;\
useradd mysql;\
chown -R www:www /www;\
chown -R www:www /log;\
chown -R www:www /pma;\
chown -R mysql:mysql /data/mysql;\
# 全局准备
\cp /root/epel-7.repo /etc/yum.repos.d/epel-ali.repo;\
yum install yum-fastestmirror git zip cmake3 unzip expect crontabs -y;\
ln -s /usr/bin/cmake3 /usr/bin/cmake;\
# 安装Nginx
## 1准备工作
yum install gcc-c++ make perl -y;\
## 2安装pcre
cd /root/pcre-8.45;\
./configure;\
make;\
make install;\
## 3安装zlib
cd /root/zlib-1.2.11;\
./configure;\
make;\
make install;\
## 4安装openssl
## (已经通过ADD解压，无需操作)
## 5安装nginx
cd /root/nginx-1.21.4;\
./configure \
--prefix=/usr/local/nginx/ \
--with-http_v2_module \
--with-http_ssl_module \
--with-http_realip_module \
--with-http_stub_status_module \
--with-pcre=/root/pcre-8.45/ \
--with-zlib=/root/zlib-1.2.11/ \
--with-openssl=/root/openssl-1.1.1m;\
make;\
make install;\
\cp /root/nginx.conf /usr/local/nginx/conf/nginx.conf;\
\cp /root/nginx.service /etc/systemd/system/nginx.service;\
ln -s /etc/systemd/system/nginx.service /etc/systemd/system/multi-user.target.wants/nginx.service;\
chown -R www:www /usr/local/nginx;\
# 安装php
## 1准备工作
yum install autoconf sqlite-devel libxml2-devel openssl-devel re2c -y;\
## 2安装php
cd /root/php-7.4.27;\
./configure \
--prefix=/usr/local/php \
--enable-mysqlnd \
--enable-sockets \
--with-openssl \
--enable-fpm;\
make;\
make install;\
\cp /root/composer /usr/local/php/bin/composer;\
ln -s /usr/local/php/bin/composer /usr/local/php/bin/composer7;\
\cp /root/cacert.pem /usr/local/php/lib/cacert.pem;\
\cp /root/php.ini /usr/local/php/lib/php.ini;\
\cp /root/php-fpm.conf /usr/local/php/etc/php-fpm.conf;\
\cp /root/www.conf /usr/local/php/etc/php-fpm.d/www.conf;\
\cp /root/php.service /etc/systemd/system/php.service;\
ln -s /etc/systemd/system/php.service /etc/systemd/system/multi-user.target.wants/php.service;\
ln -s /usr/local/php/bin/php /usr/local/php/bin/php;\
chmod -R 755 /usr/local/php/bin/composer;\
## 3扩展安装
### bcmath
cd /root/php-7.4.27/ext/bcmath;\
/usr/local/php/bin/phpize;\
./configure --with-php-config=/usr/local/php/bin/php-config;\
make;\
make install;\
### curl
yum install curl-devel -y;\
cd /root/php-7.4.27/ext/curl;\
/usr/local/php/bin/phpize;\
./configure CC=c99 --with-php-config=/usr/local/php/bin/php-config;\
make;\
make install;\
### gd
yum install libXpm-devel libpng-devel libjpeg-devel libwebp-devel freetype-devel -y;\
cd /root/php-7.4.27/ext/gd;\
/usr/local/php/bin/phpize;\
./configure --with-php-config=/usr/local/php/bin/php-config \
--with-xpm \
--with-jpeg \
--with-webp \
--with-freetype;\
make;\
make install;\
### calendar
cd /root/php-7.4.27/ext/calendar;\
/usr/local/php/bin/phpize;\
./configure --with-php-config=/usr/local/php/bin/php-config;\
make;\
make install;\
### intl
yum install libicu-devel -y;\
cd /root/php-7.4.27/ext/intl;\
/usr/local/php/bin/phpize;\
./configure --with-php-config=/usr/local/php/bin/php-config;\
make;\
make install;\
### mbstring
yum install oniguruma-devel -y;\
cd /root/php-7.4.27/ext/mbstring;\
/usr/local/php/bin/phpize;\
./configure --with-php-config=/usr/local/php/bin/php-config;\
make;\
make install;\
### mcrypt
yum install libmcrypt-devel -y;\
cd /root/mcrypt-1.0.4;\
/usr/local/php/bin/phpize;\
./configure --with-php-config=/usr/local/php/bin/php-config;\
make;\
make install;\
### mysqli
cd /root/php-7.4.27/ext/mysqli;\
/usr/local/php/bin/phpize;\
./configure --with-php-config=/usr/local/php/bin/php-config;\
make;\
make install;\
### pdo_mysql
cd /root/php-7.4.27/ext/pdo_mysql;\
/usr/local/php/bin/phpize;\
./configure --with-php-config=/usr/local/php/bin/php-config;\
make;\
make install;\
### sockets
# cd /root/php-7.4.27/ext/sockets;\
# /usr/local/php/bin/phpize;\
# ./configure --with-php-config=/usr/local/php/bin/php-config;\
# make;\
# make install;\
### bz2
yum install bzip2-devel -y;\
cd /root/php-7.4.27/ext/bz2;\
/usr/local/php/bin/phpize;\
./configure --with-php-config=/usr/local/php/bin/php-config;\
make;\
make install;\
### zip
yum remove libzip-devel -y;\
cd /root/libzip-1.8.0;\
mkdir build;\
cd /root/libzip-1.8.0/build;\
cmake ..;\
make;\
make install;\
cd /root/php-7.4.27/ext/zip;\
/usr/local/php/bin/phpize;\
./configure --with-php-config=/usr/local/php/bin/php-config PKG_CONFIG_PATH=/usr/local/lib64/pkgconfig/;\
make;\
make install;\
### zlib
cd /root/php-7.4.27/ext/zlib;\
\cp config0.m4 config.m4;\
/usr/local/php/bin/phpize;\
./configure --with-php-config=/usr/local/php/bin/php-config;\
make;\
make install;\
### opcache
cd /root/php-7.4.27/ext/opcache;\
/usr/local/php/bin/phpize;\
./configure --with-php-config=/usr/local/php/bin/php-config;\
make;\
make install;\
### redis
cd /root/redis-5.3.5;\
/usr/local/php/bin/phpize;\
./configure --with-php-config=/usr/local/php/bin/php-config;\
make;\
make install;\
### memcache
cd /root/memcache-4.0.5.2;\
/usr/local/php/bin/phpize;\
./configure --with-php-config=/usr/local/php/bin/php-config;\
make;\
make install;\
### memcached
yum install libmemcached-devel -y;\
cd /root/memcached-3.1.5;\
/usr/local/php/bin/phpize;\
./configure --with-php-config=/usr/local/php/bin/php-config;\
make;\
make install;\
### mongodb
cd /root/mongodb-1.12.0;\
/usr/local/php/bin/phpize;\
./configure --with-php-config=/usr/local/php/bin/php-config;\
make;\
make install;\
### pcntl
cd /root/php-7.4.27/ext/pcntl;\
/usr/local/php/bin/phpize;\
./configure --with-php-config=/usr/local/php/bin/php-config;\
make;\
make install;\
### swoole
cd /root/nghttp2-1.46.0;\
./configure;\
make;\
make install;\
cd /root/swoole-4.8.5;\
/usr/local/php/bin/phpize;\
./configure --with-php-config=/usr/local/php/bin/php-config --enable-sockets --enable-http2 --enable-openssl --enable-mysqlnd;\
make;\
make install;\
## 4目录权限
chown -R www:www /usr/local/php;\
# 安装MySQL
## 1安装MySQL
\cp /root/limits.conf /etc/security/limits.conf;\
cd /root/;\
rpm -ivh mysql57-el7-10.noarch.rpm;\
yum install mysql-server -y --nogpgcheck;\
\cp /root/my.cnf /etc/my.cnf;\
\cp /root/mysqld.service /usr/lib/systemd/system/mysqld.service;\
ln -s /usr/lib/systemd/system/mysqld.service /etc/systemd/system/multi-user.target.wants/mysqld.service;\
# 安装Redis
## 1升级GCC
yum install centos-release-scl -y;\
yum install devtoolset-9-gcc devtoolset-9-gcc-c++ devtoolset-9-binutils -y;\
scl enable devtoolset-9 bash;\
source /opt/rh/devtoolset-9/enable;\
## 2安装redis
useradd redis;\
cd /root/redis-6.2.6;\
make PREFIX=/usr/local/redis/ install;\
mkdir /data/redis;\
mkdir /data/redis/log;\
\cp /root/redis.conf /usr/local/redis;\
chown -R redis:redis /data/redis;\
chown -R redis:redis /usr/local/redis;\
chmod -R 600 /usr/local/redis/redis.conf;\
\cp /root/redis.service /etc/systemd/system/redis.service;\
ln -s /etc/systemd/system/redis.service /etc/systemd/system/multi-user.target.wants/redis.service;\
# 快捷脚本
\cp /root/owner /usr/bin;\
chmod -R 755 /usr/bin/owner;\
\cp /root/mysql_init /usr/bin;\
chmod -R 755 /usr/bin/mysql_init;\
\cp /root/owner.service /etc/systemd/system/owner.service;\
ln -s /etc/systemd/system/owner.service /etc/systemd/system/multi-user.target.wants/owner.service;\
# 删除所有安装包
rm -rf /root/*
# 环境变量
ENV PATH $PATH:/usr/local/php/bin:/usr/local/php/sbin:/usr/local/nginx/sbin:/usr/local/redis/bin
# 创建卷
VOLUME ["/sys/fs/cgroup","/www","/data/mysql","/data/redis"]
# 初始化
CMD ["/usr/sbin/init"]
