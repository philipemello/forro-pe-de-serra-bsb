# Forró Pé de Serra BSB

Hotsite do evento, com painel administrativo (Fase 1: dados mockados).

- Site público: `/`
- Painel (demo): `/#/admin`
- Instagram: https://www.instagram.com/forropedeserrabsb/

## Como funciona agora
Site estático (um único `index.html`). A Vercel publica automaticamente a cada commit na branch `main`.
Os dados ainda são demonstrativos e as edições do painel ficam só na memória da página.

## Próximas fases
- Supabase (banco, storage, autenticação, RLS)
- Migração para projeto com build (Next.js), mantendo a camada de dados `MockSource` -> `SupabaseSource`

## Segredos
Nunca coloque chaves no repositório. Use `.env.example` como modelo e configure as variáveis na Vercel.
