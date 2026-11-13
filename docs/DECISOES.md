# Decisões do time

Uma linha por decisão, a mais nova em cima. Antes de mudar algo que já foi decidido, leve para a reunião de quarta.

| Data | Decisão | Quem decidiu |
|---|---|---|
| 13/11/2026 | SaaS e sistemas em multi-tenancy (banco único com empresa_id); WhatsApp pela API oficial da Meta, aviso só como utilidade, franquia na mensalidade e excedente/marketing repassados | Tech lead |
| 13/11/2026 | Hospedagem: sites na Cloudflare (Vercel grátis proíbe uso comercial), 1º teste no site da Septa; sistemas no Railway até o 3º, VPS nosso a partir do 4º; domínio e e-mail no nome do cliente. Detalhes no docs/AMBIENTES.md | Tech lead |
| 13/11/2026 | Continuam 3 ambientes (Local, Teste, Produção); Teste faz o papel de DEV/QA/HOMOLOG. Rollback: primeiro volta, depois investiga (volta para a versão anterior no painel / deploy da versão anterior) | Tech lead |
| 13/11/2026 | Manual com o que veio das aulas: tabela do começo ao fim; C1/C2 com tipo e verbo, modelo de domínio em classDiagram, restrições, cenários de qualidade, ADR com o que sacrificamos; fila de saída + worker no lugar de Celery/Redis; regra de import entre apps; dinheiro em Decimal; testes de 404, clique duplo e limites; sessão do Django em vez de JWT; UX com heurísticas (/revisar-tela) e teste com 5 pessoas | Tech lead |
| 13/11/2026 | Repo novo só pelo `scripts/novo-repo.sh` (docs/NOVO-REPO.md): privado por padrão, nome `site-cliente` ou `sistema-cliente` | Tech lead |
| 11/11/2026 | Padrões de código (docs/PADROES.md): nomes do negócio em português sem acento, Django em inglês; Ruff + pre-commit; testes obrigatórios de regra, permissão e bug corrigido; sem meta de % de cobertura | Tech lead |
| 11/11/2026 | Segurança (docs/SEGURANCA.md): base OWASP Top 10 + ASVS nível 1 + LGPD; nunca dado real de cliente no Claude; Dependabot e secret scanning ligados | Tech lead |
| 11/11/2026 | Processo de arquitetura em 5 fases (docs/ARQUITETURA.md): sem PRD e arquitetura aprovados, não se programa. Fundamentos: C4, ADR, monólito primeiro, DDD leve, 12-Factor, SOLID, KISS/YAGNI, pirâmide de testes | Tech lead |
| 11/11/2026 | Ambientes: local, teste e produção (docs/AMBIENTES.md). Sistemas: produção só pelo botão do Tech lead; dado real só em produção | Tech lead |
| 11/11/2026 | Visibilidade: manual e site da Septa públicos (trava completa); projeto de cliente privado (vale a Regra nº 1 do CLAUDE.md + combinado do time) | Tech lead |
| 11/11/2026 | GitHub no plano grátis: repositório privado não tem trava da main, então a regra "nada na main sem aprovação do Tech lead" fica como Regra nº 1 do CLAUDE.md | Tech lead |
| 11/11/2026 | Branches: feature/, bugfix/, hotfix/, chore/ + nº da issue. Commits: Conventional Commits (feat, fix, docs, refactor, test, chore), descrição em português | Tech lead |
| 11/11/2026 | Fluxo do código: issue → branch → PR com modelo → teste automático → 1 aprovação → squash → deploy automático (docs/FLUXO.md) | Tech lead |
| 11/11/2026 | Tarefas de código no GitHub Projects; resto da empresa no Trello | Tech lead |
| 11/11/2026 | Stack: sites em Astro + Vercel (trocado por Cloudflare em 13/11); sistemas em Django + PostgreSQL + Docker (+ HTMX, Tailwind, pytest, Ruff) | Tech lead |
| __/__/2026 | Ferramentas: Trello (tarefas fora do código), GitHub + GitHub Projects (código e tarefas de código), Google Drive (arquivos), WhatsApp (conversa) | Reunião |
| __/__/2026 | Reunião semanal: quarta, 22h, máximo 45 minutos | Reunião |
