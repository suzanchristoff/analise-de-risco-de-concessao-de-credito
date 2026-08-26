## 1. Visão geral da camada

A camada Bronze é a segunda etapa da arquitetura utilizada neste projeto. Seu papel é receber os dados brutos das tabelas de origem (schema "banco-super-caja".main) e aplicar apenas transformações estruturais mínimas: tradução e padronização de nomes de colunas e categorias para o português, tratamento inicial de valores nulos, criação de flags/descrições de apoio e a exclusão de registros identificados como inválidos para a análise. Nenhuma regra de negócio analítica (cálculo de risco, segmentação, scoring) é aplicada nesta camada — isso é responsabilidade das camadas Silver e Gold.

Ao todo, a camada Bronze é composta por 5 tabelas, descritas nas seções seguintes.

## 2. Tabelas

### 2.1 bronze.cadastro_clientes

**Objetivo:** Padronizar os dados cadastrais dos clientes, traduzindo colunas e categorias para o português, tratando o número de dependentes ausente e sinalizando a situação da informação de renda de cada cliente.

**Origem:** "banco-super-caja".main.cadastro_clientes

| **Coluna origem** | **Coluna bronze** | **Descrição / transformação** |
| --- | --- | --- |
| user_ID | id_usuario | Identificador do cliente. |
| age | idade | Idade do cliente. |
| sex | sexo | Traduzido: 'F' → 'feminino', 'M' → 'masculino'. Qualquer outro valor é mantido como veio da origem. |
| last_month_salary | salario_ultimo_mes | Renda do cliente no último mês, sem alteração de valor. |
| number_dependents | numero_dependentes | Valores nulos são substituídos por 0 via COALESCE. |
| (derivada) | situacao_salarial | Classifica a qualidade da informação de renda: 'Renda não informada' quando o salário é nulo; 'Sem renda no último mês' quando o salário é 0; 'Renda informada' nos demais casos. |

### 2.2 bronze.carteira_emprestimos

**Objetivo:** Padronizar o tipo de empréstimo, unificando variações de grafia (maiúsculas/minúsculas) da origem em categorias únicas e tratando valores nulos.

**Origem:** "banco-super-caja".main.carteira_emprestimos

| **Coluna origem** | **Coluna bronze** | **Descrição / transformação** |
| --- | --- | --- |
| loan_id | id_emprestimo | Identificador do empréstimo. |
| user_id | id_usuario | Identificador do cliente. |
| loan_type | tipo_emprestimo | Padronizado: 'REAL ESTATE' ou 'Real Estate' → 'real estate'; 'others', 'OTHER' ou 'Other' → 'other'; nulo → 'não informado'. Demais valores são mantidos como vieram da origem. |

### 2.3 bronze.detalhes_emprestimos

**Objetivo:** Trazer as métricas de atraso, uso de limite e endividamento associadas a cada empréstimo, aplicando um filtro de qualidade de dados que remove registros considerados inválidos para a análise.

**Origem:** "banco-super-caja".main.detalhes_emprestimos

| **Coluna origem** | **Coluna bronze** | **Descrição / transformação** |
| --- | --- | --- |
| user_id | id_usuario | Identificador do cliente. |
| more_90_days_overdue | atraso_emprestimo_mais_90_dias | Número de vezes com atraso superior a 90 dias. |
| using_lines_not_secured_personal_assets | percentual_uso_limite_credito | Percentual de uso do limite de crédito disponível. |
| number_times_delayed_payment_loan_30_59_days | atraso_emprestimo_30_59_dias | Número de vezes com atraso entre 30 e 59 dias. |
| debt_ratio | indice_endividamento | Índice de endividamento do cliente. |
| number_times_delayed_payment_loan_60_89_days | atraso_emprestimo_60_89_dias | Número de vezes com atraso entre 60 e 89 dias. |

**Regra de filtro aplicada (WHERE):**

- São mantidos apenas os registros em que atraso_emprestimo_mais_90_dias < 96. Clientes com valor igual ou superior a 96 nesse campo são excluídos da camada Bronze em diante — esse valor é tratado como um código de dado inválido/outlier da base de origem, e não como uma contagem real de atrasos.

### 2.4 bronze.flag_inadimplencia

**Objetivo:** Padronizar o identificador do cliente para o tipo VARCHAR (compatibilizando com as demais tabelas) e criar uma descrição textual para a flag de inadimplência.

**Origem:** "banco-super-caja".main.flag_inadimplencia

| **Coluna origem** | **Coluna bronze** | **Descrição / transformação** |
| --- | --- | --- |
| user_id | id_usuario | Identificador do cliente, convertido de seu tipo original para VARCHAR via CAST. |
| default_flag | flag_inadimplencia | Flag original de inadimplência, mantida sem alteração de valor (0 ou 1). |
| (derivada) | flag_inadimplencia_desc | Descrição textual da flag: 0 → 'Não', 1 → 'Sim'. |

### 2.5 bronze.emprestimos_totais_por_cliente

**Objetivo:** Agregar por cliente a contagem de empréstimos por tipo (imóveis e outros) e o total geral de empréstimos, a partir da tabela bronze.carteira_emprestimos já tratada.

**Origem:** "banco-super-caja".bronze.carteira_emprestimos (agregação sobre a própria camada Bronze, não sobre a origem bruta)

| **Coluna origem** | **Coluna bronze** | **Descrição / transformação** |
| --- | --- | --- |
| (agregada) | id_usuario | Identificador do cliente, vindo da CTE real_estate. |
| (agregada) | total_imoveis | Contagem de empréstimos do cliente com tipo_emprestimo = 'real estate', via COUNTIF, calculada na CTE real_estate. |
| (agregada) | total_outros | Contagem de empréstimos do cliente com tipo_emprestimo = 'other', via COUNTIF, calculada na CTE other. |
| (derivada) | total_emprestimos | Soma de total_imoveis e total_outros para o cliente. |

**Lógica da consulta:**

- Duas CTEs (real_estate e other) agrupam a carteira de empréstimos por id_usuario e contam, cada uma, as ocorrências do seu respectivo tipo de empréstimo com COUNTIF.
- As duas CTEs são unidas com LEFT JOIN, partindo de real_estate como tabela base e trazendo other pela chave id_usuario.
