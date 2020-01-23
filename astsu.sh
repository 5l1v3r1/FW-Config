#!/bin/bash

function help() {
    echo "astsu - Firewall Configuration Tool"
    echo -e "Lista de comandos - Help\n"
    echo "--start : Sets the firewall configuration"
    echo "--set-default : Sets the default firewall configuration" 
    echo -e "--configure : Configure the script\n"
}

function set_all_configs(){
    file="/usr/share/astsu/config"
    declare -a options_array
    options_array=()

    while IFS= read -r line
    do
        options_array+=(${line:0:2})
    done < "$file"

    echo ${options_array[2]} > /proc/sys/net/ipv4/tcp_syncookies
    echo ${options_array[1]} > /proc/sys/net/ipv4/icmp_echo_ignore_broadcasts
    echo ${options_array[0]} > /proc/sys/net/ipv4/icmp_echo_ignore_all
    iptables -A INPUT -p udp -m limit --limit ${options_array[4]}/s -j ACCEPT
    iptables -A INPUT -p tcp --syn --dport 80 -m connlimit --connlimit-above ${options_array[3]} -j DROP
    iptables -A INPUT -p tcp --syn --dport 443 -m connlimit --connlimit-above ${options_array[3]} -j DROP
}

function set_default(){
    echo 0 > /proc/sys/net/ipv4/tcp_syncookies
    echo 0 > /proc/sys/net/ipv4/icmp_echo_ignore_broadcasts
    echo 0 > /proc/sys/net/ipv4/icmp_echo_ignore_all
    iptables --flush
}

function set_config_file(){
    declare -A options
    read -p "Ignore all icmp requests? y/n: " option;
    if [ "$option" == "y" ]
    then
        options=( ["icmp_all"]=1 )
    elif [ "$option" == "n" ]
    then
        options+=( ["icmp_all"]=0 )
    fi

    read -p "Ignore icmp broadcasts? y/n: " option;
    if [ "$option" == "y" ]
    then
        options+=( ["icmp_broadcasts"]=1 )
    elif [ "$option" == "n" ]
    then
        options+=( ["icmp_broadcasts"]=0 )
    fi

    read -p "Enable TCP_SYN cookies? y/n: " option;
    if [ "$option" == "y" ]
    then
        options+=( ["tcp_syncookies"]=1 )
    elif [ "$option" == "n" ]
    then
        options+=( ["tcp_syncookies"]=0 )
    fi

    read -p "Connections limit per ip: " option;
    options+=( ["connections_limit"]=$option )

    read -p "UDP packet limit per second: " option;
    options+=( ["udp_limit"]=$option )

    echo "${options['icmp_all']}   :   Ignore all icmp requests" > /usr/share/astsu/config
    echo "${options['icmp_broadcasts']}   :   Ignore all icmp broadcast requests" >> /usr/share/astsu/config
    echo "${options['tcp_syncookies']}   :   Enable TCP SYN cookies" >> /usr/share/astsu/config
    if [ ${#options['connections_limit']} == 1 ]
    then
        echo "${options['connections_limit']}   :   Configure connections limit per ip" >> /usr/share/astsu/config
    else
        echo "${options['connections_limit']}  :   Configure connections limit per ip" >> /usr/share/astsu/config
    fi
    echo "${options['udp_limit']}   :   UDP packet limit per second" >> /usr/share/astsu/config

}

case $1 in
    --start)
        set_all_configs ;;

    --set-default)
        set_default ;;

    --configure)
        set_config_file ;;

    -h | --help) 
        help ;;

    *) echo -e "astsu v1.0: Nenhum comando especificado ou desconhecido\nTente astsu -h ou astsu --help" ;;
esac