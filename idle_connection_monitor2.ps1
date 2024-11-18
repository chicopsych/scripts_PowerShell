# Script para monitorar conexões ociosas no servidor SMB Windows
# Autor: Francisco Luvisari Scavassa
# Data: 2024-11-18
# Versão: 1.1

# Configuração inicial
$continue = "S"
$set_session_time = 300 # Tempo máximo de existência da sessão (em segundos)
$set_session_idle = 30  # Tempo máximo de ociosidade permitido (em segundos)

# Função para fechar sessões antigas ou ociosas
function Close-IdleSessions {
  # Obtem todas as sessões SMB
  $sessions = Get-SmbSession

  foreach ($session in $sessions) {
    # Fecha sessões ociosas
    if ($session.NumOpens -eq 0 -and $session.SecondsExists -gt $set_session_time -and $session.SecondsIdle -gt $set_session_idle) {
      Write-Host "Fechando sessão ociosa: ID $($session.SessionId), Usuário $($session.ClientUserName)"
      Close-SmbSession -SessionId $session.SessionId -Force
    }
  }

  # Verifica se o número total de sessões ultrapassou o limite e fecha a mais antiga
  if ($sessions.Count -gt 20) {
    $oldestSession = $sessions | Sort-Object SecondsExists -Descending | Select-Object -First 1
    Write-Host "Fechando sessão mais antiga: ID $($oldestSession.SessionId), Usuário $($oldestSession.ClientUserName)"
    Close-SmbSession -SessionId $oldestSession.SessionId -Force
  }
}

# Loop de monitoramento
do {
  # Obtem o número de sessões abertas
  $session_count = (Get-SmbSession | Measure-Object).Count

  if ($session_count -eq 0) {
    # Pergunta ao administrador se deseja continuar monitorando
    $continue = Read-Host "Nenhuma sessão aberta. Deseja monitorar novamente? (S/N)"
    if ($continue -eq "N") {
      Write-Host "Monitoramento encerrado."
      break
    }
    elseif ($continue -ne "S") {
      Write-Host "Opção inválida. Por favor, digite S ou N."
      $continue = "S"
    }
  }
  else {
    Write-Host "Sessões abertas detectadas: $session_count"
    Close-IdleSessions
  }

  # Pausa o monitoramento por 60 segundos
  Start-Sleep -Seconds 60

} while ($continue -eq "S")

Write-Host "Script encerrado."
