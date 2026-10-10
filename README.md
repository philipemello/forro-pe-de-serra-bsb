# Forró Pé de Serra BSB

Hotsite com painel administrativo. Site estático (sem build) + Supabase (banco, arquivos e login). Publicado na Vercel a partir do GitHub.

- Site: `/`  ·  Painel: `/admin` (ou `/#/admin`)
- Sem `config.js` preenchido, o site roda em **modo demonstração** (dados fictícios, nada é salvo).

## Arquivos
- `index.html` — site público e painel
- `config.js` — URL e chave **anon** do Supabase (públicas; segurança vem do RLS)
- `supabase/schema.sql` — tabelas, políticas RLS e bucket de imagens
- `vercel.json` — redireciona `/admin` para o painel

## Configurar o Supabase (uma vez)
1. Em supabase.com, crie um projeto (região South America, São Paulo).
2. **SQL Editor** → cole o conteúdo de `supabase/schema.sql` → **Run**.
3. **Authentication → Users → Add user**: informe e-mail e senha do administrador (marque confirmar e-mail automaticamente).
4. No **SQL Editor**, autorize esse usuário (troque o e-mail):
   ```sql
   insert into public.admins (user_id, email)
   select id, email from auth.users where email = 'SEU_EMAIL@exemplo.com';
   ```
5. **Authentication → Sign In / Providers**: desative o cadastro público de novos usuários ("Allow new users to sign up").
6. **Authentication → URL Configuration**: em Site URL, coloque o endereço da Vercel.
7. **Project Settings → API**: copie a **Project URL** e a chave **anon public**. Edite `config.js` com esses dois valores. Nunca use a `service_role`.
8. Suba o `config.js` atualizado no GitHub. A Vercel publica sozinha.

## Segurança
- Leitura pública só do conteúdo publicado; escrita e upload só para quem está na tabela `admins` (RLS e políticas do Storage).
- Imagens: JPEG, PNG, WebP ou AVIF, até 10 MB (o limite também vale no bucket).
- Textos formatados são filtrados antes de aparecer no site.

## Pendências conhecidas
- Upload de vídeos (MP4/WebM) ainda não implementado.
- Recuperação de senha pelo painel: por enquanto, pelo painel do Supabase (Authentication → Users).
- Sitemap, robots.txt, imagem Open Graph e favicon próprios.
- Barra de progresso real no upload (hoje mostra "Enviando imagem...").
