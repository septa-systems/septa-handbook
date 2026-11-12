# Como um projeto nasce

Na Septa, ninguém pede código ao Claude logo de cara. Primeiro a gente **entende o problema**, depois **decide a estrutura**, e só então programa.

Tudo de cada projeto fica em `docs/projeto/` no repositório dele:

```
docs/projeto/
├── entrevista.md     # fase 1
├── prd.md            # fase 2
├── arquitetura.md    # fase 3
└── adr/              # fase 3 (uma decisão por arquivo)
    └── 0001-usar-django.md
```

Modelos de cada arquivo em `docs/modelos/` deste manual.

## As 5 fases

### 1. Descoberta (com o cliente)
- Conversa com o cliente usando `docs/modelos/entrevista-cliente.md`.
- Sai daqui: **o problema em 1 frase** e **como medir o sucesso**.
  Ex.: "O petshop perde ~5 horários por semana porque o cliente esquece. Sucesso = menos de 1 por semana."
- Quem: Vendas / Sucesso do cliente + Tech lead.
- Arquivo: `docs/projeto/entrevista.md`.

### 2. Entendimento (cada um com o seu Claude)
- `/grill-me`: o Claude entrevista você, uma pergunta por vez, até não sobrar dúvida.
- `/write-prd`: transforma a conversa no **PRD** (problema, usuários, histórias, fora do escopo, critérios de pronto).
- Arquivo: `docs/projeto/prd.md`.

### 3. Arquitetura
- `/arquitetura`: o Claude monta, a partir do PRD, o documento de arquitetura e as ADRs.
- Arquivos: `docs/projeto/arquitetura.md` e `docs/projeto/adr/`.

### 4. Revisão humana
- PRD e arquitetura entram por **PR**, como código. O Tech lead aprova.
- **Sem PRD e arquitetura aprovados, ninguém programa.**

### 5. Fatiar em tarefas
- O PRD vira issues pequenas, cada uma entregando algo que funciona de ponta a ponta (fatia vertical: tela + regra + banco).
- Daqui em diante, segue o `docs/FLUXO.md`.

## Os fundamentos que seguimos

| Fundamento | Em uma frase | Como aplicamos |
|---|---|---|
| **Modelo C4** (Simon Brown) | desenhar o sistema em níveis de zoom | todo projeto tem diagrama de **Contexto** e de **Containers** (em Mermaid, dentro do `arquitetura.md`) |
| **ADR** (Michael Nygard) | toda decisão importante registrada com o porquê | um arquivo por decisão em `docs/projeto/adr/` |
| **Monólito primeiro** (Martin Fowler) | começar com um sistema só, bem dividido | 1 projeto Django, apps separados por área do negócio; nada de microserviços |
| **DDD leve** | o código fala a língua do cliente | glossário no PRD; nome de model e app = palavra que o cliente usa |
| **12-Factor App** | o sistema roda igual em qualquer lugar | configuração por variável de ambiente, ver `docs/AMBIENTES.md` |
| **Separação de responsabilidades / SOLID** | cada parte faz uma coisa só | view fina → regra de negócio em `services.py` → dados no model |
| **Módulo profundo** (John Ousterhout) | interface pequena, muita lógica dentro | funções de serviço com poucos parâmetros, fáceis de testar |
| **KISS e YAGNI** | o mais simples que resolve; nada que não foi pedido | nosso valor "simples primeiro" |
| **Pirâmide de testes** | muitos testes pequenos, poucos grandes | pytest nas regras de negócio (`services.py`); poucos testes de tela |
| **Segurança desde o projeto** | segurança é decidida antes, não remendada depois | seção obrigatória no `arquitetura.md` (ver `docs/SEGURANCA.md`, quando existir) |

## Estrutura padrão de um sistema Django

```
projeto/
├── config/              # settings, urls (lê tudo do .env)
├── <area_do_negocio>/   # um app por área: agenda/, clientes/, pagamentos/
│   ├── models.py        # dados
│   ├── services.py      # regras de negócio (onde ficam os testes)
│   ├── views.py         # só recebe o pedido e chama o service
│   ├── templates/
│   └── tests/
├── docs/projeto/
├── docker-compose.yml
└── .env.example
```
