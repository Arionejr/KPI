--AUTOR: ARIONE JUNIOR 
-- KPI
-- FATURAMENTO MENSAL POR COBRAN�A
-- PRAZO FIXO
-- 01/01/2017 AT� TRUNC(SYSDATE)  

WITH saidas
        AS (SELECT   nf.codcob,
                     nf.dtsaida,
                     TO_CHAR (nf.dtsaida,
                              'MON',
                              'NLS_DATE_LANGUAGE =''BRAZILIAN PORTUGUESE''')
                         AS mes,
                     nf.vltotal,
                     nf.vltotger
              FROM   pcnfsaid nf
             WHERE       nf.especie IN ('NF')
                     AND nf.situacaonfe IN ('100', '150')
                     AND nf.dtsaida BETWEEN '01/11/2017' AND trunc(sysdate))
  SELECT   codcob AS serie, mes AS x, SUM (vltotal) AS y
    FROM   saidas
GROUP BY   codcob, mes