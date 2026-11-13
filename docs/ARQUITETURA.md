# Como um projeto nasce

Na Septa, ninguém pede código ao Claude logo de cara. Primeiro a gente **entende o problema**, depois **decide a estrutura**, e só então programa.

## Do começo ao fim

| # | Etapa | O que sai | Documento / skill |
|---|---|---|---|
| 1 | Descoberta com o cliente | problema em 1 frase + como medir o sucesso | `docs/modelos/entrevista-cliente.md` |
| 2 | Entendimento | PRD com meta de usabilidade e casos de teste | `/grill-me` → `/write-prd` |
| 3 | Arquitetura | C1, C2, modelo de domínio, restrições, cenários de qualidade, ADRs | `/arquitetura` |
| 4 | Revisão humana | PRD e arquitetura aprovados por PR | checklist da fase 4 (abaixo) |
| 5 | Fatiar | issues pequenas, de ponta a ponta | GitHub Projects |
| 6 | Programar | código no padrão, com testes | `docs/PADROES.md`, `docs/SEGURANCA.md` |
| 7 | Revisar a tela | as 10 heurísticas conferidas | `/revisar-tela` |
| 8 | PR e revisão | checagem verde + revisão de outra pessoa | `docs/FLUXO.md`, `/security-review` |
| 9 | Deploy | teste rápido (smoke) de 2 minutos | `docs/AMBIENTES.md` |
| 10 | Lançamento | checklist de segurança + teste com 5 pessoas reais | `docs/SEGURANCA.md` seção 6, `docs/PADROES.md` seção 6 |
| 11 | Evoluir | erro ou pedido vira issue; decisão nova vira ADR | `docs/DECISOES.md` |

Tudo de cada projeto fica em `docs/projeto/` no repositório dele:

```
docs/projeto/
├── entrevista.md     # fase 1
├── prd.md            # fase 2
├── arquitetura.md    # fase 3
└── adr/              # fase 3 (uma decisão por arquivo)
    └── 0001-usar-django.md
```

Os modelos de cada arquivo ficam em `docs/modelos/` deste manual.

## As 5 fases

### 1. Descoberta (com o cliente)
- Conversa com o cliente usando `docs/modelos/entrevista-cliente.md`.
- Sai daqui: **o problema em 1 frase** e **como medir o sucesso**.
  Ex.: "A barbearia perde ~5 horários por semana porque o cliente esquece. Sucesso = menos de 1 por semana."
- Quem: Vendas / Sucesso do cliente + Tech lead.
- Arquivo: `docs/projeto/entrevista.md`.

### 2. Entendimento (cada um com o seu Claude)
- `/grill-me`: o Claude entrevista você, uma pergunta por vez, até não sobrar dúvida.
- `/write-prd`: transforma a conversa no **PRD** (problema, meta de usabilidade, usuários, histórias, casos de teste, fora do escopo).
- Arquivo: `docs/projeto/prd.md`.

### 3. Arquitetura
- `/arquitetura`: o Claude monta, a partir do PRD, o documento de arquitetura e as ADRs.
- Arquivos: `docs/projeto/arquitetura.md` e `docs/projeto/adr/`.
- **Do PRD para o modelo de domínio, em 5 passos:**
  1. **Achar os conceitos**: os substantivos do PRD e do glossário (cliente, barbeiro, horário, serviço).
  2. **Tirar os falsos**: tela, botão, verbo solto e detalhe técnico não viram classe.
  3. **Ligar**: quem tem, contém ou depende de quem.
  4. **Validar os números**: a multiplicidade de cada ponta, com o cliente ("um agendamento pode ter mais de um serviço?").
  5. **Detalhar com propósito**: só os atributos que explicam uma regra.
- **Os mesmos nomes em todos os níveis**: se no C1 é "Agenda da barbearia" e no domínio é "Agendamento", o app é `agenda` e o model é `Agendamento`.
- **Decida logo aqui o que custa caro mudar depois**, com ADR. Ex.: vários clientes num banco só (coluna `empresa_id`) ou um banco por cliente.

### 4. Revisão humana
- PRD e arquitetura entram por **PR**, como código. O Tech lead aprova.
- **Sem PRD e arquitetura aprovados, ninguém programa.**
- Checklist do PR de arquitetura:

  | Diagramas C4 | Modelo de domínio |
  |---|---|
  | O título diz o nível (C1 ou C2)? | As classes são conceitos do negócio, e não telas? |
  | Toda caixa tem nome, tipo e o que faz? | Toda ligação tem multiplicidade nas duas pontas? |
  | Toda seta tem verbo (C1) ou protocolo (C2)? | As multiplicidades foram confirmadas (cliente ou model)? |
  | O C1 está sem tecnologia e o C2 com? | Composição e herança têm sentido real? |
  | Os nomes batem com o PRD e com o código? | Não virou só o desenho das tabelas? |

  Também: as restrições estão escritas? Os requisitos de qualidade têm número? Toda ADR diz o que sacrificamos?

### 5. Fatiar em tarefas
- O PRD vira issues pequenas, e cada uma entrega algo que funciona de ponta a ponta (fatia vertical: tela + regra + banco).
- Daqui em diante, segue o `docs/FLUXO.md`.

## Os fundamentos que seguimos

| Fundamento | Em uma frase | Como aplicamos |
|---|---|---|
| **Modelo C4** (Simon Brown) | desenhar o sistema em níveis de zoom | todo projeto tem **Contexto**, **Containers** e **modelo de domínio** (Mermaid, no `arquitetura.md`). C3 e diagrama de classes UML só se agregarem: a tabela de apps e o código já fazem esse papel |
| **ADR** (Michael Nygard) | toda decisão importante registrada com o porquê | um arquivo por decisão em `docs/projeto/adr/`, sempre com o que sacrificamos |
| **Monólito modular** (Martin Fowler) | um sistema só, com fronteiras claras por dentro | 1 projeto Django, apps por área do negócio; entre apps só se importa `models`, `services` e `forms`/`serializers` (nunca `views`, templates ou `_privada`). Microsserviço só com necessidade medida (uma parte que escala muito mais que o resto, ou exigência de segurança bem diferente) |
| **Multi-tenancy** (um sistema, vários clientes) | todos os clientes no mesmo sistema e banco, cada registro com a empresa dona | padrão de todo sistema: `Empresa` + `empresa_do_usuario`; o model de cliente bloqueia ler/gravar sem empresa; teste de outra empresa → 404 obrigatório; comando para exportar e apagar os dados de um cliente. Schema ou banco por cliente só com ADR (cliente grande ou regulado) |
| **Fila de saída** (outbox) | o pedido não espera o serviço de fora | aviso de WhatsApp ou e-mail é gravado numa tabela e um worker (`manage.py`) envia e tenta de novo. Celery/Redis e cache só com ADR e lentidão medida |
| **DDD leve** | o código fala a língua do cliente | glossário no PRD; o nome do model e do app é a palavra que o cliente usa |
| **12-Factor App** | o sistema roda igual em qualquer lugar | configuração por variável de ambiente, ver `docs/AMBIENTES.md` |
| **Separação de responsabilidades / SOLID** | cada parte faz uma coisa só | view fina → regra de negócio em `services.py` → dados no model. Cadastro simples (CRUD) não precisa de service: ModelForm + view genérica resolvem |
| **Módulo profundo** (John Ousterhout) | interface pequena, muita lógica dentro | funções de serviço com poucos parâmetros, fáceis de testar |
| **KISS e YAGNI** | o mais simples que resolve; nada que não foi pedido | nosso valor "simples primeiro": camada que só repassa dado é custo, não arquitetura |
| **Pirâmide de testes** | muitos testes pequenos, poucos grandes | pytest nas regras de negócio (`services.py`); poucos testes de tela |
| **Segurança desde o projeto** | segurança é decidida antes, não remendada depois | seção obrigatória no `arquitetura.md` (ver `docs/SEGURANCA.md`) |

**Arquitetura evolui:** erro, lentidão ou pedido novo → ADR nova (a antiga vira "substituída") → o código e o documento mudam juntos. Documento desatualizado engana mais que documento nenhum.

## Estrutura padrão de um sistema Django

```
projeto/
├── config/              # settings, urls (lê tudo do .env)
├── <area_do_negocio>/   # um app por área: agenda/, clientes/, pagamentos/
│   ├── models.py        # dados
│   ├── services.py      # regras de negócio, quando existem (é onde ficam os testes)
│   ├── views.py         # só recebe o pedido e chama o service
│   ├── templates/
│   └── tests/
├── notificacoes/        # fila de saída + worker (quando o sistema avisa alguém)
├── docs/projeto/
├── docker-compose.yml
└── .env.example
```
