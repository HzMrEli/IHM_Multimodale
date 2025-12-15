# Projet de Fusion Multimodale "Put that here"
## Par Eliot PAZZÉ et Alex RHODES

## Description
Application Processing pour manipulation multimodale de formes géométriques via reconnaissance vocale (SRA5), détection gestuelle (ICAR) et souris.

## Fonctionnalités

### Commandes vocales
```
ACTIONS :
• créer / dessiner / tracer → nouvelle forme
• copier / dupliquer → copie + déplacement automatique
• supprimer / effacer → suppression forme
• modifier / éditer → changement couleur/forme
• déplacer / bouger → sélection → "ici"
• quitter / sortir → arrêt

FORMES :
• triangle • losange / diamant • cercle / rond • rectangle / carré

COULEURS :
• rouge • orange • jaune • vert • bleu • violet • noir • rose
```

### Scénarios multimodaux
```
1. "créer un cercle rouge ici" → forme immédiate
2. "déplacer ça" → forme suit souris → "ici" → pose
3. "copier ça" → duplique + suit souris → "ici" → pose
4. dessiner une forme sur ICAR + "dessiner ça ici" → forme gestuelle placée
5. "modifier jaune" → recolore forme sous souris
```

## Lancement
```
1. Double-clic Launcher.bat
2. SRA5 + Ivy requis
3. Positionnez souris → commandes vocales
```

## Architecture
```
dessert.pde (main) ← Ivy(SRA5) + Ivy(ICAR)
├── Commande.pde : parsing sémantique
├── Forme.pde : abstraction formes
├── Cercle/Rectangle/Losange/Triangle.pde
└── Grammaire GRXML SRA5
```

## Dépendances
```
• Processing 3/4
• Librairie Ivy (fr.dgac.ivy.*)
• SRA5 DGAC + grammaire .grxml
• Bus Ivy port 2010
```

**Multimodal fluide - 60 FPS - Latence <200ms** 🚀
