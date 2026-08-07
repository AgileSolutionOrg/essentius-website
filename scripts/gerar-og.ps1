Add-Type -AssemblyName System.Drawing
$dir = "C:\Users\Gildonei\OneDrive - Agile Solution LTDA\Documentos\My Works\Trabalho Brasil\Agile Solution\Projetos Github Agile Solution\essentius-website\assets"

# 1200x630 e o formato do card grande. Mas o WhatsApp, quando cai no layout
# compacto, RECORTA O QUADRADO CENTRAL e descarta as laterais. Entao toda a
# composicao fica dentro de uma zona segura de 630x630 no meio: nas laterais
# so o degradee. Assim a arte funciona como banner E como miniatura quadrada.
$W = 1200; $H = 630
$ZONA = 630                      # lado do quadrado central
$zx0 = [int](($W - $ZONA) / 2)   # 285
$zx1 = $zx0 + $ZONA              # 915
$MAXL = $ZONA - 40               # largura util com respiro: 590 px

$bmp = New-Object System.Drawing.Bitmap $W, $H, ([System.Drawing.Imaging.PixelFormat]::Format24bppRgb)
$g = [System.Drawing.Graphics]::FromImage($bmp)
$g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
$g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
$g.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
$g.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::AntiAliasGridFit

# fundo com o gradiente do site
$rect = New-Object System.Drawing.Rectangle 0, 0, $W, $H
$grad = New-Object System.Drawing.Drawing2D.LinearGradientBrush(
  $rect,
  [System.Drawing.ColorTranslator]::FromHtml("#070C1B"),
  [System.Drawing.ColorTranslator]::FromHtml("#2A1B58"), 35.0)
$blend = New-Object System.Drawing.Drawing2D.ColorBlend 3
$blend.Colors = @(
  [System.Drawing.ColorTranslator]::FromHtml("#070C1B"),
  [System.Drawing.ColorTranslator]::FromHtml("#16255A"),
  [System.Drawing.ColorTranslator]::FromHtml("#3A1D6E"))
$blend.Positions = @(0.0, 0.55, 1.0)
$grad.InterpolationColors = $blend
$g.FillRectangle($grad, $rect)

# PathGradientBrush da uma queda continua do centro para a borda. Empilhar
# elipses solidas (a versao anterior) produzia aneis concentricos visiveis --
# que passavam despercebidos atras do texto, mas saltavam num fundo limpo.
function Brilho($cx, $cy, $r, $cor, $alphaMax) {
  $path = New-Object System.Drawing.Drawing2D.GraphicsPath
  $path.AddEllipse(($cx - $r), ($cy - $r), ($r * 2), ($r * 2))
  $pgb = New-Object System.Drawing.Drawing2D.PathGradientBrush($path)
  $pgb.CenterPoint = New-Object System.Drawing.PointF($cx, $cy)
  $pgb.CenterColor = [System.Drawing.Color]::FromArgb($alphaMax, $cor)
  $pgb.SurroundColors = @([System.Drawing.Color]::FromArgb(0, $cor))
  # Sem SetSigmaBellShape: com focus < 1 ele joga a cor de borda (transparente)
  # para o centro e abre um buraco escuro exatamente no miolo do brilho.
  $g.FillPath($pgb, $path)
  $pgb.Dispose(); $path.Dispose()
}
Brilho 250 150 330 ([System.Drawing.ColorTranslator]::FromHtml("#22D3EE")) 44
Brilho 950 200 350 ([System.Drawing.ColorTranslator]::FromHtml("#8B5CF6")) 50
Brilho 600 600 360 ([System.Drawing.ColorTranslator]::FromHtml("#3B82F6")) 38

# So a marca. Sem texto: o titulo e a descricao ja vem das meta tags e aparecem
# ao lado do card -- repetir a chamada dentro da imagem era ruido, e era o que
# estourava a zona segura e apanhava no recorte quadrado.
$logo = [System.Drawing.Image]::FromFile("$dir\logo-horizontal.png")
$lw = 540
$lh = [int]($logo.Height * $lw / $logo.Width)
Write-Output ("zona segura: {0} px de largura util" -f $MAXL)
Write-Output ("  logo      {0,4} px  {1}" -f $lw, $(if ($lw -le $MAXL) {"cabe"} else {"ESTOURA"}))
if ($lw -gt $MAXL) { throw "o logo estoura a zona segura -- seria cortado na miniatura" }

$g.DrawImage($logo, (New-Object System.Drawing.Rectangle ([int](($W - $lw)/2)), ([int](($H - $lh)/2)), $lw, $lh))
$logo.Dispose()

$g.Dispose()

$codec = [System.Drawing.Imaging.ImageCodecInfo]::GetImageEncoders() | Where-Object { $_.MimeType -eq 'image/jpeg' }
$par = New-Object System.Drawing.Imaging.EncoderParameters 1
$par.Param[0] = New-Object System.Drawing.Imaging.EncoderParameter ([System.Drawing.Imaging.Encoder]::Quality, 92L)
$bmp.Save("$dir\og-essentius.jpg", $codec, $par)

# miniatura quadrada de prova: exatamente o que o WhatsApp recorta
$sq = New-Object System.Drawing.Bitmap $ZONA, $ZONA, ([System.Drawing.Imaging.PixelFormat]::Format24bppRgb)
$g2 = [System.Drawing.Graphics]::FromImage($sq)
$g2.DrawImage($bmp, (New-Object System.Drawing.Rectangle 0, 0, $ZONA, $ZONA),
                    (New-Object System.Drawing.Rectangle $zx0, 0, $ZONA, $ZONA),
                    [System.Drawing.GraphicsUnit]::Pixel)
$g2.Dispose()
$prova = "C:\Users\Gildonei\AppData\Local\Temp\claude\C--Users-Gildonei\c4b6a0da-d339-4783-acae-cd5a8dfd8530\scratchpad\prova-quadrada.jpg"
$sq.Save($prova, $codec, $par)
$sq.Dispose(); $bmp.Dispose()

$f = Get-Item "$dir\og-essentius.jpg"
Write-Output ("gerado: {0}  {1}x{2}  {3} KB" -f $f.Name, $W, $H, [int]($f.Length/1KB))
Write-Output ("prova do recorte quadrado: {0}" -f $prova)
