#!/bin/bash

#Ejecuta en segundo plano y sin outputs el script de python
sudo nohup python /home/pi/mqtt_broker_database.py &

#Nuestro servidor MQTT
mqtt_broker='192.168.1.20'

#Todos los topics
topic_temp="casa/habitacion/raspberrypi-1/temp"
topic_n_process="casa/habitacion/raspberrypi-1/n_process"
topic_cpu_usage="casa/habitacion/raspberrypi-1/cpu_usage"
topic_ram_usage="casa/habitacion/raspberrypi-1/ram_usage"
topic_ram_free="casa/habitacion/raspberrypi-1/ram_free"
topic_rx_traffic_eth0="casa/habitacion/raspberrypi-1/rx_traffic_eth0"
topic_tx_traffic_eth0="casa/habitacion/raspberrypi-1/tx_traffic_eth0"
topic_rx_traffic_wlan0="casa/habitacion/raspberrypi-1/rx_traffic_wlan0"
topic_tx_traffic_wlan0="casa/habitacion/raspberrypi-1/tx_traffic_wlan0"
topic_rx_traffic_tun1="casa/habitacion/raspberrypi-1/rx_traffic_tun1"
topic_tx_traffic_tun1="casa/habitacion/raspberrypi-1/tx_traffic_tun1"
topic_rx_traffic_tun2="casa/habitacion/raspberrypi-1/rx_traffic_tun2"
topic_tx_traffic_tun2="casa/habitacion/raspberrypi-1/tx_traffic_tun2"
topic_rx_bytes_eth0="casa/habitacion/raspberrypi-1/rx_bytes_eth0"
topic_tx_bytes_eth0="casa/habitacion/raspberrypi-1/tx_bytes_eth0"
topic_rx_bytes_wlan0="casa/habitacion/raspberrypi-1/rx_bytes_wlan0"
topic_tx_bytes_wlan0="casa/habitacion/raspberrypi-1/tx_bytes_wlan0"
topic_rx_bytes_tun1="casa/habitacion/raspberrypi-1/rx_bytes_tun1"
topic_tx_bytes_tun1="casa/habitacion/raspberrypi-1/tx_bytes_tun1"
topic_rx_bytes_tun2="casa/habitacion/raspberrypi-1/rx_bytes_tun2"
topic_tx_bytes_tun2="casa/habitacion/raspberrypi-1/tx_bytes_tun2"
topic_ping_min="casa/habitacion/raspberrypi-1/ping_min"
topic_ping_avg="casa/habitacion/raspberrypi-1/ping_avg"
topic_ping_max="casa/habitacion/raspberrypi-1/ping_max"
topic_ping_losts="casa/habitacion/raspberrypi-1/ping_losts"

#Bucle infinito
while true;
do
	#Guardamos resultado de un ping a google
	ping -c 10 -s 1000 -i 0.2 8.8.8.8 > /tmp/mqtt_ping

	#Almacenamos todos los valores en variables
	temp=`cat /sys/class/thermal/thermal_zone0/temp | cut -c1,2`
	n_process=`ps aux | wc -l`
	cpu_usage=`mpstat | grep -A 5 "%idle" | tail -n 1 | awk -F " " '{print 100 -  $ 12}'a`
	ram_usage=`free -h | grep Mem: |tr -s " " | cut -f3 -d' ' | grep -o [0-9]*`
	ram_free=`free -h | grep Mem: |tr -s " " | cut -f4 -d' ' | grep -o [0-9]*`
	rx_traffic_eth0=`ifstat -i eth0 0.1 1 | tail -n1 | tr -s " " | cut -f2 -d' '`
	tx_traffic_eth0=`ifstat -i eth0 0.1 1 | tail -n1 | tr -s " " | cut -f3 -d' '`
	rx_traffic_wlan0=`ifstat -i wlan0 0.1 1 | tail -n1 | tr -s " " | cut -f2 -d' '`
	tx_traffic_wlan0=`ifstat -i wlan0 0.1 1 | tail -n1 | tr -s " " | cut -f3 -d' '`
	rx_traffic_tun1=`ifstat -i tun1 0.1 1 | tail -n1 | tr -s " " | cut -f2 -d' '`
	tx_traffic_tun1=`ifstat -i tun1 0.1 1 | tail -n1 | tr -s " " | cut -f3 -d' '`
	rx_traffic_tun2=`ifstat -i tun2 0.1 1 | tail -n1 | tr -s " " | cut -f2 -d' '`
	tx_traffic_tun2=`ifstat -i tun2 0.1 1 | tail -n1 | tr -s " " | cut -f3 -d' '`
	rx_bytes_eth0=`ifconfig eth0 | tail -n2 | cut -f2 -d'X' | grep -o \([0-9]*\.[0-9]* | cut -f2 -d'('`
	tx_bytes_eth0=`ifconfig eth0 | tail -n2 | cut -f3 -d'X' | grep -o \([0-9]*\.[0-9]* | cut -f2 -d'('`
	rx_bytes_wlan0=`ifconfig wlan0 | tail -n2 | cut -f2 -d'X' | grep -o \([0-9]*\.[0-9]* | cut -f2 -d'('`
	tx_bytes_wlan0=`ifconfig wlan0 | tail -n2 | cut -f3 -d'X' | grep -o \([0-9]*\.[0-9]* | cut -f2 -d'('`
	rx_bytes_tun1=`ifconfig tun1 | tail -n2 | cut -f2 -d'X' | grep -o \([0-9]*\.[0-9]* | cut -f2 -d'('`
	tx_bytes_tun1=`ifconfig tun1 | tail -n2 | cut -f3 -d'X' | grep -o \([0-9]*\.[0-9]* | cut -f2 -d'('`
	rx_bytes_tun2=`ifconfig tun2 | tail -n2 | cut -f2 -d'X' | grep -o \([0-9]*\.[0-9]* | cut -f2 -d'('`
	tx_bytes_tun2=`ifconfig tun2 | tail -n2 | cut -f3 -d'X' | grep -o \([0-9]*\.[0-9]* | cut -f2 -d'('`
	ping_min=`cat /tmp/mqtt_ping | grep rtt | cut -f2 -d'=' | tr -d 'ms'' ' | cut -f1 -d /`
	ping_avg=`cat /tmp/mqtt_ping | grep rtt | cut -f2 -d'=' | tr -d 'ms'' ' | cut -f2 -d /`
	ping_max=`cat /tmp/mqtt_ping | grep rtt | cut -f2 -d'=' | tr -d 'ms'' ' | cut -f3 -d /`
	ping_losts=`cat /tmp/mqtt_ping | grep -o [0-9]*% | grep -o [0-9]`

	#Publicamos cada valor al broker por el topic que especificamos
	mosquitto_pub -h $mqtt_broker -t $topic_temp -m "$temp"
	mosquitto_pub -h $mqtt_broker -t $topic_n_process -m "$n_process"
	mosquitto_pub -h $mqtt_broker -t $topic_cpu_usage -m "$cpu_usage"
	mosquitto_pub -h $mqtt_broker -t $topic_ram_usage -m "$ram_usage"
	mosquitto_pub -h $mqtt_broker -t $topic_ram_free -m "$ram_free"

	mosquitto_pub -h $mqtt_broker -t $topic_rx_traffic_eth0 -m "$rx_traffic_eth0"
	mosquitto_pub -h $mqtt_broker -t $topic_tx_traffic_eth0 -m "$tx_traffic_eth0"

	mosquitto_pub -h $mqtt_broker -t $topic_rx_traffic_wlan0 -m "$rx_traffic_wlan0"
	mosquitto_pub -h $mqtt_broker -t $topic_tx_traffic_wlan0 -m "$tx_traffic_wlan0"

	mosquitto_pub -h $mqtt_broker -t $topic_rx_traffic_tun1 -m "$rx_traffic_tun1"
	mosquitto_pub -h $mqtt_broker -t $topic_tx_traffic_tun1 -m "$tx_traffic_tun1"

	mosquitto_pub -h $mqtt_broker -t $topic_rx_traffic_tun2 -m "$rx_traffic_tun2"
	mosquitto_pub -h $mqtt_broker -t $topic_tx_traffic_tun2 -m "$tx_traffic_tun2"

	mosquitto_pub -h $mqtt_broker -t $topic_rx_bytes_eth0 -m "$rx_bytes_eth0"
	mosquitto_pub -h $mqtt_broker -t $topic_tx_bytes_eth0 -m "$tx_bytes_eth0"

	mosquitto_pub -h $mqtt_broker -t $topic_rx_bytes_wlan0 -m "$rx_bytes_wlan0"
	mosquitto_pub -h $mqtt_broker -t $topic_tx_bytes_wlan0 -m "$tx_bytes_wlan0"

	mosquitto_pub -h $mqtt_broker -t $topic_rx_bytes_tun1 -m "$rx_bytes_tun1"
	mosquitto_pub -h $mqtt_broker -t $topic_tx_bytes_tun1 -m "$tx_bytes_tun1"

	mosquitto_pub -h $mqtt_broker -t $topic_rx_bytes_tun2 -m "$rx_bytes_tun2"
	mosquitto_pub -h $mqtt_broker -t $topic_tx_bytes_tun2 -m "$tx_bytes_tun2"

	mosquitto_pub -h $mqtt_broker -t $topic_ping_min -m "$ping_min"
	mosquitto_pub -h $mqtt_broker -t $topic_ping_avg -m "$ping_avg"
	mosquitto_pub -h $mqtt_broker -t $topic_ping_max -m "$ping_max"
	mosquitto_pub -h $mqtt_broker -t $topic_ping_losts -m "$ping_losts"

	sleep 2
done
