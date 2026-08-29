# Roman-Sadcifer

Site type "forum" où **toi seul** publie, et où le monde peut seulement
réagir avec 9 émojis (une fois approuvé). Fond noir, texte blanc, accents
rouge sang.

## Structure des fichiers

```
index.html                  <- le site au complet (HTML/CSS/JS, vanilla)
supabase_schema.sql          <- à rouler dans Supabase
assets/img/logo.png          <- logo "Roman-Sadcifer" (police Sabersong)
assets/img/favicon.png/.ico  <- favicon "RS" (+ tailles multiples)
assets/img/{tes-images}.png  <- DÉPOSE ICI tes images pour les publications
assets/emojis/*.png          <- les 9 réactions (version noire + blanche)
assets/song/{1-24}.mp3       <- DÉPOSE ICI tes 24 chansons (voir plus bas)
```

## Installation (5 étapes)

### 1. Crée un projet Supabase
Va sur [supabase.com](https://supabase.com), crée un nouveau projet gratuit.

### 2. Roule le schéma SQL
Dashboard Supabase → **SQL Editor** → colle le contenu de `supabase_schema.sql`
→ Run. Ça crée les tables `profiles`, `posts`, `reactions` avec toute la
sécurité (RLS) : seul l'admin publie, seuls les gens approuvés réagissent.

### 3. Désactive la confirmation par courriel (recommandé)
Dashboard → **Authentication → Providers → Email** → décoche
"Confirm email". Sinon les gens doivent cliquer un lien de courriel avant
que leur compte fonctionne.

### 4. Branche tes clés dans `index.html`
Dashboard → **Project Settings → API**. Copie :
- `Project URL` → remplace `SUPABASE_URL` en haut du `<script>` dans `index.html`
- `anon public key` → remplace `SUPABASE_ANON_KEY`

### 5. Deviens admin
- Inscris-toi une première fois sur ton propre site (bouton "Faire une demande").
- Dashboard Supabase → **Table Editor → profiles** → trouve ta ligne
  → change `status` à `approved` et `is_admin` à `true`.
- (Ou via SQL Editor, voir le commentaire à la fin de `supabase_schema.sql`.)
- Recharge le site connecté avec ce compte : le panneau de publication
  et le bouton "Demandes" apparaissent.

## Ajouter des images à tes publications

1. Mets ton fichier image dans `assets/img/` (ex: `assets/img/photo1.jpg`).
2. Dans le panneau de publication, écris exactement `photo1.jpg` dans le
   champ image.
3. Publie : le site va chercher le fichier directement dans `assets/img/`
   (pas besoin de Supabase Storage).

## Approuver / refuser une inscription

Une fois connecté comme admin, clique **"Demandes"** en haut à droite :
liste des comptes en attente avec boutons Approuver / Refuser.

## Personnaliser tes publications

Dans le panneau de publication (visible seulement pour toi, l'admin) :
- Police (Metal Mania, Eater, Nosifer, Creepster, ou polices classiques)
- Taille du texte
- Gras / Italique
- Image (nom du fichier dans `assets/img/`)

## Musique (24 pistes aléatoires)

Le site a un lecteur audio flottant en bas à droite (bouton play, piste
suivante, volume). Dépose tes 24 fichiers dans `assets/song/` et nomme-les
exactement :

```
assets/song/1.mp3
assets/song/2.mp3
...
assets/song/24.mp3
```

Le lecteur pige les 24 numéros dans un ordre aléatoire (mélangé), joue une
chanson à la fois, et passe automatiquement à la suivante à la fin — sans
jamais répéter avant d'avoir fait le tour des 24. Comme les navigateurs
bloquent la lecture automatique du son, la musique démarre seulement quand
quelqu'un clique le bouton ▶ la première fois (c'est normal, c'est une
règle des navigateurs, pas un bug).

Si un des 24 fichiers manque sur le serveur, le lecteur l'indique
("Fichier manquant") plutôt que de planter.

## Les 9 réactions

skull (mort), devil (démon), crying (larmes), brokenheart (coeur brisé),
flame (flamme), pentagram (pentagramme), ghost (fantôme), bat (chauve-souris),
tombstone (tombe). Icône blanche par défaut, devient un cercle blanc avec
icône noire quand quelqu'un a réagi.

## Hébergement

Ce site est 100% statique (aucun serveur nécessaire à part Supabase).
Tu peux l'héberger gratuitement sur **GitHub Pages**, **Netlify**, ou
**Vercel** — dépose juste tout le dossier tel quel.
