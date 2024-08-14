# Script para implementar protetor de tela para usuários do Windows
# Autor: Francisco Luvisari Scavassa
# Data: 2024-08-09
# Versão: 2.0

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
function ComparaHashes {
    $hash1 = Get-FileHash -Path $protetorDeTela -Algorithm MD5
    $hash2 = Get-FileHash -Path $protetorDeTelaNoServidor -Algorithm MD5
    if ($hash1.Hash -eq $hash2.Hash) {
        Write-LogMessage "Hashes iguais"
        return $true
    } else {
        Write-LogMessage "Hashes diferentes"
        Write-LogMessage "Hash1: $($hash1.Hash)"
        Write-LogMessage "Hash2: $($hash2.Hash)"
        return $false
    }
}

# Função para copiar o protetor de tela para a pasta temporária
function CopyScreenSaver {
    Write-LogMessage "Iniciando cópia do protetor de tela..."
    try {
        if (-Not (Test-Path $pastaProtetorDeTela)) {
            New-Item -Path $pastaProtetorDeTela -ItemType Directory
            Write-LogMessage "Pasta temporária criada"
        }

        if (-Not (Test-Path $protetorDeTela) -or -Not (ComparaHashes)) {
            Copy-Item -Path $protetorDeTelaNoServidor -Destination $protetorDeTela -Force -ErrorAction Stop
            Write-LogMessage "Protetor de tela copiado para a pasta temporária"
        } else {
            Write-LogMessage "Protetor de tela já existe na pasta temporária e está atualizado"
        }
    } catch {
        Write-LogMessage "Erro ao copiar o protetor de tela: $_"
    }
    Write-LogMessage "Cópia do protetor de tela finalizada."
}

# Função para verificar e ativar o protetor de tela
function CheckAndActivateScreenSaver {
    Write-LogMessage "Verificando e ativando o protetor de tela..."
    if ($screenSaveActive.ScreenSaveActive -ne 1) {
        Write-LogMessage "Protetor de tela estava inativo! ...ativando..."
        Set-ItemProperty -Path $registryPath -Name ScreenSaveActive -Value 1
    } else {
        Write-LogMessage "Protetor de tela ativo"
    }

    if ($screenSaverIsSecure.ScreenSaverIsSecure -ne 1) {
        Write-LogMessage "Protetor de tela não exige senha para desbloqueio"
    } else {
        Write-LogMessage "Desativando exigência de senha para desbloqueio"
        Set-ItemProperty -Path $registryPath -Name ScreenSaverIsSecure -Value 0
    }
    Write-LogMessage "Protetor de tela verificado e ativado."
}

# Função para definir o tempo de inatividade para ativação do protetor de tela
function SetScreenSaveTimeOut {
    Write-LogMessage "Definindo tempo de inatividade para ativação do protetor de tela..."
    if ($screenSaveTimeOut.ScreenSaveTimeOut -ne $timeInactivity) {
        Write-LogMessage "Definindo tempo de inatividade para ativação do protetor de tela: $timeInactivity segundos"
        Set-ItemProperty -Path $registryPath -Name ScreenSaveTimeOut -Value $timeInactivity
    } else {
        Write-LogMessage "Tempo de inatividade já está configurado para $timeInactivity segundos"
    }
    Write-LogMessage "Tempo de inatividade definido."
}

# Função para definir o protetor de tela copiado para pasta temporária
function SetScreenSaver {
    Write-LogMessage "Definindo o protetor de tela..."
    if ($scrnSave.'SCRNSAVE.EXE' -ne $protetorDeTela) {
        Write-LogMessage "Definindo protetor de tela para: protetorDeTela.scr"
        Set-ItemProperty -Path $registryPath -Name SCRNSAVE.EXE -Value $protetorDeTela
    } else {
        Write-LogMessage "Protetor de tela já está definido"
    }
    Write-LogMessage "Protetor de tela definido."
}

# Início da execução do script
Write-LogMessage "Início da execução do script"
# Verifica se o arquivo do protetor de tela está na pasta temporária e se precisa ser atualizado
if (-Not (Test-Path $protetorDeTela) -or -Not (ComparaHashes)) {
    CopyScreenSaver
}

CheckAndActivateScreenSaver
SetScreenSaveTimeOut
SetScreenSaver
