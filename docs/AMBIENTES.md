# Ambientes

Todo projeto da Septa roda em 3 lugares:

| Ambiente | Para quê | Quem usa |
|---|---|---|
| **Local** | programar e testar à vontade | o dev |
| **Teste** | conferir antes de publicar, mostrar ao cliente | time e cliente |
| **Produção** | o que está no ar de verdade | cliente e usuários dele |

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

## O que todo projeto precisa ter

- [ ] `.env.example`
- [ ] `docker-compose.yml` (sistemas)
- [ ] comando `seed` com dados falsos (sistemas)
- [ ] README com "como rodar no PC"

Esses itens vêm prontos nos projetos-base.
