-- ============================================================
-- TRANSFORMAÇÃO E TRATAMENTO DE DADOS
-- Projeto: Análise de Risco de Crédito
-- Banco: BigQuery | Dataset: PROJETO3
-- ============================================================


-- ------------------------------------------------------------
-- 1. Padronização de variáveis categóricas — loan_type
--    Converte variações de 'others' para 'OTHER' em maiúsculas
-- ------------------------------------------------------------
SELECT
  loan_id,
  user_id,
  UPPER(REGEXP_REPLACE(loan_type, 'others', 'OTHER')) AS loan_type
FROM `meu-primeiro-projeto-419811.PROJETO3.tb_loans_outstanding`;


-- ------------------------------------------------------------
-- 2. Codificação One-Hot — tipo de empréstimo (etapa 1)
--    Cria flags binárias para cada tipo de empréstimo
-- ------------------------------------------------------------
SELECT
  user_id,
  loan_type,
  CASE WHEN loan_type = 'REAL STATE' THEN 1 ELSE 0 END AS real_state,
  CASE WHEN loan_type = 'OTHER'      THEN 1 ELSE 0 END AS other
FROM `meu-primeiro-projeto-419811.PROJETO3.view_tb_loans_outstanding`;


-- ------------------------------------------------------------
-- 3. Codificação One-Hot — tipo de empréstimo (etapa 2, view final)
--    Aplicada sobre view_tb_dados_totais
-- ------------------------------------------------------------
SELECT
  user_id,
  type_real_estate,
  type_other,
  CASE WHEN type_real_estate = 'REAL STATE' THEN 1 ELSE 0 END AS real_state,
  CASE WHEN type_other       = 'OTHER'      THEN 1 ELSE 0 END AS other
FROM `meu-primeiro-projeto-419811.PROJETO3.view_tb_dados_totais`;


-- ------------------------------------------------------------
-- 4. União das tabelas principais (view base do projeto)
--    Combina: tb_default + tb_loans_detail + tb_user_info
--             + view_tb_total_loans_por_cliente
-- ------------------------------------------------------------
SELECT
  d.user_id,
  d.default_flag,
  l.more_90_days_overdue,
  l.using_lines_not_secured_personal_assets,
  l.number_times_delayed_payment_loan_30_59_days,
  l.debt_ratio,
  l.number_times_delayed_payment_loan_60_89_days,
  u.age,
  u.sex,
  u.last_month_salary,
  u.number_dependents,
  t.total_loans
FROM `meu-primeiro-projeto-419811.PROJETO3.tb_defaut` AS d
LEFT JOIN `meu-primeiro-projeto-419811.PROJETO3.tb_loans_detail` AS l
  ON d.user_id = l.user_id
LEFT JOIN `meu-primeiro-projeto-419811.PROJETO3.tb_user_info` AS u
  ON d.user_id = u.user_id
LEFT JOIN `meu-primeiro-projeto-419811.PROJETO3.view_tb_total_loans_por_cliente` AS t
  ON d.user_id = t.user_id
WHERE
  (IFNULL(r.total_real_estate, 0) + IFNULL(o.total_other, 0)) <> 0;
