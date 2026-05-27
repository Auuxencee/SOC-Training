#!/bin/bash

# ============================================================
#  SIMULATION — Scan de Ports (Niveau 1)
#  MITRE ATT&CK : T1046 — Network Service Discovery
# ============================================================
#
#  Ce script simule un scan de reconnaissance réseau sur
#  l'infrastructure locale. Il détecte les ports ouverts.
#
#  USAGE ÉDUCATIF UNIQUEMENT — Infrastructure locale uniquement
# ============================================================

TARGET="127.0.0.1"

RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
NC='\033[0m'

echo ""
echo "============================================================"
echo -e "  ${RED}[SIMULATION] Scan de Ports — Niveau 1${NC}"
echo "============================================================"
echo ""
echo -e "  ${YELLOW}Cible${NC}  : $TARGET"
echo -e "  ${YELLOW}MITRE${NC}  : T1046 — Network Service Discovery"
echo ""
echo "  Regarde le Wazuh Dashboard pendant le scan :"
echo "  → https://localhost → Security Events"
echo ""

# Vérifier nmap
if ! command -v nmap &>/dev/null; then
    echo -e "${YELLOW}[!] nmap non installé.${NC}"
    echo "    Installation : brew install nmap"
    echo ""
    echo "    Simulation avec /dev/tcp à la place..."
    echo ""

    # Fallback : scan basique sans nmap
    echo -e "${CYAN}[*] Scan des ports communs (méthode bash)...${NC}"
    echo ""

    PORTS=(21 22 23 25 53 80 110 143 443 445 3306 3389 5432 6379 8080 8443 9200 9300)

    for PORT in "${PORTS[@]}"; do
        (
            if 2>/dev/null echo > "/dev/tcp/$TARGET/$PORT"; then
                echo -e "  Port ${GREEN}$PORT${NC} → OUVERT"
            fi
        ) &
    done
    wait

    echo ""
    echo -e "${GREEN}[+] Scan basique terminé${NC}"
    echo ""
    echo "  Note : installe nmap pour un scan plus réaliste"
    echo "         et des alertes Wazuh plus précises."
    exit 0
fi

echo -e "${CYAN}[*] Phase 1 — Scan SYN rapide (ports communs)...${NC}"
echo ""

# Scan SYN des ports les plus courants — génère du trafic réseau visible
nmap -sS -T4 --top-ports 100 "$TARGET" 2>/dev/null | grep -E "^[0-9]|Nmap scan|PORT|open|closed|filtered"

echo ""
echo -e "${CYAN}[*] Phase 2 — Détection de services et versions...${NC}"
echo ""

# Scan de détection de services sur les ports Wazuh/SOC
nmap -sV -T3 -p 22,80,443,1514,1515,9200,9300,55000 "$TARGET" 2>/dev/null | grep -E "^[0-9]|open|closed"

echo ""
echo -e "${CYAN}[*] Phase 3 — Scan UDP ports clés...${NC}"
echo ""

# Scan UDP limité
nmap -sU -T3 --top-ports 20 "$TARGET" 2>/dev/null | grep -E "^[0-9]|open" || echo "  (scan UDP peut nécessiter sudo)"

echo ""
echo "============================================================"
echo -e "  ${GREEN}Scan terminé${NC}"
echo "============================================================"
echo ""
echo "  Maintenant dans Wazuh Dashboard :"
echo ""
echo -e "  ${CYAN}1. Va dans Security Events${NC}"
echo "     Cherche des alertes liées au réseau"
echo "     Filtre : rule.groups: network_scan"
echo ""
echo -e "  ${CYAN}2. Questions à te poser :${NC}"
echo "     → Wazuh a-t-il détecté le scan ? (et si non, pourquoi ?)"
echo "     → Dans quelle source de log apparaît l'événement ?"
echo "     → Quelle règle est déclenchée ?"
echo ""
echo -e "  ${CYAN}3. Observation importante :${NC}"
echo "     Le scan de ports n'est pas toujours détecté par défaut dans Wazuh."
echo "     Pour une meilleure détection, il faut configurer un IDS réseau"
echo "     (ex: Suricata) ou des règles firewall avec logging."
echo "     → C'est une limite à documenter dans ton SOC !"
echo ""
echo -e "  ${CYAN}4. Amélioration possible :${NC}"
echo "     Activer Suricata comme IDS réseau dans Wazuh"
echo "     core/config/wazuh-manager.conf → section <localfile> pour suricata"
echo ""
