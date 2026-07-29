# Valida o SEO tecnico do site antes de publicar.
$w = Split-Path -Parent $PSScriptRoot
$falhas = 0

function Falhou($msg) { $script:falhas++; "  FALHA $msg" }
function Ok($msg) { "  OK    $msg" }

$paginas = @(
    @{ arq = "$w\index.html";                              url = "https://essentius.com.br/" },
    @{ arq = "$w\app-para-controlar-diabetes\index.html";  url = "https://essentius.com.br/app-para-controlar-diabetes/" },
    @{ arq = "$w\perguntas-frequentes\index.html";         url = "https://essentius.com.br/perguntas-frequentes/" }
)

foreach ($p in $paginas) {
    $nome = Split-Path (Split-Path $p.arq -Parent) -Leaf
    "`n== $nome =="
    if (-not (Test-Path $p.arq)) { Falhou "arquivo nao existe"; continue }
    $html = [System.Text.Encoding]::UTF8.GetString([System.IO.File]::ReadAllBytes($p.arq))

    # title
    $titulo = ([regex]::Match($html, '(?s)<title>(.*?)</title>')).Groups[1].Value.Trim()
    if (-not $titulo) { Falhou "sem <title>" }
    elseif ($titulo.Length -gt 62) { Falhou "title com $($titulo.Length) chars (Google corta ~60): $titulo" }
    else { Ok "title ($($titulo.Length) chars)" }

    # description
    $desc = ([regex]::Match($html, '<meta name="description" content="([^"]*)"')).Groups[1].Value
    if (-not $desc) { Falhou "sem meta description" }
    elseif ($desc.Length -gt 160) { Falhou "description com $($desc.Length) chars (corta em ~155)" }
    elseif ($desc.Length -lt 70) { Falhou "description curta demais ($($desc.Length) chars)" }
    else { Ok "description ($($desc.Length) chars)" }

    # canonical correto
    $canon = ([regex]::Match($html, '<link rel="canonical" href="([^"]*)"')).Groups[1].Value
    if ($canon -ne $p.url) { Falhou "canonical '$canon' deveria ser '$($p.url)'" } else { Ok "canonical" }

    # um unico h1
    $h1s = [regex]::Matches($html, '<h1[^>]*>')
    if ($h1s.Count -ne 1) { Falhou "$($h1s.Count) tags h1 (tem que ser exatamente 1)" } else { Ok "h1 unico" }

    # JSON-LD valido
    $blocos = [regex]::Matches($html, '(?s)<script type="application/ld\+json">(.*?)</script>')
    if ($blocos.Count -eq 0) { Falhou "sem JSON-LD" }
    foreach ($b in $blocos) {
        try { $b.Groups[1].Value | ConvertFrom-Json | Out-Null; Ok "JSON-LD valido" }
        catch { Falhou "JSON-LD invalido: $($_.Exception.Message)" }
    }

    # imagens com alt
    $imgs = [regex]::Matches($html, '<img[^>]*>')
    $semAlt = @($imgs | Where-Object { $_.Value -notmatch 'alt=' })
    if ($semAlt.Count -gt 0) { Falhou "$($semAlt.Count) imagem(ns) sem alt" } else { Ok "imagens com alt ($($imgs.Count))" }

    # volume de texto
    $texto = ($html -replace '(?s)<script.*?</script>','' -replace '(?s)<style.*?</style>','' -replace '<[^>]+>',' ' -replace '\s+',' ').Trim()
    $palavras = ($texto -split ' ').Count
    if ($palavras -lt 300) { Falhou "so $palavras palavras (fino demais para ranquear)" } else { Ok "$palavras palavras" }
}

"`n== arquivos de indexacao =="
if (Test-Path "$w\robots.txt") { Ok "robots.txt" } else { Falhou "robots.txt ausente" }
if (Test-Path "$w\sitemap.xml") {
    try {
        $xml = [xml](Get-Content "$w\sitemap.xml" -Raw)
        $ns = $xml.DocumentElement.NamespaceURI
        if ($ns -ne "http://www.sitemaps.org/schemas/sitemap/0.9") { Falhou "namespace do sitemap errado: $ns" }
        else { Ok "sitemap.xml valido ($($xml.urlset.url.Count) URLs)" }
        # toda URL do sitemap tem que existir como arquivo
        foreach ($u in $xml.urlset.url) {
            $rel = ($u.loc -replace 'https://essentius.com.br/','') -replace '/$',''
            $alvo = if ($rel -eq '') { "$w\index.html" } else { "$w\$rel\index.html" }
            if (-not (Test-Path $alvo)) { Falhou "sitemap aponta para $($u.loc) mas o arquivo nao existe" }
        }
    } catch { Falhou "sitemap.xml invalido: $($_.Exception.Message)" }
} else { Falhou "sitemap.xml ausente" }

"`n== links internos =="
foreach ($p in $paginas) {
    if (-not (Test-Path $p.arq)) { continue }
    $html = [System.Text.Encoding]::UTF8.GetString([System.IO.File]::ReadAllBytes($p.arq))
    foreach ($href in ([regex]::Matches($html, 'href="(/[^"#]*)"') | ForEach-Object { $_.Groups[1].Value } | Select-Object -Unique)) {
        $rel = $href.TrimStart('/').TrimEnd('/')
        $alvo = if ($rel -eq '') { "$w\index.html" } elseif ($rel -match '\.\w+$') { "$w\$($rel -replace '/','\')" } else { "$w\$($rel -replace '/','\')\index.html" }
        if (-not (Test-Path $alvo)) { Falhou "$(Split-Path (Split-Path $p.arq -Parent) -Leaf): link quebrado -> $href" }
    }
}
if ($falhas -eq 0) { Ok "nenhum link interno quebrado" }

""
if ($falhas -eq 0) { "RESULTADO: SEO tecnico OK." } else { "RESULTADO: $falhas problema(s)."; exit 1 }
