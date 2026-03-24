-- ----------------------------
-- sp_carga_DimCanal
-- ----------------------------
CREATE OR ALTER PROCEDURE sp_carga_DimCanal
AS
BEGIN
    SET NOCOUNT ON;

    TRUNCATE TABLE DimCanal;

    INSERT INTO DimCanal
    (
        skCanal,
        dsCanal,
        tpCanal,
        dtUltAtualizacao
    )
    SELECT
        ROW_NUMBER() OVER (ORDER BY dsCanalPadrao)  AS skCanal,
        dsCanalPadrao                               AS dsCanal,
        CASE dsCanalPadrao
            WHEN 'E-COMMERCE'               THEN 'Digital'
            WHEN 'MARKETPLACE'              THEN 'Digital'
            WHEN 'TELEVENDAS'               THEN 'Digital'
            WHEN 'LOJA FÍSICA'              THEN 'Presencial'
            WHEN 'REPRESENTANTE COMERCIAL'  THEN 'Indireto'
            ELSE 'Outros'
        END AS tpCanal,
        GETDATE()
    FROM
    (
        SELECT DISTINCT UPPER(TRIM(dsCanal)) AS dsCanalPadrao
        FROM Stage.vendas.tbVendas
        WHERE dsCanal IS NOT NULL
    ) canal;

    PRINT 'DimCanal: carga concluída.';
END;
