# Triage des alertes — Méthodologie

## Qu'est-ce que le triage ?

Le triage est la première étape de réponse à une alerte SOC. L'objectif : **décider rapidement si une alerte mérite investigation ou peut être ignorée**.

---

## Le processus en 5 questions

Quand une alerte arrive, pose-toi ces questions dans l'ordre :

```
1. Est-ce réel ?         → Vrai positif ou faux positif ?
2. Qui est impacté ?     → Quel host, quel utilisateur, quelle IP ?
3. Quelle est la sévérité ? → Quel risque business ?
4. Est-ce en cours ?     → L'attaque est active ou terminée ?
5. Quelle action ?       → Escalader / Contenir / Ignorer / Documenter ?
```

---

## Classification des alertes Wazuh

| Niveau Wazuh | Signification | Action recommandée |
|--------------|---------------|--------------------|
| 0-3 | Informatif | Ignorer en production |
| 4-6 | Faible | Surveiller, corréler |
| 7-9 | Moyen | Investiguer |
| 10-11 | Haute | Répondre rapidement |
| 12-14 | Critique | Réponse immédiate |
| 15 | Maximum | Incident majeur |

---

## Comment lire une alerte Wazuh

### Structure d'une alerte JSON
```json
{
  "timestamp": "2026-05-27T14:32:11.000Z",
  "rule": {
    "id": "5763",
    "level": 10,
    "description": "sshd: brute force trying to get access",
    "groups": ["authentication_failures", "pci_dss_10.2.4"]
  },
  "agent": {
    "id": "001",
    "name": "wazuh-agent-01"
  },
  "data": {
    "srcip": "192.168.1.50",
    "dstport": "22"
  },
  "full_log": "..."
}
```

### Champs clés à lire
- `rule.id` : identifiant de la règle déclenchée
- `rule.level` : sévérité (0-15)
- `rule.description` : description humaine
- `rule.groups` : catégories (ex: `authentication_failures`)
- `data.srcip` : IP source (l'attaquant potentiel)
- `agent.name` : machine cible
- `full_log` : log brut original

---

## Faux positifs courants à connaître

| Alerte | Contexte légitime | Comment vérifier |
|--------|------------------|------------------|
| Brute force SSH | Backup automatique, CI/CD | Vérifier la source IP, l'heure, la régularité |
| Scan de ports | Monitoring réseau (Zabbix, etc.) | IP interne ? Heure de maintenance ? |
| Modification /etc | Mise à jour système | `dpkg.log`, timestamp cohérent avec `apt` ? |
| Sudo failures | Mauvais mot de passe tapé | Isolé ou répété ? Même user ? |

---

## Corrélation : chercher le contexte

Une alerte isolée est peu fiable. Cherche **d'autres signaux** autour :

```
Timeline d'investigation :
T-5min  : Y avait-il des scans de ports avant ?
T+0     : L'alerte principale
T+5min  : D'autres tentatives depuis la même IP ?
T+10min : Connexion réussie après les échecs ?
```

Dans Wazuh Dashboard :
1. Note l'IP source de l'alerte
2. Filtre par `data.srcip: <IP>` sur les 30 dernières minutes
3. Trie par timestamp
4. Reconstitue la timeline

---

## Décisions de triage

```
ALERTE REÇUE
    │
    ▼
Faux positif connu ? ──YES──▶ Documenter et ignorer
    │
   NO
    ▼
IP interne / outil légitime ? ──YES──▶ Contextualiser, surveiller
    │
   NO
    ▼
Activité en cours ? ──YES──▶ CONTENIR (bloquer IP) + Escalader
    │
   NO
    ▼
Activité passée terminée ? ──▶ Analyser logs complets + Documenter
```

---

## Template de rapport de triage

```
# Triage — [DATE] [ID ALERTE]

**Alerte** : rule.id XXXXX — [description]
**Niveau** : X/15
**Host impacté** : 
**IP source** : 
**Timestamp** : 

**Contexte** :
- (autres événements corrélés)

**Verdict** : [ ] Vrai positif  [ ] Faux positif  [ ] Indéterminé

**Action prise** :
- 

**À surveiller** :
- 
```
