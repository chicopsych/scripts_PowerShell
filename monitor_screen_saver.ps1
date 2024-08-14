# Script para monitorar protetor de tela e executar a atulização do papel de parede bginfo
# Autor: Francisco Luvisari Scavassa
# Data: 2024-08-09
# Versão: 1.0

# Variáveis globais
$processName = "protetorDeTela.scr"
$processActive

# Função procurar pelo processo
function Get-Proccess {
    param (
        [string]$processName
    )
    $process = Get-Process -Name $processName -ErrorAction SilentlyContinue
    if ($process) {

        Write-Host "Protetor de tela ativo"
    } else {
        Write-Host "Protetor de tela inativo"
    }
}


# Função para verificar se o protetor de tela está ativo
while ($true) {
    Clear-Host
    Get-Process -Name $processName
    Start-Sleep -Seconds 1
}

# chama bat para atualizar papel de parede
Invoke-Expression -Command "papel"
