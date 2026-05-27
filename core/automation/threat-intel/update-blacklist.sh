#!/bin/bash
# Mise à jour de la CDB List Threat Intelligence
# À lancer manuellement ou en cron sur le host Docker

CONTAINER=$(docker ps --format "{{.Names}}" 2>/dev/null | grep "wazuh.manager" | head -1)
LOCAL_LIST="$(dirname "$0")/blacklist_ips.txt"
REMOTE_PATH="/var/ossec/etc/lists/blacklist_ips"

if [ -z "$CONTAINER" ]; then
    echo "Erreur : container Wazuh Manager non trouvé"
    exit 1
fi

echo "[*] Mise à jour de la CDB List..."

# Optionnel : télécharger une liste externe (décommenter si besoin)
# Exemple : AbuseIPDB top 1000 (nécessite une clé API)
# curl -s -G "https://api.abuseipdb.com/api/v2/blacklist" \
#     -d confidenceMinimum=90 \
#     -H "Key: $ABUSEIPDB_KEY" \
#     -H "Accept: text/plain" >> "$LOCAL_LIST"

# Copier la liste dans le container
docker cp "$LOCAL_LIST" "$CONTAINER:$REMOTE_PATH"

# Compiler la CDB List
docker exec "$CONTAINER" /var/ossec/bin/wazuh-makelists
echo "[*] CDB List compilée"

# Recharger les règles sans redémarrage complet
docker exec "$CONTAINER" kill -HUP "$(docker exec "$CONTAINER" cat /var/ossec/var/run/wazuh-analysisd.pid 2>/dev/null)" 2>/dev/null \
    || docker exec "$CONTAINER" /var/ossec/bin/wazuh-control restart

echo "[+] Mise à jour terminée : $REMOTE_PATH"
echo "    IPs dans la liste : $(grep -c ':' "$LOCAL_LIST" 2>/dev/null || echo '?')"
