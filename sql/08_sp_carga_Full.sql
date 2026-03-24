CREATE OR ALTER PROCEDURE sp_carga_Full
AS
BEGIN
    SET NOCOUNT ON;
    PRINT '=== INÍCIO CARGA FULL ==' + CAST(GETDATE() AS VARCHAR);

    EXEC sp_carga_DimCanal;
    EXEC sp_carga_DimCliente    @modo = 'FULL';
    EXEC sp_carga_DimProduto    @modo = 'FULL';
    EXEC sp_carga_FatoVenda     @modo = 'FULL';
    -- EXEC sp_carga_DimData; 

    PRINT '=== FIM CARGA FULL ===' + CAST(GETDATE() AS VARCHAR);
END;
