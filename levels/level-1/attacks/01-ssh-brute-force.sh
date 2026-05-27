#!/bin/bash

# ============================================================
#  SIMULATION — Brute Force SSH (Niveau 1)
#  MITRE ATT&CK : T1110.001 — Password Guessing
# ============================================================
#
#  Injection de faux logs SSH dans Wazuh via syslog (port 514).
#  Wazuh reçoit les logs, les décode et génère les alertes.
#
#  Pourquoi syslog et pas SSH direct ?
#  Wazuh surveille les logs du container Docker, pas les logs
#  macOS. L'injection syslog est la méthode correcte pour
#  simuler des attaques dans cet environnement.
#
#  USAGE ÉDUCATIF UNIQUEMENT
# ============================================================

WAZUH_IP="127.0.0.1"
SYSLOG_PORT="514"
ATTEMPTS=25
ATTACKER_IP="192.168.100.50"  # IP fictive de l'attaquant

RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
NC='\033[0m'

echo ""
echo "============================================================"
echo -e "  ${RED}[SIMULATION] Brute Force SSH — Niveau 1${NC}"
echo "============================================================"
echo ""
echo -e "  ${YELLOW}IP attaquant simulé${NC} : $ATTACKER_IP"
echo -e "  ${YELLOW}Tentatives${NC}          : $ATTEMPTS"
echo -e "  ${YELLOW}Méthode${NC}             : Injection syslog → Wazuh port 514"
echo -e "  ${YELLOW}MITRE${NC}               : T1110.001 — Password Guessing"
echo ""
echo "  Regarde le Wazuh Dashboard pendant l'attaque :"
echo "  → https://localhost → Threat Intelligence → Threat Hunting"
echo ""

# Vérifier que le port syslog Wazuh est accessible
if ! nc -z -u -w2 "$WAZUH_IP" "$SYSLOG_PORT" 2>/dev/null && ! nc -z -w2 "$WAZUH_IP" "$SYSLOG_PORT" 2>/dev/null; then
    echo -e "${YELLOW}[!] Port 514 non accessible — vérifier que le SOC tourne (./soc-start.sh)${NC}"
    echo ""
fi

USERS=("root" "admin" "ubuntu" "user" "test" "deploy" "git" "oracle" "postgres")
DATE=$(date '+%b %d %H:%M:%S')
HOSTNAME="web-server-01"

send_syslog() {
    local MSG="$1"
    # Priorité 36 = facility:4 (auth), severity:4 (warning)
    printf "<36>%s %s %s\n" "$DATE" "$HOSTNAME" "$MSG" | nc -u -w1 "$WAZUH_IP" "$SYSLOG_PORT" 2>/dev/null || \
    printf "<36>%s %s %s\n" "$DATE" "$HOSTNAME" "$MSG" | nc -w1 "$WAZUH_IP" "$SYSLOG_PORT" 2>/dev/null
}

echo -e "${CYAN}[*] Injection des logs SSH en cours...${NC}"
echo ""

PORT_SRC=$((RANDOM % 20000 + 40000))

for i in $(seq 1 $ATTEMPTS); do
    USER="${USERS[$((RANDOM % ${#USERS[@]}))]}"
    PORT_SRC=$((PORT_SRC + 1))

    printf "  [%02d/%02d] Failed password for %-10s from %s → " "$i" "$ATTEMPTS" "$USER" "$ATTACKER_IP"

    if [ "$((RANDOM % 3))" -eq 0 ]; then
        # User inexistant — déclenche rule 5710/5712
        send_syslog "sshd[$$]: Invalid user $USER from $ATTACKER_IP port $PORT_SRC"
        send_syslog "sshd[$$]: Failed password for invalid user $USER from $ATTACKER_IP port $PORT_SRC ssh2"
    else
        # User existant — déclenche rule 5551/5760
        send_syslog "sshd[$$]: Failed password for $USER from $ATTACKER_IP port $PORT_SRC ssh2"
    fi

    echo -e "${RED}injecté${NC}"
    sleep 0.3
done

echo ""
# Injection de l'alerte brute force finale (agrégation)
send_syslog "sshd[$$]: Failed password for root from $ATTACKER_IP port $((PORT_SRC+1)) ssh2"
send_syslog "sshd[$$]: Failed password for root from $ATTACKER_IP port $((PORT_SRC+2)) ssh2"
send_syslog "sshd[$$]: Failed password for root from $ATTACKER_IP port $((PORT_SRC+3)) ssh2"

echo "============================================================"
echo -e "  ${GREEN}$ATTEMPTS logs SSH injectés dans Wazuh${NC}"
echo "============================================================"
echo ""
echo "  Dans Wazuh Dashboard :"
echo ""
echo -e "  ${CYAN}1. Threat Intelligence → Threat Hunting${NC}"
echo "     Barre de recherche : rule.id: 5763"
echo "     Ou ajoute un filtre : rule.groups = authentication_failures"
echo ""
echo -e "  ${CYAN}2. Alertes attendues :${NC}"
echo "     → rule.id 5551  : SSH authentication failure"
echo "     → rule.id 5710  : sshd: Attempt to login using a non-existent user"
echo "     → rule.id 5760  : sshd: brute force trying to get access"
echo ""
echo -e "  ${CYAN}3. IP attaquant simulé : ${RED}$ATTACKER_IP${NC}"
echo "     → Filtre : data.srcip: $ATTACKER_IP"
echo ""
echo -e "  ${CYAN}4. Ouvre le playbook :${NC}"
echo "     core/incident-response/playbooks/01-brute-force.md"
echo ""
