#!/bin/bash
BOLD='\e[1m'
RED='\e[38;5;196m'
GREEN='\e[38;5;46m' 
GOLD='\e[38;5;226m'
GREY='\033[0;37m'
ORANGE='\e[38;5;202m'
CYAN='\033[0;36m'
echo -e "${GOLD}${BOLD}$(figlet -f slant  MAL-OR-NOT!)"
echo -e "${RED}${BOLD}\t\t\t\t-Malicious Entity Detector.${CYAN}\n"
spin='-\|/'
bash speedtest.sh & pid=`echo $!`
i=0
while kill -0 $pid 2>/dev/null
do
  i=$(( (i+1) %4 ))
  printf "\r[${spin:$i:1}] Fetching internet stability. Have patience."
  sleep .1
done
echo -e "\n"
p=$(cat /tmp/speed_report.txt | grep Ping | cut -d " " -f 2)
if (( $(echo "$p < 100" |bc -l) ))
then echo -e "${GREEN}${BOLD}[i] Your ping is: $p ms. The program should work fine.${CYAN}"
elif (( $(echo "$p > 100" |bc -l) )) && (( $(echo "$p < 250" |bc -l) ))
then echo -e "${ORANGE}${BOLD}[i] Your ping is: $p ms. Some processes might take longer than usual.${CYAN}" 
else
echo -e "${RED}${BOLD}[i] Your ping is: $p ms. Some options might not work well. Consider switching your network. Exiting..."; exit
fi
echo -e "\n"
# read -p "Enter username:" USER
# read -p "Enter city:" CITY
