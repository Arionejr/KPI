SELECT PVENDA as VALOR FROM (
SELECT 
       SUM(ROUND(NVL(PCPEDI.QT,0)*(NVL(PCPEDI.PVENDA, 0) + NVL(PCPEDI.VLOUTRASDESP, 0) + NVL(PCPEDI.VLFRETE, 0)),2)) AS PVENDA
FROM     
PCPEDI,  
PCPEDC,  
PCPRODUT,
PCCLIENT,
PCFORNEC,
PCDEPTO
WHERE 1=1 
AND PCPEDC.DATA BETWEEN TO_DATE('01/'||TO_CHAR(ADD_MONTHS (TRUNC(SYSDATE),-0),'MM/YYYY'), 'DD/MM/YYYY')
AND LAST_DAY(ADD_MONTHS(TRUNC(SYSDATE),-0))
AND PCPEDC.CODFILIAL IN ('1')
AND PCPEDC.CONDVENDA IN (1, 2, 3, 7, 9, 14, 15, 17, 18, 19, 98)
and PCPEDC.NUMPED    = PCPEDI.NUMPED
AND   PCPEDI.CODPROD   = PCPRODUT.CODPROD
AND   PCPEDC.CODCLI    = PCCLIENT.CODCLI
AND   PCPRODUT.CODFORNEC = PCFORNEC.CODFORNEC
AND   PCPRODUT.CODEPTO = PCDEPTO.codepto
 AND NVL(PCPEDI.BONIFIC, 'N') =  'N' 
AND   PCDEPTO.CODEPTO IN (100)
AND   PCPRODUT.codsec IN (101)
AND   PCPEDC.POSICAO IN ('F')
AND   PCPEDC.DTCANCEL IS NULL) Q
