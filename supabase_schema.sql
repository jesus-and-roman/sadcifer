-- =========================================================
-- ROMAN-SADCIFER — Schéma Supabase
-- À exécuter dans : Supabase Dashboard > SQL Editor > New query
-- =========================================================

-- Extension pour uuid
create extension if not exists "pgcrypto";

-- ---------------------------------------------------------
-- TABLE: profiles
-- Un profil par utilisateur inscrit. Créé en 'pending' tant
-- que l'admin (toi) ne l'approuve pas.
-- ---------------------------------------------------------
create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  username text unique not null,
  status text not null default 'pending' check (status in ('pending','approved','rejected')),
  is_admin boolean not null default false,
  created_at timestamptz not null default now()
);

alter table public.profiles enable row level security;

-- fonction utilitaire (security definer = pas de récursion RLS)
create or replace function public.is_admin()
returns boolean
language sql
security definer
stable
as $$
  select coalesce((select is_admin from public.profiles where id = auth.uid()), false);
$$;

create or replace function public.is_approved()
returns boolean
language sql
security definer
stable
as $$
  select coalesce((select status = 'approved' from public.profiles where id = auth.uid()), false);
$$;

-- Lecture : chacun voit son propre profil ; les profils approuvés sont visibles
-- de tous (pour afficher le nom d'utilisateur qui réagit) ; l'admin voit tout.
create policy "profiles_select_own" on public.profiles
  for select using (auth.uid() = id);

create policy "profiles_select_approved" on public.profiles
  for select using (status = 'approved');

create policy "profiles_select_admin" on public.profiles
  for select using (public.is_admin());

-- Création : un utilisateur ne peut créer que SON propre profil, en 'pending',
-- jamais admin.
create policy "profiles_insert_self" on public.profiles
  for insert with check (
    auth.uid() = id
    and status = 'pending'
    and is_admin = false
  );

-- Mise à jour : seul l'admin peut changer le statut (approuver/refuser) ou le flag admin.
create policy "profiles_update_admin_only" on public.profiles
  for update using (public.is_admin()) with check (public.is_admin());

-- ---------------------------------------------------------
-- TABLE: posts
-- Seul l'admin (toi) peut publier / modifier / supprimer.
-- image_name = nom de fichier dans assets/img/{image_name}
-- ---------------------------------------------------------
create table if not exists public.posts (
  id uuid primary key default gen_random_uuid(),
  author_id uuid not null references public.profiles(id),
  content text not null default '',
  font_family text not null default 'inherit',
  font_size int not null default 16,
  bold boolean not null default false,
  italic boolean not null default false,
  image_name text,
  created_at timestamptz not null default now(),
  updated_at timestamptz
);

alter table public.posts enable row level security;

-- Tout le monde (même visiteurs non connectés) peut lire le mur.
create policy "posts_select_all" on public.posts
  for select using (true);

create policy "posts_insert_admin_only" on public.posts
  for insert with check (public.is_admin());

create policy "posts_update_admin_only" on public.posts
  for update using (public.is_admin()) with check (public.is_admin());

create policy "posts_delete_admin_only" on public.posts
  for delete using (public.is_admin());

-- ---------------------------------------------------------
-- TABLE: reactions
-- 9 émojis possibles. Un utilisateur approuvé peut réagir
-- (une fois par type d'émoji par post), et retirer sa réaction.
-- ---------------------------------------------------------
create table if not exists public.reactions (
  id uuid primary key default gen_random_uuid(),
  post_id uuid not null references public.posts(id) on delete cascade,
  user_id uuid not null references public.profiles(id) on delete cascade,
  emoji_type text not null check (emoji_type in (
    'skull','devil','crying','brokenheart','flame',
    'pentagram','ghost','bat','tombstone'
  )),
  created_at timestamptz not null default now(),
  unique (post_id, user_id, emoji_type)
);

alter table public.reactions enable row level security;

-- Les compteurs de réactions sont publics.
create policy "reactions_select_all" on public.reactions
  for select using (true);

-- Seul un utilisateur approuvé peut ajouter une réaction, et seulement en son nom.
create policy "reactions_insert_approved" on public.reactions
  for insert with check (
    auth.uid() = user_id
    and public.is_approved()
  );

-- Un utilisateur peut retirer sa propre réaction.
create policy "reactions_delete_own" on public.reactions
  for delete using (auth.uid() = user_id);

-- =========================================================
-- APRÈS AVOIR EXÉCUTÉ CE SCRIPT :
--
-- 1. Va dans Authentication > Users, crée TON compte (ou inscris-toi
--    depuis le site), puis note ton UUID.
-- 2. Roule cette commande en remplaçant TON_UUID et TON_USERNAME
--    pour te transformer en admin approuvé :
--
--    insert into public.profiles (id, username, status, is_admin)
--    values ('TON_UUID', 'TON_USERNAME', 'approved', true)
--    on conflict (id) do update set status = 'approved', is_admin = true;
--
-- 3. Tous les autres utilisateurs qui s'inscrivent tombent en
--    status='pending' automatiquement — tu les approuves depuis
--    le panneau admin du site (ou directement en SQL).
-- =========================================================
