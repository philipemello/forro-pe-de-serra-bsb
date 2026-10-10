-- Forró Pé de Serra BSB — esquema do Supabase (pode rodar mais de uma vez)

-- 1) Administradores autorizados
create table if not exists public.admins (
  user_id uuid primary key references auth.users(id) on delete cascade,
  email text
);
alter table public.admins enable row level security;

create or replace function public.is_admin() returns boolean
language sql stable security definer set search_path = public as $$
  select exists (select 1 from public.admins where user_id = auth.uid());
$$;
revoke all on function public.is_admin() from public;
grant execute on function public.is_admin() to anon, authenticated;

drop policy if exists "admin vê a própria linha" on public.admins;
create policy "admin vê a própria linha" on public.admins
  for select to authenticated using (user_id = auth.uid());

-- 2) Tabelas de conteúdo
create table if not exists public.site_settings (
  id int primary key check (id = 1),
  data jsonb not null default '{}'::jsonb,
  updated_at timestamptz not null default now()
);
create table if not exists public.about_gallery (
  id uuid primary key default gen_random_uuid(),
  src text not null default '',
  alt_text text not null default '',
  caption text not null default '',
  position int not null default 0,
  published boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
create table if not exists public.event_posters (
  id uuid primary key default gen_random_uuid(),
  src text not null default '',
  title text not null default '',
  alt_text text not null default '',
  caption text not null default '',
  position int not null default 0,
  published boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

alter table public.site_settings enable row level security;
alter table public.about_gallery enable row level security;
alter table public.event_posters enable row level security;

-- 3) Políticas: leitura pública só do que está publicado; escrita só de admin
drop policy if exists "leitura pública" on public.site_settings;
create policy "leitura pública" on public.site_settings for select to anon, authenticated using (true);
drop policy if exists "admin insere" on public.site_settings;
create policy "admin insere" on public.site_settings for insert to authenticated with check (public.is_admin());
drop policy if exists "admin atualiza" on public.site_settings;
create policy "admin atualiza" on public.site_settings for update to authenticated using (public.is_admin()) with check (public.is_admin());

drop policy if exists "leitura publicados" on public.about_gallery;
create policy "leitura publicados" on public.about_gallery for select to anon, authenticated using (published or public.is_admin());
drop policy if exists "admin insere" on public.about_gallery;
create policy "admin insere" on public.about_gallery for insert to authenticated with check (public.is_admin());
drop policy if exists "admin atualiza" on public.about_gallery;
create policy "admin atualiza" on public.about_gallery for update to authenticated using (public.is_admin()) with check (public.is_admin());
drop policy if exists "admin exclui" on public.about_gallery;
create policy "admin exclui" on public.about_gallery for delete to authenticated using (public.is_admin());

drop policy if exists "leitura publicados" on public.event_posters;
create policy "leitura publicados" on public.event_posters for select to anon, authenticated using (published or public.is_admin());
drop policy if exists "admin insere" on public.event_posters;
create policy "admin insere" on public.event_posters for insert to authenticated with check (public.is_admin());
drop policy if exists "admin atualiza" on public.event_posters;
create policy "admin atualiza" on public.event_posters for update to authenticated using (public.is_admin()) with check (public.is_admin());
drop policy if exists "admin exclui" on public.event_posters;
create policy "admin exclui" on public.event_posters for delete to authenticated using (public.is_admin());

-- 4) Conteúdo inicial (sem datas, locais ou chave Pix inventados)
insert into public.site_settings (id, data) values (1, '{
  "settings": {
    "lema": "",
    "aboutHtml": "<p>Edite este texto no painel administrativo.</p>",
    "eventHtml": "<p>Edite este texto no painel administrativo.</p>",
    "contribHtml": "<p>A contribuição é voluntária e não é necessária para participar do evento.</p>",
    "pixLabel": "Contribuir via Pix", "pixEnabled": true,
    "igUrl": "https://www.instagram.com/forropedeserrabsb/", "igLabel": "Siga no Instagram", "igEnabled": true
  }
}'::jsonb) on conflict (id) do nothing;

-- 5) Armazenamento de imagens (bucket público para leitura; escrita só de admin)
insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values ('media', 'media', true, 10485760, array['image/jpeg','image/png','image/webp','image/avif'])
on conflict (id) do update set public = true, file_size_limit = 10485760,
  allowed_mime_types = array['image/jpeg','image/png','image/webp','image/avif'];

drop policy if exists "media leitura" on storage.objects;
create policy "media leitura" on storage.objects for select to anon, authenticated using (bucket_id = 'media');
drop policy if exists "media admin insere" on storage.objects;
create policy "media admin insere" on storage.objects for insert to authenticated with check (bucket_id = 'media' and public.is_admin());
drop policy if exists "media admin atualiza" on storage.objects;
create policy "media admin atualiza" on storage.objects for update to authenticated using (bucket_id = 'media' and public.is_admin());
drop policy if exists "media admin exclui" on storage.objects;
create policy "media admin exclui" on storage.objects for delete to authenticated using (bucket_id = 'media' and public.is_admin());
