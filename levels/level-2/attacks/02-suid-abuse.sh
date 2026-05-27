#!/bin/bash

# ============================================================
#  SIMULATION — SUID Abuse (Niveau 2)
#  MITRE ATT&CK : T1548.001 — Setuid and Setgid
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
echo -e "  ${RED}[SIMULATION] SUID Abuse — Niveau 2${NC}"
echo "============================================================"
echo ""
echo -e "  ${YELLOW}MITRE${NC} : T1548.001 — Setuid and Setgid"
echo ""

DATE=$(date '+%b %d %H:%M:%S')

send_syslog() {
    printf "<38>%s %s %s\n" "$DATE" "$HOSTNAME" "$1" | nc -u -w1 "$WAZUH_IP" "$SYSLOG_PORT" 2>/dev/null || \
    printf "<38>%s %s %s\n" "$DATE" "$HOSTNAME" "$1" | nc -w1 "$WAZUH_IP" "$SYSLOG_PORT" 2>/dev/null
}

echo -e "${CYAN}[*] Phase 1 — Copie d'un binaire système...${NC}"
send_syslog "ossec: New file '/tmp/.hidden/bash' added to the file system."
send_syslog "ossec: File '/tmp/.hidden/bash' added. Mode: 755. Owner: root."
sleep 0.5

echo -e "${CYAN}[*] Phase 2 — chmod +s sur le binaire...${NC}"
send_syslog "ossec: File '/tmp/.hidden/bash' modified. Mode changed: 755 -> 4755 (SUID set)."
send_syslog "ossec: Rootcheck: SUID binary found: '/tmp/.hidden/bash'. Size: 1234567."
sleep 0.5

echo -e "${CYAN}[*] Phase 3 — Rootcheck détecte le SUID anormal...${NC}"
send_syslog "ossec: Rootkit detected: '/tmp/.hidden/bash' is a SUID/SGID binary not in database."
send_syslog "ossec: File '/usr/local/bin/sysinfo' has been modified. SUID bit set."
sleep 0.5

echo -e "${CYAN}[*] Phase 4 — Exécution avec privilèges élevés...${NC}"
send_syslog "sudo: jdupont : TTY=pts/1 ; PWD=/tmp ; USER=root ; COMMAND=/tmp/.hidden/bash -p"
send_syslog "su: (to root) jdupont on pts/1"
send_syslog "su: pam_unix(su-l:session): session opened for user root by jdupont(uid=1001)"
sleep 0.3

echo ""
echo "============================================================"
echo -e "  ${GREEN}Simulation terminée${NC}"
echo "============================================================"
echo ""
echo "  Dans Wazuh → Threat Hunting :"
echo ""
echo -e "  ${CYAN}1. rule.groups: rootcheck${NC}"
echo "     Cherche 'SUID' dans les descriptions"
echo ""
echo -e "  ${CYAN}2. Questions :${NC}"
echo "     → Quel fichier a reçu le bit SUID ?"
echo "     → Pourquoi /tmp est-il suspect ?"
echo "     → Comment vérifier tous les SUID sur un système :"
echo "       find / -perm -4000 -type f 2>/dev/null"
echo ""
echo -e "  ${CYAN}3. Concept clé :${NC}"
echo "     SUID sur bash = n'importe quel user peut lancer bash en root."
echo "     C'est une technique d'escalade classique post-exploitation."
echo ""
