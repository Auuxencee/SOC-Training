# Playbook — Brute Force SSH

---

## Contexte

**Type d'incident** : Attaque par force brute sur SSH  
**MITRE ATT&CK** : T1110 — Brute Force  
**Règles Wazuh associées** : 5551, 5712, 5763 (sshd multiple auth failures)  
**Niveau de sévérité typique** : 10  

---

## Signes d'alerte (IoA)

- [ ] Alerte rule.id 5763 — `sshd: brute force trying to get access to the system`
- [ ] Nombreuses alertes 5551 (auth failed) depuis la même IP en peu de temps
- [ ] Tentatives sur plusieurs usernames différents

---

## Etape 1 — Triage initial (< 5 min)

- [ ] Ouvrir Wazuh → Security Events, filtrer `rule.id: 5763`
- [ ] Identifier l'IP source (`data.srcip`)
- [ ] Identifier le host cible (`agent.name`)
- [ ] Compter les tentatives : `data.srcip: <IP>` sur les 30 dernières minutes
- [ ] Vérifier s'il y a eu une connexion **réussie** après les échecs

**Verdict** : `[ ] Vrai positif` | `[ ] Faux positif` | `[ ] Indéterminé`

> Faux positif possible : outil de backup automatique, pipeline CI/CD avec mauvaise clé SSH.
> Vérifier : l'heure est-elle inhabituelle ? L'IP est-elle interne ?

---

## Etape 2 — Investigation

*Questions à répondre :*

- Depuis quand dure l'attaque ?
- Combien de tentatives par minute ?
- Quels usernames ont été essayés ?
- Y a-t-il eu une connexion SSH réussie ?
- L'IP a-t-elle fait autre chose (scan, autres services) ?

*Commandes utiles :*
```bash
# Voir les logs SSH bruts dans le container
docker exec -it single-node-wazuh.manager-1 bash
tail -f /var/ossec/logs/alerts/alerts.json | jq 'select(.rule.id == "5763")'

# Compter les tentatives depuis une IP
grep "data.srcip: <IP>" /var/ossec/logs/alerts/alerts.log | wc -l

# Dernières connexions réussies
last -n 20
```

*[À COMPLÉTER après l'exercice Level 1 : ajoute ici les commandes qui t'ont été utiles]*

---

## Etape 3 — Confinement

*Si attaque confirmée en cours :*

- [ ] Bloquer l'IP source (choisir l'option adaptée) :

```bash
# Option A : blocage via iptables (temporaire, dans le container)
docker exec -it single-node-wazuh.manager-1 bash
iptables -A INPUT -s <IP_ATTAQUANT> -j DROP

# Option B : Active Response Wazuh (permanent)
# Activer dans core/config/wazuh-manager.conf → <active-response>
```

- [ ] Vérifier que le blocage est effectif (plus d'alertes depuis cette IP)
- [ ] Si connexion réussie détectée : **ESCALADER** → isolation du host

---

## Etape 4 — Eradication

*Si connexion réussie et compromission suspectée :*

- [ ] Vérifier les nouveaux comptes créés : `cat /etc/passwd | grep -v nologin`
- [ ] Vérifier les clés SSH ajoutées : `cat ~/.ssh/authorized_keys`
- [ ] Vérifier les crons ajoutés : `crontab -l`, `cat /etc/cron*`
- [ ] [À COMPLÉTER après Level 1]

---

## Etape 5 — Amélioration SOC

*À remplir après l'exercice :*

- Règle custom à créer : `[À COMPLÉTER dans local_rules.xml]`
- Seuil de déclenchement optimal : `[À COMPLÉTER]`
- Blocage automatique à configurer : `[À COMPLÉTER]`

---

## Historique des incidents

| Date | Niveau | IP Source | Tentatives | Connexion réussie | Résolution |
|------|--------|-----------|------------|-------------------|------------|
|      |        |           |            | Oui / Non         |            |
