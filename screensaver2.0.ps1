# Script para implementar protetor de tela para usuários do Windows
# Autor: Francisco Luvisari Scavassa
# Data: 2024-08-09
# Versão: 1.4.2b - teste de hash para verificar se o protetor de tela foi alterado

# Variáveis globais
$registryPath = "HKCU:\Control Panel\Desktop"
$screenSaveActive = Get-ItemProperty -Path $registryPath -Name ScreenSaveActive
$screenSaverIsSecure = Get-ItemProperty -Path $registryPath -Name ScreenSaverIsSecure
$screenSaveTimeOut = Get-ItemProperty -Path $registryPath -Name ScreenSaveTimeOut
$scrnSave = Get-ItemProperty -Path $registryPath -Name SCRNSAVE.EXE

$protetorDeTela = "$env:TEMP\protetordetela\protetorDeTela.scr"
$protetorDeTelaNoServidor = "D:\teste\test_screensaver\protetorDeTela.scr"
$pastaProtetorDeTela = "$env:TEMP\protetordetela"
$logFile = "$pastaProtetorDeTela\script_log.txt"
$timeInactivity = 60 # Tempo de inatividade em segundos

# Função de log do script
function Write-LogMessage {
    param (
        [string]$message
    )
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logEntry = "$timestamp - $message"
    Write-Host $logEntry
    if (-Not (Test-Path $pastaProtetorDeTela)) {
        New-Item -Path $pastaProtetorDeTela -ItemType Directory | Out-Null
    }
    $logEntry | Out-File -FilePath $logFile -Append -Encoding utf8
}

# Função de comparação de Hash dos arquivos origem e destino
function comparaHashes() {
    param (

    )
    $hash1 = Get-FileHash -Path $arquivo1 -Algorithm MD5
    $hash2 = Get-FileHash -Path $arquivo2 -Algorithm MD5
    if ($hash1.Hash -eq $hash2.Hash) {
        return $true
    } else {
        return $false
    }    
}