# Padrões de código

Objetivo: todo código da Septa parecer escrito pela mesma pessoa, seja de qual sócio ou Claude for.

## 1. Formatação e erros (automático)

| Projeto | Ferramenta | O que faz |
|---|---|---|
| Django | **Ruff** (`ruff format` + `ruff check`) | formata, organiza imports, acha bugs e falhas de segurança |
| Astro | **Prettier** + `astro check` | formata e acha erros |
| Todos | **pre-commit** | roda tudo isso sozinho antes de cada commit |
| Todos | `.editorconfig` | mesmo recuo e fim de linha em qualquer editor |

Ninguém discute vírgula ou espaço na revisão: a ferramenta decide.

Configuração do Ruff (vem pronta no projeto-base):
```toml
[tool.ruff]
line-length = 100
target-version = "py312"

[tool.ruff.lint]
select = ["E", "F", "I", "B", "UP", "DJ", "S"]
# E/F erros, I imports, B bugs comuns, UP Python moderno, DJ Django, S segurança

[tool.ruff.lint.per-file-ignores]
"**/tests/**" = ["S101"]  # assert é normal em teste
```

## 2. Nomes

**Negócio em português, Django em inglês.** As palavras do glossário do PRD viram os nomes no código.

| O quê | Padrão | Exemplo |
|---|---|---|
| Classe / model | `PascalCase`, singular | `Agendamento`, `Cliente`, `Servico` |
| Função / variável | `snake_case`, verbo para função | `cancelar_agendamento()`, `horario_inicio` |
| Constante | `MAIUSCULO` | `PRAZO_CANCELAMENTO_HORAS = 24` |
| App Django | plural, área do negócio | `agendamentos/`, `clientes/` |
| URL | minúsculo com hífen | `/agendamentos/novo/` |
| Teste | `test_` + o comportamento | `test_nao_agenda_em_horario_ocupado` |

- **Sem acento e sem ç nos nomes** (`Servico`, `configuracao`). Acento só em texto que o usuário vê.
- O que é do Django fica como o Django chama: `models.py`, `views.py`, `save()`, `get_queryset()`.

## 3. Escrita do código

- **Funções pequenas, uma tarefa cada.** Se precisou de "e" para explicar, divida.
- **Regra de negócio em `services.py`**, view fina (ver `docs/ARQUITETURA.md`). Cadastro simples sem regra não precisa de service: ModelForm + view genérica. Service que só chama `.save()` é camada a mais.
- **Entre apps** só se importa `models.py`, `services.py` e `forms.py`/`serializers.py`. Nunca `views.py`, templates ou função que começa com `_`. Precisou de algo da view de outro app? Mova para o `services.py` dele.
- **Dinheiro sempre em `Decimal`** (`DecimalField` no model), nunca `float`.
- **Serviço de fora atrás de um contrato só:** WhatsApp, e-mail e pagamento têm uma função (`enviar_aviso(...)`) e o provedor vem da configuração (console no PC, real em produção, mock no teste). Todo provedor reage igual a erro.
- **Abstração só se passar nas 3 perguntas:** reduz uma mudança que vai acontecer? deixa o teste mais fácil? protege uma fronteira importante (como provedor de fora)? Se não, não crie.
- **Refatoração vai num PR separado** (`refactor:`), com os testes passando antes e depois, sem misturar com funcionalidade nova. Arquivo grande que funciona se divide quando for mexer nele.
- **Tipos nas funções de serviço:**
  ```python
  def agendar(cliente: Cliente, servico: Servico, inicio: datetime) -> Agendamento:
  ```
- **Sem número mágico**: `PRAZO_CANCELAMENTO_HORAS = 24`, não `24` solto.
- **Sem `print`**: use `logging`, sem dados pessoais na mensagem.
- **Sem código comentado** esquecido. O git guarda o histórico.
- **Comentário explica o porquê, não o quê.** Em português.
- **Erros de negócio com exceção própria** (`HorarioOcupado`), não `return None`.

## 4. Testes

Ferramentas: **pytest + pytest-django + factory_boy** (cria dados falsos rápido).

**Obrigatório testar** (começando pelo que mais dói se der errado):
1. **Isolamento**: usuário da empresa A abre cliente da empresa B → **404** (não 403: nem confirma que existe). É o bug mais grave de um SaaS.
2. **Permissões**: sem login redireciona; funcionário comum não abre tela de dono.
3. **Dinheiro**: desconto, comissão e total certos, em `Decimal`.
4. **Duplicidade**: clicar duas vezes ou reenviar o pedido não agenda nem cobra duas vezes.
5. **Integrações**: a regra chama o envio de WhatsApp/e-mail (com mock, sem enviar de verdade).
6. Toda regra de negócio em `services.py`.
7. **Todo bug corrigido ganha um teste** que falhava antes da correção.

**Como escolher os casos:** um valor de cada grupo (válido, abaixo, acima) e **os limites**, porque bug adora morar na borda (`<` no lugar de `<=`). Cupom de R$ 100 a R$ 500 → teste 99, 100, 500 e 501. Os casos de teste do PRD viram os testes quase um para um.

**O teste protege?** Se eu quebrar a regra de propósito, algum teste fica vermelho? Se não fica, o teste não está protegendo nada.

Regras:
- Sem meta de porcentagem por enquanto (vira teste inútil para bater número).
- Teste não depende de outro teste nem da ordem em que roda.
- Teste não acessa internet: WhatsApp, e-mail e pagamento são simulados (mock).
- Estrutura: **prepara → executa → confere**.
  ```python
  def test_nao_agenda_em_horario_ocupado(cliente, servico):
      agendar(cliente, servico, inicio=AS_10H)          # prepara

      with pytest.raises(HorarioOcupado):               # confere
          agendar(cliente, servico, inicio=AS_10H)      # executa
  ```

## 5. Banco de dados (migrations)

- Migration vai **no mesmo commit** que a mudança no model.
- **Nunca editar migration que já rodou em produção.** Crie uma nova.
- Apagar ou renomear coluna em 2 passos: (1) o código para de usar e vai pro ar; (2) uma migration nova remove.
- Campo novo obrigatório em tabela com dados: com valor padrão ou em 2 passos.
- Revisor confere toda migration no PR.

## 6. Telas

- **Celular primeiro**: o cliente de pequeno negócio usa celular.
- **Acessibilidade básica**: todo campo com `<label>`, toda imagem com `alt`, contraste legível, dá para usar só com o teclado.
- Textos em português simples, sem jargão (é o nosso tom).
- **Botão que envia** mostra "Enviando..." e fica travado até responder (evita clique duplo).
- **Impedir o erro antes**: horário ocupado já aparece bloqueado, e não recusado só no fim.
- **Mensagem de erro diz o que houve e o que fazer**, na língua do usuário: "Este horário acabou de ser reservado. Escolha outro.", e nunca "Erro 409" ou "Ocorreu um erro".
- **Dá para voltar, corrigir e cancelar** sem recomeçar e sem perder o que já foi preenchido.
- **Antes de entregar uma tela**, rode o `/revisar-tela` (as 10 heurísticas de Nielsen).
- **Antes de lançar**, teste com umas **5 pessoas reais** do público, dando o objetivo ("marque um banho para terça") e não o caminho. Anote sucesso, tempo (mediana) e onde travaram. Corrija primeiro o **crítico** (não conclui a tarefa) e o **alto** (erro frequente ou perda de dados).
- **Sites**: nota **90 ou mais** no Lighthouse em Desempenho, Acessibilidade, Boas práticas e SEO.

## 7. Checagem automática dos projetos

Em todo PR, e bloqueiam se falharem:

| Projeto | Roda |
|---|---|
| Todos | Padrão do time (título, branch, `.env`) |
| Django | `ruff format --check`, `ruff check`, `pytest`, `python manage.py check --deploy`, `makemigrations --check` (migration esquecida) |
| Astro | `prettier --check`, `astro check`, `astro build` |

Vem pronta nos projetos-base.
