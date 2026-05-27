#!/bin/bash

# ============================================================
#  SIMULATION — DNS Exfiltration (Niveau 3)
#  MITRE ATT&CK : T1048.003 — Exfiltration Over Alternative Protocol: DNS
# ============================================================
#
#  Technique : encoder des données dans des sous-domaines DNS.
#  Ex: "aW1wb3J0YW50LnR4dA==.attacker.com" = base64 du fichier.
#  Difficile à détecter : le DNS est rarement filtré ou loggué.
# ============================================================

WAZUH_IP="127.0.0.1"
SYSLOG_PORT="514"
HOSTNAME="apt-host-42"
C2_DOMAIN="exfil.c2.io"  # Domaine C2 fictif

RED='\033[0;31m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo ""
echo "============================================================"
echo -e "  ${RED}[SIMULATION] DNS Exfiltration — Niveau 3${NC}"
echo "============================================================"
echo ""
echo -e "  ${YELLOW}MITRE${NC}  : T1048.003"
echo -e "  ${YELLOW}Host${NC}   : $HOSTNAME"
echo -e "  ${YELLOW}Domain${NC} : $C2_DOMAIN"
echo ""

DATE=$(date '+%b %d %H:%M:%S')

send_syslog() {
    printf "<38>%s %s %s\n" "$DATE" "$HOSTNAME" "$1" | nc -u -w1 "$WAZUH_IP" "$SYSLOG_PORT" 2>/dev/null || \
    printf "<38>%s %s %s\n" "$DATE" "$HOSTNAME" "$1" | nc -w1 "$WAZUH_IP" "$SYSLOG_PORT" 2>/dev/null
}

echo -e "${CYAN}[*] Phase 1 — Requêtes DNS anormalement longues (chunks de données)...${NC}"
send_syslog "named[4001]: client 127.0.0.1#54321: query: aW1wb3J0YW50LXNlY3JldC50eHQ=.chunk1.$C2_DOMAIN IN A"
send_syslog "named[4002]: client 127.0.0.1#54322: query: dGhpcyBpcyBzZW5zaXRpdmUgZGF0YQ==.chunk2.$C2_DOMAIN IN A"
send_syslog "named[4003]: client 127.0.0.1#54323: query: cGFzc3dvcmQ6IHN1cGVyc2VjcmV0MTIz.chunk3.$C2_DOMAIN IN A"
sleep 0.5

echo -e "${CYAN}[*] Phase 2 — Volume élevé de requêtes vers domaine externe...${NC}"
for i in $(seq 4 15); do
    CHUNK=$(cat /dev/urandom 2>/dev/null | head -c 20 | base64 2>/dev/null | tr -d '=\n' | head -c 32 || echo "Y2h1bmske2l9")
    send_syslog "named[40$i]: client 127.0.0.1#5432$i: query: ${CHUNK}.chunk$i.$C2_DOMAIN IN A"
done
sleep 0.5

echo -e "${CYAN}[*] Phase 3 — Réponses TXT avec commandes encodées (C2 via DNS)...${NC}"
send_syslog "named[4020]: client 127.0.0.1#54400: query: cmd.$C2_DOMAIN IN TXT"
send_syslog "named[4021]: response to 127.0.0.1#54400: cmd.$C2_DOMAIN TXT \"d2hvYW1pO2lkO3VuYW1lIC1h\""
send_syslog "named[4022]: client 127.0.0.1#54401: query: cmd.$C2_DOMAIN IN TXT"
send_syslog "named[4023]: response to 127.0.0.1#54401: cmd.$C2_DOMAIN TXT \"Y2F0IC9ldGMvc2hhZG93\""
sleep 0.3

echo ""
echo "============================================================"
echo -e "  ${GREEN}Simulation terminée${NC}"
echo "============================================================"
echo ""
echo "  Dans Wazuh → Threat Hunting :"
echo ""
echo -e "  ${CYAN}1. Cherche : data.hostname: apt-host-42 AND data.program: named${NC}"
echo "     → Tu verras des sous-domaines encodés en base64"
echo ""
echo -e "  ${CYAN}2. Signaux à détecter :${NC}"
echo "     → Longueur de sous-domaine > 40 caractères (anormal)"
echo "     → Même domaine parent interrogé > 10 fois en 60 secondes"
echo "     → Requêtes TXT vers domaines inconnus (C2 via DNS)"
echo ""
echo -e "  ${CYAN}3. Défi :${NC}"
echo "     Écrire une règle qui détecte les sous-domaines base64 suspects"
echo "     (regex sur data.dns.question.name avec pattern [A-Za-z0-9+/]{30,})"
echo ""
echo -e "  ${CYAN}4. Domaine C2 : ${RED}$C2_DOMAIN${NC}"
echo ""
