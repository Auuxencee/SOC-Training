#!/bin/bash

# ============================================
#   SOC PERSONAL — SCRIPT D'ARRÊT & COMPRESSION
# ============================================

SOC_DIR="$HOME/Documents/Prog/SOC/wazuh-docker/single-node"
WAZUH_DIR="$HOME/Documents/Prog/SOC/wazuh-docker"
ARCHIVE="$HOME/Documents/Prog/SOC/wazuh-docker.tar.gz"

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo ""
echo "============================================"
echo "   🛑  SOC PERSONAL — ARRÊT & COMPRESSION"
echo "============================================"
echo ""

# 1. Vérifier que Docker tourne
echo -n "[ 1/4 ] Vérification de Docker... "
if ! docker info > /dev/null 2>&1; then
    echo -e "${YELLOW}⚠️  Docker non actif, on passe à la compression.${NC}"
else
    echo -e "${GREEN}✅ Docker actif${NC}"

    # 2. Arrêter les containers proprement
    echo -n "[ 2/4 ] Arrêt des containers Wazuh... "
    if [ -d "$SOC_DIR" ]; then
        cd "$SOC_DIR"
        docker compose down > /dev/null 2>&1
        echo -e "${GREEN}✅ Containers arrêtés${NC}"
    else
        echo -e "${YELLOW}⚠️  Dossier introuvable, skip${NC}"
    fi
fi

# 3. Compression du dossier wazuh-docker
echo -n "[ 3/4 ] Compression de wazuh-docker... "
if [ -d "$WAZUH_DIR" ]; then
    cd "$HOME/Documents/Prog/SOC"

    # Supprimer l'ancienne archive si elle existe
    [ -f "wazuh-docker.tar.gz" ] && rm -f wazuh-docker.tar.gz

    tar -czf wazuh-docker.tar.gz wazuh-docker/
    SIZE=$(du -sh wazuh-docker.tar.gz | cut -f1)
    echo -e "${GREEN}✅ Archive créée (${SIZE})${NC}"

    # 4. Supprimer le dossier source
    echo -n "[ 4/4 ] Suppression du dossier source... "
    rm -rf wazuh-docker/
    echo -e "${GREEN}✅ Dossier supprimé${NC}"
else
    echo -e "${YELLOW}⚠️  Dossier wazuh-docker introuvable${NC}"
    echo "      (déjà compressé ?)"
    exit 0
fi

# Espace libéré
FREED=$(du -sh "$ARCHIVE" | cut -f1)
echo ""
echo "============================================"
echo -e "   ${GREEN}💾 SOC arrêté et compressé !${NC}"
echo "============================================"
echo ""
echo "   📦 Archive : ~/Documents/Prog/SOC/wazuh-docker.tar.gz"
echo "   📏 Taille  : $FREED"
echo ""
echo "   Pour relancer : ./soc-start.sh"
echo ""
