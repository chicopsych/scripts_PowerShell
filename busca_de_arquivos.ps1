# Busca de arquivos por extensão em um diretório
# Autor: Francisco Luvisari Scavassa
# Data: 2024-11-26
# Versão: 1.1

# Função: Pergunta qual extensão de arquivo deseja buscar
function Get-FileType {
  param (
      [string]$Prompt = "Qual extensão de arquivo deseja buscar?"
  )
  $type = Read-Host $Prompt
  return $type
}

# Função: Pergunta qual diretório ou unidade deseja buscar
function Get-DirectoryPath {
  param (
      [string]$Prompt = "Qual diretório ou unidade deseja buscar?"
  )
  $path = Read-Host $Prompt
  return $path
}

# Função: Busca arquivos no diretório e subdiretórios e grava o resultado em um arquivo txt
function Search-File {
  param (
      [string]$type,   # Extensão do arquivo (sem o ponto, ex.: txt, jpg)
      [string]$path    # Diretório onde a busca será realizada
  )

  Write-Host "Iniciando busca de arquivos com a extensão '$type' no diretório '$path'..."

  # Valida o caminho do diretório de busca
  if (!(Test-Path -Path $path)) {
      Write-Host "Diretório '$path' não encontrado. O script será encerrado."
      return
  }

  # Solicita o diretório para salvar os resultados
  $pathResult = Get-DirectoryPath -Prompt "Onde deseja salvar o resultado da busca? (Caminho completo)"
  if (!(Test-Path -Path $pathResult)) {
      Write-Host "Diretório não encontrado. Deseja criar ou informar outro caminho?"
      $answer = Read-Host "Digite 'criar' para criar o diretório ou 'não' para informar outro caminho"

      if ($answer -eq "criar") {
          try {
              New-Item -Path $pathResult -ItemType Directory -Force | Out-Null
              Write-Host "Diretório criado com sucesso em '$pathResult'"
          } catch {
              Write-Host "Erro ao criar o diretório. Verifique as permissões e tente novamente."
              return
          }
      } else {
          $pathResult = Get-DirectoryPath -Prompt "Digite o caminho do diretório novamente"
          if (!(Test-Path -Path $pathResult)) {
              Write-Host "Diretório ainda não encontrado. Encerrando o script."
              return
          }
      }
  }

  # Busca arquivos com a extensão especificada
  try {
      $files = Get-ChildItem -Path $path -Recurse -Filter "*.$type" | Select-Object -ExpandProperty FullName
  } catch {
      Write-Host "Erro ao buscar arquivos no diretório '$path'. Verifique o caminho e tente novamente."
      return
  }

  # Exibe e salva os resultados
  if ($files.Count -eq 0) {
      Write-Host "Nenhum arquivo com a extensão '$type' foi encontrado no diretório '$path'."
  } else {
      Write-Host "Arquivos encontrados:"
      $files | ForEach-Object { Write-Host $_ }

      # Salva os resultados em um arquivo no diretório de destino
      try {
          $resultFilePath = Join-Path -Path $pathResult -ChildPath "ResultadoBusca.txt"
          $files | Out-File -FilePath $resultFilePath -Encoding UTF8
          Write-Host "Resultados salvos com sucesso em '$resultFilePath'"
      } catch {
          Write-Host "Erro ao salvar os resultados no diretório '$pathResult'. Verifique as permissões."
      }
  }
}

# Execução do script
$type = Get-FileType
$path = Get-DirectoryPath
Search-File -type $type -path $path
