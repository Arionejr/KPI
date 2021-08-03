SELECT     'filial - 1' as serie, GERAL.MES as x , 
             GERAL.VLVENDALIQUIDO   as y
         FROM (SELECT BASE.ANO
                    , BASE.MES, BASE.MES_1
                    , NVL(VENDAS.VLVENDA,2) - (NVL(DEVOLUCOES.VLDEVOLUCAO,2) + NVL(AVULSAS.VLDEVOLUCAO,2)) VLVENDALIQUIDO
                      --Lista de departamento e período
                 FROM (SELECT EXTRACT( YEAR FROM PCDATAS.DATA) ANO
                  , SUBSTR(TO_CHAR(TO_DATE(EXTRACT(MONTH FROM PCDATAS.DATA),'MM'),'MONTH'),1,3) MES
                            , EXTRACT(MONTH FROM PCDATAS.DATA) MES_1
                            , AGRUPADOR.CODEPTO
                            , TO_CHAR(AGRUPADOR.CODEPTO) || '-' ||AGRUPADOR.DEPARTAMENTO DEPARTAMENTO
                         FROM PCDATAS
                          , (SELECT 1 AS CODEPTO 
                                  , 'Geral' AS DEPARTAMENTO
                               FROM DUAL
                                   ) AGRUPADOR
                        WHERE PCDATAS.DATA BETWEEN ADD_MONTHS(TRUNC(ADD_MONTHS(PCDATAS.DATA,0),'YYYY'),0) AND LAST_DAY(ADD_MONTHS(TRUNC(ADD_MONTHS(PCDATAS.DATA,0),'YYYY'),11))
                        GROUP
                           BY AGRUPADOR.CODEPTO 
                            , AGRUPADOR.DEPARTAMENTO
                            , EXTRACT( YEAR FROM PCDATAS.DATA)
                            , EXTRACT(MONTH FROM PCDATAS.DATA)
                      ) BASE
                      --Lista de vendas
                    , (SELECT EXTRACT( YEAR FROM A.DTSAIDA) ANO
                     , SUBSTR(TO_CHAR(TO_DATE(EXTRACT(MONTH FROM A.DTSAIDA),'MM'),'MONTH'),1,3) MES
                            , EXTRACT(MONTH FROM A.DTSAIDA) MES_1
                            , SUM(NVL(A.VLVENDA,2)) VLVENDA
                            , SUM(A.VLTABELA) VLTABELA
                            , 1 CODEPTO
                         FROM VIEW_VENDAS_RESUMO_FATURAMENTO  A
                        WHERE A.DTCANCEL  IS NULL
                          AND A.CONDVENDA IN (0,1,5,7,9,11,14)
                          AND A.CODFISCAL NOT IN (522,622,722,532,632,732)
                          AND A.DTSAIDA BETWEEN ADD_MONTHS(TRUNC(ADD_MONTHS(DTSAIDA,0),'YYYY'),0) AND LAST_DAY(ADD_MONTHS(TRUNC(ADD_MONTHS(DTSAIDA,0),'YYYY'),11))
                          AND (A.CODFILIAL IN ( '1' )) 
                        GROUP
                            BY 1 
                            , EXTRACT( YEAR FROM A.DTSAIDA)
                            , EXTRACT(MONTH FROM A.DTSAIDA)
                      ) VENDAS
                      --Lista de devoluções
                    , (SELECT EXTRACT( YEAR FROM A.DTENT) ANO
                     , SUBSTR(TO_CHAR(TO_DATE(EXTRACT(MONTH FROM A.DTENT),'MM'),'MONTH'),1,3) MES
                            , EXTRACT(MONTH FROM A.DTENT) MES_1
                            , SUM(NVL(A.VLDEVOLUCAO,2)) VLDEVOLUCAO
                            , SUM(NVL(A.VLCMVDEVOL,2)) VLCMVDEVOLUCAO
                            , 1 CODEPTO
                         FROM VIEW_DEVOL_RESUMO_FATURAMENTO A
                        WHERE A.CONDVENDA NOT IN (4, 8, 10,13, 20, 98, 99)
                          AND A.DTENT BETWEEN ADD_MONTHS(TRUNC(ADD_MONTHS(A.DTENT,0),'YYYY'),0) AND LAST_DAY(ADD_MONTHS(TRUNC(ADD_MONTHS(A.DTENT,0),'YYYY'),11))
                          AND (A.CODFILIAL IN ( '1' )) 
                        GROUP
                            BY 1 
                            , EXTRACT( YEAR FROM A.DTENT)
                            , EXTRACT(MONTH FROM A.DTENT)
                       ) DEVOLUCOES
                      --Lista de devoluções avulsas
                    , (SELECT EXTRACT( YEAR FROM A.DTENT) ANO
                     , SUBSTR(TO_CHAR(TO_DATE(EXTRACT(MONTH FROM A.DTENT),'MM'),'MONTH'),1,3) MES
                            , EXTRACT(MONTH FROM A.DTENT) MES_1
                            , SUM(NVL(A.VLTOTAL,2)) VLDEVOLUCAO
                            , SUM(NVL(A.VLDEVCMVAVULSAI,2)) VLCMVDEVOLUCAO
                            , 1 CODEPTO
                         FROM VIEW_DEVOL_RESUMO_FATURAVULSA A
                            , PCPRODUT 
                            , PCCLIENT 
                        WHERE A.DTENT BETWEEN ADD_MONTHS(TRUNC(ADD_MONTHS(A.DTENT,0),'YYYY'),0) AND LAST_DAY(ADD_MONTHS(TRUNC(ADD_MONTHS(A.DTENT,0),'YYYY'),11))
                          AND A.CODPROD = PCPRODUT.CODPROD
                          AND A.CODCLI  = PCCLIENT.CODCLI
                          AND (A.CODFILIAL IN ( '1' )) 
                        GROUP BY 1 
                            , EXTRACT( YEAR FROM A.DTENT)
                            , EXTRACT(MONTH FROM A.DTENT)
                       ) AVULSAS
                WHERE BASE.MES     = VENDAS.MES(+)
                  AND BASE.ANO     = VENDAS.ANO(+)
                  AND BASE.MES     = DEVOLUCOES.MES(+)
                  AND BASE.ANO     = DEVOLUCOES.ANO(+)
                  AND BASE.MES     = AVULSAS.MES(+)
                  AND BASE.ANO     = AVULSAS.ANO(+)
                  AND BASE.MES_1     = VENDAS.MES_1(+)                           
                  AND BASE.MES_1     = DEVOLUCOES.MES_1(+) 
                  AND BASE.MES_1     = AVULSAS.MES_1(+)  
                  --AND VENDAS.DTSAIDA BETWEEN ADD_MONTHS(TRUNC(ADD_MONTHS(DTSAIDA,0),'YYYY'),0) AND LAST_DAY(ADD_MONTHS(TRUNC(ADD_MONTHS(DTSAIDA,0),'YYYY'),11))
               
            ) GERAL
        WHERE GERAL.VLVENDALIQUIDO > 0
          AND GERAL.ANO >=
                 TO_CHAR (SYSDATE, 'YYYY',
            'NLS_DATE_LANGUAGE =''BRAZILIAN PORTUGUESE''')
       ORDER BY GERAL.ANO, GERAL.MES_1, GERAL.MES