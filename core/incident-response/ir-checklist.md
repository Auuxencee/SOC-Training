# Checklist Générale d'Investigation

Utilise cette checklist pour chaque incident. Coche au fur et à mesure.

---

## Phase 1 — Identification

- [ ] Ouvrir Wazuh Dashboard → Security Events
- [ ] Identifier la ou les alertes déclenchées
- [ ] Noter : `rule.id`, `rule.level`, `rule.description`
- [ ] Identifier l'IP source (`data.srcip`)
- [ ] Identifier le host cible (`agent.name`)
- [ ] Vérifier le timestamp — quand a commencé l'activité ?
- [ ] L'activité est-elle encore en cours ? (alerte récente vs ancienne)

---

## Phase 2 — Contextualisation

- [ ] Filtrer par IP source sur les 30 dernières minutes
- [ ] Chercher d'autres alertes sur le même host
- [ ] Vérifier si l'IP est interne ou externe
- [ ] Consulter les logs bruts (`full_log`) pour comprendre l'événement exact
- [ ] Chercher des patterns : fréquence, régularité, heure (nuit = suspect)
- [ ] Corréler avec d'autres sources si disponible

**Verdict triage :**
- [ ] Faux positif → documenter pourquoi, ignorer
- [ ] Vrai positif → continuer checklist
- [ ] Indéterminé → continuer checklist avec prudence

---

## Phase 3 — Confinement

*Applicable si activité malveillante confirmée ou fortement suspectée*

- [ ] Identifier si l'attaque est encore active
- [ ] Option A : blocage manuel de l'IP (firewall, iptables)
  ```bash
  # Exemple : bloquer une IP via iptables (dans le container)
  iptables -A INPUT -s <IP_SUSPECTE> -j DROP
  ```
- [ ] Option B : activer Active Response Wazuh pour blocage auto
- [ ] Isoler le host si compromis (déconnecter du réseau)
- [ ] Préserver les preuves avant toute action destructrice

---

## Phase 4 — Investigation approfondie

- [ ] Lire les logs complets de la période d'attaque
- [ ] Chercher des IoC : IPs, usernames, commandes exécutées
- [ ] Vérifier les connexions SSH réussies après les tentatives
- [ ] Vérifier les processus lancés (`ps aux`, `last`, `who`)
- [ ] Vérifier les modifications de fichiers (alertes FIM)
- [ ] Chercher des backdoors : cron, nouveaux users, SUID

---

## Phase 5 — Eradication & Remédiation

- [ ] Supprimer les accès malveillants (user, clé SSH)
- [ ] Patcher la vulnérabilité exploitée si identifiée
- [ ] Changer les credentials compromis
- [ ] Vérifier l'intégrité du système (FIM, rootcheck)
- [ ] Mettre à jour les règles Wazuh pour mieux détecter dans le futur

---

## Phase 6 — Documentation (Post-mortem)

- [ ] Remplir le template de rapport d'incident
- [ ] Timeline complète de l'attaque
- [ ] Actions prises et leur efficacité
- [ ] Améliorations à apporter au SOC
- [ ] Mettre à jour le playbook correspondant

---

## Template rapport d'incident

```
# Rapport d'Incident — [DATE]

## Résumé
**Type** : 
**Sévérité** : 
**Durée** : de [HH:MM] à [HH:MM]
**Status** : Résolu / En cours

## Timeline
| Heure | Événement |
|-------|-----------|
|       |           |

## Indicateurs de Compromission (IoC)
- IPs : 
- Users : 
- Fichiers : 

## Actions prises
1. 
2. 

## Cause racine
[À documenter]

## Améliorations SOC
- Règle à créer/modifier : 
- Playbook à mettre à jour : 
- Config à renforcer : 
```
