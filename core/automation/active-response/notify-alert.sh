#!/bin/bash
# Active Response — Notification d'alerte
# Envoie une notification webhook (Slack/Teams/Discord) ou écrit dans un log
# Variables d'environnement à configurer :
#   WEBHOOK_URL : URL du webhook (laisser vide pour log uniquement)

ACTION=$1
USER=$2
IP=$3
ALERT_ID=$4
RULE_ID=$5

LOG_FILE="/var/ossec/logs/active-responses.log"
NOTIF_LOG="/var/ossec/logs/notifications.log"

# Configurer ici ou via variable d'environnement
WEBHOOK_URL="${NOTIFY_WEBHOOK_URL:-}"

TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
HOSTNAME=$(hostname)

MESSAGE="[WAZUH ALERT] $TIMESTAMP | Host: $HOSTNAME | Rule: $RULE_ID | IP: $IP | Alert: $ALERT_ID"

# Log local (toujours)
echo "$MESSAGE" >> "$NOTIF_LOG"
echo "$(date) notify-alert: rule=$RULE_ID ip=$IP" >> "$LOG_FILE"

# Webhook Slack/Teams/Discord (optionnel)
if [ -n "$WEBHOOK_URL" ] && command -v curl &>/dev/null; then
    PAYLOAD="{\"text\": \"$MESSAGE\"}"
    curl -s -X POST -H 'Content-type: application/json' \
        --data "$PAYLOAD" \
        "$WEBHOOK_URL" >> "$LOG_FILE" 2>&1
fi

exit 0
