#!/bin/bash

# ============================================
#   SOC PERSONAL — SCRIPT DE DÉMARRAGE
# ============================================

SOC_DIR="$HOME/Documents/Prog/SOC/wazuh-docker/single-node"
ARCHIVE="$HOME/Documents/Prog/SOC/wazuh-docker.tar.gz"
WAZUH_DIR="$HOME/Documents/Prog/SOC/wazuh-docker"

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo ""
echo "============================================"
echo "   🛡️  SOC PERSONAL — DÉMARRAGE"
echo "============================================"
echo ""

# 1. Vérifier que Docker tourne
echo -n "[ 1/5 ] Vérification de Docker... "
if ! docker info > /dev/null 2>&1; then
    echo -e "${RED}❌ Docker n'est pas lancé.${NC}"
    echo "      👉 Ouvrez Docker Desktop et relancez ce script."
    exit 1
fi
echo -e "${GREEN}✅ Docker actif${NC}"

# 2. Décompresser si nécessaire
echo -n "[ 2/5 ] Vérification des fichiers Wazuh... "
if [ ! -d "$SOC_DIR" ]; then
    if [ -f "$ARCHIVE" ]; then
        echo -e "${YELLOW}📦 Archive détectée, décompression...${NC}"
        cd "$HOME/Documents/Prog/SOC"
        tar -xzf wazuh-docker.tar.gz
        echo -e "${GREEN}✅ Décompression terminée${NC}"
    else
        echo -e "${RED}❌ Ni le dossier ni l'archive trouvés.${NC}"
        echo "      👉 Vérifiez que wazuh-docker existe dans ~/Documents/Prog/SOC/"
        exit 1
    fi
else
    echo -e "${GREEN}✅ Fichiers présents${NC}"
fi

# 3. Paramètre kernel pour Elasticsearch
echo -n "[ 3/5 ] Paramètre vm.max_map_count... "
docker run --rm --privileged alpine sysctl -w vm.max_map_count=262144 > /dev/null 2>&1
echo -e "${GREEN}✅ OK (262144)${NC}"

# 4. Lancer les containers
echo -n "[ 4/5 ] Démarrage des containers Wazuh... "
cd "$SOC_DIR"
docker compose up -d > /dev/null 2>&1
echo -e "${GREEN}✅ Containers lancés${NC}"

# 5. Attendre que le dashboard soit prêt
echo -n "[ 5/5 ] Attente du dashboard"
for i in {1..24}; do
    sleep 5
    STATUS=$(curl -sk -o /dev/null -w "%{http_code}" https://localhost 2>/dev/null)
    if [ "$STATUS" = "200" ] || [ "$STATUS" = "302" ] || [ "$STATUS" = "301" ]; then
        echo -e " ${GREEN}✅ Prêt !${NC}"
        break
    fi
    echo -n "."
done

echo ""
echo "============================================"
echo -e "   ${GREEN}🚀 SOC opérationnel !${NC}"
echo "============================================"
echo ""
echo "   🌐 Dashboard : https://localhost"
echo "   👤 Login     : admin"
echo "   🔑 Password  : MonSoc@dmin"
echo ""
echo "   Containers actifs :"
docker compose ps --format "table {{.Name}}\t{{.Status}}" 2>/dev/null
echo ""
