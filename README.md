# SOC Training — Apprendre la cybersécurité défensive par la pratique

> **Objectif** : Monter un SOC (Security Operations Center) fonctionnel de zéro, en passant par des niveaux de difficulté croissants, des simulations d'attaques réelles et des décisions humaines à chaque étape.

---

## Qu'est-ce que ce projet ?

Ce dépôt est un **laboratoire d'entraînement SOC** conçu pour apprendre à détecter, analyser et répondre aux incidents de sécurité. Contrairement aux certifications théoriques, l'approche ici est **hands-on** :

1. Tu pars d'une infrastructure SOC minimale (squelette)
2. Des attaques simulées frappent ton environnement
3. Tu dois **détecter manuellement**, analyser les logs, et prendre des décisions
4. Ensuite tu **automatises** ta réponse (règles, alertes, playbooks)

Le cycle se répète à chaque niveau, avec des attaques plus sophistiquées.

---

## Stack technique

| Composant | Rôle |
|-----------|------|
| **Wazuh Manager** | SIEM / IDS — collecte et corrèle les alertes |
| **Wazuh Indexer** | Stockage et indexation des logs (OpenSearch) |
| **Wazuh Dashboard** | Interface d'analyse visuelle |
| **Docker Compose** | Infrastructure locale reproductible |

---

## Architecture du projet

```
SOC-Training/
├── README.md                   ← Ce fichier
├── soc-start.sh                ← Démarrer le SOC (Docker)
├── soc-stop.sh                 ← Arrêter et compresser
│
├── core/                       ← Infrastructure SOC de base
│   ├── README.md
│   ├── config/                 ← Configurations Wazuh à compléter
│   │   ├── wazuh-manager.conf  ← ossec.conf squelette
│   │   └── local_rules.xml     ← Règles custom à écrire
│   ├── docs/                   ← Documentation pédagogique
│   │   ├── 01-soc-overview.md
│   │   ├── 02-tools.md
│   │   ├── 03-alert-triage.md
│   │   └── 04-glossary.md
│   └── incident-response/      ← Procédures de réponse aux incidents
│       ├── README.md
│       ├── ir-checklist.md
│       └── playbooks/
│           ├── 00-template.md
│           ├── 01-brute-force.md
│           └── 02-malware.md
│
└── levels/
    ├── level-1/                ← Niveau 1 : Détection basique
    │   ├── README.md
    │   ├── attacks/            ← Scripts de simulation d'attaques
    │   └── validation.md       ← Critères de réussite
    ├── level-2/                ← Niveau 2 : Persistance & escalade
    └── level-3/                ← Niveau 3 : APT & attaques avancées
```

---

## Comment progresser

### Étape 1 — Préparer l'environnement
```bash
# Cloner le dépôt
git clone https://github.com/Auuxencee/SOC-Training.git
cd SOC-Training

# Démarrer le SOC (nécessite Docker Desktop)
./soc-start.sh
```

### Étape 2 — Lire la documentation core
Commence par `core/docs/` pour comprendre les outils et la méthodologie SOC.

### Étape 3 — Attaquer ton propre SOC (par niveau)
Chaque niveau dans `levels/` contient :
- Un `README.md` avec le contexte et les objectifs
- Des scripts d'attaque à lancer dans `attacks/`
- Des critères de validation dans `validation.md`

### Étape 4 — Détecter, analyser, répondre
- Ouvre le dashboard : `https://localhost`
- Login : `admin` / `MonSoc@dmin`
- Cherche les alertes, remonte les traces, documente

### Étape 5 — Affiner ton SOC
Améliore les configs dans `core/config/` et complète les playbooks dans `core/incident-response/`.

---

## Niveaux de difficulté

| Niveau | Thème | Attaques simulées | Statut |
|--------|-------|-------------------|--------|
| **Level 1** | Détection basique | Brute force SSH, scan de ports, échecs d'auth | ✅ Disponible |
| **Level 2** | Persistance & escalade | Cron backdoor, SUID abuse, lateral movement | 🔜 En cours |
| **Level 3** | APT & évasion | Living-off-the-land, obfuscation, C2 simulé | 🔜 En cours |

---

## Prérequis

- macOS / Linux
- Docker Desktop (>= 4.x)
- 8 Go RAM minimum recommandés
- Bash 4+
- `curl`, `nmap` installés

---

## Ressources complémentaires

- [Documentation Wazuh](https://documentation.wazuh.com/)
- [MITRE ATT&CK](https://attack.mitre.org/)
- [NIST Incident Handling Guide (SP 800-61)](https://nvlpubs.nist.gov/nistpubs/SpecialPublications/NIST.SP.800-61r2.pdf)

---

*Projet personnel d'entraînement SOC — usage pédagogique uniquement. Ne jamais utiliser les scripts d'attaque sur des systèmes sans autorisation.*
