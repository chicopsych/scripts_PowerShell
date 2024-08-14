# verifica a politica de execução de scripts
# e a configura para Unrestricted

function policyExecution {
    $policy = Get-ExecutionPolicy
    if ($policy -eq "Restricted") {
        Write-Host "A política de execução de scripts está configurada como Restricted"
        Write-Host "Configurando a política de execução de scripts para Unrestricted"
        Set-ExecutionPolicy Unrestricted
    } else {
        Write-Host "A política de execução de scripts está configurada como $policy"
    }                               
}

policyExecution
