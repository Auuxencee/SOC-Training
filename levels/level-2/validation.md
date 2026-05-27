# Validation — Niveau 2

---

## Critères de validation

### Détection (obligatoire)

- [ ] **L2-DET-01** : Règle Wazuh déclenchée par le cron backdoor
  - Rule ID : _______ | Fichier détecté : _______________________

- [ ] **L2-DET-02** : Règle Wazuh déclenchée par le SUID
  - Rule ID : _______ | Binaire concerné : _______________________

- [ ] **L2-DET-03** : Règle Wazuh pour la création de compte
  - Rule ID : _______ | Username backdoor : _______________________

- [ ] **L2-DET-04** : Règle Wazuh pour le log tampering
  - Rule ID : _______ | Fichiers supprimés : _______________________

- [ ] **L2-DET-05** : Tu as corrélé les 4 alertes en une kill chain cohérente

---

### Investigation (obligatoire)

- [ ] **L2-INV-01** : Timeline complète de l'intrusion (niveau 1 + niveau 2)

- [ ] **L2-INV-02** : Identification de tous les IoC (IPs, usernames, fichiers)

- [ ] **L2-INV-03** : Impact estimé : qu'est-ce que l'attaquant peut faire maintenant ?

- [ ] **L2-INV-04** : Tu as identifié pourquoi "svc_monitor" est suspect malgré son nom légitime

---

### Réponse (obligatoire)

- [ ] **L2-REP-01** : Playbook `03-persistence.md` complété (>= 4 étapes)

- [ ] **L2-REP-02** : Rapport d'incident avec timeline et IoC

---

### Amélioration SOC (bonus)

- [ ] **L2-SOC-01** : Règle custom pour détecter les nouveaux cron en dehors des heures ouvrées

- [ ] **L2-SOC-02** : Règle custom pour alerter sur tout nouveau user avec UID > 1000 ajouté à sudo

- [ ] **L2-SOC-03** : Active Response configuré — blocage IP auto sur création de compte suspect

---

## Questions de compréhension

**Q1** : Pourquoi un attaquant efface-t-il les logs après une intrusion ?
Réponse : ___________________________________________________________________

**Q2** : Quelle est la différence entre FIM et rootcheck dans Wazuh ?
Réponse : ___________________________________________________________________

**Q3** : Comment distinguer un compte système légitime d'un compte backdoor ?
Réponse : ___________________________________________________________________

**Q4** : Pourquoi est-il important que les logs Wazuh soient stockés hors du système compromis ?
Réponse : ___________________________________________________________________

---

## Score

| Catégorie | Points max | Tes points |
|-----------|------------|------------|
| Détection (5 critères) | 50 | /50 |
| Investigation (4 critères) | 40 | /40 |
| Réponse (2 critères) | 20 | /20 |
| Bonus SOC (3 critères) | 30 | /30 |
| **Total** | **110 (+30)** | **/110** |

**Seuil de réussite : 70/110**  
**Niveau suivant débloqué à : 90/110**
