# Glossaire SOC

Termes essentiels pour un analyste SOC. Classés par thème.

---

## Infrastructure & Monitoring

| Terme | Définition |
|-------|------------|
| **SIEM** | Security Information and Event Management — centralise et corrèle les logs |
| **XDR** | Extended Detection and Response — SIEM étendu aux endpoints et réseau |
| **IDS** | Intrusion Detection System — détecte les intrusions (pas de blocage) |
| **IPS** | Intrusion Prevention System — détecte ET bloque |
| **EDR** | Endpoint Detection and Response — détection sur les postes |
| **Log** | Enregistrement d'un événement système (connexion, modification, erreur) |
| **Agent** | Programme installé sur un host pour envoyer ses logs au SIEM |
| **FIM** | File Integrity Monitoring — surveille les modifications de fichiers |

---

## Attaques & Menaces

| Terme | Définition |
|-------|------------|
| **Brute Force** | Attaque par force brute — essayer des milliers de mots de passe |
| **Port Scan** | Sonde les ports d'un host pour identifier les services ouverts |
| **Lateral Movement** | Déplacement de l'attaquant d'une machine à une autre dans le réseau |
| **Persistence** | Mécanisme pour maintenir l'accès après un reboot (cron, service) |
| **Privilege Escalation** | Obtenir des droits plus élevés (ex: passer de user à root) |
| **C2 / C&C** | Command & Control — serveur de l'attaquant qui pilote les malwares |
| **APT** | Advanced Persistent Threat — attaquant sophistiqué et discret sur la durée |
| **Payload** | Code malveillant exécuté sur la victime |
| **Exfiltration** | Vol de données vers l'extérieur |
| **Living off the Land** | Utiliser les outils légitimes du système pour attaquer (nmap, curl, bash…) |

---

## Réponse aux incidents

| Terme | Définition |
|-------|------------|
| **IoC** | Indicator of Compromise — signe qu'un système a été compromis (IP, hash, domaine) |
| **IoA** | Indicator of Attack — signe d'une attaque en cours (comportement) |
| **TTP** | Tactics, Techniques, Procedures — les méthodes d'un attaquant |
| **Playbook** | Procédure documentée de réponse à un type d'incident |
| **Triage** | Classification et priorisation des alertes |
| **Containment** | Actions pour limiter la propagation d'un incident |
| **Eradication** | Suppression de la cause racine |
| **Post-mortem** | Analyse après incident pour en tirer des leçons |
| **MTTD** | Mean Time To Detect — délai moyen de détection |
| **MTTR** | Mean Time To Respond — délai moyen de réponse |

---

## Wazuh spécifique

| Terme | Définition |
|-------|------------|
| **Rule** | Règle de corrélation qui analyse les logs et génère des alertes |
| **Decoder** | Parse un format de log brut en champs structurés |
| **Group** | Catégorie d'alertes (ex: `authentication_failures`) |
| **Active Response** | Action automatique déclenchée par une règle (bloquer IP, kill process) |
| **Ruleset** | Ensemble des règles chargées (Wazuh default + custom) |
| **Alert level** | Sévérité d'une règle de 0 à 15 |
| **CDB List** | Liste de valeurs (IPs, hashes) consultée par les règles |

---

## MITRE ATT&CK

Le framework MITRE ATT&CK catalogue les techniques d'attaques réelles.

| Tactique (phase) | Exemples de techniques |
|------------------|----------------------|
| **Initial Access** | Phishing, Exploit public |
| **Execution** | Command Line, Scripts |
| **Persistence** | Cron, Registry, Startup |
| **Privilege Escalation** | SUID, Sudo, Token manipulation |
| **Defense Evasion** | Log clearing, Obfuscation |
| **Credential Access** | Brute Force, Keylogging |
| **Discovery** | Port Scan, Network enumeration |
| **Lateral Movement** | SSH, Pass-the-Hash |
| **Exfiltration** | Over HTTP, DNS tunneling |

> Dans Wazuh Dashboard, chaque alerte est mappée sur MITRE ATT&CK.
> Utilise cela pour comprendre la phase de l'attaque.
