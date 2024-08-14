# Script para implementar protetor de tela para usuários do Windows
# Autor: Francisco Luvisari Scavassa
# Data: 2024-08-09
# Versão: 1.4.1b - teste de hash para verificar se o protetor de tela foi alterado

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

# Função para logar mensagens
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

# Função para copiar protetor de tela do servidor para a máquina local
function CopyScreenSaver {
    Write-LogMessage "Iniciando cópia do protetor de tela..."
    try {
        if (-Not (Test-Path $pastaProtetorDeTela)) {
            New-Item -Path $pastaProtetorDeTela -ItemType Directory
            Write-LogMessage "Pasta temporária criada"
        }

        if (-Not (Test-Path $protetorDeTela)) {
            Copy-Item -Path $protetorDeTelaNoServidor -Destination $protetorDeTela -ErrorAction Stop
            Write-LogMessage "Protetor de tela copiado para a pasta temporária"
        } else {
            Write-LogMessage "Protetor de tela já existe na pasta temporária"
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
        Write-LogMessage "Protetor de tela exige senha para desbloqueio"
        Set-ItemProperty -Path $registryPath -Name ScreenSaverIsSecure -Value 0
    }
    Write-LogMessage "Protetor de tela verificado e ativado."
}

# Função para definir o tempo de inatividade para ativação do protetor de tela
function SetScreenSaveTimeOut {
    $timeout = 60
    Write-LogMessage "Definindo tempo de inatividade para ativação do protetor de tela..."
    if ($screenSaveTimeOut.ScreenSaveTimeOut -ne $timeout) {
        Write-LogMessage "Definindo tempo de inatividade para ativação do protetor de tela: 1 minuto"
        Set-ItemProperty -Path $registryPath -Name ScreenSaveTimeOut -Value $timeout
    } else {
        Write-LogMessage "Tempo de inatividade já está configurado para 1 minuto"
    }
    Write-LogMessage "Tempo de inatividade definido."
}

# Função para definir o protetor de tela copiado para pasta temporária
function SetScreenSaver {
    $defaultSaver = "$env:TEMP\protetordetela\protetorDeTela.scr"
    Write-LogMessage "Definindo o protetor de tela..."
    if ($scrnSave.'SCRNSAVE.EXE' -ne $defaultSaver) {
        Write-LogMessage "Definindo protetor de tela para: protetorDeTela.scr"
        Set-ItemProperty -Path $registryPath -Name SCRNSAVE.EXE -Value $defaultSaver
    } else {
        Write-LogMessage "Protetor de tela já está definido como protetorDeTela.scr"
    }
    Write-LogMessage "Protetor de tela definido."
}
# Executa teste de hash para verificar nessecidade de executar o resto do script
function HashTest {
    $hashLocal = Get-FileHash -Path $protetorDeTela -Algorithm SHA1
    Write-LogMessage "Hash local: $($hashLocal.Hash)"
    $hashServidor = Get-FileHash -Path $protetorDeTelaNoServidor -Algorithm SHA1
    Write-LogMessage "Hash servidor: $($hashServidor.Hash)"
    if ($hashLocal.Hash -ne $hashServidor.Hash) {
        Write-LogMessage "Hashes diferentes. Copiando protetor de tela do servidor para a máquina local..."
        CopyScreenSaver
        CheckAndActivateScreenSaver
        SetScreenSaveTimeOut
        SetScreenSaver
    } else {
        Write-LogMessage "Hashes iguais. Protetor de tela já está atualizado."
    }
}

# Fim do script
Write-LogMessage "Script finalizado."