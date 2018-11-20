--AUTOR: ARIONE JUNIOR 
--FATURAMENTO BRUTO POR MÊS
--DTINI = 01/01/2017
--DTFIM = SYSDATE

SELECT 'FATURAMENTO' as SERIE, MES AS X, VLFATURADO AS Y FROM (
SELECT  substr(to_char(to_date(EXTRACT(MONTH FROM NF.DTSAIDA),'MM'),'MONTH'),1,3) MES, D.VLVENDA VLFATURADO
  FROM   table(CAST (
                   func_resumofaturamento (
                       NULL,
                       TO_DATE ('01/01/2017', 'DD/MM/YYYY'),
                       TRUNC(SYSDATE),       --TO_DATE ('27/11/2017', 'DD/MM/YYYY'),
                       21,
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
                       0,
                       0,
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
                       --WHERE D.CODUSUR = NF.CODUSUR
                       GROUP BY EXTRACT(MONTH FROM NF.DTSAIDA), D.VLVENDA
                       ) Q