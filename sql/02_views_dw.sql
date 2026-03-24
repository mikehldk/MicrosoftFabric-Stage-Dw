-- ************ --
-- vw_tbCliente --
-- ************ --
CREATE OR ALTER VIEW vw_tbCliente
AS

SELECT
    CAST(idCliente AS BIGINT) AS idCliente,
    UPPER(TRIM(nmCliente)) AS nmCliente,
    UPPER(TRIM(tpDocumento)) AS tpDocumento,
    TRIM(nrDocumento) AS nrDocumento,
    UPPER(TRIM(dsCidade)) AS dsCidade,
    UPPER(TRIM(sgEstado)) AS sgEstado,
    NULLIF(TRIM(dsBairro), '') AS dsBairro,
    NULLIF(TRIM(nrCEP), '') AS nrCEP,
    CASE
        WHEN LEN(dtCadastro) = 10 AND SUBSTRING(dtCadastro,5,1) = '-' AND SUBSTRING(dtCadastro,8,1) = '-'
            THEN CONVERT(DATE, dtCadastro, 120)
        WHEN LEN(dtCadastro) = 10 AND SUBSTRING(dtCadastro,3,1) = '/' AND SUBSTRING(dtCadastro,6,1) = '/'
            THEN CONVERT(DATE,
                        SUBSTRING(dtCadastro,7,4) + '-' + SUBSTRING(dtCadastro,4,2) + '-' + SUBSTRING(dtCadastro,1,2),
                        120)
        WHEN LEN(dtCadastro) = 10 AND SUBSTRING(dtCadastro,3,1) = '-' AND SUBSTRING(dtCadastro,6,1) = '-'
            THEN CONVERT(DATE,
                        SUBSTRING(dtCadastro,7,4) + '-' + SUBSTRING(dtCadastro,4,2) + '-' + SUBSTRING(dtCadastro,1,2),
                        120)
        WHEN LEN(dtCadastro) = 8 AND ISNUMERIC(dtCadastro) = 1
            THEN CONVERT(DATE,
                        SUBSTRING(dtCadastro,1,4) + '-' + SUBSTRING(dtCadastro,5,2) + '-' + SUBSTRING(dtCadastro,7,2),
                        120)
        ELSE NULL
    END AS dtCadastro,
    NULLIF(LOWER(TRIM(dsEmail)), '') AS dsEmail,
    NULLIF(TRIM(nrTelefone), '') AS nrTelefone
FROM Stage.vendas.tbCliente;
GO


-- ************ --
-- vw_tbProduto --
-- ************ --
CREATE OR ALTER VIEW vw_tbProduto
AS

SELECT
    CAST(idProduto AS INT) AS idProduto,
    UPPER(TRIM(nmProduto)) AS nmProduto,
    UPPER(TRIM(dsCategoria)) AS dsCategoria,
    TRY_CAST(vlPrecoLista AS DECIMAL(12,2)) AS vlPrecoLista,
    CASE
        WHEN LEN(dtCadastro) = 10 AND SUBSTRING(dtCadastro,5,1) = '-' AND SUBSTRING(dtCadastro,8,1) = '-'
            THEN CONVERT(DATE, dtCadastro, 120)
        WHEN LEN(dtCadastro) = 10 AND SUBSTRING(dtCadastro,3,1) = '/' AND SUBSTRING(dtCadastro,6,1) = '/'
            THEN CONVERT(DATE,
                        SUBSTRING(dtCadastro,7,4) + '-' + SUBSTRING(dtCadastro,4,2) + '-' + SUBSTRING(dtCadastro,1,2),
                        120)
        WHEN LEN(dtCadastro) = 10 AND SUBSTRING(dtCadastro,3,1) = '-' AND SUBSTRING(dtCadastro,6,1) = '-'
            THEN CONVERT(DATE,
                        SUBSTRING(dtCadastro,7,4) + '-' + SUBSTRING(dtCadastro,4,2) + '-' + SUBSTRING(dtCadastro,1,2),
                        120)
        WHEN LEN(dtCadastro) = 8 AND ISNUMERIC(dtCadastro) = 1
            THEN CONVERT(DATE,
                        SUBSTRING(dtCadastro,1,4) + '-' + SUBSTRING(dtCadastro,5,2) + '-' + SUBSTRING(dtCadastro,7,2),
                        120)
        ELSE NULL
    END AS dtCadastro,
    TRY_CAST(flAtivo AS BIT) AS flAtivo
FROM Stage.vendas.tbProduto;
GO


-- *********** --
-- vw_tbVendas --
-- *********** --
CREATE OR ALTER VIEW vw_tbVendas
AS

SELECT
	idVenda,
	idCliente,

    CASE
        WHEN LEN(V.dtVenda) = 10 AND SUBSTRING(V.dtVenda,5,1) = '-' AND SUBSTRING(V.dtVenda,8,1) = '-'
            THEN CONVERT(DATE, V.dtVenda, 120)
        WHEN LEN(V.dtVenda) = 10 AND SUBSTRING(V.dtVenda,3,1) = '/' AND SUBSTRING(V.dtVenda,6,1) = '/'
            THEN CONVERT(DATE,
                        SUBSTRING(V.dtVenda,7,4) + '-' + SUBSTRING(V.dtVenda,4,2) + '-' + SUBSTRING(V.dtVenda,1,2),
                        120)
        WHEN LEN(V.dtVenda) = 10 AND SUBSTRING(V.dtVenda,3,1) = '-' AND SUBSTRING(V.dtVenda,6,1) = '-'
            THEN CONVERT(DATE,
                        SUBSTRING(V.dtVenda,7,4) + '-' + SUBSTRING(V.dtVenda,4,2) + '-' + SUBSTRING(V.dtVenda,1,2),
                        120)
        WHEN LEN(V.dtVenda) = 8 AND ISNUMERIC(V.dtVenda) = 1
            THEN CONVERT(DATE,
                        SUBSTRING(V.dtVenda,1,4) + '-' + SUBSTRING(V.dtVenda,5,2) + '-' + SUBSTRING(V.dtVenda,7,2),
                        120)
        ELSE NULL
    END AS dtVenda,

    CASE
        WHEN LEN(V.dtPrazoEntrega) = 10 AND SUBSTRING(V.dtPrazoEntrega,5,1) = '-' AND SUBSTRING(V.dtPrazoEntrega,8,1) = '-'
            THEN CONVERT(DATE, V.dtPrazoEntrega, 120)
        WHEN LEN(V.dtPrazoEntrega) = 10 AND SUBSTRING(V.dtPrazoEntrega,3,1) = '/' AND SUBSTRING(V.dtPrazoEntrega,6,1) = '/'
            THEN CONVERT(DATE,
                        SUBSTRING(V.dtPrazoEntrega,7,4) + '-' + SUBSTRING(V.dtPrazoEntrega,4,2) + '-' + SUBSTRING(V.dtPrazoEntrega,1,2),
                        120)
        WHEN LEN(V.dtPrazoEntrega) = 10 AND SUBSTRING(V.dtPrazoEntrega,3,1) = '-' AND SUBSTRING(V.dtPrazoEntrega,6,1) = '-'
            THEN CONVERT(DATE,
                        SUBSTRING(V.dtPrazoEntrega,7,4) + '-' + SUBSTRING(V.dtPrazoEntrega,4,2) + '-' + SUBSTRING(V.dtPrazoEntrega,1,2),
                        120)
        WHEN LEN(V.dtPrazoEntrega) = 8 AND ISNUMERIC(V.dtPrazoEntrega) = 1
            THEN CONVERT(DATE,
                        SUBSTRING(V.dtPrazoEntrega,1,4) + '-' + SUBSTRING(V.dtPrazoEntrega,5,2) + '-' + SUBSTRING(V.dtPrazoEntrega,7,2),
                        120)
        ELSE NULL
    END AS dtPrazoEntrega,

    UPPER(TRIM(V.dsCanal)) AS dsCanal,
    TRIM(V.dsStatus) AS dsStatus,
	dsCidadeEntrega,
	sgEstadoEntrega,
	nrCEPEntrega,
    NULLIF(CAST(V.nrNotaFiscal AS VARCHAR(10)),'') AS nrNotaFiscal,

    CASE
        WHEN LEN(V.dtNotaFiscal) = 10 AND SUBSTRING(V.dtNotaFiscal,5,1) = '-' AND SUBSTRING(V.dtNotaFiscal,8,1) = '-'
            THEN CONVERT(DATE, V.dtNotaFiscal, 120)
        WHEN LEN(V.dtNotaFiscal) = 10 AND SUBSTRING(V.dtNotaFiscal,3,1) = '/' AND SUBSTRING(V.dtNotaFiscal,6,1) = '/'
            THEN CONVERT(DATE,
                        SUBSTRING(V.dtNotaFiscal,7,4) + '-' + SUBSTRING(V.dtNotaFiscal,4,2) + '-' + SUBSTRING(V.dtNotaFiscal,1,2),
                        120)
        WHEN LEN(V.dtNotaFiscal) = 10 AND SUBSTRING(V.dtNotaFiscal,3,1) = '-' AND SUBSTRING(V.dtNotaFiscal,6,1) = '-'
            THEN CONVERT(DATE,
                        SUBSTRING(V.dtNotaFiscal,7,4) + '-' + SUBSTRING(V.dtNotaFiscal,4,2) + '-' + SUBSTRING(V.dtNotaFiscal,1,2),
                        120)
        WHEN LEN(V.dtNotaFiscal) = 8 AND ISNUMERIC(V.dtNotaFiscal) = 1
            THEN CONVERT(DATE,
                        SUBSTRING(V.dtNotaFiscal,1,4) + '-' + SUBSTRING(V.dtNotaFiscal,5,2) + '-' + SUBSTRING(V.dtNotaFiscal,7,2),
                        120)
        ELSE NULL
    END AS dtNotaFiscal,

    TRY_CAST(V.vlFrete      AS DECIMAL(12,2)) AS vlFrete,
    TRY_CAST(V.vlDesconto   AS DECIMAL(12,2)) AS vlDesconto,
	dtCarga
FROM Stage.vendas.tbVendas V;
GO
