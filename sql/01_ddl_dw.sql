-- ----------------------------
-- DimData  (Calendário)
-- ----------------------------
DROP TABLE IF EXISTS DimData;
CREATE TABLE DimData (
    skData          INT         NOT NULL, -- "identity" surrogate key
    dtData          DATE        NOT NULL,
    nrAno           SMALLINT    NOT NULL,
    nrMes           SMALLINT    NOT NULL,
    nmMes           VARCHAR(20) NOT NULL,
    nmMesAbrev      VARCHAR(5)  NOT NULL,
    nrTrimestre     SMALLINT    NOT NULL,
    nrSemestre      SMALLINT    NOT NULL,
    nrDiaSemana     SMALLINT    NOT NULL,   -- 1=Dom … 7=Sáb
    nmDiaSemana     VARCHAR(20) NOT NULL,
    flFimSemana     SMALLINT    NOT NULL,   -- 0/1
    nrSemanaAno     SMALLINT    NOT NULL,
    nrDiaMes        SMALLINT    NOT NULL,
    nrDiaAno        SMALLINT    NOT NULL,
    dsAnoMes        VARCHAR(7)  NOT NULL,   -- 'YYYY-MM'
    dsAnoTrimestre  VARCHAR(7)  NOT NULL    -- 'YYYY-Q1'
);
GO

-- ----------------------------
-- DimCliente
-- ----------------------------
DROP TABLE IF EXISTS DimCliente;
CREATE TABLE DimCliente (
    skCliente       BIGINT          NOT NULL, -- "identity" surrogate key
    idCliente       BIGINT          NOT NULL, -- natural key
    nmCliente       VARCHAR(255)    NOT NULL,
    tpDocumento     VARCHAR(10),
    nrDocumento     VARCHAR(30),
    dsCidade        VARCHAR(100),
    sgEstado        VARCHAR(5),
    dsBairro        VARCHAR(100),
    nrCEP           VARCHAR(20),
    dsEmail         VARCHAR(255),
    nrTelefone      VARCHAR(30),
    dtCadastro      DATE,
    -- SCD Type 1: sobrescreve (sem histórico neste modelo Stage→DW)
    
    -- The DEFAULT keyword is not supported in the CREATE TABLE statement in this edition of SQL Server.
    -- dtUltAtualizacao DATETIME2      NOT NULL DEFAULT GETDATE()
    dtUltAtualizacao DATETIME2(3)   NOT NULL
);
GO

-- ----------------------------
-- DimProduto
-- ----------------------------
DROP TABLE IF EXISTS DimProduto;
CREATE TABLE DimProduto (
    skProduto           INT             NOT NULL, -- "identity" surrogate key
    idProduto           INT             NOT NULL, -- natural key
    nmProduto           VARCHAR(200)    NOT NULL,
    dsCategoria         VARCHAR(100)    NOT NULL,
    vlPrecoLista        DECIMAL(12,2),
    dtCadastro          DATE,
    -- The DEFAULT keyword is not supported in the CREATE TABLE statement in this edition of SQL Server.
    -- flAtivo         SMALLINT         NOT NULL DEFAULT 1,
    -- dtUltAtualizacao DATETIME2 NOT NULL DEFAULT GETDATE()
    flAtivo             BIT             NOT NULL,
    dtUltAtualizacao    DATETIME2(3)    NOT NULL
);
GO

-- ----------------------------
-- DimCanal
-- ----------------------------
DROP TABLE IF EXISTS DimCanal;
CREATE TABLE DimCanal (
    skCanal             INT             NOT NULL, -- "identity" surrogate key
    dsCanal             VARCHAR(100)    NOT NULL, -- natural key (domínio)
    tpCanal             VARCHAR(50)     NOT NULL,
    dtUltAtualizacao    DATETIME2(3)    NOT NULL
);
GO

-- ----------------------------
-- FatoVenda
-- ----------------------------
DROP TABLE IF EXISTS FatoVenda;
CREATE TABLE FatoVenda (
    idVenda             BIGINT          NOT NULL, -- natural key
    idItemVenda         BIGINT          NOT NULL,
    skCliente           BIGINT          NOT NULL, -- foreign key
    skProduto           INT             NOT NULL, -- foreign key
    skCanal             INT             NOT NULL, -- foreign key
    skDataVenda         INT             NULL, -- FK dimData
    skDataNota          INT             NULL, -- FK dimData
    skDataEntrega       INT             NULL, -- FK dimData
    dsStatus            VARCHAR(50)     NOT NULL,
    nrSequenciaItem     SMALLINT        NOT NULL,
    qtItem              SMALLINT        NOT NULL,
    vlPrecoUnit         DECIMAL(12,2)   NOT NULL,
    vlDescItem          DECIMAL(12,2)   NOT NULL,
    vlTotalItem         DECIMAL(12,2)   NOT NULL,
    vlFrete             DECIMAL(12,2)   NOT NULL,
    vlDescontoVenda     DECIMAL(12,2)   NOT NULL,
    nrNotaFiscal        VARCHAR(30),
	dsCidadeEntrega     VARCHAR(30),
	sgEstadoEntrega     VARCHAR(30),
	nrCEPEntrega        VARCHAR(30),
    dtUltAtualizacao    DATETIME2(3)    NOT NULL
);
GO