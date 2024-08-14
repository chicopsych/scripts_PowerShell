# Script para implementar protetor de tela para usuarios do Windows
# Autor: Francisco Luvisari Scavassa
# Data: 2024-08-05
# Versão: 1.0

# Variaveis globais
$screenSaveActive = Get-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name ScreenSaveActive
$screenSaverIsSecure = Get-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name ScreenSaverIsSecure
$screenSaveTimeOut = Get-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name ScreenSaveTimeOut
$scrnSave = Get-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name SCRNSAVE.EXE

$protetorDeTela = "%temp%\protetordetela\scrnsave.scr"
$protetorDeTelaNoServidor = "\\servidor\compartilhamento\protetorDeTela.scr"
$pastaTemp = "%temp%"
$pastaProtetorDeTela = "%temp%\protetordetela"

# Função para copiar protetor de tela do servidor para a máquina local
function CopyScreenSaver {
    # Verificando se a pasta temporária existe
    if (Test-Path $pastaTemp) {
        # Verificando se o protetor de tela já existe na pasta temporária
        if (Test-Path $protetorDeTela) {
            Write-Host "Protetor de tela já existe na pasta temporária"
        } else {
            # Copiando protetor de tela para a pasta temporária
            Copy-Item -Path $protetorDeTelaNoServidor -Destination $protetorDeTela
            Write-Host "Protetor de tela copiado para a pasta temporária"
        }
    } else {
        Write-Host "Pasta temporária não existe"
        # Criando pasta temporária
        New-Item -Path $pastaProtetorDeTela -ItemType Directory
        Write-Host "Pasta temporária criada"
        # Copiando protetor de tela para a pasta temporária
        Copy-Item -Path $protetorDeTelaNoServidor -Destination $protetorDeTela
        Write-Host "Protetor de tela copiado para a pasta temporária"
    }
}

# Função para verificar se o protetor de tela está ativo
function CheckScreenSaveActive {
    if ($screenSaveActive.ScreenSaveActive -eq 1) {
        Write-Host "Protetor de tela ativo"
    } else {
        Write-Host "Protetor de tela estava inativo! ...ativando..."
        # Ativando protetor de tela
        Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name ScreenSaveActive -Value 1
    }
}

# Função para verificar se o protetor de tela é seguro
function CheckScreenSaverIsSecure {
    if ($screenSaverIsSecure.ScreenSaverIsSecure -eq 0) {
        Write-Host "Protetor de tela nao exige senha para desbloqueio"
    } else {
        Write-Host "Protetor de tela exige senha para desbloqueio"
        # Desativando senha para desbloqueio
        Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name ScreenSaverIsSecure -Value 0
    }
}

# Função para definir o tempo de inatividade para ativação do protetor de tela
function SetScreenSaveTimeOut {
    if ($screenSaveTimeOut.ScreenSaveTimeOut -eq 600) {
        Write-Host "Tempo de inatividade para ativação do protetor de tela: 10 minutos"
    } else {
        Write-Host "Tempo de inatividade para ativação do protetor de tela: 10 minutos"
        # Definindo tempo de inatividade para ativação do protetor de tela
        Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name ScreenSaveTimeOut -Value 600
    }
}

# Função para definir o protetor de tela
function SetScreenSaver {
    if ($scrnSave.SCRNSAVE.EXE -eq "C:\Windows\system32\scrnsave.scr") {
        Write-Host "Protetor de tela: scrnsave.scr"
    } else {
        Write-Host "Protetor de tela: scrnsave.scr"
        # Definindo protetor de tela
        Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name SCRNSAVE.EXE -Value "C:\Windows\system32\scrnsave.scr"
    }
}

# Chamando funções
CopyScreenSaver
CheckScreenSaveActive
CheckScreenSaverIsSecure
SetScreenSaveTimeOut
SetScreenSaver

# fim do script