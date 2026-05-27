# Attaques — Niveau 1

> **IMPORTANT** : Ces scripts sont conçus pour être utilisés **uniquement** sur ton infrastructure locale (localhost / conteneurs Docker). Ne les utilise jamais sur des systèmes tiers.

---

## Vue d'ensemble

| Script | Type | Cible | Durée | Objectif |
|--------|------|-------|-------|----------|
| `01-ssh-brute-force.sh` | Brute force SSH | localhost:22 | ~30s | Générer des alertes d'auth failures |
| `02-port-scan.sh` | Scan de ports | localhost | ~15s | Détecter un scan réseau |
| `03-failed-logins.sh` | Auth failures su/sudo | Local system | ~20s | Détecter escalades échouées |

---

## Prérequis

```bash
# Vérifier que nmap est installé (pour l'attaque 2)
nmap --version

# Installer si nécessaire
brew install nmap
```

---

## Comment lancer les attaques

Lance chaque script depuis la racine du projet :

```bash
bash levels/level-1/attacks/01-ssh-brute-force.sh
bash levels/level-1/attacks/02-port-scan.sh
bash levels/level-1/attacks/03-failed-logins.sh
```

---

## Ce que chaque attaque génère

### 01 — SSH Brute Force
- Tentatives de connexion SSH avec des mots de passe incorrects
- Génère des logs `auth.log` ou `sshd` → Wazuh rules 5551, 5712, 5763
- MITRE : T1110.001 (Password Guessing)

### 02 — Port Scan
- Scan SYN des ports communs avec nmap
- Peut être visible dans les logs réseau / Wazuh
- MITRE : T1046 (Network Service Discovery)

### 03 — Failed Logins (su/sudo)
- Tentatives d'utilisation de `su` et `sudo` avec mauvais mot de passe
- Génère des logs PAM → Wazuh rules 5401-5503
- MITRE : T1548.003 (Sudo and Sudo Caching)

---

## Après chaque attaque

1. Ouvre Wazuh Dashboard → Security Events
2. Cherche les alertes générées
3. Note le `rule.id` et le niveau
4. Lis le `full_log` pour comprendre l'événement brut
5. Ouvre le playbook correspondant dans `core/incident-response/playbooks/`
