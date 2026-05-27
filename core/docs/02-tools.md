# Outils du SOC

## Stack principale : Wazuh

Wazuh est une plateforme open-source de sécurité unifiée. Elle combine SIEM, XDR et CSPM.

### Composants déployés

```
┌─────────────────────────────────────────────┐
│                WAZUH STACK                   │
│                                              │
│  ┌──────────────┐    ┌───────────────────┐  │
│  │   Wazuh      │───▶│  Wazuh Indexer    │  │
│  │   Manager    │    │  (OpenSearch)     │  │
│  │              │    └────────┬──────────┘  │
│  │  - Analyse   │             │              │
│  │  - Corrèle   │    ┌────────▼──────────┐  │
│  │  - Alertes   │    │  Wazuh Dashboard  │  │
│  └──────────────┘    │  (Kibana-like)    │  │
│                      └───────────────────┘  │
└─────────────────────────────────────────────┘
          ▲
     Logs / Events
          │
   [Agents / Syslog]
```

### Wazuh Manager
- **Rôle** : cerveau du SOC. Reçoit les logs, applique les règles, génère les alertes.
- **Config principale** : `core/config/wazuh-manager.conf`
- **Règles custom** : `core/config/local_rules.xml`
- **Port** : 1514 (agents), 1515 (enrollment), 55000 (API REST)

### Wazuh Indexer
- **Rôle** : stockage et indexation des alertes (moteur OpenSearch)
- **Port** : 9200 (HTTP), 9300 (cluster)
- **Accès** : via le Dashboard uniquement en usage normal

### Wazuh Dashboard
- **Rôle** : interface de visualisation et d'investigation
- **URL** : `https://localhost`
- **Login** : `admin` / `MonSoc@dmin`

---

## Naviguer dans le Dashboard

### Sections importantes

| Section | Description |
|---------|-------------|
| **Security Events** | Vue temps réel de toutes les alertes |
| **Threat Intelligence** | MITRE ATT&CK mapping |
| **Integrity Monitoring** | Alertes FIM (fichiers modifiés) |
| **Vulnerabilities** | CVE détectées |
| **Agents** | État des agents connectés |

### Filtrer les alertes

Dans la barre de recherche Discover :
```
# Toutes les alertes de niveau >= 7
rule.level: [7 TO *]

# Alertes SSH
rule.groups: authentication_failed

# Alertes d'une IP précise
data.srcip: 192.168.1.100

# Filtrer par règle
rule.id: 5763
```

---

## Outils complémentaires (ligne de commande)

### Sur le manager (dans le container Docker)
```bash
# Entrer dans le container manager
docker exec -it single-node-wazuh.manager-1 bash

# Voir les alertes en temps réel
tail -f /var/ossec/logs/alerts/alerts.json | jq .

# Vérifier les logs du manager
tail -f /var/ossec/logs/ossec.log

# Recharger les règles (après modification)
/var/ossec/bin/wazuh-control restart
```

### Vérifier la syntaxe des règles
```bash
docker exec -it single-node-wazuh.manager-1 \
  /var/ossec/bin/wazuh-logtest
```

---

## Outils d'attaque (Niveau 1)

Ces outils sont utilisés pour simuler les attaques dans `levels/` :

| Outil | Usage | Installation |
|-------|-------|--------------|
| `nmap` | Scan de ports | `brew install nmap` |
| `hydra` | Brute force SSH | `brew install hydra` |
| `bash` | Scripts d'attaque | Natif |

> **Rappel** : ces outils ne doivent être utilisés que sur ton infrastructure locale (`localhost`, `127.0.0.1`) dans le cadre de cet entraînement.
