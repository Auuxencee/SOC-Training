# Attaques — Niveau 3

Niveau APT : les attaques sont **discrètes par conception**. Certaines ne déclenchent aucune règle Wazuh par défaut — à toi d'écrire les détections avant de lancer.

| Script | Technique | MITRE | Difficulté détection |
|--------|-----------|-------|---------------------|
| `01-living-off-the-land.sh` | Curl/wget/base64 malveillants | T1059, T1140 | ★★★ |
| `02-dns-exfiltration.sh` | Exfil via requêtes DNS longues | T1048.003 | ★★★★ |
| `03-lateral-movement.sh` | SSH interne + pass-the-hash sim | T1021.004 | ★★★ |
| `04-c2-beacon.sh` | Beaconing HTTP régulier | T1071.001 | ★★★★ |

## Ordre recommandé

Lance **toutes les attaques d'un coup** — comme un vrai APT qui opère plusieurs techniques en parallèle :

```bash
bash levels/level-3/attacks/01-living-off-the-land.sh &
bash levels/level-3/attacks/02-dns-exfiltration.sh &
bash levels/level-3/attacks/03-lateral-movement.sh
bash levels/level-3/attacks/04-c2-beacon.sh
```

Puis investigue : quelles alertes as-tu ? Lesquelles as-tu manquées ?

## Host simulé

Les logs sont injectés depuis `apt-host-42` — un host interne qui a été compromis.
