-- ----------------------------
-- sp_carga_DimData
-- ----------------------------
CREATE OR ALTER PROCEDURE sp_carga_DimData
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @dtInicio   DATE = '2022-01-01'; -- '2022-01-01';
    DECLARE @dtFim      DATE = '2026-12-31'; -- '2026-12-31';
    DECLARE @dtAtual    DATE = @dtInicio;

    TRUNCATE TABLE DimData;

    WHILE @dtAtual <= @dtFim
    BEGIN
        DECLARE @mes      TINYINT = MONTH(@dtAtual);
        DECLARE @diaSem   TINYINT = DATEPART(WEEKDAY, @dtAtual);
        DECLARE @trim     TINYINT = ((@mes - 1) / 3) + 1;

        BEGIN
            INSERT INTO DimData
            (
                skData, dtData, nrAno, nrMes, nmMes, nmMesAbrev,
                nrTrimestre, nrSemestre, nrDiaSemana, nmDiaSemana,
                flFimSemana, nrSemanaAno, nrDiaMes, nrDiaAno,
                dsAnoMes, dsAnoTrimestre
            )
            VALUES (
                CAST(FORMAT(@dtAtual,'yyyyMMdd') AS INT),
                @dtAtual,
                YEAR(@dtAtual),
                @mes,

                -- nmMes
                CASE @mes
                    WHEN 1  THEN 'Janeiro'   WHEN 2  THEN 'Fevereiro'
                    WHEN 3  THEN 'Março'     WHEN 4  THEN 'Abril'
                    WHEN 5  THEN 'Maio'      WHEN 6  THEN 'Junho'
                    WHEN 7  THEN 'Julho'     WHEN 8  THEN 'Agosto'
                    WHEN 9  THEN 'Setembro'  WHEN 10 THEN 'Outubro'
                    WHEN 11 THEN 'Novembro'  WHEN 12 THEN 'Dezembro'
                END,

                -- nmMesAbrev
                CASE @mes
                    WHEN 1  THEN 'Jan'  WHEN 2  THEN 'Fev'
                    WHEN 3  THEN 'Mar'  WHEN 4  THEN 'Abr'
                    WHEN 5  THEN 'Mai'  WHEN 6  THEN 'Jun'
                    WHEN 7  THEN 'Jul'  WHEN 8  THEN 'Ago'
                    WHEN 9  THEN 'Set'  WHEN 10 THEN 'Out'
                    WHEN 11 THEN 'Nov'  WHEN 12 THEN 'Dez'
                END,

                @trim,

                -- nrSemestre
                CASE WHEN @mes <= 6 THEN 1 ELSE 2 END,

                @diaSem,

                -- nmDiaSemana
                CASE @diaSem
                    WHEN 1 THEN 'Domingo'
                    WHEN 2 THEN 'Segunda-feira'
                    WHEN 3 THEN 'Terça-feira'
                    WHEN 4 THEN 'Quarta-feira'
                    WHEN 5 THEN 'Quinta-feira'
                    WHEN 6 THEN 'Sexta-feira'
                    WHEN 7 THEN 'Sábado'
                END,

                -- flFimSemana
                CASE WHEN @diaSem IN (1, 7) THEN 1 ELSE 0 END,

                DATEPART(WEEK, @dtAtual),
                DAY(@dtAtual),
                DATEPART(DAYOFYEAR, @dtAtual),

                -- dsAnoMes  ex: 2024-03
                FORMAT(@dtAtual, 'yyyy-MM'),

                -- dsAnoTrimestre  ex: 2024-Q1
                CAST(YEAR(@dtAtual) AS VARCHAR(4)) + '-Q' + CAST(@trim AS VARCHAR(1))
            );
        END;

        SET @dtAtual = DATEADD(DAY, 1, @dtAtual);
    END;

    PRINT 'DimData: calendário gerado/atualizado.';
END;
GO