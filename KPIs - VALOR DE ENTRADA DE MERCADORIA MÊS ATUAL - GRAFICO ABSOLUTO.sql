--AUTOR CONSULTOR TOTVS ARIONE.JUNIOR@TOTVS.COM.BR
--NOME RELATORIO: VALOR DE ENTRADA DE MERCADORIA NO MÊS ATUAL
--ROTINA 218
--ERP WINTHOR
--TIPO DO GRÁFICO: ABSOLUTO



SELECT   round(SUM (vlentrada),2) as valor
  FROM   (  SELECT   pcnfent.codfornec,
                     pcfornec.fornecedor,
                     COUNT (DISTINCT pcmov.numnota) numnfs,
                     COUNT (pcmov.codprod) numitens,
                     SUM(NVL (pcprodut.pesobruto, 0)
                         * (DECODE (NVL (pcmov.qt, 0),
                                    0, NVL (pcmov.qtcont, 0),
                                    pcmov.qt)))
                         pesoent,
                     SUM(NVL (pcprodut.volume, 0)
                         * (DECODE (NVL (pcmov.qt, 0),
                                    0, NVL (pcmov.qtcont, 0),
                                    pcmov.qt)))
                         totvolume,
                     SUM( (DECODE (pcmov.status,
                                   'A', NVL (pcmov.qtcont, 0),
                                   NVL (pcmov.qt, 0)))
                         * DECODE (NVL (pcmov.punit, 0),
                                   0, NVL (pcmov.punitcont, 0),
                                   pcmov.punit))
                         vlentrada,
                     SUM(DECODE (NVL (pcmov.qt, 0),
                                 0, NVL (pcmov.qtcont, 0),
                                 pcmov.qt))
                         AS qt
              FROM   pcmov,
                     pcprodut,
                     pcfornec,
                     pcdepto,
                     pcsecao,
                     pcnfent,
                     pcconsum,
                     pcprodfilial,
                     pcpedido,
                     pcbonusc
             WHERE       pcmov.codprod = pcprodut.codprod
                     AND pcmov.numtransent = pcnfent.numtransent
                     AND pcprodut.codepto = pcdepto.codepto
                     AND pcprodut.codsec = pcsecao.codsec(+)
                     AND pcnfent.codfornec = pcfornec.codfornec
                     AND pcmov.codprod = pcprodfilial.codprod
                     AND pcmov.codfilial = pcprodfilial.codfilial
                     AND pcmov.numped = pcpedido.numped(+)
                     AND pcnfent.numbonus = pcbonusc.numbonus(+)
                     --AND PCNFENT.CODCONT NOT IN (PCCONSUM.CODCONTFRE, PCCONSUM.CODCONTOUT, PARAMFILIAL.OBTERCOMONUMBER('CODCONTSERV'))
                     AND pcnfent.tipodescarga NOT IN ('6', '7', '8', 'N', 'F')
                     AND pcmov.codoper NOT IN ('ED', 'EA')
                     AND pcprodut.codepto IN (100, 200, 300) -- parametro departamento
                     AND pcprodut.codsec IN (111, 210, 305) -- parametro secao
                     AND pcmov.dtcancel IS NULL
                     AND pcmov.qt > 0
                     AND pcmov.codoper LIKE 'E%'
                     /*         VALIDAÇÃO MES ATUAL          */
                     AND PCMOV.DTMOV BETWEEN TO_DATE('01/'||TO_CHAR(ADD_MONTHS (TRUNC(SYSDATE),-0),'MM/YYYY'), 'DD/MM/YYYY')
                     AND LAST_DAY(ADD_MONTHS(TRUNC(SYSDATE),-0))
                     /*             FIM                     */
                     AND pcnfent.codfilial NOT IN ('99')
                     AND pcmov.codoper LIKE 'E%'
          GROUP BY   pcnfent.codfornec, pcfornec.fornecedor
          ORDER BY   SUM (pcmov.qt * pcmov.punit) DESC, pcnfent.codfornec) a
          
