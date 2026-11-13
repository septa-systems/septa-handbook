# Repo novo

Todo projeto de cliente nasce de um dos modelos:

| Tipo | Modelo | Para quê |
|---|---|---|
| `site` | [modelo-site](https://github.com/septa-systems/modelo-site) | Site, landing page, cardápio (Astro + Cloudflare) |
| `sistema` | [modelo-sistema](https://github.com/septa-systems/modelo-sistema) | Sistema com login e banco (Django + PostgreSQL) |

Quando um repo é criado a partir de um modelo, o GitHub copia **só o código**. A configuração fica para trás. Por isso existe o `scripts/novo-repo.sh`.

## Como criar

Só o Tech lead (admin da org) roda o script. Os membros não conseguem criar repositório: é de propósito, para todo projeto nascer com a mesma configuração. Precisa de um projeto novo? Peça no quadro.

```bash
# 1. ver o que vai acontecer, sem mudar nada
scripts/novo-repo.sh site-padaria-joao site --simular

# 2. criar de verdade
scripts/novo-repo.sh site-padaria-joao site

# 3. baixar e seguir o README do projeto
gh repo clone septa-systems/site-padaria-joao
```

**Nome do repo:** tudo minúsculo, sem acento, com hífen, começando pelo tipo: `site-padaria-joao`, `sistema-agenda-barbearia-ze`.

## O que o script configura

1. **Cria** o repo a partir do modelo. Por padrão ele é **privado**, porque projeto de cliente é privado (ver DECISOES).
2. **Merge:** só "Squash and merge", e a branch é apagada depois.
3. **Segurança:** liga os alertas e as correções do Dependabot. No repo público, também liga a busca de senhas no código e o bloqueio de push com senha.
4. **Proteção da `main`** (só repo público; no privado, no plano grátis, vale a Regra nº 1 do `CLAUDE.md`): a mesma regra dos modelos, com PR obrigatório, aprovação do Tech lead, conversas resolvidas e as checagens "Padrão do time" + "Site" ou "Sistema". O admin pode passar por cima.
5. **Quadro:** liga o repo ao quadro [Desenvolvimento](https://github.com/orgs/septa-systems/projects/1).
6. **Time:** dá **Write** para o time `socios` no repo. Sem isso, num repo privado os sócios só conseguem ler e não abrem PR.

O `dependabot.yml`, as checagens e o `CLAUDE.md` vêm no código do modelo.

## Outras opções

| Opção | O que faz |
|---|---|
| `--simular` | Mostra os comandos sem rodar |
| `--publico` | Repo público. Só para coisas da Septa (site da empresa, manual, modelos). É o único jeito de ter a proteção da `main` no plano grátis |
| `--so-config` | Não cria nada, só (re)aplica a configuração num repo que já existe. Pode rodar quantas vezes quiser, porque não duplica a regra |

## Se der erro

- **"A main não apareceu"**: o GitHub demorou para copiar o modelo. Espere 1 minuto e rode de novo com `--so-config`.
- **Erro 403 ou "Resource not accessible"**: você não é admin da org, ou falta escopo no `gh`. Rode `gh auth refresh -s project,workflow,admin:org`.
- **Checagem não aparece no PR**: o nome da checagem no workflow mudou. Ele tem que ser igual ao que está no script.

## Mudou a regra?

Se a proteção da `main` mudar, atualize o script **e** rode `--so-config` em todos os repos, para nenhum ficar com a regra antiga.
