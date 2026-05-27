#!/bin/bash

# ============================================================
#  SIMULATION — Echecs sudo/su (Niveau 1)
#  MITRE ATT&CK : T1548.003 — Sudo and Sudo Caching
# ============================================================
#
#  Injection de logs PAM/sudo dans Wazuh via syslog.
#  Simule des tentatives d'escalade de privilèges locales.
# ============================================================

WAZUH_IP="127.0.0.1"
SYSLOG_PORT="514"
HOSTNAME="workstation-01"
LOCAL_USER="jdupont"

RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
NC='\033[0m'

echo ""
echo "============================================================"
echo -e "  ${RED}[SIMULATION] Echecs d'authentification — Niveau 1${NC}"
echo "============================================================"
echo ""
echo -e "  ${YELLOW}User simulé${NC} : $LOCAL_USER"
echo -e "  ${YELLOW}Type${NC}        : sudo / su failures (attaque locale)"
echo -e "  ${YELLOW}MITRE${NC}       : T1548.003 — Sudo and Sudo Caching"
echo ""
echo "  → https://localhost → Threat Intelligence → Threat Hunting"
echo ""

DATE=$(date '+%b %d %H:%M:%S')

send_syslog() {
    local MSG="$1"
    # Priorité 36 = auth facility
    printf "<36>%s %s %s\n" "$DATE" "$HOSTNAME" "$MSG" | nc -u -w1 "$WAZUH_IP" "$SYSLOG_PORT" 2>/dev/null || \
    printf "<36>%s %s %s\n" "$DATE" "$HOSTNAME" "$MSG" | nc -w1 "$WAZUH_IP" "$SYSLOG_PORT" 2>/dev/null
}

echo -e "${CYAN}[*] Simulation tentatives sudo échouées...${NC}"
echo ""

for i in $(seq 1 8); do
    printf "  [sudo %02d] %s tente sudo → " "$i" "$LOCAL_USER"
    send_syslog "sudo: $LOCAL_USER : 3 incorrect password attempts ; TTY=pts/0 ; PWD=/home/$LOCAL_USER ; USER=root ; COMMAND=/bin/bash"
    send_syslog "sudo: pam_unix(sudo:auth): authentication failure; logname=$LOCAL_USER uid=1001 euid=0 tty=/dev/pts/0 ruser=$LOCAL_USER rhost= user=$LOCAL_USER"
    echo -e "${RED}échec injecté${NC}"
    sleep 0.4
done

echo ""
echo -e "${CYAN}[*] Simulation tentatives su vers root...${NC}"
echo ""

FAKE_USERS=("hacker" "backdoor" "sysadmin" "$LOCAL_USER")
for USER in "${FAKE_USERS[@]}"; do
    printf "  [su] %s → root → " "$USER"
    send_syslog "su: pam_unix(su:auth): authentication failure; logname=$USER uid=1001 euid=0 tty=pts/1 ruser=$USER rhost= user=root"
    send_syslog "su: FAILED SU (to root) $USER on pts/1"
    echo -e "${RED}échec injecté${NC}"
    sleep 0.4
done

echo ""
echo "============================================================"
echo -e "  ${GREEN}Logs d'escalade injectés dans Wazuh${NC}"
echo "============================================================"
echo ""
echo "  Dans Wazuh Dashboard → Threat Hunting :"
echo ""
echo -e "  ${CYAN}1. Filtre : rule.groups: authentication_failed${NC}"
echo "     ou : data.srcuser: $LOCAL_USER"
echo ""
echo -e "  ${CYAN}2. Règles attendues :${NC}"
echo "     → rule.id 5401 : Wazuh system audit - sudo event"
echo "     → rule.id 5503 : sudo: authentication failure"
echo "     → rule.id 5551 : su auth failed"
echo ""
echo -e "  ${CYAN}3. Différence clé avec le brute force SSH :${NC}"
echo "     SSH brute force  = attaque RÉSEAU  (IP externe : 192.168.100.50)"
echo "     sudo/su failures = attaque LOCALE  (user : $LOCAL_USER, pas d'IP source)"
echo "     → 2 vecteurs d'attaque distincts !"
echo ""
