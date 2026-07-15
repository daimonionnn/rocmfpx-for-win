# Confirmation point: 128K prefill on the ROCm 7 gfx1151 build (b1295).
# Control (b9910) at 131072 = 32.34 t/s (~68 min TTFT). Appends to the rocm7 CSV.
$ErrorActionPreference = 'Continue'
# Historical: the ROCm 7 build originally lived side-by-side in bin-rocm7-gfx1151\ during the
# A/B; it has since become the default bin\ (Setup.ps1). Kept relative for reproducibility.
$devRoot = Split-Path (Split-Path $PSScriptRoot -Parent) -Parent
$bin  = "$devRoot\llm-bench\bin\llama-bench.exe"
$qwen = "$env:USERPROFILE\.lmstudio\models\unsloth\Qwen3.6-27B-MTP-GGUF\Qwen3.6-27B-UD-Q4_K_XL.gguf"
$out  = "$PSScriptRoot\..\results\longctx-prefill-rocm7.csv"

$args = @('-m',$qwen,'-ngl','-1','-fa','on','-p','131072','-n','0','-t','16','-r','2','-ub','1024')
Write-Host "> llama-bench $($args -join ' ')" -ForegroundColor DarkGray
$md = & $bin @args -o md 2>$null
$code = $LASTEXITCODE
$md | ForEach-Object { Write-Host $_ }
if ($code -ne 0) { Write-Host "  (rocm7 pp131072 FAILED, code $code)" -ForegroundColor Red; exit 1 }
$csv = & $bin @args -o csv 2>$null
$lines = $csv -split "`r?`n" | Where-Object { $_ -ne '' }
foreach ($d in ($lines | Select-Object -Skip 1)) { $d | Out-File $out -Append -Encoding utf8 }
Write-Host "`nDONE -> $out" -ForegroundColor Green
