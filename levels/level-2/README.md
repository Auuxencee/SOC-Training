# Niveau 2 — Persistance & Escalade de Privilèges

> **Statut** : En cours de développement  
> **Prérequis** : Niveau 1 validé (score >= 80/100)

---

## Aperçu

Le Niveau 2 introduit des techniques d'attaque plus sophistiquées :  
un attaquant qui a réussi à entrer cherche maintenant à **rester** et à **élargir** ses accès.

---

## Attaques prévues

| Type | Technique | MITRE |
|------|-----------|-------|
| Backdoor cron | Tâche planifiée malveillante | T1053.003 |
| SUID abuse | Escalade via binaire SUID | T1548.001 |
| Ajout utilisateur | Création compte backdoor | T1136.001 |
| Lateral movement SSH | Réutilisation de clé SSH | T1021.004 |
| Log tampering | Effacement des traces | T1070.002 |

---

## Objectifs pédagogiques

- Détecter une tâche cron malveillante avec FIM
- Identifier une escalade de privilèges SUID dans les logs
- Chasser des traces d'effacement de logs
- Ecrire des règles de détection avancées

---

## Disponibilité

Ce niveau sera disponible prochainement.  
Pour contribuer : voir [CONTRIBUTING.md](../../CONTRIBUTING.md)
