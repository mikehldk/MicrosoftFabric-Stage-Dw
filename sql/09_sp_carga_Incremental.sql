CREATE OR ALTER   PROCEDURE sp_carga_Incremental
    @dtCorte DATE = NULL    -- NULL = últimos 7 dias (padrão)
AS
BEGIN
    SET NOCOUNT ON;

    IF @dtCorte IS NULL
        SET @dtCorte = DATEADD(DAY, -15, CAST(GETDATE() AS DATE));

    PRINT '=== INÍCIO CARGA INCREMENTAL === Corte: ' + CAST(@dtCorte AS VARCHAR);

    -- Dims: MERGE (captura novos clientes/produtos que entraram no período)
    EXEC sp_carga_DimCanal;
    EXEC sp_carga_DimCliente    @modo = 'INCR';
    EXEC sp_carga_DimProduto    @modo = 'INCR';

    -- Fato: recarrega janela de 7 dias    
    EXEC sp_carga_FatoVenda     @modo = 'INCR', @dtCorte = @dtCorte;

    PRINT '=== FIM CARGA INCREMENTAL ===' + CAST(GETDATE() AS VARCHAR);
END;
