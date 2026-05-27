# Validation — Niveau 4

---

## Critères de validation

### Active Response (obligatoire)

- [ ] **L4-AR-01** : Blocage automatique IP brute force en < 30 secondes
  - Temps mesuré : _______ | Rule déclenchée : _______________________

- [ ] **L4-AR-02** : Script de notification configuré (webhook ou log)
  - Événement notifié : _______ | Niveau d'alerte seuil : _______

- [ ] **L4-AR-03** : Active Response fonctionne sur les 3 hosts simulés
  - Hosts testés : _______________________

---

### Threat Intelligence (obligatoire)

- [ ] **L4-TI-01** : CDB List `blacklist_ips.txt` créée avec les IPs C2
  - IPs ajoutées : _______________________

- [ ] **L4-TI-02** : Règle custom qui élève le niveau d'alerte sur IP blacklistée
  - Rule ID : _______ | Niveau avant/après : _______

- [ ] **L4-TI-03** : Script de mise à jour de la CDB List (cron ou manuel)
  - Script : _______________________

---

### Test Final Red Team (obligatoire)

- [ ] **L4-RT-01** : 8 phases de la kill chain identifiées dans Wazuh
  - Phases détectées : ___/8 | Phases manquées : _______________________

- [ ] **L4-RT-02** : Timeline complète de l'incident construite (< 15 min)
  - Temps total : _______ minutes

- [ ] **L4-RT-03** : Rapport d'incident complet rédigé
  - Fichier : _______________________

---

### Métriques SOC (obligatoire)

- [ ] **L4-MET-01** : MTTD mesuré avant automation
  - MTTD manuel : _______ minutes

- [ ] **L4-MET-02** : MTTD mesuré avec automation activée
  - MTTD auto : _______ secondes

- [ ] **L4-MET-03** : MTTR mesuré avec automation activée
  - MTTR auto : _______ secondes

---

### Amélioration SOC (bonus)

- [ ] **L4-SOC-01** : Dashboard Wazuh avec métriques MTTD/MTTR

- [ ] **L4-SOC-02** : Rapport de maturité SOC (modèle CMMC ou similaire)

- [ ] **L4-SOC-03** : Intégration d'une source TI externe (AbuseIPDB, Shodan, etc.)

---

## Questions de compréhension

**Q1** : Quelle est la différence entre Active Response et SOAR ?
Réponse : ___________________________________________________________________

**Q2** : Pourquoi est-il important que les réponses automatiques soient réversibles ?
Réponse : ___________________________________________________________________

**Q3** : Explique pourquoi une CDB List est plus efficace qu'une règle avec des IPs en dur.
Réponse : ___________________________________________________________________

**Q4** : Comment éviter les faux positifs dans un système de blocage automatique ?
Réponse : ___________________________________________________________________

---

## Score

| Catégorie | Points max | Tes points |
|-----------|------------|------------|
| Active Response (3 critères) | 30 | /30 |
| Threat Intelligence (3 critères) | 30 | /30 |
| Red Team final (3 critères) | 30 | /30 |
| Métriques SOC (3 critères) | 30 | /30 |
| Bonus (3 critères) | 30 | /30 |
| **Total** | **120 (+30)** | **/120** |

**Seuil de réussite : 80/120**  
**Certification SOC Niveau 4 à : 100/120**
