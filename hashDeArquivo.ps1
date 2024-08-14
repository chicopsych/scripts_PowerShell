#Executa teste sha1 no aquivo local
$hashLocal = Get-FileHash -Path $protetorDeTela -Algorithm SHA1
Write-LogMessage "Hash local: $($hashLocal.Hash)"
#Executa teste sha1 no aquivo do servidor
$hashServidor = Get-FileHash -Path $protetorDeTelaNoServidor -Algorithm SHA1
Write-LogMessage "Hash servidor: $($hashServidor.Hash)"
#Compara os hashes e copia o arquivo do servidor para a máquina local se forem diferentes
if ($hashLocal.Hash -ne $hashServidor.Hash) {
    Write-LogMessage "Hashes diferentes. Copiando protetor de tela do servidor para a máquina local..."
    CopyScreenSaver
    CheckAndActivateScreenSaver
} else {
    Write-LogMessage "Hashes iguais. Protetor de tela já está atualizado."
}