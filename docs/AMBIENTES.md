# Ambientes

Todo projeto da Septa roda em 3 lugares:

| Ambiente | Para quê | Quem usa |
|---|---|---|
| **Local** | programar e testar à vontade | o dev |
| **Teste** | conferir antes de publicar, mostrar ao cliente | time e cliente |
| **Produção** | o que está no ar de verdade | cliente e usuários dele |

### E os nomes que aparecem por aí?

| Nome comum | Na Septa |
|---|---|
| LOCAL | **Local** |
| DEV (compartilhado) | **Teste**: com uma branch por tarefa e PR pequeno, o código junta na `main` várias vezes por dia |
| TEST / QA | a **checagem automática** de todo PR + os 5 minutos tentando quebrar na revisão + o **Teste** |
| HOMOLOG | **Teste**: nos sites, o link de prévia do PR, que o cliente aprova; nos sistemas, `teste-<cliente>` |
| PROD | **Produção** |

**Por que só 3:** cada ambiente a mais é mais um servidor para pagar, atualizar e proteger, e o mesmo time testaria tudo de novo em cada um. Faz sentido em empresa com time de QA separado. Se um cliente exigir homologação própria, cria-se uma, com ADR.

### CI e CD
- **CI (integração contínua):** a checagem de todo PR (Padrão do time + Site ou Sistema). Ficou vermelho, não junta.
- **Sites:** *Continuous Deployment*. Entrou na `main`, vai para o ar sozinho.
- **Sistemas:** *Continuous Delivery*. Entrou na `main`, vai sozinho para o **Teste**; a **Produção** só sobe pelo botão do Tech lead.

## Sites (Astro + Vercel)

| | Local | Teste (prévia) | Produção |
|---|---|---|---|
| Onde roda | PC do dev | Vercel | Vercel |
| Endereço | `localhost:4321` | link automático por PR | domínio do site (ex.: `septasystems.com.br`) |
| Como sobe | `npm run dev` | sozinho ao abrir/atualizar o PR | sozinho quando o PR entra na `main` |
| Quem vê | o dev | time e cliente (pelo link) | todo mundo |
| Banco de dados | não tem | não tem | não tem |
| Senhas e chaves | `.env` no PC | painel do Vercel (Preview) | painel do Vercel (Production) |
| Custo | grátis | grátis | grátis + domínio (~R$ 40/ano) |

Formulário de contato: a chave do serviço de e-mail fica no painel do Vercel. Em teste envia para o e-mail do time; em produção, para o cliente.

## Sistemas (Django + PostgreSQL + Docker)

| | Local | Teste | Produção |
|---|---|---|---|
| Onde roda | PC do dev, com Docker | servidor (Railway ou Render) | servidor (Railway ou Render) |
| Endereço | `localhost:8000` | `teste-<cliente>.septasystems.com.br` | domínio do cliente |
| Como sobe | `docker compose up` | sozinho quando o PR entra na `main` | **só pelo botão do Tech lead** (GitHub Actions) |
| Quem vê | o dev | time e cliente, com login | cliente e usuários dele |
| Banco | PostgreSQL no Docker | PostgreSQL próprio de teste | PostgreSQL próprio, **backup diário** |
| Dados | falsos (comando `seed`) | falsos (mesmo `seed`) | **reais, só aqui** |
| E-mail / WhatsApp | não envia, só mostra no terminal | envia só para contatos do time | envia de verdade |
| Erros | na tela (`DEBUG=True`) | Sentry | Sentry, com aviso no grupo |
| Senhas e chaves | `.env` no PC (cópia do `.env.example`) | painel do servidor | painel do servidor, **diferentes das de teste** |
| Custo | grátis | ~US$ 5/mês | ~US$ 5–20/mês, entra na mensalidade do cliente |

## Regras para todos

1. **Dado real só em produção.** Local e teste usam o `seed`. Nunca copiar o banco de produção para o PC (LGPD).
2. **Chaves diferentes em cada ambiente.** Se a de teste vazar, a produção não é afetada.
3. **No código só vai o `.env.example`**: nomes das variáveis, sem valores. A checagem "Padrão do time" barra `.env`.
4. **Banco de produção com backup diário**, e um teste de restauração por mês.
5. **Erro em produção vira issue de Bug.** Urgente → `hotfix/`.
6. **Painel de produção:** só o Tech lead e o dev responsável pelo cliente, com verificação em 2 etapas.
7. `DEBUG=False` em teste e produção, sempre.

## Se uma atualização quebrar a produção (rollback)

**Primeiro volta, depois investiga.** O cliente não espera a gente achar o bug.

1. **Voltar para a versão anterior:**
   - **Site:** no Vercel, abra *Deployments*, escolha o último que funcionava e clique em **Instant Rollback**. Leva segundos.
   - **Sistema:** suba de novo a versão anterior pelo mesmo botão de deploy, escolhendo o commit anterior, ou use o **Rollback** no painel do Railway/Render. O deploy de produção é montado com o 1º cliente, e já deve nascer aceitando a escolha da versão.
2. **Avisar** no grupo Código o que caiu e que já voltou.
3. **Corrigir com calma:** issue de Bug, `git revert` do PR que quebrou (em `hotfix/`), ou a correção com o teste que pegaria o erro. Só depois disso sobe de novo.
4. **Dado estragado** (a atualização gravou errado): restaure o backup, com o Tech lead, e siga o `docs/SEGURANCA.md` seção 7 se envolver dado pessoal.

**O que permite voltar sem quebrar o banco:** migration em 2 passos (`docs/PADROES.md` seção 5). Se uma versão apaga uma coluna junto com o código que a usa, a versão anterior não roda mais e o rollback falha.

## O que todo projeto precisa ter

- [ ] `.env.example`
- [ ] `docker-compose.yml` (sistemas)
- [ ] comando `seed` com dados falsos (sistemas)
- [ ] README com "como rodar no PC"

Esses itens vêm prontos nos projetos-base.
