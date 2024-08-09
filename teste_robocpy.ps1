Write-Output 'Iniciando back-up da pasta sql ged'

robocopy z:\ 'D:\bkp_ged' *.BAK /s /e /j /dcopy:dat /mov
winrar a -ibck -oc -tnmc1d -agYYYYMMDD-NN -df -m3 D:\bkp_ged\backup.rar D:\bkp_ged\*.BAK
robocopy D:\bkp_ged 'z:\' *.rar /s /e /j /dcopy:dat /mov
