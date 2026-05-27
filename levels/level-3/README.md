# Niveau 3 — APT & Techniques d'Évasion

> **Difficulté** : Avancé  
> **Durée estimée** : 5 à 8 heures  
> **Prérequis** : Niveau 2 validé (score >= 80/100)

---

## Contexte scénaristique

Tu fais face à un attaquant **sophistiqué et discret**. Il n'utilise que des outils légitimes déjà présents sur le système (Living off the Land), efface ses traces, et communique via des canaux détournés.

Pas de malware évident. Pas de brute force visible. Seulement des **signaux faibles** à corréler.

Tu passes en mode **Threat Hunter** : tu ne réagis plus aux alertes, tu **chasses activement** les anomalies.

---

## Objectifs pédagogiques

1. **Chasser** des signaux faibles sans alerte évidente
2. **Détecter** du Living off the Land (curl, wget, bash, base64)
3. **Détecter** de l'exfiltration DNS
4. **Détecter** du mouvement latéral SSH interne
5. **Détecter** un pattern de beaconing C2
6. **Construire** des règles de détection custom complexes
7. **Automatiser** une réponse complète multi-étapes

---

## Les attaques simulées

| ID | Type | Script | MITRE | Complexité |
|----|------|--------|-------|------------|
| L3-01 | Living off the Land | `attacks/01-living-off-the-land.sh` | T1059.004, T1140 | Élevé |
| L3-02 | DNS Exfiltration | `attacks/02-dns-exfiltration.sh` | T1048.003 | Élevé |
| L3-03 | Mouvement latéral | `attacks/03-lateral-movement.sh` | T1021.004 | Élevé |
| L3-04 | Beaconing C2 | `attacks/04-c2-beacon.sh` | T1071.001 | Élevé |

---

## Déroulement recommandé

### Phase 1 — Threat Hunting proactif
Avant de lancer les attaques, configure des règles de détection dans `core/config/local_rules.xml`.
Le défi : détecter des techniques qui ne déclenchent PAS les règles par défaut.

### Phase 2 — Simulation APT complète
Lance **toutes les attaques à la suite** (comme un vrai APT multi-étapes) :

```bash
bash levels/level-3/attacks/01-living-off-the-land.sh
bash levels/level-3/attacks/02-dns-exfiltration.sh
bash levels/level-3/attacks/03-lateral-movement.sh
bash levels/level-3/attacks/04-c2-beacon.sh
```

### Phase 3 — Investigation forensique
- Reconstitue la kill chain complète (toutes les étapes depuis niveau 1)
- Identifie le "patient zéro" et le vecteur initial
- Estime l'impact : qu'est-ce que l'attaquant a pu exfiltrer ?

### Phase 4 — Durcissement
- Rédige des règles Wazuh pour chaque technique détectée
- Configure la réponse automatisée complète (`core/automation/`)
- Produis un rapport d'incident complet

---

## Missions à accomplir

### Mission 1 — Living off the Land
- [ ] Détecter l'utilisation de curl/wget/base64 à des fins malveillantes
- [ ] Distinguer un usage légitime d'un usage malveillant
- [ ] Écrire une règle Wazuh pour détecter les one-liners suspects

### Mission 2 — DNS Exfiltration
- [ ] Identifier des requêtes DNS anormalement longues dans les logs
- [ ] Calculer le volume de données potentiellement exfiltré
- [ ] Comprendre pourquoi le DNS est un canal d'exfiltration difficile à bloquer

### Mission 3 — Mouvement latéral
- [ ] Détecter des connexions SSH inter-machines inhabituelles
- [ ] Identifier la machine pivot et la machine cible
- [ ] Corréler avec les events du niveau 2 (clé SSH backdoor ?)

### Mission 4 — Beaconing C2
- [ ] Identifier un pattern de connexions régulières (toutes les X minutes)
- [ ] Calculer l'intervalle de beaconing
- [ ] Écrire une règle de détection basée sur la fréquence

### Mission 5 — Kill chain complète (obligatoire)
- [ ] Reconstituer les 3 niveaux en une kill chain MITRE ATT&CK complète
- [ ] Remplir `core/incident-response/playbooks/04-apt-response.md`
- [ ] Produire un rapport d'incident professionnel

### Mission 6 — Durcissement avancé (bonus)
- [ ] 3 nouvelles règles custom dans `local_rules.xml`
- [ ] Active Response multi-étapes configuré
- [ ] Rapport de recommandations de sécurité
