#!/bin/bash
# Active Response — Quarantaine d'un host
# Bloque tout le trafic sauf vers le SIEM (management)
# À utiliser sur détection d'un host compromis (persistence, C2, etc.)

ACTION=$1
USER=$2
IP=$3

LOG_FILE="/var/ossec/logs/active-responses.log"
QUARANTINE_LOG="/var/ossec/logs/quarantine.log"

# IP du manager Wazuh à préserver (toujours autoriser)
MANAGER_IP="${WAZUH_MANAGER_IP:-127.0.0.1}"

log() {
    echo "$(date) quarantine[$ACTION]: host=$IP manager=$MANAGER_IP $*" | tee -a "$LOG_FILE" >> "$QUARANTINE_LOG"
}

if [ -z "$IP" ] || [ "$IP" = "-" ]; then
    log "ERREUR: IP manquante"
    exit 1
fi

if command -v iptables &>/dev/null; then
    if [ "$ACTION" = "add" ]; then
        # Autoriser le manager (ne jamais se couper du SIEM)
        iptables -I INPUT -s "$MANAGER_IP" -j ACCEPT
        iptables -I OUTPUT -d "$MANAGER_IP" -j ACCEPT
        # Bloquer tout le reste depuis/vers cet IP
        iptables -I INPUT -s "$IP" -j DROP
        iptables -I OUTPUT -d "$IP" -j DROP
        log "HOST MIS EN QUARANTAINE"

    elif [ "$ACTION" = "delete" ]; then
        iptables -D INPUT -s "$IP" -j DROP 2>/dev/null
        iptables -D OUTPUT -d "$IP" -j DROP 2>/dev/null
        log "quarantaine levée"
    fi
else
    # Fallback : log de la demande de quarantaine
    if [ "$ACTION" = "add" ]; then
        echo "$IP $(date) QUARANTINE_REQUESTED" >> "$QUARANTINE_LOG"
        log "iptables indisponible — quarantaine manuelle requise pour $IP"
    fi
fi

exit 0
