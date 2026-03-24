CREATE OR ALTER PROCEDURE sp_carga_FatoVenda
    @modo       VARCHAR(10) = 'FULL',
    @dtCorte    DATE        = NULL
AS
BEGIN
    SET NOCOUNT ON;

    -- Define corte padrão: últimos 7 dias
    IF @dtCorte IS NULL
        SET @dtCorte = DATEADD(DAY, -15, CAST(GETDATE() AS DATE));


    IF @modo = 'FULL'
    BEGIN
        TRUNCATE TABLE FatoVenda;
    END
    ELSE
    BEGIN
    	DELETE FROM FatoVenda
		FROM FatoVenda FV
		INNER JOIN DimData DD
				ON FV.skDataVenda = DD.skData
        WHERE DD.dtData >= @dtCorte;
    END;

    INSERT INTO FatoVenda
	(
        idVenda, idItemVenda,
        skCliente, skProduto, skCanal,
        skDataVenda, skDataNota, skDataEntrega,
        dsStatus, nrSequenciaItem,
        qtItem, vlPrecoUnit, vlDescItem, vlTotalItem,
        vlFrete, vlDescontoVenda, nrNotaFiscal,
		dsCidadeEntrega, sgEstadoEntrega, nrCEPEntrega, dtUltAtualizacao
    )
    SELECT
        V.idVenda,
        IV.idItemVenda,
        ISNULL(C.skCliente,	-1),	-- -1 = "Não identificado"
        ISNULL(P.skProduto,	-1),
        ISNULL(CN.skCanal,	-1),
        DtVenda.skData,
		DtNota.skData,
        DtEntrega.skData,
        V.dsStatus,
		CAST(IV.nrSequencia		AS SMALLINT),
        CAST(IV.qtItem			AS SMALLINT),
        TRY_CAST(IV.vlPrecoUnit	AS DECIMAL(12,2)),
        TRY_CAST(IV.vlDescItem	AS DECIMAL(12,2)),
        TRY_CAST(IV.vlTotalItem	AS DECIMAL(12,2)),
        ISNULL(V.vlFrete,   0),
        ISNULL(V.vlDesconto,0),
        V.nrNotaFiscal,
		V.dsCidadeEntrega,
		V.sgEstadoEntrega,
		V.nrCEPEntrega,
        GETDATE()
    FROM vw_tbVendas V
	LEFT  JOIN Stage.vendas.tbItensVendas IV
			ON V.idVenda = IV.idVenda
    LEFT JOIN DimCliente C
			ON C.idCliente = V.idCliente
    LEFT JOIN DimProduto P
			ON P.idProduto = IV.idProduto
    LEFT JOIN DimCanal CN
			ON CN.dsCanal = V.dsCanal
    LEFT JOIN DimData DtVenda
			ON DtVenda.dtData = V.dtVenda
    LEFT JOIN DimData DtNota
			ON DtNota.dtData = V.dtNotaFiscal
    LEFT JOIN DimData DtEntrega
			ON DtEntrega.dtData = V.dtPrazoEntrega
	WHERE
		(
            @modo = 'FULL'
            OR V.dtVenda >= @dtCorte -- Filtro incremental
        );

    PRINT 'FatoVenda: carga ' + @modo + ' concluída. Corte: ' + CAST(@dtCorte AS VARCHAR);
END;
GO