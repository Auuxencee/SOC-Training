# Incident Response — Programme de Réponse aux Incidents

## Objectif

Ce dossier contient les **procédures de réponse aux incidents** de ton SOC. Ils sont volontairement incomplets au départ — tu les complètes au fil des exercices.

---

## Structure

```
incident-response/
├── README.md          ← Ce fichier
├── ir-checklist.md    ← Checklist générale d'investigation
└── playbooks/
    ├── 00-template.md      ← Template à copier pour nouveau playbook
    ├── 01-brute-force.md   ← Réponse brute force SSH (à compléter)
    └── 02-malware.md       ← Réponse malware (à compléter)
```

---

## Comment utiliser les playbooks

1. **Pendant l'exercice** : ouvre le playbook correspondant au type d'attaque simulée
2. **Suis les étapes** dans l'ordre — chaque étape a une case à cocher
3. **Documente tes observations** dans les zones prévues
4. **Après l'exercice** : complète les sections vides du playbook avec ce que tu as appris

---

## Principe des playbooks incomplets

Les playbooks ont des sections **à toi de remplir** notées `[À COMPLÉTER]`.

Ce n'est pas un oubli — c'est **pédagogique** :
- Au Niveau 1, tu remplis les étapes basiques après les avoir découvertes
- Au Niveau 2, tu affines avec des techniques plus avancées
- Au Niveau 3, tu construis des playbooks pour des attaques que tu n'as jamais vues

C'est ainsi qu'un vrai analyste SOC construit sa documentation.

---

## Escalade

| Sévérité | Délai de réponse | Action |
|----------|-----------------|--------|
| Niveau < 7 | Pas d'urgence | Logger, surveiller |
| Niveau 7-9 | Dans l'heure | Investiguer, documenter |
| Niveau 10-11 | Dans les 15 min | Contenir, escalader |
| Niveau >= 12 | Immédiat | Incident majeur — tout stopper |
