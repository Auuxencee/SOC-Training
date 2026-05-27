# Attaques — Niveau 4

Niveau Expert : les attaques testent ton SOC **automatisé**. L'objectif n'est plus de détecter manuellement — c'est de valider que tes règles et ton Active Response fonctionnent end-to-end.

| Script | Description | Objectif |
|--------|-------------|----------|
| `01-combined-attack.sh` | Replay niveaux 1+2 en 60 secondes | Valider Active Response sur brute force + persistence |
| `02-fast-exfil.sh` | Exfiltration massive + beaconing simultané | Tester la vitesse de réponse automatique |
| `03-full-redteam.sh` | Kill chain complète (niveaux 1→4) | Validation finale du SOC |

## Ordre recommandé

**Mission 1** : Test de l'Active Response uniquement

```bash
bash levels/level-4/attacks/01-combined-attack.sh
# Vérifie que l'IP est bloquée en < 30s dans les alertes Wazuh
```

**Mission 2** : Test de vitesse

```bash
bash levels/level-4/attacks/02-fast-exfil.sh
# Mesure ton MTTD : temps entre le premier log et la première alerte
```

**Mission 3** : Red team complet (exercice final)

```bash
bash levels/level-4/attacks/03-full-redteam.sh
# Réponds à toutes les menaces en < 15 minutes
# Ne lis pas le script avant — c'est le test final
```

## Métriques à mesurer

- **MTTD** (Mean Time to Detect) : temps entre l'injection du log et la première alerte Wazuh
- **MTTR** (Mean Time to Respond) : temps entre la première alerte et l'action de blocage
- **Objectifs** : MTTD < 2 min, MTTR < 5 min avec automation activée
