# Niveau 4 — SOC Automation & Threat Intelligence

> **Difficulté** : Expert  
> **Durée estimée** : 8 à 12 heures  
> **Prérequis** : Niveau 3 validé

---

## Contexte scénaristique

Ton SOC détecte bien. Maintenant l'objectif : **répondre plus vite que l'attaquant**.  
Tu passes de l'analyse manuelle à un **SOC automatisé** : chaque menace connue déclenche une réponse automatique, tracée, et réversible.

Parallèlement, tu intègres de la **Threat Intelligence** externe pour enrichir tes alertes.

---

## Objectifs pédagogiques

1. **Configurer** l'Active Response Wazuh end-to-end
2. **Écrire** des scripts de réponse automatique personnalisés
3. **Intégrer** une source de Threat Intelligence (listes noires IP)
4. **Simuler** un incident complet avec réponse automatisée
5. **Mesurer** le MTTD et MTTR avant/après automatisation
6. **Produire** un rapport de maturité SOC

---

## Les attaques simulées

| ID | Type | Script | Objectif |
|----|------|--------|----------|
| L4-01 | Attaque combinée niveau 1+2 | `attacks/01-combined-attack.sh` | Tester la réponse auto niveau 1+2 |
| L4-02 | Exfiltration rapide | `attacks/02-fast-exfil.sh` | Tester la vitesse de réponse |
| L4-03 | Simulation red team complète | `attacks/03-full-redteam.sh` | Validation finale du SOC |

---

## Missions à accomplir

### Mission 1 — Active Response opérationnel
- [ ] Blocage IP automatique sur brute force SSH (< 30 secondes)
- [ ] Quarantaine automatique sur détection persistance
- [ ] Notification automatique (webhook/email) sur niveau >= 10
- [ ] Voir `core/automation/README.md` pour l'implémentation

### Mission 2 — Threat Intelligence
- [ ] Intégrer une CDB List avec des IPs malveillantes connues
- [ ] Créer une règle qui élève le niveau d'alerte si l'IP est dans la liste
- [ ] Mettre à jour la liste automatiquement

### Mission 3 — Métriques SOC
- [ ] Calculer ton MTTD pour chaque type d'attaque
- [ ] Calculer ton MTTR avec et sans automation
- [ ] Objectif : MTTD < 2 min, MTTR < 5 min avec automation

### Mission 4 — Validation finale
- [ ] Lancer `attacks/03-full-redteam.sh` sans regarder ce qu'il fait
- [ ] Détecter et répondre à toutes les menaces en < 15 minutes
- [ ] Rapport d'incident complet post-exercice
