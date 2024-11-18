# Scrip para monitorar conexões ociosas no servidor smb windows
# Autor: Francisco Luvisari Scavassa
# Data: 2024-11-18
# Versão: 1.0

# Monitorar tempo de sessão de usuários no compartilhamento SMB

# Variaveis
$session_count = 0
$continue = "S"
$id_old_session = 0
$set_session_time = 300
$set_session_idle = 30



# Função para monitorar sessões
do {
  # Conta numero de sessões abertas com o servidor local
  $session_count = (Get-SmbSession | Measure-Object).Count

  if ($session_count -eq 0) {
    # Pergunta ao administrador se deseja monitorar novamente
    $continue = Read-Host "Nenhuma sessão aberta. Deseja monitorar novamente? (S/N)"
    if ($continue -eq "S") {
      # Continua monitorando
      Write-Host "Monitorando novamente..."
    }
    elseif ($continue -eq "N") {
      Write-Host "Monitoramento encerrado."
      break
    }
    else {
      Write-Host "Opção inválida. Por favor, digite S ou N."
      $continue = Read-Host "Deseja monitorar novamente? (S/N)"
    }


  }
  else {
    Write-Host "Sessões abertas detectadas: $session_count"
  }
} while ($session_count -gt 0 -or $continue -eq "S") {

  for ($i = 0; $i -le $session_count; $i++) {
    $id_session = Get-SmbSession | Select-Object -Index[$i]
    if ($id_session.NumOpens -eq 0) {
      if($id_session.SecondsExists -gt $set_session_time) {
        if ($id_session.SecondsIdle -gt $set_session_idle) {
          Close-SmbSession -SessionId $id_session.SessionId -Force
        }

      }
    } else {
      if ($session_count -eq 20) {
        $id_old_session.SessionId = Get-SmbSession | Sort-Object SecondsExists -Descending | Select-Object -First 1
        Close-SmbSession -SessionId $id_old_session.SessionId -Force
      }
    }

  }
  
  start-sleep -Seconds 60
}
