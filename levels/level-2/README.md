# Niveau 2 — Persistance & Escalade de Privilèges

> **Difficulté** : Intermédiaire  
> **Durée estimée** : 3 à 5 heures  
> **Prérequis** : Niveau 1 validé (score >= 80/100)

---

## Contexte scénaristique

L'attaquant a obtenu un accès initial (via le brute force SSH du niveau 1).  
Il est maintenant **à l'intérieur** du système. Son objectif : **rester** et **élargir** ses accès.

Tu joues un rôle de Tier 2 : l'alerte initiale a été escaladée, tu dois comprendre l'étendue de la compromission.

---

## Objectifs pédagogiques

1. **Détecter** un mécanisme de persistance (cron malveillant)
2. **Détecter** une escalade de privilèges via SUID
3. **Détecter** la création d'un compte backdoor
4. **Détecter** une tentative d'effacement de logs
5. **Corréler** plusieurs alertes en un incident unique cohérent
6. **Configurer** ta première règle d'Active Response automatique

---

## Les attaques simulées

| ID | Type | Script | MITRE | Complexité |
|----|------|--------|-------|------------|
| L2-01 | Cron backdoor | `attacks/01-cron-backdoor.sh` | T1053.003 | Moyen |
| L2-02 | SUID abuse | `attacks/02-suid-abuse.sh` | T1548.001 | Moyen |
| L2-03 | Compte backdoor | `attacks/03-new-user-backdoor.sh` | T1136.001 | Moyen |
| L2-04 | Log tampering | `attacks/04-log-tampering.sh` | T1070.002 | Moyen |

---

## Déroulement recommandé

### Phase 1 — Détection manuelle
Lance les attaques **une par une** et cherche les alertes avant de passer à la suivante.

```bash
bash levels/level-2/attacks/01-cron-backdoor.sh
# → Observer, investiguer, documenter
bash levels/level-2/attacks/02-suid-abuse.sh
bash levels/level-2/attacks/03-new-user-backdoor.sh
bash levels/level-2/attacks/04-log-tampering.sh
```

### Phase 2 — Corrélation
Après toutes les attaques :
- Reconstitue la **kill chain complète** dans Threat Hunting
- Timeline : de l'accès initial (niveau 1) jusqu'à la persistance
- Quels sont les IoC communs entre les alertes ?

### Phase 3 — Réponse automatisée
- Lire `core/automation/README.md`
- Configurer l'Active Response Wazuh pour au moins une menace de ce niveau
- Vérifier que la réponse se déclenche automatiquement

---

## Missions à accomplir

### Mission 1 — Persistance via cron
- [ ] Détecter l'ajout d'un cron malveillant dans Wazuh
- [ ] Identifier la règle FIM déclenchée
- [ ] Trouver le fichier modifié et son contenu

### Mission 2 — Escalade SUID
- [ ] Détecter le chmod +s dans les alertes
- [ ] Comprendre pourquoi SUID est dangereux
- [ ] Identifier le binaire ciblé

### Mission 3 — Compte backdoor
- [ ] Détecter la création de compte dans Wazuh
- [ ] Trouver le nouveau user et ses groupes
- [ ] Vérifier s'il a été ajouté à sudo

### Mission 4 — Log tampering
- [ ] Détecter la tentative d'effacement de logs
- [ ] Comprendre l'implication SOC (qu'est-ce qu'on perd si les logs sont effacés ?)
- [ ] Identifier la règle Wazuh correspondante

### Mission 5 — Kill chain (obligatoire)
- [ ] Relier les 4 attaques en une timeline cohérente
- [ ] Remplir le playbook `core/incident-response/playbooks/03-persistence.md`
- [ ] Identifier les IoC de chaque étape

### Mission 6 — Active Response (bonus)
- [ ] Configurer un blocage IP automatique sur détection de persistance
- [ ] Tester et valider le déclenchement automatique
- [ ] Consulter `core/automation/README.md` pour le guide

---

## Indices (ne pas lire avant d'avoir cherché)

<details>
<summary>Indice Mission 1</summary>
Dans Wazuh, les modifications de cron sont détectées via FIM (File Integrity Monitoring).
Cherche des alertes de groupe `syscheck` ou `ossec` avec des chemins `/etc/cron*` ou `/var/spool/cron/`.
Rule IDs autour de 550-556.
</details>

<details>
<summary>Indice Mission 2</summary>
Les permissions SUID sont détectées par le rootcheck de Wazuh.
Cherche des alertes rule group `rootcheck` avec "SUID" dans la description.
Rule IDs autour de 510-516.
</details>

<details>
<summary>Indice Mission 3</summary>
La création d'utilisateurs génère des logs PAM/useradd.
Cherche rule.groups: `account_changed` ou `adduser`.
Rule IDs autour de 5901-5910.
</details>

<details>
<summary>Indice Mission 4</summary>
L'effacement de logs déclenche des règles Wazuh spécifiques.
Cherche rule.id 591 ou des alertes contenant "log" dans les groups.
</details>
