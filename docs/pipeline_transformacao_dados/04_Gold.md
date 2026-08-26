# 1. Visao Geral da Camada Gold

A camada Gold é o produto final da arquitetura do projeto Super Caja Bank. Ela consome as dimensões enriquecidas da camada Silver e produz três tabelas analíticas complementares: uma base unificada para análise exploratória, uma tabela de segmentação de risco por variável e um score final de risco por cliente.

# 2. Tabela: gold.base_analise

**Base Unificada para Análise Exploratória de Risco de Credito**

## 2.1 Descricao

A tabela base_analise foi criada com a finalidade de ser  a fundação analítica da camada Gold. Ela une as duas dimensões da camada Silver (dim_cliente e fato_risco_credito) em uma visão única por cliente, reunindo atributos demográficos, comportamento financeiro e a flag de inadimplência. É a tabela de referência para as análises exploratórias e para o cálculo dos segmentos de risco.

## 2.2 Origens dos Dados

| **Tabela Silver** | **Tipo de JOIN** | **Dados fornecidos** |
| --- | --- | --- |
| silver.dim_cliente | Base (FROM) | Dados demográficos: idade, sexo, salários, dependentes e classificações. |
| silver.fato_risco_credito | INNER JOIN | Indicadores de risco: atrasos, uso de crédito, endividamento, flag de inadimplência |

*Decisão de design: o INNER JOIN garante que apenas clientes com dados de risco completos integrem a base de análise, evitando linhas com métricas de risco ausentes.*

## 2.3 Dicionário de Colunas - gold.base_analise

| **Coluna** | **Tipo** | **Origem Silver** | **Descricao** |
| --- | --- | --- | --- |
| id_usuario | INTEGER | dim_cliente | Identificador único do cliente (chave primaria) |
| idade | INTEGER | dim_cliente | Idade em anos |
| faixa_etaria | VARCHAR | dim_cliente | Segmento etário: Jovem / Adulto jovem / Adulto / Senior |
| salario_ultimo_mes | FLOAT | dim_cliente | Salario bruto declarado no último mês |
| classif_salario | VARCHAR | dim_cliente | Faixa salarial relativa por quartis: Baixo / Medio-baixo / Medio-alto / Alto |
| numero_dependentes | INTEGER | dim_cliente | Quantidade de dependentes declarados |
| tem_dependentes | VARCHAR | dim_cliente | Flag de presença de dependentes: Sim / Não |
| classif_num_dependentes | VARCHAR | dim_cliente | Rótulo categorizado do número de dependentes |
| atraso_emprestimo_mais_90_dias | INTEGER | dim_risco_credito | Número de ocorrências de atraso superior a 90 dias |
| classif_atrasos | VARCHAR | dim_risco_credito | Nível de risco por atrasos: Sem atraso / Baixo / Medio / Alto / Critico |
| percentual_uso_limite_credito | FLOAT | dim_risco_credito | Percentual de uso do limite de credito disponível |
| classif_uso_credito | VARCHAR | dim_risco_credito | Faixa de uso de crédito por quartis: Baixo / Medio-baixo / Medio-alto / Alto |
| indice_endividamento | FLOAT | dim_risco_credito | Índice de comprometimento de renda com dividas |
| classif_dividas | VARCHAR | dim_risco_credito | Faixa de endividamento por quartis: Baixo / Medio-baixo / Medio-alto / Alto |
| total_emprestimos | INTEGER | dim_risco_credito | Numero total de empréstimos contratados |
| classif_qtdade_emprestimos | VARCHAR | dim_risco_credito | Volume de emprestimos: Baixo / Medio / Alto / Critico |
| flag_inadimplencia | INTEGER | dim_risco_credito | Flag binaria de inadimplencia: 1 = inadimplente, 0 = adimplente |

# 3. Tabela: gold.segmentos_risco

**Segmentacao de Risco por Variavel - Razao de Risco e Dummies**

## 3.1 Descricao

A tabela segmentos_risco é a base para a criação do modelo de credit scoring. Para cada variável analítica e cada segmento dentro dela, calcula a taxa de inadimplencia do segmento, compara com a taxa geral da carteira e deriva uma razao de risco que determina se o segmento possui risco acima ou abaixo da media. O resultado final é uma variavel dummy (0 ou 1) que será usada diretamente na composicao do score de cada cliente.

## 3.2 Variaveis Analisadas

| **Variavel (campo variavel)** | **Coluna de segmentacao** | **Segmentos gerados** |
| --- | --- | --- |
| idade | faixa_etaria | Jovem / Adulto jovem / Adulto / Senior |
| salario | classif_salario | Baixo / Medio-baixo / Medio-alto / Alto |
| tem dependentes | tem_dependentes | Sim / Nao |
| no emprestimos ativos | classif_qtdade_emprestimos | Baixo / Medio / Alto / Critico |
| numero de atrasos mais 90 dias | classif_atrasos | Sem atraso / Baixo / Medio / Alto / Critico |
| uso do limite de credito | classif_uso_credito | Baixo / Medio-baixo / Medio-alto / Alto |
| nivel de endividamento | classif_dividas | Baixo / Medio-baixo / Medio-alto / Alto |

## 3.3 Metodologia: Razao de Risco

A razão de risco é o indicador central desta tabela. Ela expressa quantas vezes a taxa de inadimplencia de um segmento e maior ou menor do que a taxa media da carteira geral:

razao_risco = taxa_inadimplencia_segmento / taxa_inadimplencia_geral

- - razao_risco < 1 => segmento abaixo da media => 'baixo risco' => dummy = 0
- - razao_risco >= 1 => segmento acima da media => 'alto risco' => dummy = 1

*A taxa geral e calculada uma unica vez via CTE taxa_geral sobre gold.base_analise, e então cruzada com todos os segmentos via CROSS JOIN - garantindo que todos os segmentos usem exatamente o mesmo denominador.*

## 3.4 Estrutura de CTEs

A query é construida em duas camadas de CTEs antes da selecao final:

| **CTE** | **Responsabilidade** |
| --- | --- |
| taxa_geral | Calcula a taxa media de inadimplencia de toda a carteira (AVG da flag_inadimplencia como DOUBLE) |
| seg_faixa_etaria | Agrupa por faixa_etaria: conta clientes, soma inadimplentes, calcula taxa do segmento e captura minimo/maximo de idade |
| seg_faixa_salarial | Agrupa por classif_salario: mesma estrutura, com min/max de salario_ultimo_mes |
| seg_tem_dependentes | Agrupa por tem_dependentes (Sim/Nao): captura min/max de numero_dependentes |
| seg_qtdade_emprestimos | Agrupa por classif_qtdade_emprestimos: min/max de total_emprestimos |
| seg_atrasos | Agrupa por classif_atrasos: min/max de atraso_emprestimo_mais_90_dias |
| seg_uso_limite | Agrupa por classif_uso_credito: min/max de percentual_uso_limite_credito |
| seg_endividamento | Agrupa por classif_dividas: min/max de indice_endividamento |
| todos_segmentos | Une todos os segmentos acima via UNION ALL em estrutura uniforme |

## 3.5 Dicionario de Colunas - gold.segmentos_risco

| **Coluna** | **Tipo** | **Descricao** |
| --- | --- | --- |
| variavel | VARCHAR | Nome da variavel analisada (ex: 'idade', 'salario', 'uso do limite de credito') |
| segmento | VARCHAR | Valor do segmento dentro da variavel (ex: 'Jovem', 'Alto', 'Sem atraso') |
| minimo | FLOAT | Valor minimo da variavel numerica original no segmento |
| maximo | FLOAT | Valor maximo da variavel numerica original no segmento |
| total_clientes | INTEGER | Numero de clientes no segmento |
| qtd_inadimplentes | INTEGER | Numero de clientes inadimplentes no segmento |
| taxa_inadimplencia_segmento | FLOAT | Taxa de inadimplencia do segmento (arredondada em 6 casas) |
| taxa_inadimplencia_geral | FLOAT | Taxa media de inadimplencia de toda a carteira (referencia) |
| razao_risco | FLOAT | Razao entre taxa do segmento e taxa geral (arredondada em 4 casas) |
| flag_risco | VARCHAR | Classificacao qualitativa: 'baixo risco' (razao < 1) ou 'alto risco' (razao >= 1) |
| dummy_risco | INTEGER | Variavel binaria: 0 = baixo risco, 1 = alto risco |

# 4. Tabela: gold.score_clientes

**Score Final de Risco por Cliente - Modelo de Credit Scoring por Dummies**

## 4.1 Descricao

A tabela score_clientes é o produto final do modelo de credit scoring. Para cada cliente, ela atribui um score de risco somando as dummies de risco de cinco variaveis-chave obtidas por meio da tabela segmentos_risco. O score varia de 0 a 5 e é mapeado para um perfil qualitativo de risco que sintetiza a posicao do cliente na carteira.

## 4.2 Metodologia: Modelo de Score por Dummies

O modelo é baseado na soma de variáveis binárias(dummies), onde cada dummy representa se o cliente pertence a um segmento classificado como 'alto risco' (dummy = 1) ou 'baixo risco' (dummy = 0) na tabela segmentos_risco. Cinco dimensões de risco são consideradas:

| **Dummy** | **Coluna do cliente** | **Segmento de origem em segmentos_risco** |
| --- | --- | --- |
| dummy_idade | faixa_etaria | variavel = 'idade' |
| dummy_salario | classif_salario | variavel = 'salario' |
| dummy_atrasos | classif_atrasos | variavel = 'numero de atrasos mais 90 dias' |
| dummy_uso_credito | classif_uso_credito | variavel = 'uso do limite de credito' |
| dummy_dividas | classif_dividas | variavel = 'nivel de endividamento' |

score_total = dummy_idade + dummy_salario + dummy_atrasos

+ dummy_uso_credito + dummy_dividas

- - Range: 0 (nenhum fator de risco) a 5 (todos os fatores de risco presentes)

## 4.3 Escala de Perfil de Risco Final

| **Score Total** | **Perfil de Risco Final** | **Interpretacao** |
| --- | --- | --- |
| **0** | risco muito baixo | Nenhum fator de risco presente - perfil altamente seguro |
| **1 a 2** | risco baixo | Poucos fatores de risco - cliente com boa saude financeira |
| **3** | risco medio | Multiplos fatores de risco - requer analise adicional |
| **4 a 5** | risco alto | Maioria dos fatores de risco presentes - alto potencial de inadimplencia |

## 4.4 Dicionario de Colunas - gold.score_clientes

| **Coluna** | **Tipo** | **Descricao** |
| --- | --- | --- |
| id_usuario | INTEGER | Identificador unico do cliente |
| faixa_etaria | VARCHAR | Segmento etario do cliente |
| dummy_idade | INTEGER | 1 se a faixa etaria do cliente e de alto risco, 0 caso contrario |
| classif_salario | VARCHAR | Classificacao salarial do cliente por quartis |
| dummy_salario | INTEGER | 1 se a faixa salarial do cliente e de alto risco, 0 caso contrario |
| classif_atrasos | VARCHAR | Nivel de atrasos acima de 90 dias |
| dummy_atrasos | INTEGER | 1 se o nivel de atrasos do cliente e de alto risco, 0 caso contrario |
| classif_uso_credito | VARCHAR | Faixa de uso do limite de credito por quartis |
| dummy_uso_credito | INTEGER | 1 se o uso de credito do cliente e de alto risco, 0 caso contrario |
| classif_dividas | VARCHAR | Faixa de endividamento por quartis |
| dummy_dividas | INTEGER | 1 se o nivel de endividamento do cliente e de alto risco, 0 caso contrario |
| score_total | INTEGER | Soma das 5 dummies de risco (range: 0 a 5) |
| perfil_risco_final | VARCHAR | Perfil qualitativo: risco muito baixo / baixo / medio / alto |
| flag_inadimplencia | INTEGER | Flag real de inadimplencia: 1 = inadimplente, 0 = adimplente (para validacao do modelo) |

# 5. Notas Tecnicas e Decisoes de Design

| **Decisao** | **Justificativa** |
| --- | --- |
| INNER JOIN em base_analise | Garante que apenas clientes com dados de risco completos integrem a base, evitando distorcoes nas taxas de inadimplencia calculadas em segmentos_risco. |
| CROSS JOIN com taxa_geral | Propaga o denominador global para todos os segmentos em uma unica operacao, garantindo consistencia do calculo sem subconsultas repetidas. |
| UNION ALL para unir segmentos | Todos os segmentos possuem estrutura identica de colunas, tornando UNION ALL semanticamente correto e mais eficiente que UNION (sem verificacao de duplicatas). |
| Dummies aditivas no score | A soma de variaveis binarias e uma abordagem interpretavel e auditavel: cada ponto do score e rastreavel a um segmento especifico de risco. |
| flag_inadimplencia em score_clientes | Mantida como coluna de validacao para permitir avaliacao da qualidade preditiva do score atraves de comparacoes diretas entre score_total e o status real de inadimplencia. |
| CREATE OR REPLACE em todas as tabelas | Permite reprocessamento idempotente sem necessidade de scripts de limpeza manual. |
