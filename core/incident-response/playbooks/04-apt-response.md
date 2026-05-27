# Playbook — Réponse à une Attaque APT (Advanced Persistent Threat)

> MITRE ATT&CK : Kill chain complète — Initial Access → C2 → Exfiltration

---

## Critères de déclenchement

Ce playbook s'active sur détection d'une ou plusieurs de ces conditions :
- Mouvement latéral SSH entre hosts internes
- Beaconing HTTP vers IP externe (connexions répétées à intervalle régulier)
- Exfiltration de données (gros volumes POST, requêtes DNS encodées)
- Présence d'IoC dans la CDB blacklist (IP C2 connue)

---

## Modèle PICERL

### P — Préparation

- [ ] CDB blacklist mise à jour avec les IoC connus
- [ ] Active Response configuré et testé (firewall-drop, notify)
- [ ] Playbooks de réponse accessibles hors du système compromis

---

### I — Identification

- [ ] Heure de première détection : _______________________
- [ ] Host(s) concerné(s) : _______________________
- [ ] Technique(s) identifiée(s) (MITRE) :
  - [ ] Initial Access : _______________________
  - [ ] Execution : _______________________
  - [ ] Persistence : _______________________
  - [ ] Privilege Escalation : _______________________
  - [ ] Defense Evasion : _______________________
  - [ ] Lateral Movement : _______________________
  - [ ] C2 : _______________________
  - [ ] Exfiltration : _______________________
- [ ] IP attaquante(s) : _______________________
- [ ] Durée estimée de l'intrusion : _______________________

---

### C — Containment

**Court terme (immédiat)** :
- [ ] Bloquer l'IP C2 au firewall / Active Response
- [ ] Isoler le(s) host(s) compromis en quarantaine réseau
- [ ] Révoquer les clés SSH volées

**Long terme** :
- [ ] Changer tous les mots de passe sur les systèmes touchés
- [ ] Rotation des clés SSH sur tous les hosts internes
- [ ] Segmentation réseau renforcée

---

### E — Éradication

- [ ] Supprimer tous les comptes backdoor identifiés
- [ ] Retirer toutes les entrées cron malveillantes
- [ ] Scanner tous les hosts latéraux pour traces de persistence
- [ ] Vérifier l'intégrité des binaires systèmes (FIM)
- [ ] Rechercher d'autres implants C2 (netstat, lsof, ps auxf)

---

### R — Récupération

- [ ] Restaurer depuis backup sain si intégrité compromise
- [ ] Rétablir les logs depuis le SIEM centralisé
- [ ] Valider le fonctionnement normal de chaque service
- [ ] Monitoring renforcé pendant 72h post-incident

---

### L — Leçons apprises

**Timeline complète de l'incident** :

| Heure | Événement | Source | Action prise |
|-------|-----------|--------|--------------|
| | | | |
| | | | |
| | | | |

**Questions post-mortem** :

1. Quel a été le vecteur d'accès initial ?
   Réponse : ___________________________________________________________________

2. Combien de temps l'attaquant est-il resté présent avant détection ?
   Réponse : ___________________________________________________________________

3. Quelles données ont été exfiltrées (ou potentiellement exfiltrées) ?
   Réponse : ___________________________________________________________________

4. Quelle règle ou mécanisme aurait permis une détection plus rapide ?
   Réponse : ___________________________________________________________________

---

## Métriques incident

| Métrique | Valeur |
|----------|--------|
| MTTD (Mean Time to Detect) | |
| MTTR (Mean Time to Respond) | |
| Hosts compromis | |
| Durée totale de l'intrusion | |
| Données exfiltrées (estimé) | |
