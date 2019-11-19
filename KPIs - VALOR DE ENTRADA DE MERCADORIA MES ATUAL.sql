--AUTOR CONSULTOR TOTVS ARIONE.JUNIOR@TOTVS.COM.BR
--NOME RELATORIO: VALOR DE ENTRADA DE MERCADORIA NO MÊS ATUAL
--ROTINA 218 - 158 POR PRODUTO DEPARTAMENTOS [PARAMETRIZADO]
--ERP WINTHOR
--TIPO DO GRÁFICO: ABSOLUTO


SELECT   SUM (tabela.VLTOTAL) vltotal FROM   (
SELECT   SUM(compra.vlentrad) VLENTRAD,
                   nvl(saida.vldevol,0) vldevol,
                   SUM(compra.vlentrad) - nvl(saida.vldevol,0) vltotal
            FROM   (  SELECT   ( (DECODE (pcmov.status,
                                          'A', NVL (pcmov.qtcont, 0),
                                          NVL (pcmov.qt, 0)))
                                * DECODE (NVL (pcmov.punit, 0),
                                          0, NVL (pcmov.punitcont, 0),
                                          pcmov.punit))
                                   vlentrad
                        FROM   pcmov,
                               pcprodut,
                               pcfornec,
                               pcdepto,
                               pcsecao,
                               pcnfent,
                               pcempr,
                               pcconsum,
                               pcprodfilial,
                               pcpedido,
                               pcfilial,
                               pcbonusc
                       WHERE   (    pcempr.matricula(+) = pcnfent.codfunclanc
                                AND (pcmov.codprod = pcprodut.codprod)
                                AND pcmov.numtransent = pcnfent.numtransent
                                AND pcnfent.codfilial = pcfilial.codigo
                                AND pcmov.codoper NOT IN ('ED', 'EA')
                                AND pcmov.dtcancel IS NULL
                                AND pcprodut.codepto = pcdepto.codepto
                                AND pcprodut.codsec = pcsecao.codsec(+)
                                AND pcmov.codprod = pcprodfilial.codprod
                                AND pcmov.codfilial = pcprodfilial.codfilial
                                AND pcmov.numped = pcpedido.numped(+)
                                AND (pcmov.qt > 0
                                     OR (pcmov.qtcont > 0
                                         AND pcnfent.tipodescarga = '4'))
                                AND pcnfent.codfornec = pcfornec.codfornec
                                AND pcnfent.tipodescarga NOT IN
                                           ('6', '7', '8', 'N', 'F')
                                AND pcnfent.numbonus = pcbonusc.numbonus(+)
                                AND ( (pcnfent.codcont =
                                           NVL (pcnfent.codcontfor,
                                                pcconsum.codcontfor))
                                     OR (pcnfent.codcont =
                                             pcconsum.codcontajusteest
                                         AND pcnfent.tipodescarga = '4')
                                     OR (pcnfent.tipodescarga = 'S'
                                         AND ( (pcnfent.especie = 'NF')
                                              OR (pcnfent.especie = 'NE')))))
                               AND (pcprodut.codepto IN (100))
                               AND pcmov.dtmov BETWEEN TO_DATE ('01/' || TO_CHAR (ADD_MONTHS (TRUNC(SYSDATE),-0), 'MM/YYYY'),'DD/MM/YYYY')
                                    AND  LAST_DAY(ADD_MONTHS (TRUNC(SYSDATE),-0)) /*PERIODO MÊS ATUAL*/
                               AND pcnfent.codfilial IN ('1') -- FILIAL DEFINIDA
                               AND pcprodut.codepto IN (100) --PARAMETRO CLIENTE
                               AND pcprodut.codsec IN (101) --PARAMETRO CLIENTE
                               AND pcmov.codoper LIKE 'E%'
                                ) compra,
                   (  SELECT ROUND(SUM(NVL(PCMOVCOMPLE.VLSUBTOTITEM, NVL(PCMOV.QT,0)*NVL(PCMOV.PUNIT,0)) ),2) VLDEVOL
                             FROM PCNFSAID, PCMOV, PCPRODUT, PCMOVCOMPLE
                            WHERE PCNFSAID.NUMTRANSVENDA = PCMOV.NUMTRANSVENDA
                              AND PCMOVCOMPLE.NUMTRANSITEM = PCMOV.NUMTRANSITEM
                              AND PCMOV.CODPROD = PCPRODUT.CODPROD
                              AND pcnfsaid.dtsaida BETWEEN TO_DATE ('01/' || TO_CHAR (ADD_MONTHS (TRUNC(SYSDATE),-0), 'MM/YYYY'),'DD/MM/YYYY')
                                    AND  LAST_DAY(ADD_MONTHS (TRUNC(SYSDATE),-0))
                              AND PCNFSAID.DTCANCEL IS NULL  
                              AND PCNFSAID.CODFILIAL ='1'
                              AND PCNFSAID.CODFISCAL IN (532,632,732,5202,6202)
                              AND pcprodut.codepto IN (100) --PARAMETRO CLIENTE
                              AND pcprodut.codsec IN (101) --PARAMETRO CLIENTE
                         ORDER BY VLTOTAL DESC) saida
                             
                         
                         GROUP BY saida.vldevol
                    ) tabela;