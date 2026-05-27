# Validation — Niveau 1

## Comment savoir si tu as réussi ?

Ce niveau est réussi quand tu peux répondre à toutes ces questions **sans regarder les solutions**.

---

## Critères de validation

### Détection (obligatoire)

- [ ] **L1-DET-01** : Tu as identifié la règle Wazuh déclenchée par le brute force SSH
  - Rule ID : _______ | Niveau : _______ | Description : _______________________

- [ ] **L1-DET-02** : Tu as retrouvé l'IP source de l'attaque SSH dans le dashboard
  - IP identifiée : _______

- [ ] **L1-DET-03** : Tu as compté le nombre de tentatives SSH dans Wazuh
  - Nombre de tentatives : _______

- [ ] **L1-DET-04** : Tu as identifié la règle pour les échecs su/sudo
  - Rule ID : _______ | Niveau : _______

- [ ] **L1-DET-05** : Tu sais expliquer la différence entre une attaque SSH réseau et des échecs locaux sudo

---

### Investigation (obligatoire)

- [ ] **L1-INV-01** : Tu as lu le `full_log` d'une alerte brute force et tu comprends ce qu'il contient

- [ ] **L1-INV-02** : Tu as reconstruit la timeline de l'attaque SSH (heure de début, heure de fin, fréquence)

- [ ] **L1-INV-03** : Tu as vérifié s'il y avait eu une **connexion réussie** après les tentatives échouées

---

### Réponse (obligatoire)

- [ ] **L1-REP-01** : Tu as complété au moins 3 étapes du playbook `01-brute-force.md`

- [ ] **L1-REP-02** : Tu as documenté un rapport de triage (même minimaliste) pour l'attaque SSH

---

### Amélioration SOC (bonus)

- [ ] **L1-SOC-01** : Tu as décommenté et testé la règle 100001 dans `local_rules.xml`

- [ ] **L1-SOC-02** : Ta règle custom se déclenche quand tu relances le brute force

- [ ] **L1-SOC-03** : Tu as activé et testé l'Active Response pour bloquer l'IP automatiquement

---

## Questions de compréhension

Réponds à ces questions pour valider ta compréhension :

**Q1** : Quelle est la différence entre un IDS et un SIEM ?
Réponse : ___________________________________________________________________

**Q2** : Qu'est-ce qu'un "faux positif" et comment le distinguer d'un vrai positif dans le cas du brute force SSH ?
Réponse : ___________________________________________________________________

**Q3** : Pourquoi le scan de ports est-il plus difficile à détecter que le brute force SSH ?
Réponse : ___________________________________________________________________

**Q4** : Quelles informations dois-tu collecter avant de bloquer une IP ?
Réponse : ___________________________________________________________________

---

## Score

| Catégorie | Points max | Tes points |
|-----------|------------|------------|
| Détection (5 critères) | 50 | /50 |
| Investigation (3 critères) | 30 | /30 |
| Réponse (2 critères) | 20 | /20 |
| Bonus SOC (3 critères) | 30 | /30 |
| **Total** | **100 (+30)** | **/100** |

**Seuil de réussite : 60/100**
**Niveau suivant débloqué à : 80/100**

---

## Passage au Niveau 2

Quand tu as >= 80/100 :
1. Complète les playbooks non terminés
2. Assure-toi que `local_rules.xml` contient tes règles custom
3. Documente tes apprentissages dans le rapport post-mortem
4. Passe au `levels/level-2/README.md`
