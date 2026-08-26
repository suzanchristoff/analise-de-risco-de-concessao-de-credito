-- =====================================================
-- Camada silver - tabela dim_cliente
-- =====================================================

CREATE OR REPLACE TABLE silver.dim_cliente AS


WITH 


sal_imputado 
AS (SELECT *,
     COALESCE(salario_ultimo_mes, MEDIAN(salario_ultimo_mes) OVER()) AS salario_ultimo_mes_imputado
     FROM "banco-super-caja".bronze.cadastro_clientes),
     
quartis 
AS (SELECT *,
    quantile_cont(salario_ultimo_mes_imputado, 0.25) OVER () AS sal_p25,
    quantile_cont(salario_ultimo_mes_imputado, 0.50) OVER () AS sal_p50,
    quantile_cont(salario_ultimo_mes_imputado, 0.75) OVER () AS sal_p75
FROM sal_imputado)


SELECT id_usuario,idade,
CASE 
   WHEN idade < 25 THEN '1.Jovem 18-25 anos' -- início da vida financeira
   WHEN idade < 40 THEN '2.Adulto jovem 26-40 anos' -- crescimento de renda e crédito
   WHEN idade < 60 THEN '3.Adulto 41-60 anos' -- pico de capacidade financeira
   ELSE '4.Sênior + 60 anos' -- aposentadoria / renda fixa
   END AS faixa_etaria,


sexo,
salario_ultimo_mes, situacao_salarial, salario_ultimo_mes_imputado,
CASE 
   WHEN salario_ultimo_mes_imputado IS NULL THEN 'Não-informado'
   WHEN salario_ultimo_mes_imputado <= sal_p25 THEN 'Baixo'
   WHEN salario_ultimo_mes_imputado <= sal_p50 THEN 'Médio-baixo'
   WHEN salario_ultimo_mes_imputado <= sal_p75 THEN 'Médio-alto'
      ELSE 'Alto'
   END AS classif_salario,
      numero_dependentes,
  CASE 
   WHEN numero_dependentes = 0 THEN 'Não'
   WHEN numero_dependentes >= 1 THEN 'Sim'
   END AS tem_dependentes,
   
  CASE 
   WHEN numero_dependentes = 0 THEN 'Sem dependentes'
   WHEN numero_dependentes = 1 THEN '1 dependente'
   WHEN numero_dependentes = 2 THEN '2 dependentes'
   WHEN numero_dependentes = 3 THEN '3 dependentes'
   WHEN numero_dependentes >= 4 THEN '4 dependentes ou mais'
   END AS classif_num_dependentes,


FROM quartis;


-- =====================================================
-- camada silver - tabela fato_risco_credito 
--===================================================== 


CREATE OR REPLACE TABLE silver.fato_risco_credito AS

WITH quartis_credito_e_dividas AS(

SELECT 
    *,
    quantile_cont(percentual_uso_limite_credito, 0.25) OVER () AS cred_p25,
    quantile_cont(percentual_uso_limite_credito, 0.50) OVER () AS cred_p50,
    quantile_cont(percentual_uso_limite_credito, 0.75) OVER () AS cred_p75,

    quantile_cont(indice_endividamento, 0.25) OVER () AS div_p25,
    quantile_cont(indice_endividamento, 0.50) OVER () AS div_p50,
    quantile_cont(indice_endividamento, 0.75) OVER () AS div_p75,

FROM "banco-super-caja".bronze.detalhes_emprestimos
)

SELECT 
q.id_usuario, 
atraso_emprestimo_mais_90_dias,

CASE 
	WHEN atraso_emprestimo_mais_90_dias = 0 THEN 'Sem atraso'
    WHEN atraso_emprestimo_mais_90_dias = 1 THEN 'Baixo '
    WHEN atraso_emprestimo_mais_90_dias <= 3 THEN 'Médio'
    WHEN atraso_emprestimo_mais_90_dias <= 6 THEN 'Alto'
    ELSE 'Crítico'
    END AS classif_atrasos,
    
 CASE 
	WHEN atraso_emprestimo_mais_90_dias = 0 THEN 'Não'
	WHEN atraso_emprestimo_mais_90_dias > 0 THEN 'Sim'
	END AS tem_atrasos,
    
percentual_uso_limite_credito,

CASE 
   WHEN percentual_uso_limite_credito <= cred_p25 THEN 'Baixo'
   WHEN percentual_uso_limite_credito <= cred_p50 THEN 'Médio-baixo'
   WHEN percentual_uso_limite_credito <= cred_p75 THEN 'Médio-alto'
   ELSE 'Alto'
   END AS classif_uso_credito,
   
indice_endividamento,

CASE 
   WHEN indice_endividamento <= div_p25 THEN 'Baixo'
   WHEN indice_endividamento <= div_p50 THEN 'Médio-baixo'
   WHEN indice_endividamento <= div_p75 THEN 'Médio-alto'
   ELSE 'Alto'
   END AS classif_dividas,
   
e.total_emprestimos,

CASE 
	WHEN e.total_emprestimos <= 5 THEN '1-5'
    WHEN e.total_emprestimos <= 10 THEN '6-10'
    WHEN e.total_emprestimos <= 15  THEN '11-15'
    ELSE '16 ou mais'
    END AS classif_qtdade_emprestimos,
    
    f.flag_inadimplencia,
    f.flag_inadimplencia_desc
  
FROM quartis_credito_e_dividas q

LEFT JOIN "banco-super-caja".bronze.flag_inadimplencia f

ON q.id_usuario = f.id_usuario

LEFT JOIN "banco-super-caja".bronze.emprestimos_totais_por_cliente e

ON q.id_usuario = e.id_usuario;

