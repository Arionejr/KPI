--AUTOR CONSULTOR TOTVS ARIONE.JUNIOR@TOTVS.COM.BR
--NOME RELATORIO: VALOR DE ENTRADA DE MERCADORIA NO MÊS ATUAL
--ROTINA 218 VALIDANDO DEVOLUÇÃO DE FORNECEDOR ROTINA 158
--ERP WINTHOR
--TIPO DO GRÁFICO: ABSOLUTO


SELECT   SUM (tabela.VLTOTAL) vltotal FROM   (
SELECT   SUM(compra.vlentrad) VLENTRAD,
                   saida.vldevol,
                   SUM(compra.vlentrad) - saida.vldevol vltotal
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
                               AND pcmov.dtmov BETWEEN TO_DATE (
                                                           '01/'
                                                           || TO_CHAR (
                                                                  ADD_MONTHS (
                                                                      TRUNC(SYSDATE),
                                                                      -0),
                                                                  'MM/YYYY'),
                                                           'DD/MM/YYYY')
                                                   AND  LAST_DAY(ADD_MONTHS (
                                                                     TRUNC(SYSDATE),
                                                                     -0)) /*PERIODO MÊS ATUAL*/
                               AND pcnfent.codfilial IN ('1') -- FILIAL DEFINIDA
                               AND pcprodut.codepto IN (100) --PARAMETRO CLIENTE
                               AND pcprodut.codsec IN (101) --PARAMETRO CLIENTE
                               AND pcmov.codoper LIKE 'E%'
                                ) compra,
                   (  SELECT                                            
                               SUM (NVL (pcprest.valor, 0)) vldevol
                        FROM   pcnfsaid, pcprest, pcclient
                       WHERE   pcnfsaid.numtransvenda = pcprest.numtransvenda
                               AND pcprest.codcli = pcclient.codcli
                               AND pcprest.dtpag IS NULL
                               AND pcnfsaid.dtsaida BETWEEN TO_DATE (
                                                                '01/'
                                                                || TO_CHAR (
                                                                       ADD_MONTHS (
                                                                           TRUNC(SYSDATE),
                                                                           -0),
                                                                       'MM/YYYY'),
                                                                'DD/MM/YYYY')
                                                        AND  LAST_DAY(ADD_MONTHS (
                                                                          TRUNC(SYSDATE),
                                                                          -0))
                               AND pcnfsaid.dtcancel IS NULL
                               AND pcnfsaid.codfilial = '1'
                               AND pcnfsaid.codfiscal IN
                                          (532, 632, 732, 5202, 6202)
                    ORDER BY   vldevol DESC) saida
                    GROUP BY saida.vldevol
                    ) tabela;