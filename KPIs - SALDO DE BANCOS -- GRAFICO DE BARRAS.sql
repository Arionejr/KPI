--AUTOR: ARIONE JUNIOR 
SELECT   banco AS nome, 'BANCO' AS x, valor AS y
  FROM   (SELECT   d.codbanco || ' - ' || d.nomebanco banco, d.valor valor
            FROM   table(CAST (
                             boletim_financeiro.consultabanco (
                                 '1'',''11'',''2'',''3'',''5'',''99') AS tabela_boletimfinanceiro)) d)
         a            
