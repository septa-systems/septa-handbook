# Segurança

Base: [OWASP Top 10](https://owasp.org/www-project-top-ten/) (os ataques mais comuns na web), [OWASP ASVS nível 1](https://owasp.org/www-project-application-security-verification-standard/) (checklist mínimo) e a LGPD.

Segurança é decidida **no projeto** (seção 6 do `arquitetura.md`), não remendada depois.

## 1. Pessoas e contas
- **2FA em todas as contas** da Septa e dos clientes que a gente acessa.
- Senhas no **Bitwarden** (cofre compartilhado). Nunca senha por WhatsApp, e-mail ou print.
- **Menor acesso possível**: cada um acessa só o que precisa. Painel de produção: Tech lead + dev responsável pelo cliente.
- Senha de cliente (hospedagem, domínio, redes) fica no Bitwarden, numa pasta por cliente.
- **Saída de sócio** (no mesmo dia): tirar do GitHub, Vercel, servidores, Bitwarden, Google Drive e trocar as senhas que ele conhecia.

## 2. IA (Claude) e dados
- **Nunca cole dado real de cliente no Claude**: nome, telefone, CPF, conversa, planilha, banco de produção. Use dados falsos do `seed`.
- Nunca cole senha, chave ou `.env` no Claude.
- Para investigar um erro de produção, copie a mensagem de erro **sem** dados pessoais.

## 3. Código (sistemas Django)
| Regra | Por quê (OWASP) |
|---|---|
| **Toda view confere permissão no servidor**: login + "esse usuário pode ver *este* registro?". Esconder botão não protege. | Controle de acesso quebrado (nº 1 do Top 10) |
| **Sistema com vários clientes: cliente A nunca vê dado do cliente B.** Toda consulta filtra pelo cliente, e isso tem teste obrigatório. | Controle de acesso quebrado |
| Nada de SQL montado na mão. Use o ORM; se precisar de SQL, com parâmetros. | Injeção |
| Não use `\|safe` nem `mark_safe` em texto vindo do usuário. | XSS |
| Formulários com `{% csrf_token %}` (padrão do Django). Nada de `@csrf_exempt` sem ADR. | Formulário forjado |
| Upload: limitar tipo e tamanho, renomear o arquivo, guardar fora da pasta do código (R2). | Upload malicioso |
| Links com token (redefinir senha, convite, avaliação) **expiram** e servem uma vez só. | Falha de autenticação |
| Webhook (pagamento, WhatsApp): **conferir a assinatura** antes de confiar. | Requisição falsa |
| API (DRF): toda rota com autenticação e permissão; CORS só para os domínios do projeto. | Controle de acesso |
| Bibliotecas com versão fixa (`requirements.txt` com `==`). | Componentes vulneráveis |

### Login
- Limite de tentativas com `django-axes`.
- Admin do Django em endereço diferente de `/admin/` e com 2FA (`django-otp`).
- Senha mínima de 8 caracteres e validadores padrão do Django.
- **Pedir a senha de novo** antes de ação sem volta (apagar conta, excluir dados, trocar e-mail ou permissões).
- **Segurança proporcional ao risco:** 2FA obrigatório para quem administra (dono, admin); o cliente final entra só com a senha.

### Login: o que usar em cada projeto
| Projeto | Use | Não use antes de precisar |
|---|---|---|
| Sistema com login próprio (ex.: SaaS do petshop) | **sessão do Django** (cookie HttpOnly, Secure, SameSite) | JWT |
| App de celular ou API para terceiros | OAuth 2.0 com PKCE; JWT validando assinatura, `iss`, `aud` e `exp`; Refresh Token com rotação | Implicit Flow; token na URL ou no log |
| "Entrar com Google" | OIDC pelo `django-allauth` | guardar a senha do Google |
| Cliente corporativo com vários sistemas | SSO (Keycloak, OIDC/SAML), LDAP/AD | qualquer um destes num cliente pequeno |

Cada peça a mais é mais uma coisa para manter e proteger. Na dúvida, sessão do Django.

### Papéis e registro
- **Papéis simples** (ex.: dono, recepção, profissional) num campo `papel`, conferidos no servidor em cada view. Grupos e permissões do Django só se o cliente precisar montar papéis sozinho.
- **Registrar os eventos de segurança**: login certo e errado, ações de admin, mudança de papel e exclusões. Sem senha, token ou dado pessoal no registro.
- **API**: limite de pedidos por minuto (rate limit) nas rotas públicas e de login.

### Configuração de produção
```python
DEBUG = False
SECURE_SSL_REDIRECT = True
SESSION_COOKIE_SECURE = True
CSRF_COOKIE_SECURE = True
SECURE_HSTS_SECONDS = 31536000
X_FRAME_OPTIONS = "DENY"
```
Antes de publicar: `python manage.py check --deploy` sem avisos.

## 4. GitHub (automático)
- **Dependabot**: avisa e abre PR quando uma biblioteca tem falha conhecida.
- **Secret scanning + push protection**: barra o push se tiver chave no código.
- **Checagem "Padrão do time"**: barra `.env`, chaves e certificados.
- **`/security-review`**: todo PR de sistema passa por esta revisão do Claude antes do Tech lead aprovar.

## 5. Dados e LGPD
- **Quem é quem**: o cliente é o **controlador** (dono dos dados); a Septa é **operadora** (trata em nome dele). Isso fica escrito no contrato.
- Guardar **só o necessário**. Todo dado pessoal novo aparece no PRD com o motivo.
- **Retenção**: definir no `arquitetura.md` por quanto tempo cada dado fica e como é apagado.
- HTTPS sempre. Senhas com hash (padrão do Django).
- **Backup diário**, guardado fora do servidor principal, e teste de restauração por mês.
- **Logs e Sentry sem dados pessoais** (nada de CPF, telefone ou e-mail no log; `send_default_pii=False` no Sentry).
- Todo sistema com cadastro tem **política de privacidade** e forma de o titular pedir para ver ou apagar seus dados.

## 6. Antes de lançar um sistema
- [ ] `check --deploy` sem avisos
- [ ] Teste de "cliente A não vê cliente B" passando (trocar o id na URL dá 404)
- [ ] `pip-audit` (sistemas) ou `npm audit` (sites) sem falha alta
- [ ] `/security-review` no código todo
- [ ] Varredura com [OWASP ZAP](https://www.zaproxy.org/) (modo baseline) no ambiente de teste
- [ ] Backup configurado e restaurado uma vez
- [ ] Política de privacidade no ar

## 7. Se der problema (incidente)
1. **Conter**: tirar o acesso, trocar senhas e chaves, desligar o que estiver vazando.
2. **Avisar** o Tech lead e o grupo na hora.
3. **Entender**: o que aconteceu, quando, quais dados, quantas pessoas.
4. **Comunicar o cliente** (controlador) o quanto antes.
5. Se vazou dado pessoal com risco às pessoas: o cliente comunica a **ANPD** e os titulares em até **3 dias úteis** (Resolução CD/ANPD nº 15/2024). A Septa ajuda com as informações.
6. **Corrigir** e escrever o que aprendemos em `docs/projeto/incidentes/AAAA-MM-DD.md`.
