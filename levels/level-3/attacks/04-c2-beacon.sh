#!/bin/bash

# ============================================================
#  SIMULATION — C2 Beaconing (Niveau 3)
#  MITRE ATT&CK : T1071.001 — Application Layer Protocol: Web Protocols
# ============================================================
#
#  Un implant C2 envoie des requêtes HTTP régulières (beacons)
#  vers un serveur de commande et contrôle externe.
#  Détectable via la régularité et la périodicité des connexions.
# ============================================================

WAZUH_IP="127.0.0.1"
SYSLOG_PORT="514"
HOSTNAME="apt-host-42"
C2_IP="185.220.101.45"
C2_PORT="443"
BEACON_INTERVAL=3  # Secondes entre beacons (réel : 60-300s)

RED='\033[0;31m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo ""
echo "============================================================"
echo -e "  ${RED}[SIMULATION] C2 Beaconing — Niveau 3${NC}"
echo "============================================================"
echo ""
echo -e "  ${YELLOW}MITRE${NC}     : T1071.001"
echo -e "  ${YELLOW}Host${NC}      : $HOSTNAME"
echo -e "  ${YELLOW}C2 IP${NC}     : $C2_IP:$C2_PORT"
echo -e "  ${YELLOW}Interval${NC}  : ${BEACON_INTERVAL}s (simulé)"
echo ""

DATE=$(date '+%b %d %H:%M:%S')

send_syslog() {
    printf "<38>%s %s %s\n" "$DATE" "$HOSTNAME" "$1" | nc -u -w1 "$WAZUH_IP" "$SYSLOG_PORT" 2>/dev/null || \
    printf "<38>%s %s %s\n" "$DATE" "$HOSTNAME" "$1" | nc -w1 "$WAZUH_IP" "$SYSLOG_PORT" 2>/dev/null
}

echo -e "${CYAN}[*] Phase 1 — Établissement de la connexion C2 initiale...${NC}"
send_syslog "curl[6001]: Connected to $C2_IP:$C2_PORT"
send_syslog "curl[6001]: GET /api/v1/status HTTP/1.1 Host: update-cdn.net User-Agent: Mozilla/5.0"
send_syslog "curl[6001]: HTTP/1.1 200 OK Content-Length: 32"
sleep 1

echo -e "${CYAN}[*] Phase 2 — Beacons réguliers (10 cycles simulés)...${NC}"
for i in $(seq 1 10); do
    DATE=$(date '+%b %d %H:%M:%S')
    send_syslog "curl[600$i]: GET /api/v1/tasks HTTP/1.1 Host: update-cdn.net"
    send_syslog "curl[600$i]: HTTP/1.1 200 OK Content-Length: 0"
    echo -e "    ${YELLOW}Beacon $i/10 envoyé${NC}"
    sleep "$BEACON_INTERVAL"
done
sleep 0.5

echo -e "${CYAN}[*] Phase 3 — Réception d'une commande C2...${NC}"
DATE=$(date '+%b %d %H:%M:%S')
send_syslog "curl[6020]: GET /api/v1/tasks HTTP/1.1 Host: update-cdn.net"
send_syslog "curl[6020]: HTTP/1.1 200 OK Content-Length: 128"
send_syslog "bash[6021]: Executing task: d2hvYW1pO2lkO2hvc3RuYW1lO3VuYW1lIC1h"
send_syslog "curl[6022]: POST /api/v1/results HTTP/1.1 Content-Length: 256"
sleep 0.5

echo -e "${CYAN}[*] Phase 4 — Sleep aléatoire pour éviter la détection (jitter)...${NC}"
send_syslog "curl[6030]: Sleeping 287s (jitter: +37s)"
send_syslog "curl[6031]: GET /api/v1/tasks HTTP/1.1 Host: update-cdn.net"

echo ""
echo "============================================================"
echo -e "  ${GREEN}Simulation terminée${NC}"
echo "============================================================"
echo ""
echo "  Dans Wazuh → Threat Hunting :"
echo ""
echo -e "  ${CYAN}1. Cherche des connexions répétées vers la même IP externe :${NC}"
echo "     data.dstip: $C2_IP"
echo ""
echo -e "  ${CYAN}2. Indicateurs de beaconing :${NC}"
echo "     → Même IP/domaine contactée à intervalles réguliers"
echo "     → User-Agent générique (Mozilla/5.0 sans détails OS)"
echo "     → Réponses HTTP courtes (< 50 bytes) = heartbeat"
echo "     → Jitter = variation ±10-20% de l'intervalle"
echo ""
echo -e "  ${CYAN}3. Défi avancé :${NC}"
echo "     Calculer l'intervalle moyen entre les connexions."
echo "     Si écart-type < 10% → très probablement automatisé."
echo ""
echo -e "  ${CYAN}4. C2 IP : ${RED}$C2_IP${NC} (même IP que l'attaque Living-off-the-Land)"
echo ""
