-- ----------------------------
-- sp_carga_DimCliente
-- ----------------------------
CREATE OR ALTER PROCEDURE sp_carga_DimCliente
    @modo VARCHAR(10) = 'FULL' -- INCR
AS
BEGIN
    SET NOCOUNT ON;

    IF @modo = 'FULL'
    BEGIN
        TRUNCATE TABLE DimCliente;

        INSERT INTO DimCliente
        (
            skCliente,
            idCliente,  nmCliente,  tpDocumento,    nrDocumento,
            dsCidade,   sgEstado,   dsBairro,       nrCEP, 
            dsEmail,    nrTelefone, dtCadastro,     dtUltAtualizacao
        )
        SELECT
            ROW_NUMBER() OVER (ORDER BY idCliente),
            idCliente,  nmCliente,  tpDocumento,    nrDocumento,
            dsCidade,   sgEstado,   dsBairro,       nrCEP, 
            dsEmail,    nrTelefone, dtCadastro,     GETDATE()
        FROM vw_tbCliente;
    END
    ELSE -- INCR: MERGE
    BEGIN
        MERGE DimCliente AS tgt
        USING vw_tbCliente AS src
            ON tgt.idCliente = src.idCliente

        WHEN MATCHED AND
        (
            tgt.nmCliente   <> src.nmCliente    OR
            tgt.tpDocumento <> src.tpDocumento  OR
            tgt.nrDocumento <> src.nrDocumento  OR
            tgt.dsCidade    <> src.dsCidade     OR
            tgt.sgEstado    <> src.sgEstado     OR
            tgt.dsBairro    <> src.dsBairro     OR
            tgt.nrCEP       <> src.nrCEP        OR
            tgt.dsEmail     <> src.dsEmail      OR
            tgt.nrTelefone  <> src.nrTelefone   OR
            tgt.dtCadastro  <> src.dtCadastro
        ) THEN UPDATE SET
            tgt.nmCliente           = src.nmCliente,
            tgt.tpDocumento         = src.tpDocumento,
            tgt.nrDocumento         = src.nrDocumento,
            tgt.dsCidade            = src.dsCidade,
            tgt.sgEstado            = src.sgEstado,
            tgt.dsBairro            = src.dsBairro,
            tgt.nrCEP               = src.nrCEP,
            tgt.dsEmail             = src.dsEmail,
            tgt.nrTelefone          = src.nrTelefone,
            tgt.dtCadastro          = src.dtCadastro,
            tgt.dtUltAtualizacao    = GETDATE()
        WHEN NOT MATCHED BY TARGET
        THEN INSERT
        (
            skCliente, idCliente, nmCliente, tpDocumento, nrDocumento,
            dsCidade,   sgEstado, dsBairro, nrCEP, dsEmail, nrTelefone,
            dtCadastro, dtUltAtualizacao
        )
        VALUES
        (
            (SELECT ISNULL(MAX(skCliente), 0) +1 FROM DimCliente),
            src.idCliente,  src.nmCliente,      src.tpDocumento,    src.nrDocumento,
            src.dsCidade,   src.sgEstado,       src.dsBairro,       src.nrCEP,
            src.dsEmail,    src.nrTelefone,     src.dtCadastro,     GETDATE()
        );
    END;

    PRINT 'DimCliente: carga ' + @modo + ' concluída.';
END;