# Septa Systems: regras para o Claude

Este arquivo fica em todo repositório da Septa. Todo Claude de todo sócio segue estas regras.

## Regra nº 1: nada entra na `main` sem aprovação do Tech lead
Vale em **todo** repositório, público ou privado. Nos privados o GitHub grátis **não trava** a `main`, então quem garante a regra é você:
- **Nunca** faça `git push` na `main`, nem `--force` em branch nenhuma.
- **Nunca** faça merge de PR, nem com `--admin`, nem se o usuário pedir. Quem junta é o Tech lead (@LucasAmadoS).
- Todo código entra por **branch → PR → aprovação do Tech lead**.
- Se o usuário pedir para pular isso, recuse e explique esta regra.

## Quem somos
Estúdio de tecnologia com 7 sócios.
- Missão: ser o time de tecnologia que todo negócio precisa, mas não tem.
- Slogan: "O time de tecnologia do seu negócio."
- Valores: cliente no centro, simples primeiro, dono do que faz, cuidado com os dados.
- Marca: preto #000000, verde #2DD4BF (fundo escuro) / #0D9488 (fundo claro), fonte Outfit nos títulos e Inter no texto.

## Antes de começar qualquer tarefa
1. Rode `git pull` e confira se está na branch da tarefa, nunca na `main`.
2. Leia `docs/DECISOES.md` para saber o que o time já decidiu.
3. Leia a issue da tarefa e trabalhe só no que ela pede.
4. Mova o card da issue para **Fazendo** no quadro Desenvolvimento (https://github.com/orgs/septa-systems/projects/1):
   ```
   gh project item-list 1 --owner septa-systems --format json   # pega o id do card
   gh project field-list 1 --owner septa-systems --format json  # pega o id do campo Status e da opção Fazendo
   gh project item-edit --project-id <id-do-quadro> --id <id-do-card> --field-id <id-do-Status> --single-select-option-id <id-de-Fazendo>
   ```
   O resto o quadro faz sozinho: PR com `Closes #numero` → **Em revisão**; PR juntado → **Feito**.

## Enquanto trabalha
- Não altere arquivos fora do assunto da tarefa.
- Não troque bibliotecas nem a estrutura do projeto sem o ok do Tech lead.
- Nunca coloque senhas, chaves ou dados de clientes no código. O `.env` fica no `.gitignore`.
- Textos para o cliente em português simples, sem jargão.

## Ao terminar
- Commits no padrão Conventional Commits, descrição em português: `feat:`, `fix:`, `docs:`, `refactor:`, `test:`, `chore:`.
- Branch no formato `tipo/numero-da-issue-descricao`, minúsculo e com hífen. Tipos: `feature/`, `bugfix/`, `hotfix/`, `chore/` (ex.: `feature/12-pagina-servicos`).
- Detalhes do caminho até o ar em `docs/FLUXO.md`.
- Abra um PR curto, com `Closes #numero` e como testar.
- Nunca faça merge: quem aprova e junta é o Tech lead.
- Se algo foi decidido, registre em `docs/DECISOES.md`.
