# Niveau 1 — Détection basique

> **Difficulté** : Débutant  
> **Durée estimée** : 2 à 4 heures  
> **Prérequis** : SOC démarré (`./soc-start.sh`), lecture de `core/docs/`

---

## Objectifs pédagogiques

À la fin de ce niveau, tu seras capable de :

1. **Détecter** un brute force SSH dans Wazuh
2. **Détecter** un scan de ports dans les logs
3. **Détecter** des échecs d'authentification répétés (su/sudo)
4. **Investiguer** une alerte en remontant la timeline
5. **Ecrire** tes premières règles Wazuh dans `local_rules.xml`
6. **Compléter** le playbook brute force SSH

---

## Contexte scénaristique

Tu es analyste SOC junior. Ton infrastructure vient d'être déployée.  
On t'informe qu'une **IP externe suspecte** a été détectée sur le périmètre.  
Tu dois surveiller ton SOC, identifier les activités malveillantes et y répondre.

---

## Les attaques simulées

| ID | Type | Script | Complexité |
|----|------|--------|------------|
| L1-01 | Brute force SSH | `attacks/01-ssh-brute-force.sh` | Basique |
| L1-02 | Scan de ports | `attacks/02-port-scan.sh` | Basique |
| L1-03 | Echecs d'authentification | `attacks/03-failed-logins.sh` | Basique |

---

## Déroulement recommandé

### Avant de lancer les attaques

1. Assure-toi que le SOC tourne : `./soc-start.sh`
2. Ouvre le dashboard : `https://localhost`
3. Va dans **Security Events** — il devrait être calme pour l'instant
4. Garde un onglet ouvert sur les logs en temps réel

### Lancement des attaques

Chaque attaque se lance depuis ton terminal :

```bash
# Lire le README des attaques d'abord
cat levels/level-1/attacks/README.md

# Attaque 1 : Brute force SSH
bash levels/level-1/attacks/01-ssh-brute-force.sh

# Attaque 2 : Scan de ports
bash levels/level-1/attacks/02-port-scan.sh

# Attaque 3 : Echecs d'authentification
bash levels/level-1/attacks/03-failed-logins.sh
```

> Lance chaque attaque **une par une** et observe les alertes avant de passer à la suivante.

### Pendant chaque attaque

1. Observe les alertes qui apparaissent dans Wazuh
2. Note : quel `rule.id` ? quel niveau ? quelle description ?
3. Clique sur une alerte pour voir le log brut
4. Ouvre le playbook correspondant dans `core/incident-response/playbooks/`
5. Suis la checklist

### Après chaque attaque

1. Documente ce que tu as observé (template dans `core/docs/03-alert-triage.md`)
2. Comprends POURQUOI Wazuh a déclenché l'alerte (quelle règle ?)
3. Améliore les détections dans `core/config/local_rules.xml`

---

## Missions à accomplir

### Mission 1 — Brute force SSH
- [ ] Détecter l'alerte Wazuh lors du brute force
- [ ] Identifier l'IP source, le nombre de tentatives
- [ ] Trouver la règle Wazuh déclenchée (quel ID ?)
- [ ] Compléter le playbook `01-brute-force.md`

### Mission 2 — Scan de ports
- [ ] Détecter le scan dans les logs
- [ ] Identifier les ports ciblés
- [ ] Trouver dans quel log source l'événement apparaît

### Mission 3 — Echecs d'authentification
- [ ] Détecter les échecs su/sudo dans Wazuh
- [ ] Distinguer de la mission 1 (c'est différent !)
- [ ] Identifier la règle correspondante

### Mission 4 — Règles custom (bonus)
- [ ] Ouvrir `core/config/local_rules.xml`
- [ ] Décommenter et adapter la règle 100001 (brute force)
- [ ] Recharger Wazuh et vérifier que ta règle se déclenche
- [ ] Essayer d'écrire une règle pour le scan de ports

### Mission 5 — Active Response (bonus avancé)
- [ ] Activer la réponse active dans `core/config/wazuh-manager.conf`
- [ ] Configurer le blocage automatique d'IP sur brute force
- [ ] Vérifier que le blocage fonctionne

---

## Critères de réussite

Consulte `validation.md` pour les critères détaillés.

---

## Conseils

- **Commence par observer**, pas par lire les solutions
- Si une alerte ne s'affiche pas : attends quelques secondes, Wazuh n'est pas instantané
- Le `full_log` dans chaque alerte contient le log brut original — lis-le
- La section **MITRE ATT&CK** dans le dashboard te dit à quelle phase appartient l'attaque

---

## Liens utiles pour ce niveau

- [Règles Wazuh SSH](https://github.com/wazuh/wazuh-ruleset/blob/master/rules/0095-sshd_rules.xml)
- [MITRE T1110 — Brute Force](https://attack.mitre.org/techniques/T1110/)
- [MITRE T1046 — Network Service Discovery](https://attack.mitre.org/techniques/T1046/)
