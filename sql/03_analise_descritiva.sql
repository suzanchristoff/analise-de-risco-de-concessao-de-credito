-- ============================================================
-- EXPLORAÇÃO E ANÁLISE DESCRITIVA
-- Projeto: Análise de Risco de Crédito
-- Banco: BigQuery | Dataset: PROJETO3
-- ============================================================


-- ------------------------------------------------------------
-- 1. Medidas descritivas — tb_default
-- ------------------------------------------------------------
SELECT
  AVG(default_flag) AS avg_default_flag,
  MAX(default_flag) AS max_default_flag,
  MIN(default_flag) AS min_default_flag
FROM `meu-primeiro-projeto-419811.PROJETO3.tb_defaut`;


-- ------------------------------------------------------------
-- 2. Total de empréstimos por cliente
-- ------------------------------------------------------------
SELECT
  user_id,
  COUNT(*) AS total_loans
FROM `meu-primeiro-projeto-419811.PROJETO3.tb_loans_outstanding`
GROUP BY user_id;


-- ------------------------------------------------------------
-- 3. Distribuição por tipo de empréstimo
-- ------------------------------------------------------------
SELECT
  loan_type,
  COUNT(*) AS quantidade
FROM `meu-primeiro-projeto-419811.PROJETO3.tb_loans_outstanding`
GROUP BY loan_type;


-- ------------------------------------------------------------
-- 4. Tipo de empréstimo por cliente (view agrupada)
-- ------------------------------------------------------------
SELECT
  user_id,
  loan_type,
  COUNT(*) AS total
FROM `meu-primeiro-projeto-419811.PROJETO3.view_tb_loans_outstanding`
GROUP BY user_id, loan_type
ORDER BY total DESC;


-- ------------------------------------------------------------
-- 5. Clientes inadimplentes (flag=1) com last_month_salary nulo
--    Relaciona tb_user_info x tb_default via LEFT JOIN
--    Resultado: 130 clientes identificados
-- ------------------------------------------------------------
SELECT
  a.age,
  a.last_month_salary,
  a.number_dependents,
  a.sex,
  a.user_id,
  b.default_flag
FROM `meu-primeiro-projeto-419811.PROJETO3.tb_user_info` AS a
LEFT JOIN `meu-primeiro-projeto-419811.PROJETO3.tb_defaut` AS b
  ON a.user_id = b.user_id
WHERE last_month_salary IS NULL
  AND default_flag = 1;


-- ------------------------------------------------------------
-- 6. Correlação de Pearson entre variáveis-chave
--    Base: view_tb_dados_totais
-- ------------------------------------------------------------
SELECT
  CORR(number_times_delayed_payment_loan_30_59_days, number_times_delayed_payment_loan_60_89_days) AS corr_delayed_30_59_vs_60_89,
  CORR(number_times_delayed_payment_loan_30_59_days, more_90_days_overdue)                         AS corr_delayed_30_59_vs_90plus,
  CORR(more_90_days_overdue, default_flag)                                                          AS corr_90plus_vs_default,
  CORR(total_loans, number_times_delayed_payment_loan_30_59_days)                                   AS corr_total_loans_vs_delayed_30_59,
  CORR(total_real_estate, default_flag)                                                             AS corr_real_estate_vs_default,
  CORR(total_real_estate, total_other)                                                              AS corr_real_estate_vs_other,
  CORR(number_dependents, total_loans)                                                              AS corr_dependents_vs_total_loans
FROM `meu-primeiro-projeto-419811.PROJETO3.view_tb_dados_totais`;
