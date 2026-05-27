#!/bin/bash

# ============================================================
#  SIMULATION — Brute Force SSH (Niveau 1)
#  MITRE ATT&CK : T1110.001 — Password Guessing
# ============================================================
#
#  Ce script simule une attaque brute force SSH sur localhost.
#  Il génère volontairement des échecs d'authentification pour
#  que Wazuh les détecte.
#
#  USAGE ÉDUCATIF UNIQUEMENT — Infrastructure locale uniquement
# ============================================================

TARGET="127.0.0.1"
PORT="22"
ATTEMPTS=20
DELAY=0.5

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
echo -e "  ${YELLOW}Cible${NC}    : $TARGET:$PORT"
echo -e "  ${YELLOW}Tentatives${NC} : $ATTEMPTS"
echo -e "  ${YELLOW}MITRE${NC}    : T1110.001 — Password Guessing"
echo ""
echo "  Regarde le Wazuh Dashboard pendant l'attaque :"
echo "  → https://localhost → Security Events"
echo "  → Filtre : rule.groups: authentication_failed"
echo ""

# Vérifier que SSH est accessible
if ! nc -z -w2 "$TARGET" "$PORT" 2>/dev/null; then
    echo -e "${YELLOW}[!] Port 22 non accessible sur localhost.${NC}"
    echo "    SSH n'est peut-être pas actif sur cette machine."
    echo "    Les tentatives vont quand même générer des logs de connexion refusée."
    echo ""
fi

# Liste de mots de passe courants (wordlist fictive pour simulation)
PASSWORDS=(
    "password" "123456" "admin" "root" "letmein"
    "qwerty" "abc123" "monkey" "1234567" "dragon"
    "master" "superman" "batman" "iloveyou" "login"
    "welcome" "shadow" "sunshine" "princess" "football"
)

# Utilisateurs courants à tester
USERS=("root" "admin" "user" "test" "ubuntu")

echo -e "${CYAN}[*] Démarrage de la simulation brute force...${NC}"
echo ""

SUCCESS=0
for i in $(seq 1 $ATTEMPTS); do
    USER="${USERS[$((RANDOM % ${#USERS[@]}))]}"
    PASS="${PASSWORDS[$((RANDOM % ${#PASSWORDS[@]}))]}"

    printf "  [%02d/%02d] user=%-8s pass=%-12s → " "$i" "$ATTEMPTS" "$USER" "$PASS"

    # Tentative SSH avec timeout court et options de sécurité désactivées
    # StrictHostKeyChecking=no pour éviter les prompts
    # ConnectTimeout=2 pour aller vite
    # BatchMode=yes pour ne pas attendre de saisie
    RESULT=$(ssh -o StrictHostKeyChecking=no \
                 -o ConnectTimeout=2 \
                 -o BatchMode=yes \
                 -o PasswordAuthentication=yes \
                 -o PubkeyAuthentication=no \
                 -p "$PORT" \
                 "$USER@$TARGET" \
                 "exit" 2>&1)

    echo -e "${RED}ECHEC (attendu)${NC}"
    sleep "$DELAY"
done

echo ""
echo "============================================================"
echo -e "  ${GREEN}Simulation terminée — $ATTEMPTS tentatives effectuées${NC}"
echo "============================================================"
echo ""
echo "  Maintenant dans Wazuh Dashboard :"
echo ""
echo -e "  ${CYAN}1. Va dans Security Events${NC}"
echo "     Filtre : rule.id: 5763"
echo ""
echo -e "  ${CYAN}2. Tu devrais voir :${NC}"
echo "     → rule.id 5551 : SSH authentication failure"
echo "     → rule.id 5712 : sshd: Attempt to login using a non-existent user"
echo "     → rule.id 5763 : sshd: brute force trying to get access"
echo ""
echo -e "  ${CYAN}3. Questions à te poser :${NC}"
echo "     → Depuis quelle IP vient l'attaque ?"
echo "     → Combien de tentatives Wazuh a-t-il comptées ?"
echo "     → Quel utilisateur a été le plus ciblé ?"
echo ""
echo -e "  ${CYAN}4. Ouvre le playbook :${NC}"
echo "     core/incident-response/playbooks/01-brute-force.md"
echo ""
