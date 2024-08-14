Write-Output . 'Iniciando back-up da pasta sql ged';
Write-Output . 'Movendo arquivos para compactacao'. .;
robocopy D:\bkp_ged 'D:\teste_bkp' *.BAK /s /e /j /dcopy:dat /mov
Write-Output 'Transferencia concluida, iniciando compactacao...';
winrar a -ibck -oc -tnmc1d -agYYYYMMDD-NN -df -m3 D:\teste_bkp\backup.rar D:\teste_bkp\*.BAK
Write-Output 'Aguardando compatacao...'. . ;
Wait-Process -Name WinRAR; 
Write-Output . .  'Compactacao concluida' . .;
Write-Output 'Enviando arquivo de Back-Up compactado para o servidor';
robocopy D:\teste_bkp 'D:\bkp_ged' *.rar /s /e /j /dcopy:dat /mov
Write-Output . 'Processo de Back-Up concluido.' . ;