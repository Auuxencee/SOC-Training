# Attaques — Niveau 1

> **IMPORTANT** : Ces scripts sont conçus pour être utilisés **uniquement** sur ton infrastructure locale (localhost / conteneurs Docker). Ne les utilise jamais sur des systèmes tiers.

---

## Comment ça fonctionne

Les scripts **injectent des logs via syslog** (port 514 UDP) directement dans Wazuh.
Wazuh tourne dans Docker et surveille ses propres logs container — il ne voit pas les logs macOS.
L'injection syslog est la méthode correcte pour simuler des attaques dans cet environnement.

## Vue d'ensemble

| Script | Type | Méthode | Durée | Objectif |
|--------|------|---------|-------|----------|
| `01-ssh-brute-force.sh` | Brute force SSH | Syslog UDP 514 | ~15s | Alertes auth failures SSH |
| `02-port-scan.sh` | Scan de ports | Syslog UDP 514 | ~10s | Logs firewall / scan réseau |
| `03-failed-logins.sh` | Auth failures su/sudo | Syslog UDP 514 | ~10s | Escalades de privilèges |

---

## Prérequis

```bash
# nc (netcat) doit être installé — vérifier
nc -h 2>&1 | head -1

# Installer si nécessaire
brew install netcat
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

1. Ouvre Wazuh Dashboard → Threat Intelligence → Threat Hunting
2. Cherche les alertes générées
3. Note le `rule.id` et le niveau
4. Lis le `full_log` pour comprendre l'événement brut
5. Ouvre le playbook correspondant dans `core/incident-response/playbooks/`
