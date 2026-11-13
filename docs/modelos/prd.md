# PRD: <nome do projeto>

Status: rascunho / aprovado · Responsável: ____ · Data: __/__/____

## Problema
O que o usuário sofre, do ponto de vista dele. Vem da entrevista.

## Como medir o sucesso
Um número concreto. Ex.: "as faltas caem de 5 para menos de 1 por semana".

**Meta de usabilidade** (tarefa principal, com número): ex.: "9 de 10 tutores agendam sozinhos em até 2 minutos, pelo celular".

## Solução
O que vai ser feito, em poucas linhas.

## Usuários
| Papel | O que faz no sistema | Aparelho |
|---|---|---|
| | | celular / PC |

## Glossário
Palavras do negócio do cliente, que viram os nomes no código.
| Termo | Significado |
|---|---|
| | |

## Histórias de usuário
1. Como <papel>, quero <ação> para <benefício>.

## Módulos
Módulos novos e alterados, com a interface de cada um (o que recebe e o que devolve).

## Decisões de implementação
Modelo de dados, regras, limites e dados que já existem.

## Casos de teste
Escritos antes de programar. Viram os testes do pytest quase um para um. Inclua sempre os limites da regra, o clique duplo e o acesso de outra empresa.

| ID | Cenário | Ação | Resultado esperado |
|---|---|---|---|
| CT01 | Horário já ocupado | Agendar | Recusa com mensagem clara |
| CT02 | Mesmo pedido enviado 2 vezes | Reenviar | Agenda uma vez só |
| CT03 | Usuário da empresa A | Abrir cliente da empresa B | 404; nada vaza |

## Fora do escopo
O que NÃO será feito agora.

## Dúvidas em aberto
