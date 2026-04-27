-- ============================================================
-- IDENTIFICAÇÃO DE REGISTROS DUPLICADOS
-- Projeto: Análise de Risco de Crédito
-- Banco: BigQuery | Dataset: PROJETO3
-- ============================================================


-- ------------------------------------------------------------
-- 1. Duplicados de user_id em tb_default
-- ------------------------------------------------------------
SELECT
  user_id,
  COUNT(*) AS quantidade
FROM `meu-primeiro-projeto-419811.PROJETO3.tb_defaut`
GROUP BY user_id
HAVING quantidade > 1;


-- ------------------------------------------------------------
-- 2. Duplicados de loan_id em tb_loans_outstanding
-- Obs: COUNT(*) conta o número de registros por grupo (GROUP BY)
--      e HAVING filtra apenas grupos com mais de 1 ocorrência
-- ------------------------------------------------------------
SELECT
  loan_id,
  COUNT(*) AS quantidade
FROM `meu-primeiro-projeto-419811.PROJETO3.tb_loans_outstanding`
GROUP BY loan_id
HAVING quantidade > 1;
