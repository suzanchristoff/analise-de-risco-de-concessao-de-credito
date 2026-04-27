-- ============================================================
-- VERIFICAÇÃO DE VALORES NULOS POR TABELA
-- Projeto: Análise de Risco de Crédito
-- Banco: BigQuery | Dataset: PROJETO3
-- ============================================================


-- ------------------------------------------------------------
-- 1. tb_default — verificação de user_id nulo
-- ------------------------------------------------------------
SELECT *
FROM `meu-primeiro-projeto-419811.PROJETO3.tb_defaut`
WHERE user_id IS NULL;


-- ------------------------------------------------------------
-- 2. tb_user_info — contagem de nulos por coluna
-- ------------------------------------------------------------
SELECT
  COUNT(CASE WHEN user_id           IS NULL THEN 1 END) AS user_id_null_count,
  COUNT(CASE WHEN age                IS NULL THEN 1 END) AS age_null_count,
  COUNT(CASE WHEN sex                IS NULL THEN 1 END) AS sex_null_count,
  COUNT(CASE WHEN last_month_salary  IS NULL THEN 1 END) AS last_month_salary_null_count,
  COUNT(CASE WHEN number_dependents  IS NULL THEN 1 END) AS number_dependents_null_count
FROM `meu-primeiro-projeto-419811.PROJETO3.tb_user_info`;


-- ------------------------------------------------------------
-- 3. tb_loans_outstanding — contagem de nulos por coluna
-- ------------------------------------------------------------
SELECT
  COUNT(CASE WHEN user_id   IS NULL THEN 1 END) AS user_id_null_count,
  COUNT(CASE WHEN loan_id   IS NULL THEN 1 END) AS loan_id_null_count,
  COUNT(CASE WHEN loan_type IS NULL THEN 1 END) AS loan_type_null_count
FROM `meu-primeiro-projeto-419811.PROJETO3.tb_loans_outstanding`;


-- ------------------------------------------------------------
-- 4. tb_loans_detail — contagem de nulos por coluna
-- ------------------------------------------------------------
SELECT
  COUNT(CASE WHEN user_id                                      IS NULL THEN 1 END) AS user_id_null_count,
  COUNT(CASE WHEN more_90_days_overdue                         IS NULL THEN 1 END) AS more_90_days_overdue_null_count,
  COUNT(CASE WHEN using_lines_not_secured_personal_assets      IS NULL THEN 1 END) AS using_lines_not_secured_null_count,
  COUNT(CASE WHEN number_times_delayed_payment_loan_30_59_days IS NULL THEN 1 END) AS delayed_30_59_null_count,
  COUNT(CASE WHEN debt_ratio                                   IS NULL THEN 1 END) AS debt_ratio_null_count,
  COUNT(CASE WHEN number_times_delayed_payment_loan_60_89_days IS NULL THEN 1 END) AS delayed_60_89_null_count
FROM `meu-primeiro-projeto-419811.PROJETO3.tb_loans_detail`;


-- ------------------------------------------------------------
-- 5. view_tb_dados_totais — verificação de nulos pós-união
-- ------------------------------------------------------------
SELECT
  COUNT(CASE WHEN user_id                                      IS NULL THEN 1 END) AS user_id_null_count,
  COUNT(CASE WHEN default_flag                                 IS NULL THEN 1 END) AS default_flag_null_count,
  COUNT(CASE WHEN more_90_days_overdue                         IS NULL THEN 1 END) AS more_90_days_overdue_null_count,
  COUNT(CASE WHEN using_lines_not_secured_personal_assets      IS NULL THEN 1 END) AS using_lines_not_secured_null_count,
  COUNT(CASE WHEN number_times_delayed_payment_loan_30_59_days IS NULL THEN 1 END) AS delayed_30_59_null_count,
  COUNT(CASE WHEN debt_ratio                                   IS NULL THEN 1 END) AS debt_ratio_null_count,
  COUNT(CASE WHEN number_times_delayed_payment_loan_60_89_days IS NULL THEN 1 END) AS delayed_60_89_null_count,
  COUNT(CASE WHEN age                                          IS NULL THEN 1 END) AS age_null_count,
  COUNT(CASE WHEN sex                                          IS NULL THEN 1 END) AS sex_null_count,
  COUNT(CASE WHEN last_month_salary                            IS NULL THEN 1 END) AS last_month_salary_null_count,
  COUNT(CASE WHEN number_dependents                            IS NULL THEN 1 END) AS number_dependents_null_count,
  COUNT(CASE WHEN total_loans                                  IS NULL THEN 1 END) AS total_loans_null_count
FROM `meu-primeiro-projeto-419811.PROJETO3.view_tb_dados_totais`;
