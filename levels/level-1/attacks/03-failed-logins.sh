#!/bin/bash

# ============================================================
#  SIMULATION — Echecs d'authentification su/sudo (Niveau 1)
#  MITRE ATT&CK : T1548.003 — Sudo and Sudo Caching
# ============================================================
#
#  Ce script simule des tentatives d'escalade de privilèges
#  échouées (su, sudo) pour générer des alertes Wazuh.
#
#  USAGE ÉDUCATIF UNIQUEMENT — Système local uniquement
# ============================================================

ATTEMPTS=15
DELAY=1

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
echo -e "  ${YELLOW}Type${NC}   : Tentatives su / sudo échouées"
echo -e "  ${YELLOW}MITRE${NC}  : T1548.003 — Sudo and Sudo Caching"
echo -e "  ${YELLOW}Nombre${NC} : $ATTEMPTS tentatives"
echo ""
echo "  Regarde le Wazuh Dashboard pendant la simulation :"
echo "  → https://localhost → Security Events"
echo "  → Filtre : rule.groups: authentication_failed"
echo ""
echo -e "${CYAN}[*] Démarrage de la simulation...${NC}"
echo ""

# Tentatives sudo avec mauvais mot de passe
echo -e "${YELLOW}--- Tentatives SUDO ---${NC}"
for i in $(seq 1 $((ATTEMPTS / 3))); do
    printf "  [sudo %02d] Tentative avec mauvais mot de passe → " "$i"
    # Utilise expect ou echo pipe selon disponibilité
    echo "wrongpassword123" | sudo -S ls /root 2>&1 | grep -q "incorrect\|wrong\|Sorry" && \
        echo -e "${RED}ECHEC (attendu)${NC}" || \
        echo -e "${RED}ECHEC (attendu)${NC}"
    sleep "$DELAY"
done

echo ""

# Tentatives su avec utilisateurs inexistants
echo -e "${YELLOW}--- Tentatives SU (utilisateurs inexistants) ---${NC}"
FAKE_USERS=("hacker" "backdoor" "sysadmin" "deploy" "jenkins")
for USER in "${FAKE_USERS[@]}"; do
    printf "  [su] Tentative avec user '%-10s' → " "$USER"
    # su vers un user inexistant génère un log d'échec
    echo "password" | su - "$USER" 2>&1 | head -1 &>/dev/null
    echo -e "${RED}ECHEC (attendu)${NC}"
    sleep 0.8
done

echo ""

# Tentatives sudo avec utilisateurs différents
echo -e "${YELLOW}--- Tentatives SUDO répétées (pattern brute force) ---${NC}"
COMMANDS=("cat /etc/shadow" "cat /etc/passwd" "ls /root" "id" "whoami")
for i in $(seq 1 $((ATTEMPTS / 3))); do
    CMD="${COMMANDS[$((RANDOM % ${#COMMANDS[@]}))]}"
    printf "  [sudo %02d] cmd='%s' → " "$i" "$CMD"
    echo "wrong_password_$(date +%s%N)" | sudo -S $CMD 2>&1 | grep -q "incorrect\|wrong\|Sorry\|password" && \
        echo -e "${RED}ECHEC (attendu)${NC}" || \
        echo -e "${RED}ECHEC (attendu)${NC}"
    sleep "$DELAY"
done

echo ""
echo "============================================================"
echo -e "  ${GREEN}Simulation terminée — Echecs d'auth générés${NC}"
echo "============================================================"
echo ""
echo "  Maintenant dans Wazuh Dashboard :"
echo ""
echo -e "  ${CYAN}1. Va dans Security Events${NC}"
echo "     Filtre : rule.groups: authentication_failed"
echo "     ou : data.srcuser: root (pour les tentatives sudo)"
echo ""
echo -e "  ${CYAN}2. Règles attendues :${NC}"
echo "     → 5401 : Wazuh system audit - sudo event"
echo "     → 5503 : sudo: authentication failure"
echo "     → 5551 : su auth failed"
echo ""
echo -e "  ${CYAN}3. Questions à te poser :${NC}"
echo "     → Quelle différence avec le brute force SSH ?"
echo "     → Qui est le 'srcuser' ici vs dans l'attaque SSH ?"
echo "     → Est-ce local ou distant ?"
echo ""
echo -e "  ${CYAN}4. Différence clé :${NC}"
echo "     Brute force SSH  = attaque RÉSEAU (depuis une IP externe)"
echo "     Su/sudo failures = attaque LOCALE (depuis la machine elle-même)"
echo "     Ce sont 2 patterns d'attaque distincts à surveiller !"
echo ""
echo -e "  ${CYAN}5. Ouvre la checklist :${NC}"
echo "     core/incident-response/ir-checklist.md"
echo ""
