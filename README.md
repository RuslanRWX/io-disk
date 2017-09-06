# io-disk
# Disk Performance 
1 - major number <br>
2 - minor mumber <br>
3 - device name  <br>
4 - reads completed successfully <br>
5 - reads merged  <br>
6 - sectors read  <br>
7 - time spent reading (ms) <br>
8 - writes completed  <br>
9 - writes merged <br>
10 - sectors written <br>
11 - time spent writing (ms) <br>
12 - I/Os currently in progress <br>
13 - time spent doing I/Os (ms) <br>
14 - weighted time spent doing I/Os (ms) <br>


# install <br> 
git clone https://github.com/ruslansvs2/io-disk.git <br>
mkdir /etc/zabbix/bin <br>
cd io-disk <br>
cp io.sh /etc/zabbix/bin <br>
