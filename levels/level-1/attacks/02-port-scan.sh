#!/bin/bash

# ============================================================
#  SIMULATION — Scan de Ports (Niveau 1)
#  MITRE ATT&CK : T1046 — Network Service Discovery
# ============================================================
#
#  Injection de logs firewall/nmap dans Wazuh via syslog.
#  Simule la détection d'un scan depuis une IP externe.
# ============================================================

WAZUH_IP="127.0.0.1"
SYSLOG_PORT="514"
ATTACKER_IP="192.168.100.75"
HOSTNAME="firewall-01"

RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
NC='\033[0m'

echo ""
echo "============================================================"
echo -e "  ${RED}[SIMULATION] Scan de Ports — Niveau 1${NC}"
echo "============================================================"
echo ""
echo -e "  ${YELLOW}IP attaquant simulé${NC} : $ATTACKER_IP"
echo -e "  ${YELLOW}Méthode${NC}             : Injection syslog → Wazuh port 514"
echo -e "  ${YELLOW}MITRE${NC}               : T1046 — Network Service Discovery"
echo ""
echo "  → https://localhost → Threat Intelligence → Threat Hunting"
echo ""

DATE=$(date '+%b %d %H:%M:%S')

send_syslog() {
    local MSG="$1"
    printf "<38>%s %s %s\n" "$DATE" "$HOSTNAME" "$MSG" | nc -u -w1 "$WAZUH_IP" "$SYSLOG_PORT" 2>/dev/null || \
    printf "<38>%s %s %s\n" "$DATE" "$HOSTNAME" "$MSG" | nc -w1 "$WAZUH_IP" "$SYSLOG_PORT" 2>/dev/null
}

# Ports scannés (séquence typique d'un nmap --top-ports)
PORTS=(21 22 23 25 53 80 110 135 139 143 443 445 993 995 1723 3306 3389 5900 8080 8443)

echo -e "${CYAN}[*] Simulation d'un scan nmap SYN...${NC}"
echo ""

for PORT in "${PORTS[@]}"; do
    printf "  Scan port %-5s → " "$PORT"
    # Format iptables DROP log — reconnu par Wazuh rule 4151+
    send_syslog "kernel: [UFW BLOCK] IN=eth0 OUT= MAC=00:00:00:00:00:00 SRC=$ATTACKER_IP DST=10.0.0.1 LEN=44 TOS=0x00 PREC=0x00 TTL=49 ID=$RANDOM PROTO=TCP SPT=$((RANDOM%60000+1024)) DPT=$PORT WINDOW=1024 RES=0x00 SYN URGP=0"
    echo -e "${YELLOW}bloqué (log injecté)${NC}"
    sleep 0.2
done

echo ""
echo -e "${CYAN}[*] Injection de logs nmap OS detection...${NC}"
send_syslog "kernel: [UFW BLOCK] IN=eth0 OUT= MAC=00:00:00:00:00:00 SRC=$ATTACKER_IP DST=10.0.0.1 LEN=44 PROTO=TCP SPT=55000 DPT=9200 WINDOW=1024 SYN URGP=0"
send_syslog "kernel: [UFW BLOCK] IN=eth0 OUT= MAC=00:00:00:00:00:00 SRC=$ATTACKER_IP DST=10.0.0.1 LEN=44 PROTO=TCP SPT=55001 DPT=55000 WINDOW=1024 SYN URGP=0"

echo ""
echo "============================================================"
echo -e "  ${GREEN}Scan simulé — ${#PORTS[@]} ports sondés${NC}"
echo "============================================================"
echo ""
echo "  Dans Wazuh Dashboard → Threat Hunting :"
echo ""
echo -e "  ${CYAN}1. Filtre : data.srcip: $ATTACKER_IP${NC}"
echo ""
echo -e "  ${CYAN}2. Observation clé :${NC}"
echo "     Le scan de ports est détecté via les logs firewall (iptables/UFW)."
echo "     Sans firewall logging, Wazuh ne voit PAS les scans réseau."
echo "     → C'est une limite importante de ton SOC à documenter !"
echo ""
echo -e "  ${CYAN}3. IP attaquant simulé : ${RED}$ATTACKER_IP${NC}"
echo "     (différente du brute force pour distinguer les 2 incidents)"
echo ""
