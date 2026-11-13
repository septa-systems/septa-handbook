#!/usr/bin/env bash
# Cria um repo novo da Septa a partir do modelo e deixa ele configurado
# igual aos outros (merge, segurança, proteção da main e quadro).
#
# Uso:
#   scripts/novo-repo.sh <nome> <site|sistema> [--publico] [--simular]
#   scripts/novo-repo.sh <nome> <site|sistema> --so-config [--publico] [--simular]
#
#   (padrão)     repo privado, como todo projeto de cliente (no plano grátis
#                a proteção da main não vale: segue a Regra nº 1 do CLAUDE.md)
#   --publico    repo público (só coisas da Septa: site, manual, modelos)
#   --so-config  não cria nada, só aplica a configuração num repo que já existe
#   --simular    só mostra o que faria, sem mudar nada no GitHub
#
# Precisa: gh logado com os escopos repo, workflow e project
# (gh auth refresh -s project) e ser admin da org.
set -euo pipefail

ORG="septa-systems"
QUADRO=1 # projeto "Desenvolvimento"

uso() { sed -n '5,14p' "$0" | sed 's/^# \{0,1\}//'; exit 1; }

NOME="${1:-}"; TIPO="${2:-}"
[ -z "$NOME" ] || [ -z "$TIPO" ] && uso
shift 2
PRIVADO=1; SO_CONFIG=0; SIMULAR=0
for arg in "$@"; do
  case "$arg" in
    --publico) PRIVADO=0 ;;
    --so-config) SO_CONFIG=1 ;;
    --simular) SIMULAR=1 ;;
    *) uso ;;
  esac
done

case "$TIPO" in
  site) CHECAGEM="Site (formatação, checagem e build)" ;;
  sistema) CHECAGEM="Sistema (Ruff, testes e segurança)" ;;
  *) echo "Tipo tem que ser 'site' ou 'sistema'."; exit 1 ;;
esac

if ! echo "$NOME" | grep -Eq '^[a-z0-9]+(-[a-z0-9]+)*$'; then
  echo "Nome fora do padrão: use minúsculo, sem acento, com hífen (ex.: site-padaria-joao)."
  exit 1
fi

REPO="$ORG/$NOME"

# Roda o comando, ou só mostra se for --simular.
faz() {
  if [ "$SIMULAR" = 1 ]; then echo "  [simular] $*"; else "$@"; fi
}

passo() { echo; echo "==> $*"; }

# 1. Criar a partir do modelo
if [ "$SO_CONFIG" = 0 ]; then
  passo "Criando $REPO a partir de $ORG/modelo-$TIPO"
  VIS="--public"; [ "$PRIVADO" = 1 ] && VIS="--private"
  faz gh repo create "$REPO" --template "$ORG/modelo-$TIPO" "$VIS"

  # O GitHub copia o modelo em segundo plano; espera a main aparecer.
  if [ "$SIMULAR" = 0 ]; then
    for _ in $(seq 1 30); do
      gh api "repos/$REPO/branches/main" >/dev/null 2>&1 && break
      sleep 2
    done
    gh api "repos/$REPO/branches/main" >/dev/null || { echo "A main não apareceu. Rode de novo com --so-config."; exit 1; }
  fi
else
  passo "Usando $REPO que já existe"
  # Repo que já existe: a visibilidade vem do GitHub, não da opção.
  if [ "$SIMULAR" = 0 ]; then
    [ "$(gh api "repos/$REPO" --jq .private)" = "true" ] && PRIVADO=1 || PRIVADO=0
  fi
fi

# 2. Merge: só squash, título do PR, apaga a branch depois
passo "Merge: só squash e apagar branch depois"
faz gh api -X PATCH "repos/$REPO" --silent \
  -F allow_squash_merge=true -F allow_merge_commit=false -F allow_rebase_merge=false \
  -F delete_branch_on_merge=true -F has_wiki=false \
  -f squash_merge_commit_title=COMMIT_OR_PR_TITLE -f squash_merge_commit_message=COMMIT_MESSAGES

# 3. Segurança: alertas do Dependabot, correções automáticas, segredos
passo "Segurança: Dependabot e busca de senhas no código"
faz gh api -X PUT "repos/$REPO/vulnerability-alerts" --silent
faz gh api -X PUT "repos/$REPO/automated-security-fixes" --silent
if [ "$PRIVADO" = 0 ]; then
  faz gh api -X PATCH "repos/$REPO" --silent --input - <<'JSON'
{"security_and_analysis": {
  "secret_scanning": {"status": "enabled"},
  "secret_scanning_push_protection": {"status": "enabled"}
}}
JSON
else
  echo "  Repo privado: busca de senhas fica desligada no plano grátis."
fi

# 4. Proteção da main (mesma regra dos modelos)
passo "Proteção da main: PR, aprovação do Tech lead e checagens"
if [ "$PRIVADO" = 1 ]; then
  echo "  Repo privado no plano grátis: o GitHub não aplica a regra. Vale a Regra nº 1 do CLAUDE.md."
else
  REGRA=$(cat <<JSON
{
  "name": "Proteção da main",
  "target": "branch",
  "enforcement": "active",
  "conditions": {"ref_name": {"include": ["~DEFAULT_BRANCH"], "exclude": []}},
  "bypass_actors": [{"actor_id": null, "actor_type": "OrganizationAdmin", "bypass_mode": "always"}],
  "rules": [
    {"type": "deletion"},
    {"type": "non_fast_forward"},
    {"type": "pull_request", "parameters": {
      "allowed_merge_methods": ["squash"],
      "dismiss_stale_reviews_on_push": true,
      "require_code_owner_review": true,
      "require_extra_approval_for_unattributed_changes": true,
      "require_last_push_approval": false,
      "required_approving_review_count": 1,
      "required_review_thread_resolution": true
    }},
    {"type": "required_status_checks", "parameters": {
      "do_not_enforce_on_create": false,
      "strict_required_status_checks_policy": false,
      "required_status_checks": [
        {"context": "Padrão do time", "integration_id": 15368},
        {"context": "$CHECAGEM", "integration_id": 15368}
      ]
    }}
  ]
}
JSON
)
  # Se a regra já existe, atualiza; senão, cria. Rodar duas vezes não duplica.
  ID=""
  [ "$SIMULAR" = 1 ] || ID=$(gh api "repos/$REPO/rulesets" --jq '.[] | select(.name=="Proteção da main") | .id' | head -1)
  if [ -n "$ID" ]; then
    echo "$REGRA" | faz gh api -X PUT "repos/$REPO/rulesets/$ID" --silent --input -
  else
    echo "$REGRA" | faz gh api -X POST "repos/$REPO/rulesets" --silent --input -
  fi
fi

# 5. Ligar no quadro "Desenvolvimento"
passo "Ligando no quadro Desenvolvimento"
JA=""
[ "$SIMULAR" = 1 ] || JA=$(gh api graphql -f query="{organization(login:\"$ORG\"){projectV2(number:$QUADRO){repositories(first:100){nodes{name}}}}}" \
  --jq ".data.organization.projectV2.repositories.nodes[].name | select(.==\"$NOME\")")
if [ -n "$JA" ]; then
  echo "  Já estava no quadro."
else
  faz gh project link "$QUADRO" --owner "$ORG" --repo "$REPO"
fi

echo
echo "Pronto: https://github.com/$REPO"
if [ "$SO_CONFIG" = 0 ]; then
  echo "Agora: gh repo clone $REPO e siga o README do projeto."
fi
