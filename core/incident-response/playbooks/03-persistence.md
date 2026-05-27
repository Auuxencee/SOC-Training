# Playbook — Détection et Réponse à une Persistence

> MITRE ATT&CK : T1053 (Cron), T1136 (Account), T1548 (SUID), T1070 (Log Tampering)

---

## Critères de déclenchement

Ce playbook s'active sur :
- Modification de `/etc/crontab` ou `/etc/cron.*`
- Création d'un nouveau compte utilisateur
- Ajout d'un compte au groupe `sudo` ou `wheel`
- SUID positionné sur un binaire dans `/tmp` ou `/dev`
- Troncature ou suppression de fichiers de log

---

## Étapes de réponse

### Étape 1 — Triage initial

- [ ] Identifier le host concerné : _______________________
- [ ] Heure de détection : _______________________
- [ ] Règle(s) déclenchée(s) : _______________________
- [ ] Niveau d'alerte : _______

**Question clé** : L'action vient-elle d'un admin légitime (heure ouvrée, changement planifié) ?

---

### Étape 2 — Investigation Wazuh

- [ ] Chercher toutes les alertes du même host : `agent.name: <host>`
- [ ] Chercher les alertes 60 minutes avant l'événement (contexte)
- [ ] Vérifier si l'IP source est connue : `data.srcip: <ip>`
- [ ] Corréler avec le niveau précédent (brute force ou accès initial ?)

---

### Étape 3 — Isolation (si compromission confirmée)

- [ ] Isoler le host du réseau (Active Response quarantaine ou VLAN)
- [ ] Notifier le responsable sécurité et le responsable du host
- [ ] Snapshot de la machine avant toute modification (préservation des preuves)

---

### Étape 4 — Containment

- [ ] Désactiver le compte backdoor : `usermod -L <user>`
- [ ] Supprimer la clé SSH backdoor : `rm /home/<user>/.ssh/authorized_keys`
- [ ] Supprimer l'entrée cron malveillante : `crontab -l -u root | grep -v <pattern>`
- [ ] Retirer le bit SUID du binaire suspect : `chmod -s <binaire>`
- [ ] Bloquer l'IP attaquante en firewall

---

### Étape 5 — Éradication

- [ ] Chercher d'autres binaires SUID suspects : `find / -perm -4000 -type f 2>/dev/null`
- [ ] Vérifier tous les crons : `for u in $(cut -f1 -d: /etc/passwd); do crontab -l -u $u 2>/dev/null; done`
- [ ] Lister tous les comptes avec UID > 1000 : `awk -F: '$3 >= 1000 {print $1, $3}' /etc/passwd`
- [ ] Vérifier les clés SSH autorisées sur tous les comptes

---

### Étape 6 — Récupération et leçons

- [ ] Rétablir les logs depuis la sauvegarde ou les logs Wazuh centralisés
- [ ] Valider l'absence de toute persistence restante
- [ ] Documenter dans le rapport d'incident

---

## IoC à noter

| Type | Valeur | Trouvé où |
|------|--------|-----------|
| IP attaquante | | |
| Compte backdoor | | |
| Binaire SUID | | |
| Entrée cron | | |
| Logs effacés | | |
