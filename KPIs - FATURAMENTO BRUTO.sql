--AUTOR: ARIONE JUNIOR 
-- LEIA AS VALIDAÇÕES ANTES DE USAR MONGOLOIDE
-- REGRA VALIDA TODAS FILIAIS
-- REGRA VALIDA FATURAMENTO BRUTO
-- REGRA VALIDA DO PRIMEIRO DIA DO ANO FIXO

SELECT 'FATURAMENTO' as SERIE, MES AS X, VLFATURADO AS Y FROM (
SELECT  EXTRACT(MONTH FROM NF.DTSAIDA) MES, D.VLVENDA VLFATURADO
  FROM   table(CAST (
                   func_resumofaturamento (
                       NULL,
                       TO_DATE ('01/01/2017', 'DD/MM/YYYY'),
                       TRUNC(SYSDATE),       --TO_DATE ('27/11/2017', 'DD/MM/YYYY'),
                       22,
                       0,
                       1,
                       1,
                       0,
                       0,
                       0,
                       0,
                       NULL,
                       0,
                       0,
                       0,
                       0,
                       0,
                       0,
                       NULL,
                       1,
                       NULL,
                       NULL,
                       NULL,
                       NULL,
                       NULL,
                       NULL,
                       NULL,
                       NULL,
                       NULL,
                       NULL,
                       NULL,
                       NULL,
                       NULL,
                       0,
                       NULL,
                       0,
                       0,
                       0,
                       0,
                       NULL,
                       NULL,
                       0) AS tabela_faturamento)) D, PCNFSAID NF
                       WHERE D.CODUSUR = NF.CODUSUR
                       GROUP BY EXTRACT(MONTH FROM NF.DTSAIDA), D.VLVENDA
                       ) Q