# SEO do Essentius — estratégia e estado

## A conversa difícil primeiro

**"Primeiro lugar em `diabetes`" não é uma meta alcançável.** Essa busca é ocupada há
anos por Ministério da Saúde, Sociedade Brasileira de Diabetes, Drauzio Varella,
Wikipedia e hospitais com décadas de autoridade e milhares de páginas médicas revisadas
por especialistas. Nenhuma agência séria promete essa posição, e quem promete está
vendendo o que não pode entregar — o Google não vende ranking orgânico e não garante
posição a ninguém.

`sensor` é pior ainda: sozinha, a palavra traz sensor de estacionamento, sensor de
presença, sensor automotivo. Quem digita isso não está procurando um app de diabetes.

Mas essa nem é a briga que interessa. Quem digita "diabetes" está estudando o assunto.
Quem digita **"app para controlar diabetes"** está com o celular na mão querendo
instalar alguma coisa. A segunda pessoa vale muito mais, e nela dá para ganhar — porque
a concorrência ali é de outros apps, não de enciclopédias médicas.

## Onde dá para ser primeiro (e é aí que estamos mirando)

| Intenção | Termos | Dificuldade |
|---|---|---|
| **Quer instalar agora** | app para controlar diabetes · aplicativo para diabetes · app diabetes tipo 1 · aplicativo glicemia gratuito | Média — dá para ganhar |
| **Quer resolver uma tarefa** | diário de glicemia app · app para registrar glicemia · app contar carboidratos · aplicativo controle glicemia | Baixa/média — dá para ganhar |
| **Está comparando** | melhor app para diabetes · app diabetes gratuito brasileiro | Média |
| **Está estudando** | o que é hipoglicemia · sintomas diabetes tipo 2 | Alta — exige conteúdo médico revisado |
| **Genérico** | diabetes · sensor | Inviável — não perseguir |

## O que já está feito

- `robots.txt` e `sitemap.xml` (namespace `sitemaps.org` — plural; com o singular o
  Google descarta o arquivo).
- `canonical`, `hreflang`, `theme-color` e meta `robots` em todas as páginas.
- Dados estruturados JSON-LD:
  - Home: `Organization` + `WebSite` + `SoftwareApplication` (diz ao Google que isto é
    um aplicativo de saúde brasileiro, não mais um artigo sobre diabetes);
  - `/app-para-controlar-diabetes/`: `Article` + `BreadcrumbList`;
  - `/perguntas-frequentes/`: `FAQPage` — é o que faz a resposta aparecer expandida
    direto no resultado de busca.
- Títulos e descrições reescritos dentro do limite que o Google exibe (~60 e ~155
  caracteres) e mirando o que a pessoa digita.
- Duas páginas de conteúdo real (684 e 415 palavras), linkadas da home.
- Imagens da home convertidas de PNG para JPEG: 640 KB viraram 55 KB (91% menos),
  sem perda visível. Peso da página é fator de ranqueamento via Core Web Vitals.

Validação: `scripts/validar-seo.ps1` neste repositório confere títulos,
descrições, canonical, H1 único, JSON-LD válido, `alt` das imagens, volume de texto,
sitemap e links internos quebrados.

## O que só você pode fazer

### 1. Google Search Console (o passo mais importante)

Sem isso o Google descobre o site sozinho, mas devagar, e você fica cego.

1. Acesse `search.google.com/search-console` e adicione a propriedade
   `https://essentius.com.br`.
2. Verifique por **registro DNS TXT** (você já mexe no registro.br) ou por arquivo HTML.
3. Em *Sitemaps*, envie `sitemap.xml`.
4. Em *Inspeção de URL*, peça indexação das três páginas.

Feito isso, em 3 a 7 dias começam a aparecer os termos reais pelos quais as pessoas
chegam — e aí a estratégia deixa de ser palpite.

### 2. Backlinks (o que realmente move o ponteiro)

Conteúdo bom sem ninguém apontando para ele não sai do lugar. O que funciona no caso
do Essentius:

- Associações de diabetes (ADJ, ANAD, SBD) e grupos de pacientes;
- Perfis e comunidades de pessoas com diabetes no Instagram e YouTube;
- Endocrinologistas e nutricionistas que recomendariam a ferramenta;
- Diretórios de apps de saúde brasileiros;
- Imprensa local sobre saúde digital.

Um link de uma associação de diabetes vale mais que cem de diretórios genéricos.

### 3. Publicar nas lojas

Estar na Play Store e na App Store gera busca por marca, resenhas e links — e o próprio
Google mostra o card do app. É o maior salto de autoridade que o Essentius pode ter.

### 4. Conteúdo médico, quando houver quem assine

Diabetes é tema **YMYL** (*Your Money or Your Life*): o Google avalia por E-E-A-T e
exige autoria ou revisão de profissional de saúde. Conteúdo médico assinado por
"Essentius" não ranqueia e, pior, é irresponsável.

Por isso as páginas de hoje falam **do produto**, não de medicina. Quando houver um
endocrinologista ou nutricionista parceiro que assine e revise, aí sim vale abrir a
trilha de conteúdo clínico — com nome, CRM e data de revisão visíveis na página. Essa é
a próxima grande alavanca, e ela depende de uma pessoa, não de código.

## Próximos passos técnicos

1. **Tailwind por CDN**: o navegador compila o CSS em tempo de execução, o que atrasa a
   primeira renderização. Gerar o CSS na build resolve.
2. **Mais páginas de intenção**, uma por termo da tabela acima — sempre com conteúdo de
   verdade. Três páginas boas valem mais que trinta rasas; página fina hoje é penalizada.

## Expectativa honesta de prazo

- **Semana 1–2**: indexação das páginas novas.
- **Mês 1–3**: começa a aparecer para os termos de cauda longa ("app para registrar
  glicemia").
- **Mês 3–6**: disputa real pelos termos comerciais, *se* houver backlinks e conteúdo
  novo com constância.
- **Marca ("essentius")**: primeiro lugar rápido, porque não há concorrência.

SEO não tem atalho e não tem garantia. O que dá para garantir é que a base está certa —
o que não estava.
