$compress = @{
    Path = "D:\bkp_ged\20220919_dwdata.BAK"
    CompressionLevel = "Fastest"
    DestinationPath = "D:\teste_bkp\teste1.zip"
}
Compress-Archive @compress