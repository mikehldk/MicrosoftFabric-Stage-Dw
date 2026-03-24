-- ----------------------------
-- sp_carga_DimProduto
-- ----------------------------
CREATE OR ALTER PROCEDURE sp_carga_DimProduto
    @modo VARCHAR(10) = 'FULL' -- INCR
AS
BEGIN
    SET NOCOUNT ON;

    IF @modo = 'FULL'
    BEGIN
        TRUNCATE TABLE DimProduto;

        INSERT INTO DimProduto
        (
            skProduto,
            idProduto,  nmProduto,  dsCategoria, vlPrecoLista, 
            dtCadastro, flAtivo,    dtUltAtualizacao
        )
        SELECT
            ROW_NUMBER() OVER (ORDER BY idProduto),
            idProduto,  nmProduto,  dsCategoria, vlPrecoLista, 
            dtCadastro, flAtivo,    GETDATE()
        FROM vw_tbProduto;
     END
    ELSE -- INCR: MERGE
    BEGIN
        MERGE DimProduto AS tgt
        USING vw_tbProduto AS src
            ON tgt.idProduto = src.idProduto

        WHEN MATCHED AND
        (
            tgt.nmProduto       <> src.nmProduto    OR
            tgt.dsCategoria     <> src.dsCategoria  OR
            tgt.vlPrecoLista    <> src.vlPrecoLista OR
            tgt.flAtivo         <> src.flAtivo      OR
            tgt.dtCadastro      <> src.dtCadastro
        ) THEN UPDATE SET
            tgt.nmProduto        = src.nmProduto,
            tgt.dsCategoria      = src.dsCategoria,
            tgt.vlPrecoLista     = src.vlPrecoLista,
            tgt.flAtivo          = src.flAtivo,
            tgt.dtCadastro       = src.dtCadastro,
            tgt.dtUltAtualizacao = GETDATE()
        WHEN NOT MATCHED BY TARGET
        THEN INSERT
        (
            skProduto,      idProduto,  nmProduto,  dsCategoria,
            vlPrecoLista,   dtCadastro, flAtivo,    dtUltAtualizacao
        )
        VALUES
        (
            (SELECT ISNULL(MAX(skProduto), 0) +1 FROM DimProduto),
            src.idProduto,      src.nmProduto,      src.dsCategoria,
            src.vlPrecoLista,   src.dtCadastro,     src.flAtivo, GETDATE()
        );
    END;

    PRINT 'DimProduto: carga ' + @modo + ' concluída.';
END;