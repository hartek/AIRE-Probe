# This script will contain the logic of the sniffer, and will execute each time a device connects/disconnects. 
# It will be located at /etc/hostapd/sniffer.sh.

f [[ $2 == "AP-STA-CONNECTED" ]]
then
        echo "Cliente $3 conectado en $1" >> /tmp/sniffer_log
        tcpdump -U -i $1 ether host $3 -s 0 -w "/home/pi/capturas/$3__`date +%d-%m-%Y__%T.pcap`" &
        pid=$!
        (flock -e 200
                echo "$pid $3" >> /tmp/sniffer_pids
        ) 200>/tmp/lock
fi

if [[ $2 == "AP-STA-DISCONNECTED" ]]
then
        echo "Cliente $3 desconectado en $1" >> /tmp/sniffer_log
        (flock -e 200
                line=`cat /tmp/sniffer_pids | grep $3`
                pid=`echo $line | cut -f 1 -d ' '`
                kill $pid
        ) 200>/tmp/lock
        (flock -e 200
                cat /tmp/sniffer_pids | egrep -v '^$3 .*$' > /tmp/sniffer_pids
        ) 200>/tmp/lock
fi
