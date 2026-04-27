-- ============================================================
-- DETECÇÃO DE OUTLIERS — MÉTODO IQR
-- Projeto: Análise de Risco de Crédito
-- Banco: BigQuery | Dataset: PROJETO3
-- ============================================================

-- Identifica valores atípicos na variável more_90_days_overdue
-- usando o método Intervalo Interquartil (IQR):
--   Limite inferior = Q1 - 1.5 * IQR
--   Limite superior = Q3 + 1.5 * IQR

WITH stats AS (
  SELECT
    APPROX_QUANTILES(more_90_days_overdue, 4)[OFFSET(1)] AS Q1,
    APPROX_QUANTILES(more_90_days_overdue, 4)[OFFSET(3)] AS Q3
  FROM `meu-primeiro-projeto-419811.PROJETO3.view_tb_final_dados_integrados`
),
iqr_stats AS (
  SELECT
    Q1,
    Q3,
    Q3 - Q1                   AS IQR,
    Q1 - 1.5 * (Q3 - Q1)     AS lower_bound,
    Q3 + 1.5 * (Q3 - Q1)     AS upper_bound
  FROM stats
)
SELECT
  more_90_days_overdue
FROM `meu-primeiro-projeto-419811.PROJETO3.view_tb_final_dados_integrados`, iqr_stats
WHERE
  more_90_days_overdue < lower_bound
  OR more_90_days_overdue > upper_bound;
