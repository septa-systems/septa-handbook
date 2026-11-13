# Arquitetura: <nome do projeto>

Status: rascunho / aprovado · Base: `docs/projeto/prd.md` · Data: __/__/____

> **Como usar este modelo:** troque tudo que está entre `<...>` e os nomes genéricos dos diagramas (Papel 1, Conceito A...) pelos do seu projeto, com as palavras do glossário do PRD. Os blocos "Exemplo" mostram um projeto **fictício** (agenda de uma barbearia) só para referência: **apague-os** no documento do seu projeto.

## 1. Contexto (C4 nível 1)
Quem usa o sistema e com quais sistemas de fora ele conversa. É o diagrama para o cliente entender.
- **Sem tecnologia** (nada de Django ou PostgreSQL aqui).
- Toda caixa tem **tipo**: `[pessoa]` ou `[sistema externo]`. Cada papel tem a sua caixa.
- Toda seta tem **verbo**.
- Só entra quem fala direto com o sistema.

```mermaid
flowchart LR
  p1["Papel 1 [pessoa]"] -- "verbo: o que faz" --> sis["Nome do sistema [este sistema]"]
  p2["Papel 2 [pessoa]"] -- "verbo: o que faz" --> sis
  sis -- "verbo: o que pede" --> ext["Serviço de fora [sistema externo]"]
```

<details><summary>Exemplo (fictício: agenda de uma barbearia)</summary>

```mermaid
flowchart LR
  dono["Dono [pessoa]"] -- "vê agenda, faturamento e equipe" --> sis["Agenda da barbearia [este sistema]"]
  cliente["Cliente [pessoa]"] -- "agenda, reagenda, cancela" --> sis
  barbeiro["Barbeiro [pessoa]"] -- "vê a própria agenda" --> sis
  sis -- "envia avisos" --> whatsapp["WhatsApp [sistema externo]"]
  sis -- "envia e-mails" --> email["Serviço de e-mail [sistema externo]"]
```
</details>

## 2. Containers (C4 nível 2)
O que roda. É o diagrama para o time técnico. Toda caixa tem **nome + tecnologia + o que faz**, e toda seta tem o **protocolo**.

Padrão da Septa para sistemas: web + banco + worker com **fila de saída** (uma tabela no PostgreSQL), quando o sistema avisa alguém. Celery/Redis só entram com uma ADR que mostre a necessidade medida. Sem avisos, não tem worker.

```mermaid
flowchart LR
  nav["Navegador · celular/PC"] -- "HTTPS" --> web["Web · Django + HTMX · telas e regras"]
  web -- "SQL" --> db[("Banco · PostgreSQL · dados + fila de saída")]
  worker["Worker · Django (manage.py) · lê a fila e envia"] -- "SQL" --> db
  worker -- "HTTPS/JSON" --> ext["Serviço de fora · o que faz"]
```

## 3. Restrições
O que limita as escolhas. A arquitetura equilibra estas restrições com o PRD e com a seção 8, sem maximizar uma coisa só.
- **Técnicas** (hospedagem, sistema que o cliente já usa, integração obrigatória):
- **Do time** (quem vai manter, o que sabemos fazer):
- **Do projeto** (prazo, orçamento, LGPD, dado sensível):

## 4. Apps Django (áreas do negócio)
| App | Responsável por | Depende de |
|---|---|---|
| | | |

Entre apps só se importa `models.py`, `services.py` e `forms.py`/`serializers.py`. Nunca se importa `views.py`, templates ou função que começa com `_`.

## 5. Modelo de domínio
Os conceitos do negócio, com os nomes do glossário do PRD. É isso que o cliente valida. Não é o desenho das tabelas: `empresa_id`, tabela de ligação e índice ficam no código.

```mermaid
classDiagram
  ConceitoA "1" -- "0..*" ConceitoB : verbo
  ConceitoB "1" *-- "1..*" ConceitoC : contém
  ConceitoC "0..*" -- "1" ConceitoD : de
  class ConceitoC {
    atributo_que_explica_uma_regra
  }
```
- Multiplicidade nas **duas pontas**. Leia assim: para **um** deste lado, quantos pode haver do outro? (`1`, `0..1`, `0..*`, `1..*`)
- Toda multiplicidade é **confirmada com o cliente ou no model** (`null=True`, `unique`, `OneToOne`), nunca de cabeça.
- `*--` (composição) = a parte não existe sem o todo. Herança (`<|--`) quase nunca: no Django, um campo `tipo` costuma resolver.
- Atributo só aparece quando explica uma regra.

<details><summary>Exemplo (fictício: agenda de uma barbearia)</summary>

```mermaid
classDiagram
  Cliente "1" -- "0..*" Agendamento : faz
  Barbeiro "1" -- "0..*" Agendamento : atende
  Agendamento "1" *-- "1..*" Item : contém
  Item "0..*" -- "1" Servico : de
  class Item {
    preco
  }
```
`preco` está no Item porque o preço fica congelado no dia do agendamento, mesmo que o serviço mude de preço depois.
</details>

Regras: o que é obrigatório, o que é único, o que nunca é apagado.

## 6. Fluxos principais
O passo a passo dos 2 ou 3 caminhos mais importantes (ex.: "<papel> faz <tarefa principal>").

## 7. Segurança e LGPD
- Papéis e o que cada um pode ver e editar:
- Login: sessão do Django (padrão) ou outro? Ver `docs/SEGURANCA.md`.
- Dados pessoais guardados e por quê:
- Por quanto tempo guardamos e como apagamos:
- Pontos de ataque e como protegemos:

## 8. Requisitos de qualidade
Cada requisito é um cenário: **estímulo → resposta → medida**. "Rápido e seguro" não vale.

| Estímulo (o que acontece) | Resposta (como reage) | Medida (como saber) |
|---|---|---|
| <pico de uso: quantas pessoas, quando, fazendo o quê> | <o que o sistema faz> | <número: p95 em até X s; zero erro de Y> |
| O servidor cai | volta sozinho; o backup existe | no ar em até <X> min; perda máxima de <X> h |
| Usuário abre dado de outra empresa | bloqueia | 404 em 100% dos testes de isolamento |

Tempo se mede pelo **p95** (95% dos pedidos ficam abaixo), nunca pela média. Também vale anotar aqui: celular primeiro? Qual a meta de usabilidade do PRD?

<details><summary>Exemplo (fictício: agenda de uma barbearia)</summary>

| Estímulo | Resposta | Medida |
|---|---|---|
| Sexta 18h, 200 clientes buscam horário | mostra os horários livres sem erro | 95% das buscas em até 2 s; zero horário vendido duas vezes |
| O servidor cai às 3h | volta sozinho; o backup existe | no ar em até 30 min; perda máxima de 24 h |
</details>

## 9. Decisões (ADRs)
| Nº | Decisão | Arquivo |
|---|---|---|
| 0001 | | `adr/0001-....md` |

## 10. Riscos
| Risco | Chance | Impacto | O que fazer |
|---|---|---|---|
| | | | |
