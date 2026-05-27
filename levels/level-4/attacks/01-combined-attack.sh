#!/bin/bash

# ============================================================
#  SIMULATION — Attaque Combinée Niveaux 1+2 (Niveau 4)
#  Objectif : Valider que l'Active Response se déclenche
# ============================================================
#
#  Rejoue les techniques des niveaux 1 et 2 rapidement.
#  Si ton Active Response est configuré, l'IP doit être bloquée
#  dans les 30 secondes après le brute force.
# ============================================================

WAZUH_IP="127.0.0.1"
SYSLOG_PORT="514"
HOSTNAME="server-prod-01"
ATTACKER_IP="192.168.100.50"
BACKDOOR_USER="svc_monitor"

RED='\033[0;31m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo ""
echo "============================================================"
echo -e "  ${RED}[TEST] Attaque Combinée — Niveau 4${NC}"
echo "============================================================"
echo ""
echo -e "  ${YELLOW}Objectif${NC} : Valider l'Active Response automatique"
echo -e "  ${YELLOW}MTTD cible${NC} : < 2 minutes"
echo -e "  ${YELLOW}MTTR cible${NC} : < 5 minutes"
echo ""

DATE=$(date '+%b %d %H:%M:%S')
START_TIME=$(date +%s)

send_syslog() {
    local host="$1"; shift
    printf "<36>%s %s %s\n" "$DATE" "$host" "$1" | nc -u -w1 "$WAZUH_IP" "$SYSLOG_PORT" 2>/dev/null || \
    printf "<36>%s %s %s\n" "$DATE" "$host" "$1" | nc -w1 "$WAZUH_IP" "$SYSLOG_PORT" 2>/dev/null
}

echo -e "${CYAN}[*] Phase 1 — Brute force SSH (niveau 1 replay)...${NC}"
for i in $(seq 1 8); do
    DATE=$(date '+%b %d %H:%M:%S')
    send_syslog "$HOSTNAME" "sshd[700$i]: Failed password for root from $ATTACKER_IP port $((50000+i)) ssh2"
done
echo -e "    ${YELLOW}8 tentatives SSH injectées — l'Active Response doit bloquer $ATTACKER_IP${NC}"
sleep 2

echo -e "${CYAN}[*] Phase 2 — Persistence (cron + compte backdoor)...${NC}"
DATE=$(date '+%b %d %H:%M:%S')
send_syslog "$HOSTNAME" "ossec: File '/etc/crontab' modified. Owner: root."
send_syslog "$HOSTNAME" "useradd[7020]: new user: name=$BACKDOOR_USER, UID=1337, GID=1337"
send_syslog "$HOSTNAME" "usermod[7021]: add '$BACKDOOR_USER' to group 'sudo'"
sleep 1

echo -e "${CYAN}[*] Phase 3 — Log tampering (niveau 2 replay)...${NC}"
DATE=$(date '+%b %d %H:%M:%S')
send_syslog "$HOSTNAME" "ossec: File '/var/log/auth.log' modified. Size changed: 45231 -> 0."
send_syslog "$HOSTNAME" "ossec: File '/root/.bash_history' modified. Size changed: 3421 -> 0."
sleep 1

END_TIME=$(date +%s)
ELAPSED=$((END_TIME - START_TIME))

echo ""
echo "============================================================"
echo -e "  ${GREEN}Attaque combinée injectée en ${ELAPSED}s${NC}"
echo "============================================================"
echo ""
echo "  Vérifie maintenant dans Wazuh → Threat Hunting :"
echo ""
echo -e "  ${CYAN}1. Active Response déclenché ?${NC}"
echo "     → Cherche des alertes rule.id: 601 (firewall-drop)"
echo "     → L'IP $ATTACKER_IP doit apparaître dans les alertes AR"
echo ""
echo -e "  ${CYAN}2. Mesure ton MTTD :${NC}"
echo "     Temps entre le 1er log injecté et la 1ère alerte dans Wazuh"
echo ""
echo -e "  ${CYAN}3. Mesure ton MTTR :${NC}"
echo "     Temps entre la 1ère alerte et le blocage de $ATTACKER_IP"
echo ""
echo -e "  ${CYAN}4. Score : MTTD < 2min ET MTTR < 5min = validation réussie${NC}"
echo ""
