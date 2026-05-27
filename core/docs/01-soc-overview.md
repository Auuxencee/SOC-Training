# Qu'est-ce qu'un SOC ?

## Définition

Un **Security Operations Center (SOC)** est une équipe (ou une infrastructure) dédiée à la surveillance continue, à la détection et à la réponse aux incidents de sécurité informatique.

Dans ce projet, tu es à la fois **l'analyste SOC** et **l'architecte** : tu construis l'infrastructure ET tu analyses les menaces.

---

## Les 3 fonctions fondamentales d'un SOC

### 1. Surveiller (Monitor)
- Collecter les logs de tous les systèmes
- Ingérer et corréler les événements en temps réel
- Maintenir une visibilité sur l'ensemble du périmètre

### 2. Détecter (Detect)
- Identifier des comportements anormaux ou malveillants
- Corréler plusieurs événements faibles en signal fort
- Distinguer les faux positifs des vraies menaces

### 3. Répondre (Respond)
- Qualifier l'incident (Vrai positif / Faux positif ?)
- Contenir la menace (bloquer une IP, isoler un host)
- Eradiquer et remédier (supprimer le malware, patcher)
- Documenter et apprendre (post-mortem)

---

## Le cycle PICERL

La réponse aux incidents suit le modèle **PICERL** :

```
P → Préparation       : outils, playbooks, formation en place
I → Identification    : détecter et qualifier l'incident
C → Confinement       : limiter la propagation
E → Eradication       : supprimer la cause racine
R → Restauration      : remettre en service proprement
L → Leçons apprises   : améliorer les défenses
```

---

## Types d'analystes SOC

| Niveau | Rôle | Responsabilités |
|--------|------|-----------------|
| **Tier 1** | Analyste junior | Triage des alertes, escalade |
| **Tier 2** | Analyste senior | Investigation approfondie, IR |
| **Tier 3** | Expert / Threat Hunter | Chasse aux menaces, forensics |

Dans ce projet, tu monteras progressivement du Tier 1 au Tier 3.

---

## Métriques clés d'un SOC

- **MTTD** (Mean Time To Detect) : temps entre l'attaque et la détection
- **MTTR** (Mean Time To Respond) : temps entre la détection et la résolution
- **False Positive Rate** : % d'alertes qui ne sont pas de vraies menaces

> **Objectif de ce projet** : réduire ton MTTD et MTTR à chaque niveau.

---

## Ce que tu vas apprendre ici

| Compétence | Comment |
|------------|---------|
| Lire des logs système | Exercices pratiques par niveau |
| Identifier une attaque | Simulations réelles |
| Ecrire des règles de détection | Wazuh `local_rules.xml` |
| Répondre à un incident | Playbooks à compléter |
| Automatiser les défenses | Active Response Wazuh |
