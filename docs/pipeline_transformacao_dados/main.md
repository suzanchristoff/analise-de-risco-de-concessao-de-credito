## 1. Visão geral da camada

A camada Main é o ponto de entrada dos dados no banco "banco-super-caja": cada tabela é criada diretamente a partir da leitura de um arquivo CSV bruto (read_csv), com apenas a tipagem de colunas definida explicitamente via parâmetro types. Não há nenhuma renomeação de coluna, tradução, tratamento de valores nulos ou regra de negócio aplicada nesta camada — o schema e o conteúdo permanecem exatamente como estavam no arquivo de origem, apenas com o tipo de cada coluna fixado. Essa camada corresponde à ingestão bruta dos dados; o tratamento e a padronização começam na camada Bronze.

Ao todo, a camada Main é composta por 4 tabelas, uma para cada arquivo CSV de origem, descritas nas seções seguintes.

## 2. Tabelas

### 2.1 cadastro_clientes

**Objetivo:** Ingerir, sem transformação, os dados cadastrais brutos dos clientes a partir do arquivo CSV de origem, fixando o tipo de cada coluna.

**Origem:** ...\dados\dados brutos\user_info.csv

| **Coluna (CSV)** | **Tipo definido** | **Descrição** |
| --- | --- | --- |
| user_Id | VARCHAR | Identificador do cliente. |
| age | INTEGER | Idade do cliente. |
| sex | VARCHAR | Sexo do cliente, como registrado no arquivo de origem (sem padronização). |
| last_month_salary | DOUBLE | Renda do cliente no último mês. |
| number_dependents | INTEGER | Número de dependentes do cliente. |

**Observações e pontos de atenção:**

- SELECT * traz todas as colunas do CSV na ordem em que aparecem no arquivo; nenhuma coluna é renomeada ou descartada nesta etapa.
- O parâmetro types força a tipagem indicada; qualquer valor no CSV que não seja compatível com o tipo declarado (por exemplo, texto não numérico em number_dependents) causaria erro na leitura, e não um valor nulo silencioso.

### 2.2 carteira_emprestimos

**Objetivo:** Ingerir, sem transformação, os dados brutos da carteira de empréstimos a partir do arquivo CSV de origem, fixando o tipo de cada coluna.

**Origem:** ...\dados\dados brutos\loans_outstanding.csv

| **Coluna (CSV)** | **Tipo definido** | **Descrição** |
| --- | --- | --- |
| loan_id | VARCHAR | Identificador do empréstimo. |
| user_id | VARCHAR | Identificador do cliente. |
| loan_type | VARCHAR | Tipo do empréstimo, como registrado no arquivo de origem (inclui variações de grafia, tratadas apenas na camada Bronze). |

### 2.3 detalhes_emprestimos

**Objetivo:** Ingerir, sem transformação, os dados brutos de atraso, uso de limite e endividamento associados aos empréstimos, a partir do arquivo CSV de origem, fixando o tipo de cada coluna.

**Origem:** ...\dados\dados brutos\loans_detail.csv

| **Coluna (CSV)** | **Tipo definido** | **Descrição** |
| --- | --- | --- |
| user_Id | VARCHAR | Identificador do cliente. |
| more_90_days_overdue | BIGINT | Número de vezes com atraso superior a 90 dias. |
| using_lines_not_secured_personal_assets | DOUBLE | Percentual de uso do limite de crédito disponível. |
| number_times_delayed_payment_loan_30_59_days | BIGINT | Número de vezes com atraso entre 30 e 59 dias. |
| debt_ratio | DOUBLE | Índice de endividamento do cliente. |
| number_times_delayed_payment_loan_60_89_days | BIGINT | Número de vezes com atraso entre 60 e 89 dias. |

**Observações e pontos de atenção:**

- Nesta camada não há nenhum filtro sobre more_90_days_overdue; os registros com valor ≥ 96 (tratados como inválidos/outliers) só são removidos na camada Bronze, na tabela bronze.detalhes_emprestimos.

### 2.4 flag_inadimplencia

**Objetivo:** Ingerir, sem transformação, a flag bruta de inadimplência dos clientes a partir do arquivo CSV de origem, fixando o tipo de cada coluna.

**Origem:** ...\dados\dados brutos\default.csv

| **Coluna (CSV)** | **Tipo definido** | **Descrição** |
| --- | --- | --- |
| user_Id | VARCHAR | Identificador do cliente. |
| default_flag | INTEGER | Flag bruta de inadimplência (0 ou 1, conforme registrado no arquivo de origem). |




