-- =====================================================
-- Camada gold -Tabela base_analise  
--===================================================== 
CREATE OR REPLACE TABLE gold.base_analise AS 

SELECT 
c.id_usuario,
idade, 
faixa_etaria, 
salario_ultimo_mes_imputado, 
classif_salario, 
situacao_salarial,
numero_dependentes,
tem_dependentes, 
classif_num_dependentes,

atraso_emprestimo_mais_90_dias, 
classif_atrasos, 
tem_atrasos,
percentual_uso_limite_credito, 
classif_uso_credito, indice_endividamento, 
classif_dividas, 
total_emprestimos, 
classif_qtdade_emprestimos, 
flag_inadimplencia,
flag_inadimplencia_desc

FROM "banco-super-caja".silver.dim_cliente c

INNER JOIN "banco-super-caja".silver.fato_risco_credito r

ON c.id_usuario = r.id_usuario
;

-- =====================================================
-- Camada gold - Tabela segmentos_risco 
--===================================================== 

CREATE OR REPLACE TABLE gold.segmentos_risco AS

WITH
 
-- Taxa geral de inadimplência 
taxa_geral AS (
    SELECT
        AVG(flag_inadimplencia::DOUBLE) AS taxa_inadimplencia_geral
    FROM "banco-super-caja".gold.base_analise 
),

-- Segmentação por faixa etária
seg_faixa_etaria AS (
    SELECT
        'idade'              AS variavel,
        MIN(idade)			 AS minimo,
        MAX(idade)			 AS maximo,
        faixa_etaria               AS segmento,
        COUNT(*)                     AS total_clientes,
        SUM(flag_inadimplencia)    AS qtd_inadimplentes,
        AVG(flag_inadimplencia::DOUBLE) AS taxa_inadimplencia_segmento
    FROM "banco-super-caja".gold.base_analise 
    GROUP BY faixa_etaria
 ),
    
-- Segmentação por faixa salarial
 
 seg_faixa_salarial AS (
    SELECT
        'salario'             AS variavel,
        MIN(salario_ultimo_mes_imputado)			 AS minimo,
        MAX(salario_ultimo_mes_imputado)			 AS maximo,
        classif_salario             AS segmento,
        COUNT(*)                     AS total_clientes,
        SUM(flag_inadimplencia)    AS qtd_inadimplentes,
        AVG(flag_inadimplencia::DOUBLE) AS taxa_inadimplencia_segmento
    FROM "banco-super-caja".gold.base_analise
    
    GROUP BY classif_salario
),

-- Segmentação por tem dependentes
 
 seg_tem_dependentes AS (
    SELECT
        'tem dependentes'             AS variavel,
        MIN(numero_dependentes)			 AS minimo,
        MAX(numero_dependentes)			 AS maximo,
        tem_dependentes             AS segmento,
        COUNT(*)                     AS total_clientes,
        SUM(flag_inadimplencia)    AS qtd_inadimplentes,
        AVG(flag_inadimplencia::DOUBLE) AS taxa_inadimplencia_segmento
    FROM "banco-super-caja".gold.base_analise
    
    GROUP BY tem_dependentes
),

-- Segmentação por quantidade de empréstimos ativos
 
 seg_qtdade_emprestimos AS (
    SELECT
        'nº empréstimos ativos'             AS variavel,
        MIN(total_emprestimos)			 AS minimo,
        MAX(total_emprestimos)			 AS maximo,
        classif_qtdade_emprestimos             AS segmento,
        COUNT(*)                     AS total_clientes,
        SUM(flag_inadimplencia)    AS qtd_inadimplentes,
        AVG(flag_inadimplencia::DOUBLE) AS taxa_inadimplencia_segmento
    FROM "banco-super-caja".gold.base_analise
    
    GROUP BY classif_qtdade_emprestimos
),


 
-- Segmentação por faixa de atrasos totais
seg_atrasos AS (
SELECT
        'número de atrasos mais 90 dias'             AS variavel,
        MIN(atraso_emprestimo_mais_90_dias)			 AS minimo,
        MAX(atraso_emprestimo_mais_90_dias)			 AS maximo,
        classif_atrasos             AS segmento,
        COUNT(*)                     AS total_clientes,
        SUM(flag_inadimplencia)    AS qtd_inadimplentes,
        AVG(flag_inadimplencia::DOUBLE) AS taxa_inadimplencia_segmento
    FROM "banco-super-caja".gold.base_analise
    
    GROUP BY classif_atrasos
),

-- Segmentação por uso do limite de crédito
seg_uso_limite AS (
	SELECT
        'uso do limite de crédito'             AS variavel,
        MIN(percentual_uso_limite_credito)			 AS minimo,
        MAX(percentual_uso_limite_credito)			 AS maximo,
        classif_uso_credito             AS segmento,
        COUNT(*)                     AS total_clientes,
        SUM(flag_inadimplencia)    AS qtd_inadimplentes,
        AVG(flag_inadimplencia::DOUBLE) AS taxa_inadimplencia_segmento
    FROM "banco-super-caja".gold.base_analise
    
    GROUP BY classif_uso_credito
),

-- Segmentação por índice de endividamento
seg_endividamento AS (
	SELECT
        'nível de endividamento'             AS variavel,
        MIN(indice_endividamento)			 AS minimo,
        MAX(indice_endividamento)			 AS maximo,
        classif_dividas             AS segmento,
        COUNT(*)                     AS total_clientes,
        SUM(flag_inadimplencia)    AS qtd_inadimplentes,
        AVG(flag_inadimplencia::DOUBLE) AS taxa_inadimplencia_segmento
    FROM "banco-super-caja".gold.base_analise
    
    GROUP BY classif_dividas 
),

-- União de todos os segmentos
todos_segmentos AS (
    SELECT * FROM seg_faixa_etaria
    UNION ALL
    SELECT * FROM seg_faixa_salarial
    UNION ALL
    SELECT * FROM seg_tem_dependentes
    UNION ALL
    SELECT * FROM seg_qtdade_emprestimos
    UNION ALL
    SELECT * FROM seg_atrasos
    UNION ALL
    SELECT * FROM seg_uso_limite
    UNION ALL
    SELECT * FROM seg_endividamento
)
 
-- Resultado final: razão de risco + dummies

SELECT
    variavel,
    segmento,
    minimo,
    maximo,
    total_clientes,
    qtd_inadimplentes,
    ROUND(taxa_inadimplencia_segmento, 6)  AS taxa_inadimplencia_segmento,
    ROUND(tg.taxa_inadimplencia_geral, 6)     AS taxa_inadimplencia_geral,
    ROUND((taxa_inadimplencia_segmento /tg.taxa_inadimplencia_geral), 4)                                          AS razao_risco,
    -- Flag qualitativa
    CASE
        WHEN 
        (taxa_inadimplencia_segmento /tg.taxa_inadimplencia_geral) < 1 THEN 'baixo risco'
        ELSE 'alto risco'
    END                                        AS flag_risco,
    -- Dummy: 0 = baixo risco, 1 = alto risco
    CASE
        WHEN (taxa_inadimplencia_segmento /tg.taxa_inadimplencia_geral) < 1 THEN 0
        ELSE 1
    END                                        AS dummy_risco
FROM todos_segmentos 
CROSS JOIN taxa_geral tg
ORDER BY variavel, razao_risco DESC;

-- =====================================================
-- Camada gold - Tabela score_clientes  
--===================================================== 

CREATE OR REPLACE TABLE gold.score_clientes AS

SELECT 
    v.id_usuario, 
    v.faixa_etaria, 
    s1.dummy_risco AS dummy_idade,
    v.classif_salario, 
    s2.dummy_risco AS dummy_salario,
    v.classif_atrasos, 
    s3.dummy_risco AS dummy_atrasos,
    v.classif_uso_credito,
    s4.dummy_risco AS dummy_uso_credito,
    v.classif_dividas, 
    s5.dummy_risco AS dummy_dividas,
    (dummy_idade + dummy_salario + dummy_atrasos + dummy_uso_credito + dummy_dividas) AS score_total,
   CASE
   	WHEN score_total = 0 THEN 'risco muito baixo'
   	WHEN score_total BETWEEN 1 AND 2 THEN 'risco baixo'
   	WHEN score_total = 3 THEN 'risco médio'
   	WHEN score_total BETWEEN 4 AND 5 THEN 'risco alto'
   	END AS perfil_risco_final,
      
    v.flag_inadimplencia,
    v.flag_inadimplencia_desc
    
FROM "banco-super-caja".gold.base_analise v

JOIN "banco-super-caja".gold.segmentos_risco s1
    ON v.faixa_etaria = s1.segmento AND s1.variavel = 'idade'
    
JOIN "banco-super-caja".gold.segmentos_risco s2
    ON v.classif_salario = s2.segmento AND s2.variavel = 'salario'

JOIN "banco-super-caja".gold.segmentos_risco s3
    ON v.classif_atrasos = s3.segmento AND s3.variavel = 'número de atrasos mais 90 dias'

JOIN "banco-super-caja".gold.segmentos_risco s4
    ON v.classif_uso_credito = s4.segmento AND s4.variavel = 'uso do limite de crédito'
    
JOIN "banco-super-caja".gold.segmentos_risco s5
    ON v.classif_dividas = s5.segmento AND s5.variavel = 'nível de endividamento'
    
    ;

   
