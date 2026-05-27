# Attaques — Niveau 2

Tous les scripts injectent des logs via syslog (port 514 UDP) dans Wazuh.

| Script | Type | MITRE | Règles attendues |
|--------|------|-------|-----------------|
| `01-cron-backdoor.sh` | Persistance cron | T1053.003 | 550, 554 (FIM) |
| `02-suid-abuse.sh` | Escalade SUID | T1548.001 | 510, 514 (rootcheck) |
| `03-new-user-backdoor.sh` | Compte backdoor | T1136.001 | 5901, 5902 |
| `04-log-tampering.sh` | Effacement logs | T1070.002 | 591, 5710 |

## Ordre recommandé

Lance les attaques dans l'ordre — elles simulent une kill chain cohérente :
accès initial → persistance → escalade → création backdoor → effacement traces.

```bash
bash levels/level-2/attacks/01-cron-backdoor.sh
bash levels/level-2/attacks/02-suid-abuse.sh
bash levels/level-2/attacks/03-new-user-backdoor.sh
bash levels/level-2/attacks/04-log-tampering.sh
```

## Après chaque attaque

→ Wazuh Dashboard : **Threat Intelligence → Threat Hunting**  
→ Filtre par `agent.name: server-prod-01` (host simulé de ce niveau)
