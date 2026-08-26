
-- =====================================================
-- Camada bronze - Tabela 1 - cadasto_clientes 
-- =====================================================

CREATE OR REPLACE TABLE bronze.cadastro_clientes AS 
SELECT 
    user_ID AS id_usuario,
    age AS idade,
    CASE 
        WHEN sex = 'F' THEN 'feminino'
        WHEN sex = 'M' THEN 'masculino'
        ELSE sex
    END AS sexo,
    last_month_salary AS salario_ultimo_mes,
    --NULLIF tornar nulos os campos onde há valor 0
    COALESCE(number_dependents, 0) AS numero_dependentes, -- SUBSTITUI OS VALORES NULOS POR 0
    -- Flag para rastrear dados problemáticos
    CASE 
        WHEN last_month_salary IS NULL THEN 'Renda não informada'
        WHEN last_month_salary = 0 THEN 'Sem renda no último mês' 
        ELSE 'Renda informada' 
    END AS situacao_salarial
FROM "banco-super-caja".main.cadastro_clientes;



-- =====================================================
-- Camada bronze - Tabela 2 - carteira_emprestimos 
-- =====================================================

CREATE OR REPLACE TABLE bronze.carteira_emprestimos AS 
SELECT loan_id AS id_emprestimo, 
user_id AS id_usuario, 
CASE 
	WHEN loan_type = 'REAL ESTATE' OR  loan_type ='Real Estate' THEN 'real estate'
	WHEN loan_type = 'others' OR  loan_type ='OTHER' OR loan_type ='Other' THEN 'other'
    WHEN loan_type IS NULL THEN 'não informado'
    ELSE loan_type END AS tipo_emprestimo

FROM "banco-super-caja".main.carteira_emprestimos; 



-- =====================================================
-- Camada bronze - Tabela 3 - detalhes_emprestimos - dados tratados
--inclusive retirados da análise clientes com número de atrasos maior que 96
-- =====================================================
CREATE OR REPLACE TABLE bronze.detalhes_emprestimos AS
SELECT 
user_id AS id_usuario, 
more_90_days_overdue AS atraso_emprestimo_mais_90_dias, 
using_lines_not_secured_personal_assets AS percentual_uso_limite_credito, 
number_times_delayed_payment_loan_30_59_days AS atraso_emprestimo_30_59_dias, 
debt_ratio AS indice_endividamento, 
number_times_delayed_payment_loan_60_89_days AS atraso_emprestimo_60_89_dias
FROM "banco-super-caja".main.detalhes_emprestimos
WHERE atraso_emprestimo_mais_90_dias < 96;



-- =====================================================
-- Camada bronze - Tabela 4 - flag_inadimplencia 
-- =====================================================
CREATE OR REPLACE TABLE bronze.flag_inadimplencia AS
SELECT 
CAST(user_id AS VARCHAR) AS id_usuario, 
default_flag AS flag_inadimplencia,
CASE
	WHEN default_flag = 0 THEN 'Não'
	WHEN default_flag = 1 THEN 'Sim'
	
END AS flag_inadimplencia_desc

FROM "banco-super-caja".main.flag_inadimplencia
;

-- =====================================================
-- Camada bronze - Tabela 5 - emprestimos_totais_por_cliente 
--===================================================== 

CREATE OR REPLACE TABLE bronze.emprestimos_totais_por_cliente AS

WITH real_estate AS(

SELECT id_usuario,COUNTIF( tipo_emprestimo = 'real estate') as total_imoveis
FROM "banco-super-caja".bronze.carteira_emprestimos
GROUP BY id_usuario 
),

 other AS(
SELECT id_usuario,COUNTIF( tipo_emprestimo = 'other') as total_outros
FROM "banco-super-caja".bronze.carteira_emprestimos
GROUP BY id_usuario 
)


SELECT 
r.id_usuario, 
r.total_imoveis,
o.total_outros,
(r.total_imoveis + o.total_outros) AS total_emprestimos
FROM real_estate r
LEFT JOIN other o
ON r.id_usuario=o.id_usuario
;

