#!/bin/sh
# Disk Performance 
# 1 - major number
# 2 - minor mumber
# 3 - device name
# 4 - reads completed successfully
# 5 - reads merged
# 6 - sectors read
# 7 - time spent reading (ms)
# 8 - writes completed
# 9 - writes merged
# 10 - sectors written
# 11 - time spent writing (ms)
# 12 - I/Os currently in progress
# 13 - time spent doing I/Os (ms)
# 14 - weighted time spent doing I/Os (ms)
#

PATH="/sbin:/bin:/usr/sbin:/usr/bin:/root/bin:/usr/local/sbin:/usr/local/bin"
tmpdir='/etc/zabbix/tmp'
disk=$1
parm=$2
hostname=`uname`

IO () {

case $parm in 
    "rcs")
      cat /proc/diskstats | grep -w $disk | awk '{ print $4 }'
      ;;
        "rm")
      cat /proc/diskstats | grep -w $disk | awk '{ print $5 }'
      ;;
        "sr")
      cat /proc/diskstats | grep -w $disk | awk '{ print $6 }'
      ;;
        "tsr")
      cat /proc/diskstats | grep -w $disk | awk '{ print $7 }'
      ;;
        "wc")
      cat /proc/diskstats | grep -w $disk | awk '{ print $8 }'
      ;;
        "wm")
      cat /proc/diskstats | grep -w $disk | awk '{ print $9 }'
      ;;
        "sw")
      cat /proc/diskstats | grep -w $disk | awk '{ print $10 }'
      ;;
        "tsw")
      cat /proc/diskstats | grep -w $disk | awk '{ print $11 }'
      ;;
        "iocip")
      cat /proc/diskstats | grep -w $disk | awk '{ print $12 }'
      ;;
        "tsdio")
      cat /proc/diskstats | grep -w $disk | awk '{ print $13 }'
      ;;
        "wtsdio")
      cat /proc/diskstats | grep -w $disk | awk '{ print $14 }'
      ;;

esac
}

CreateDisk () {
case $hostname in
    "FreeBSD")
    if [ -c "/dev/mfid0" ]
    then { 
         kldstat | grep mfip.ko >> /dev/null ||  kldload mfip.ko
         ls /dev/pass* | awk -F'/' 'BEGIN { print "\{\n \"data\":[" }  { print  "\{\"{#DISK}\":\""$3"\"},"  }  END  { print " ]\n\}" }' > ${tmpdir}/disk.io.txt
         }
    else {
geom disk list | grep 'Geom name' | sed "s/\ //g" | awk -F":" 'BEGIN { print "\{\n \"data\":[" }  { print  "\{\"{#DISK}\":\""$2"\"},"  }  END  { print " ]\n\}" }' > ${tmpdir}/disk.io.txt
                     }
    fi
;;
	"Linux")
                if [ "`lspci | grep -i "RAID MegaRAID"`" != "" ]
	       	then {  
	       megacli -pdlist -a0 | grep 'Device Id' | awk 'BEGIN { print "{\n \"data\":[" }  { print  "{\"{#DISK}\":\""$3"\"},"  }  END  { print " ]\n}" }'  > ${tmpdir}/disk.smart.txt && echo 0 || echo 1
     		     }
              elif [ "`lspci | grep -i Adaptec`" != "" ]
	       	then {  
	       arcconf GETCONFIG 1 | grep "Reported Location" | awk '{print $7}' | awk 'BEGIN { print "{\n \"data\":[" }  { print  "{\"{#DISK}\":\""$1"\"},"  }  END  { print " ]\n}" }'  > ${tmpdir}/disk.smart.txt  && echo 0 || echo 1
    		     }
       		else {
                      dcount=`ls -1 /dev | egrep '^sa[a-z]$|^sd[a-z]$' | wc -l` 
                      line=`expr $dcount + 2`
	   ls -1 /dev | egrep '^sa[a-z]$|^sd[a-z]$' | awk 'BEGIN { print "{\n \"data\":[" }  { print  "{\"{#DISK}\":\""$1"\"},"  }  END  { print " ]\n}" }' | sed "${line}s/,//"  > ${tmpdir}/disk.smart.txt && echo 0 || echo 1

	             } 
              fi
        ;;
esac




chown zabbix:zabbix ${tmpdir}/disk.io.txt
echo 0
exit 0
}


if [ $1 = "create"  ]; then 
{
    CreateDisk 
} fi

IO

exit 0
