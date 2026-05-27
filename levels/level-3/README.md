# Niveau 3 — APT & Techniques Avancées

> **Statut** : En cours de développement  
> **Prérequis** : Niveau 2 validé

---

## Aperçu

Le Niveau 3 simule une attaque de type **APT (Advanced Persistent Threat)** :  
discrète, multi-étapes, utilisant des outils légitimes (Living off the Land).  
L'objectif est de détecter des signaux faibles et de chasser activement les menaces.

---

## Attaques prévues

| Type | Technique | MITRE |
|------|-----------|-------|
| DNS tunneling | Exfiltration via DNS | T1048.003 |
| Living-off-the-land | Utilisation de curl/bash pour C2 | T1059.004 |
| Memory injection | Injection dans processus légitimes | T1055 |
| Credential harvesting | Dump de credentials | T1003 |
| Evasion avancée | Obfuscation, timestomping | T1027, T1070.006 |

---

## Objectifs pédagogiques

- Threat hunting (chasse proactive aux menaces)
- Détection de signaux faibles corrélés
- Réponse à incident sur attaque multi-étapes
- Forensics basique (timeline, artefacts)

---

## Disponibilité

Ce niveau sera disponible après la validation complète des Niveaux 1 et 2.
