#!/bin/bash

# ============================================================
#  SIMULATION — Log Tampering (Niveau 2)
#  MITRE ATT&CK : T1070.002 — Indicator Removal: Clear Linux Logs
# ============================================================

WAZUH_IP="127.0.0.1"
SYSLOG_PORT="514"
HOSTNAME="server-prod-01"

RED='\033[0;31m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo ""
echo "============================================================"
echo -e "  ${RED}[SIMULATION] Log Tampering — Niveau 2${NC}"
echo "============================================================"
echo ""
echo -e "  ${YELLOW}MITRE${NC} : T1070.002 — Indicator Removal: Clear Linux Logs"
echo ""

DATE=$(date '+%b %d %H:%M:%S')

send_syslog() {
    printf "<38>%s %s %s\n" "$DATE" "$HOSTNAME" "$1" | nc -u -w1 "$WAZUH_IP" "$SYSLOG_PORT" 2>/dev/null || \
    printf "<38>%s %s %s\n" "$DATE" "$HOSTNAME" "$1" | nc -w1 "$WAZUH_IP" "$SYSLOG_PORT" 2>/dev/null
}

echo -e "${CYAN}[*] Phase 1 — Troncature du auth.log...${NC}"
send_syslog "ossec: File '/var/log/auth.log' modified. Size changed: 45231 -> 0."
send_syslog "ossec: Integrity checksum changed for '/var/log/auth.log'"
sleep 0.5

echo -e "${CYAN}[*] Phase 2 — Suppression de fichiers de log...${NC}"
send_syslog "ossec: File '/var/log/syslog.1' deleted. It was present in the database."
send_syslog "ossec: File '/var/log/auth.log.1' deleted. It was present in the database."
send_syslog "ossec: File '/root/.bash_history' modified. Size changed: 3421 -> 0."
sleep 0.5

echo -e "${CYAN}[*] Phase 3 — Modification des timestamps (anti-forensics)...${NC}"
send_syslog "ossec: File '/var/log/wtmp' modified. Modification time changed."
send_syslog "ossec: File '/var/log/lastlog' modified. Modification time changed."
sleep 0.5

echo -e "${CYAN}[*] Phase 4 — Tentative de suppression des logs Wazuh...${NC}"
send_syslog "ossec: File '/var/ossec/logs/alerts/alerts.log' modified."
send_syslog "sshd[2020]: Accepted publickey for svc_monitor from 192.168.100.50 port 55001 ssh2"
sleep 0.3

echo ""
echo "============================================================"
echo -e "  ${GREEN}Simulation terminée${NC}"
echo "============================================================"
echo ""
echo "  Dans Wazuh → Threat Hunting :"
echo ""
echo -e "  ${CYAN}1. rule.groups: syscheck${NC}"
echo "     Cherche des alertes de suppression (deleted) ou troncature (size -> 0)"
echo ""
echo -e "  ${CYAN}2. Questions :${NC}"
echo "     → Quels fichiers de log ont été modifiés/supprimés ?"
echo "     → Quelle est l'implication pour l'investigation ?"
echo "     → Que prouve le fait que Wazuh a quand même détecté ça ?"
echo ""
echo -e "  ${CYAN}3. Leçon clé :${NC}"
echo "     L'attaquant efface ses traces MAIS Wazuh surveille les fichiers de log."
echo "     Si les logs sont supprimés → Wazuh génère une alerte FIM."
echo "     → Les logs de Wazuh sont séparés et plus difficiles à effacer."
echo "     → C'est pourquoi un SIEM centralisé hors du système est essentiel."
echo ""
