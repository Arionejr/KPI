--AUTOR CONSULTOR TOTVS ARIONE.JUNIOR@TOTVS.COM.BR
--NOME RELATORIO: VALOR DE ENTRADA DE MERCADORIA NO MÊS ATUAL
--ROTINA 322 DEDUZINDO 151 POR PRODUTO DEPARTAMENTOS [PARAMETRIZADO]
--ERP WINTHOR
--TIPO DO GRÁFICO: ABSOLUTO

SELECT  pvenda - vldevolucao AS valor
  FROM  (SELECT  SUM (ROUND (NVL (pcpedi.qt, 0)
                                         * (    NVL (pcpedi.pvenda, 0)
                                             + NVL (pcpedi.vloutrasdesp, 0)
                                             + NVL (pcpedi.vlfrete, 0)), 2))
                             AS pvenda
                FROM     pcpedi, pcpedc, pcprodut, pcclient, pcfornec, pcdepto
              WHERE  1 = 1
                         AND pcpedc.data BETWEEN TO_DATE ('01/'
                                                                     || TO_CHAR (ADD_MONTHS (TRUNC(SYSDATE),
                                                                                     -0),
                                                                         'MM/YYYY'),
                                                         'DD/MM/YYYY')
                                                    AND  LAST_DAY (ADD_MONTHS (TRUNC (
                                                                                            SYSDATE
                                                                                        ), -0))
                         AND pcpedc.codfilial IN ('1')
                         AND pcpedc.condvenda IN
                                     (1, 2, 3, 7, 9, 14, 15, 17, 18, 19, 98)
                         AND pcpedc.numped = pcpedi.numped
                         AND pcpedi.codprod = pcprodut.codprod
                         AND pcpedc.codcli = pcclient.codcli
                         AND pcprodut.codfornec = pcfornec.codfornec
                         AND pcprodut.codepto = pcdepto.codepto
                         AND NVL (pcpedi.bonific, 'N') = 'N'
                         AND pcdepto.codepto IN (100)
                         AND pcprodut.codsec IN (101)
                         AND pcpedc.posicao IN ('F')
                         AND pcpedc.dtcancel IS NULL) venda,
            (SELECT  SUM (devol.vldevolucao) vldevolucao
                FROM     (SELECT   ROUND (SUM (vw.vldevolucao), 2) vldevolucao
                             FROM   view_devol_resumo_faturamento vw, pcnfent
                            WHERE       vw.numtransent = pcnfent.numtransent
                                      AND pcnfent.tipodescarga <> 'T'
                                      AND vw.codepto IN (100) /*DEPARTAMENTO DEVOL AVULSA*/
                                      AND vw.codsec IN (101)      /*SECAO DEVOL AVULSA*/
                                      AND pcnfent.dtent BETWEEN TO_DATE ('01/'
                                                                                     || TO_CHAR (ADD_MONTHS (TRUNC(SYSDATE),
                                                                                                     -0),
                                                                                         'MM/YYYY'),
                                                                         'DD/MM/YYYY')
                                                                    AND  LAST_DAY (
                                                                              ADD_MONTHS (TRUNC(SYSDATE),
                                                                              -0)
                                                                          )
                          UNION
                          SELECT   ROUND (SUM (vldevolucao), 2) vldevolucao
                             FROM   view_devol_resumo_faturavulsa
                            WHERE   codepto IN (100)     /*DEPARTAMENTO DEVOL AVULSA*/
                                                            AND codsec IN (101) /*SECAO DEVOL AVULSA*/
                                      AND dtent BETWEEN TO_DATE ('01/' || TO_CHAR (ADD_MONTHS (TRUNC (SYSDATE), -0), 'MM/YYYY'),
                                                              'DD/MM/YYYY')
                                                         AND    LAST_DAY (ADD_MONTHS (TRUNC(SYSDATE),
                                                                             -0))) devol) devol
