# Fluxo do código

Todo código da Septa segue este caminho até o ar. O Tech lead também abre branch e PR.

## O caminho

1. **Issue no GitHub Projects.** Ninguém programa sem issue. Ela diz o que fazer e o que é "pronto".
2. **Branch nova a partir da `main` atualizada:**
   ```
   git checkout main
   git pull
   git checkout -b feature/12-pagina-servicos
   ```
   Formato: `tipo/numero-da-issue-descricao`, tudo minúsculo, com hífen, sem acento.

   | Branch | Quando usar | Exemplo |
   |---|---|---|
   | `feature/` | coisa nova | `feature/12-pagina-servicos` |
   | `bugfix/` | correção normal | `bugfix/15-horario-celular` |
   | `hotfix/` | urgência em produção | `hotfix/18-login-fora-do-ar` |
   | `chore/` | manutenção (dependências, configuração) | `chore/20-atualiza-django` |

3. **Commits pequenos** no padrão [Conventional Commits](https://www.conventionalcommits.org/pt-br/): tipo em inglês, descrição em português.

   | Tipo | Quando usar | Exemplo |
   |---|---|---|
   | `feat:` | funcionalidade nova | `feat: adiciona formulário de contato` |
   | `fix:` | correção | `fix: corrige horário no celular` |
   | `docs:` | só documentação | `docs: explica como rodar o projeto` |
   | `refactor:` | reorganiza sem mudar comportamento | `refactor: separa envio de e-mail` |
   | `test:` | testes | `test: cobre cadastro de cliente` |
   | `chore:` | manutenção, dependências, GitHub Actions | `chore: atualiza Django para 5.2` |
4. **PR** usando o modelo (abre sozinho). Sempre com `Closes #numero`.
5. **Teste automático** (GitHub Actions) roda no PR. Falhou, não junta.
6. **Revisão:** o Tech lead aprova (ele é o dono do código no `CODEOWNERS`). O PR do próprio Tech lead pode ser juntado por ele sem aprovação (exceção configurada no GitHub).
7. **Merge com "Squash and merge"**: vira 1 commit na `main`. A issue fecha sozinha.
8. **Deploy automático:** o que entra na `main` vai para o ar.

## Proteção da `main` (configurada no GitHub)

- Proibido push direto na `main`.
- Merge só com teste passando e aprovação do Tech lead.
- Exceção: o Tech lead (admin da org) pode juntar sem aprovação.
- Branch apagada depois do merge.

## Antes de ir para o ar

- **Sites (Astro + Vercel):** todo PR ganha um link de prévia. O cliente aprova por ele antes do merge.
- **Sistemas (Django):** ambiente de teste entra quando tiver o 1º cliente (ver parte 3, Ambientes).

## Revisão: o que olhar

- Faz o que a issue pede, e só isso?
- Testei pelo link de prévia ou rodando local?
- Tem senha, chave ou dado de cliente no código?
- Um sócio que não escreveu isso entende o código?

Prazo: PR revisado em até **24 h**. Se o Tech lead não conseguir no prazo, avisa no grupo.

## Onde ficam as tarefas

| Quem | Ferramenta |
|---|---|
| Engenharia (código) | GitHub Projects (issues ligadas aos PRs) |
| Resto da empresa | Trello |

Colunas do GitHub Projects: **A fazer → Fazendo → Em revisão → Feito**.
