# Validation — Niveau 3

---

## Critères de validation

### Règles custom (obligatoire — aucune règle default ne couvre ces techniques)

- [ ] **L3-RULE-01** : Règle custom déclenchée par curl/wget vers IP externe
  - Rule ID : _______ | Regex utilisé : _______________________

- [ ] **L3-RULE-02** : Règle custom déclenchée par base64 + pipe bash
  - Rule ID : _______ | Pattern détecté : _______________________

- [ ] **L3-RULE-03** : Règle custom pour requêtes DNS anormalement longues
  - Rule ID : _______ | Longueur seuil : _______________________

- [ ] **L3-RULE-04** : Règle custom pour beaconing HTTP (connexions répétées)
  - Rule ID : _______ | Fréquence détectée : _______________________

---

### Investigation APT (obligatoire)

- [ ] **L3-INV-01** : Kill chain complète niveau 1 → 2 → 3 reconstituée
  - IP initiale : _______ → Host compromis : _______ → Cibles latérales : _______

- [ ] **L3-INV-02** : Identification du C2 (IP + domaine)
  - C2 IP : _______ | C2 Domain : _______________________

- [ ] **L3-INV-03** : Données exfiltrées identifiées
  - Via HTTP : _______ | Via DNS : _______________________

- [ ] **L3-INV-04** : Hosts latéraux compromis identifiés
  - Hosts : _______________________

---

### Réponse (obligatoire)

- [ ] **L3-REP-01** : Playbook `04-apt-response.md` complété

- [ ] **L3-REP-02** : Active Response configuré pour bloquer C2 IP automatiquement
  - Script utilisé : _______ | Test de déclenchement : _______________________

---

### Amélioration SOC (bonus)

- [ ] **L3-SOC-01** : CDB List créée avec IoC (IPs C2, domaines suspects)

- [ ] **L3-SOC-02** : Dashboard Wazuh personnalisé avec les 4 techniques niveau 3

- [ ] **L3-SOC-03** : Règle de fréquence (frequency) pour détecter le beaconing

---

## Questions de compréhension

**Q1** : Pourquoi "living off the land" est-il difficile à détecter avec des règles basées sur les noms de processus ?
Réponse : ___________________________________________________________________

**Q2** : Quelle est la différence entre exfiltration HTTP et exfiltration DNS ? Laquelle est la plus discrète ?
Réponse : ___________________________________________________________________

**Q3** : Comment différencier un beacon C2 d'un logiciel légitime qui check ses mises à jour ?
Réponse : ___________________________________________________________________

**Q4** : Explique le concept de "jitter" dans un beacon C2 et pourquoi il complique la détection.
Réponse : ___________________________________________________________________

---

## Score

| Catégorie | Points max | Tes points |
|-----------|------------|------------|
| Règles custom (4 critères) | 40 | /40 |
| Investigation APT (4 critères) | 40 | /40 |
| Réponse (2 critères) | 20 | /20 |
| Bonus SOC (3 critères) | 30 | /30 |
| **Total** | **100 (+30)** | **/100** |

**Seuil de réussite : 65/100**  
**Niveau suivant débloqué à : 85/100**
