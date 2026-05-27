#!/bin/bash
# Active Response — Blocage IP
# Wazuh passe les arguments : action srcip alertid ruleid
# action = add (bloquer) | delete (débloquer)

ACTION=$1
USER=$2
IP=$3

LOG_FILE="/var/ossec/logs/active-responses.log"

if [ -z "$IP" ] || [ "$IP" = "-" ]; then
    echo "$(date) firewall-drop: IP manquante" >> "$LOG_FILE"
    exit 1
fi

log() {
    echo "$(date) firewall-drop[$ACTION]: $IP $*" >> "$LOG_FILE"
}

# iptables (Linux)
if command -v iptables &>/dev/null; then
    if [ "$ACTION" = "add" ]; then
        iptables -I INPUT -s "$IP" -j DROP && log "bloquée via iptables INPUT"
        iptables -I FORWARD -s "$IP" -j DROP && log "bloquée via iptables FORWARD"
    elif [ "$ACTION" = "delete" ]; then
        iptables -D INPUT -s "$IP" -j DROP 2>/dev/null && log "débloquée iptables INPUT"
        iptables -D FORWARD -s "$IP" -j DROP 2>/dev/null && log "débloquée iptables FORWARD"
    fi
    exit 0
fi

# nftables (alternative moderne)
if command -v nft &>/dev/null; then
    if [ "$ACTION" = "add" ]; then
        nft add rule ip filter input ip saddr "$IP" drop && log "bloquée via nftables"
    fi
    exit 0
fi

# Fallback : écriture dans un fichier (environnement Docker sans NET_ADMIN)
BLOCK_FILE="/var/ossec/logs/blocked_ips.txt"
if [ "$ACTION" = "add" ]; then
    echo "$IP $(date)" >> "$BLOCK_FILE"
    log "ajoutée à $BLOCK_FILE (iptables indisponible)"
elif [ "$ACTION" = "delete" ]; then
    sed -i "/^$IP /d" "$BLOCK_FILE" 2>/dev/null
    log "retirée de $BLOCK_FILE"
fi

exit 0
