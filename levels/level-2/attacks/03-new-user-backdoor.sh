#!/bin/bash

# ============================================================
#  SIMULATION — Création compte backdoor (Niveau 2)
#  MITRE ATT&CK : T1136.001 — Create Account: Local Account
# ============================================================

WAZUH_IP="127.0.0.1"
SYSLOG_PORT="514"
HOSTNAME="server-prod-01"
BACKDOOR_USER="svc_monitor"   # Nom qui ressemble à un compte système légitime

RED='\033[0;31m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo ""
echo "============================================================"
echo -e "  ${RED}[SIMULATION] Compte Backdoor — Niveau 2${NC}"
echo "============================================================"
echo ""
echo -e "  ${YELLOW}MITRE${NC}        : T1136.001 — Create Account: Local Account"
echo -e "  ${YELLOW}User créé${NC}    : $BACKDOOR_USER (camouflé en compte système)"
echo ""

DATE=$(date '+%b %d %H:%M:%S')

send_syslog() {
    printf "<36>%s %s %s\n" "$DATE" "$HOSTNAME" "$1" | nc -u -w1 "$WAZUH_IP" "$SYSLOG_PORT" 2>/dev/null || \
    printf "<36>%s %s %s\n" "$DATE" "$HOSTNAME" "$1" | nc -w1 "$WAZUH_IP" "$SYSLOG_PORT" 2>/dev/null
}

echo -e "${CYAN}[*] Phase 1 — Création du compte backdoor...${NC}"
send_syslog "useradd[2001]: new user: name=$BACKDOOR_USER, UID=1337, GID=1337, home=/home/$BACKDOOR_USER, shell=/bin/bash"
send_syslog "passwd[2002]: pam_unix(passwd:chauthtok): password changed for $BACKDOOR_USER"
sleep 0.5

echo -e "${CYAN}[*] Phase 2 — Ajout au groupe sudo...${NC}"
send_syslog "usermod[2003]: add '$BACKDOOR_USER' to group 'sudo'"
send_syslog "usermod[2004]: add '$BACKDOOR_USER' to shadow group 'sudo'"
send_syslog "ossec: File '/etc/group' modified. Owner: root. Mode: 644."
send_syslog "ossec: File '/etc/passwd' modified. Owner: root. Mode: 644."
sleep 0.5

echo -e "${CYAN}[*] Phase 3 — Ajout clé SSH backdoor...${NC}"
send_syslog "ossec: New directory '/home/$BACKDOOR_USER/.ssh' added."
send_syslog "ossec: New file '/home/$BACKDOOR_USER/.ssh/authorized_keys' added. Owner: $BACKDOOR_USER."
sleep 0.5

echo -e "${CYAN}[*] Phase 4 — Première connexion du compte backdoor...${NC}"
send_syslog "sshd[2010]: Accepted publickey for $BACKDOOR_USER from 192.168.100.50 port 54888 ssh2"
send_syslog "sshd[2010]: pam_unix(sshd:session): session opened for user $BACKDOOR_USER by (uid=0)"
send_syslog "sudo: $BACKDOOR_USER : TTY=pts/0 ; PWD=/root ; USER=root ; COMMAND=/bin/bash"
sleep 0.3

echo ""
echo "============================================================"
echo -e "  ${GREEN}Simulation terminée${NC}"
echo "============================================================"
echo ""
echo "  Dans Wazuh → Threat Hunting :"
echo ""
echo -e "  ${CYAN}1. rule.groups: account_changed${NC}"
echo "     ou : data.dstuser: $BACKDOOR_USER"
echo ""
echo -e "  ${CYAN}2. Questions :${NC}"
echo "     → Quel UID a reçu le nouveau compte ? (1337 = suspect)"
echo "     → A-t-il eu accès à sudo ?"
echo "     → Y a-t-il eu une connexion SSH réussie depuis l'IP de l'attaquant ?"
echo ""
echo -e "  ${CYAN}3. Technique de camouflage :${NC}"
echo "     'svc_monitor' ressemble à un compte de service système légitime."
echo "     → Toujours vérifier les comptes récemment créés après un incident !"
echo ""
