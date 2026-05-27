# Automation — Réponse Automatique aux Incidents

> Ce répertoire contient tout le nécessaire pour configurer Wazuh Active Response et automatiser la réponse aux incidents.

---

## Architecture

```
core/automation/
├── README.md                    ← Ce fichier (guide principal)
├── active-response/
│   ├── firewall-drop.sh         ← Blocage IP via iptables/pfctl
│   ├── notify-alert.sh          ← Notification webhook/log
│   └── quarantine-host.sh       ← Isolation réseau d'un host
├── ossec-conf/
│   └── active-response.xml      ← Fragment ossec.conf à injecter
└── threat-intel/
    ├── blacklist_ips.txt         ← CDB List des IPs malveillantes
    └── update-blacklist.sh       ← Script de mise à jour
```

---

## Étape 1 — Copier les scripts dans le container Wazuh

```bash
# Manager container
CONTAINER=$(docker ps --format "{{.Names}}" | grep "wazuh.manager")

# Copier les scripts de réponse
docker cp core/automation/active-response/firewall-drop.sh \
    $CONTAINER:/var/ossec/active-response/bin/firewall-drop.sh
docker cp core/automation/active-response/notify-alert.sh \
    $CONTAINER:/var/ossec/active-response/bin/notify-alert.sh
docker cp core/automation/active-response/quarantine-host.sh \
    $CONTAINER:/var/ossec/active-response/bin/quarantine-host.sh

# Droits d'exécution (obligatoire)
docker exec $CONTAINER chmod 750 /var/ossec/active-response/bin/firewall-drop.sh
docker exec $CONTAINER chmod 750 /var/ossec/active-response/bin/notify-alert.sh
docker exec $CONTAINER chmod 750 /var/ossec/active-response/bin/quarantine-host.sh
docker exec $CONTAINER chown root:wazuh /var/ossec/active-response/bin/*.sh
```

---

## Étape 2 — Ajouter la configuration dans ossec.conf

Injecter le contenu de `ossec-conf/active-response.xml` dans le bloc `<ossec_config>` de ossec.conf :

```bash
CONTAINER=$(docker ps --format "{{.Names}}" | grep "wazuh.manager")

# Méthode : Python dans le container
docker exec $CONTAINER python3 -c "
import re

with open('/var/ossec/etc/ossec.conf', 'r') as f:
    content = f.read()

ar_config = open('/tmp/active-response.xml').read()

# Insérer avant la fermeture </ossec_config>
content = content.replace('</ossec_config>', ar_config + '\n</ossec_config>')

with open('/var/ossec/etc/ossec.conf', 'w') as f:
    f.write(content)
print('ossec.conf mis à jour')
"
```

Ou manuellement via `docker exec -it $CONTAINER nano /var/ossec/etc/ossec.conf`.

---

## Étape 3 — Intégrer la CDB List Threat Intelligence

```bash
CONTAINER=$(docker ps --format "{{.Names}}" | grep "wazuh.manager")

# Copier la liste noire
docker cp core/automation/threat-intel/blacklist_ips.txt \
    $CONTAINER:/var/ossec/etc/lists/blacklist_ips

# Compiler la CDB List
docker exec $CONTAINER /var/ossec/bin/wazuh-makelists

# Vérifier
docker exec $CONTAINER ls -la /var/ossec/etc/lists/
```

Ensuite ajouter dans ossec.conf (bloc `<ruleset>`) :
```xml
<list>etc/lists/blacklist_ips</list>
```

---

## Étape 4 — Redémarrer le manager

```bash
CONTAINER=$(docker ps --format "{{.Names}}" | grep "wazuh.manager")
docker exec $CONTAINER /var/ossec/bin/wazuh-control restart
```

Attendre 10-15 secondes puis vérifier dans Wazuh → Management → Configuration.

---

## Étape 5 — Tester l'Active Response

```bash
# Injecter un brute force pour déclencher le blocage automatique
bash levels/level-4/attacks/01-combined-attack.sh

# Vérifier dans les logs AR
CONTAINER=$(docker ps --format "{{.Names}}" | grep "wazuh.manager")
docker exec $CONTAINER tail -f /var/ossec/logs/active-responses.log
```

Tu dois voir une ligne comme :
```
active-response/bin/firewall-drop.sh add - 192.168.100.50 ...
```

---

## Règles custom associées

Les règles custom pour déclencher l'Active Response sont dans :
`core/config/local_rules.xml`

Voir les règles 100010-100020 pour les déclencheurs AR.

---

## Dépannage

| Problème | Cause probable | Solution |
|----------|----------------|----------|
| AR ne se déclenche pas | Script absent ou droits incorrects | Vérifier chmod 750 + chown root:wazuh |
| iptables: not found | Container sans NET_ADMIN | Utiliser le script pfctl host (macOS) |
| CDB List non chargée | wazuh-makelists pas relancé | Relancer + redémarrer manager |
| Notification silencieuse | Webhook URL incorrecte | Tester curl manuellement |
