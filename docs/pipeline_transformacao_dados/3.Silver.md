# 1. Visão Geral

Na camada Silver foi realizado o enriquecimento  e a padronização dos dados brutos provenientes da camada Bronze. Nesta etapa, os dados foram transformados com lógicas de negócio, categorizações analíticas e derivações semânticas com o intuito de formar a base para a modelagem dimensional, realizada na camada Gold.

# 2. Tabela: silver.dim_cliente

**Dimensão de Clientes — Perfil Demográfico e Financeiro**

## 2.1 Descrição

A tabela dim_cliente consolida as informações cadastrais dos clientes do Banco Super Caja, aplicando enriquecimentos analíticos que traduzem atributos numéricos em faixas semânticas interpretáveis. É gerada a partir da tabela bronze.cadastro_clientes.

## 2.2 Origem dos Dados

| **Fonte** | banco-super-caja.bronze.cadastro_clientes |
| --- | --- |
| **Tipo de carga** | CREATE TABLE AS (CTAS) — reconstrução completa |
| **Granularidade** | 1 linha por cliente (id_usuario) |

## 2.3 Transformações Aplicadas

### 2.3.1 Segmentação Etária (faixa_etaria)

A coluna faixa_etaria categoriza clientes com base em critérios de ciclo de vida financeiro:

| **Condição (idade)** | **Categoria** | **Raciocínio de negócio** |
| --- | --- | --- |
| < 25 | Jovem | Início da vida financeira, menor histórico de crédito |
| 25 a 39 | Adulto jovem | Fase de crescimento de renda e expansão do crédito |
| 40 a 59 | Adulto | Pico da capacidade financeira e patrimônio |
| ≥ 60 | Sênior | Renda tende a ser fixa (aposentadoria) |

### 2.3.2 Classificação Salarial por Quartis (classif_salario)

Utiliza funções de janela (quantile_cont) para calcular os quartis do salário no universo de clientes, categorizando cada cliente de forma relativa ao grupo:

| **Condição** | **Categoria** | **Interpretação** |
| --- | --- | --- |
| salario <= P25 | Baixo | 25% dos clientes com menor renda |
| salario <= P50 | Médio-baixo | Entre o 1º e 2º quartis |
| salario <= P75 | Médio-alto | Entre o 2º e 3º quartis |
| salario > P75 | Alto | 25% dos clientes com maior renda |

Técnica utilizada: window function quantile_cont() OVER () — os percentis são calculados globalmente sobre toda a tabela.

### 2.3.3 Indicadores de Dependentes

Dois campos complementares são derivados a partir do número de dependentes:

| **Coluna derivada** | **Tipo** | **Descrição** |
| --- | --- | --- |
| tem_dependentes | Binário (Sim/Não) | Indica se o cliente possui ao menos 1 dependente |
| classif_num_dependentes | Categórico ordinal | Rótulo legível do número exato (até '4 ou mais') |

## 2.4 Dicionário de Colunas — silver.dim_cliente

| **Coluna** | **Tipo** | **Origem** | **Descrição** |
| --- | --- | --- | --- |
| id_usuario | INTEGER | Bronze | Identificador único do cliente (chave primária) |
| idade | INTEGER | Bronze | Idade do cliente em anos |
| faixa_etaria | VARCHAR | Derivada | Segmento etário: Jovem / Adulto jovem / Adulto / Sênior |
| sexo | VARCHAR | Bronze | Sexo do cliente |
| salario_ultimo_mes | FLOAT | Bronze | Salário declarado no último mês |
| classif_salario | VARCHAR | Derivada | Faixa relativa de salário por quartis: Baixo / Médio-baixo / Médio-alto / Alto |
| numero_dependentes | INTEGER | Bronze | Quantidade de dependentes declarados |
| tem_dependentes | VARCHAR | Derivada | Flag de presença de dependentes: Sim / Não |
| classif_num_dependentes | VARCHAR | Derivada | Rótulo categorizado do número de dependentes |

# 3. Tabela: silver.fato_risco_credito

**Fato de Risco de Crédito — Comportamento Financeiro e Inadimplência**

## 3.1 Descrição

A tabela fato_risco_credito agrega os indicadores de saúde financeira dos clientes, calculando classificações de risco com base em atrasos, endividamento, uso de crédito e volume de empréstimos. Combina três tabelas da camada Bronze via JOINs.

## 3.2 Origens dos Dados

| **Tabela Bronze** | **Tipo de JOIN** | **Dados fornecidos** |
| --- | --- | --- |
| bronze.detalhes_emprestimos | Base (CTE) | Atrasos, uso de crédito, índice de endividamento |
| bronze.flag_inadimplencia | LEFT JOIN | Flag binária de inadimplência do cliente |
| bronze.emprestimos_totais_por_cliente | LEFT JOIN | Total de empréstimos contratados |

Nota: LEFT JOIN preserva todos os clientes da tabela base mesmo que não tenham registro nas tabelas auxiliares.

## 3.3 Transformações Aplicadas

### 3.3.1 Classificação de Atrasos (classif_atrasos)

Categoriza a gravidade do histórico de atrasos acima de 90 dias por faixas de frequência:

| **Condição (atrasos > 90d)** | **Categoria** | **Interpretação de risco** |
| --- | --- | --- |
| = 0 | Sem atraso | Adimplente — sem ocorrências |
| = 1 | Baixo | Ocorrência pontual — baixo risco |
| 2 a 3 | Médio | Recorrência moderada — atenção |
| 4 a 6 | Alto | Padrão de inadimplência frequente |
| > 6 | Crítico | Inadimplência sistemática |

### 3.3.2 Classificação do Uso de Crédito (classif_uso_credito)

Percentual de uso do limite de crédito — segmentado por quartis calculados via window function:

| **Condição** | **Categoria** | **Interpretação** |
| --- | --- | --- |
| <= P25 | Baixo | Uso conservador do limite disponível |
| <= P50 | Médio-baixo | Uso moderado — entre 1º e 2º quartis |
| <= P75 | Médio-alto | Uso elevado — entre 2º e 3º quartis |
| > P75 | Alto | Uso intensivo do limite — sinal de alerta |

### 3.3.3 Classificação do Índice de Endividamento (classif_dividas)

O índice de endividamento é segmentado em quartis pelo mesmo padrão do uso de crédito, permitindo análise comparativa entre os dois indicadores:

| **Condição** | **Categoria** | **Interpretação** |
| --- | --- | --- |
| <= P25 | Baixo | Endividamento controlado |
| <= P50 | Médio-baixo | Comprometimento moderado de renda |
| <= P75 | Médio-alto | Endividamento relevante |
| > P75 | Alto | Alto comprometimento — risco elevado |

### 3.3.4 Classificação por Volume de Empréstimos (classif_qtdade_emprestimos)

| **Condição (total_emprestimos)** | **Categoria** | **Interpretação** |
| --- | --- | --- |
| <= 5 | Baixo | Exposição reduzida a crédito |
| 6 a 10 | Médio | Perfil com uso moderado de crédito |
| 11 a 15 | Alto | Alta utilização de produtos de crédito |
| > 15 | Crítico | Exposição muito alta — risco sistêmico |

## 3.4 Dicionário de Colunas — silver.dim_risco_credito

| **Coluna** | **Tipo** | **Origem** | **Descrição** |
| --- | --- | --- | --- |
| id_usuario | INTEGER | Bronze | Identificador único do cliente (chave de junção) |
| atraso_emprestimo_mais_90_dias | INTEGER | Bronze | Número de ocorrências de atraso superior a 90 dias |
| classif_atrasos | VARCHAR | Derivada | Nível de risco por atrasos: Sem atraso / Baixo / Médio / Alto / Crítico |
| percentual_uso_limite_credito | FLOAT | Bronze | Percentual de uso do limite de crédito disponível |
| classif_uso_credito | VARCHAR | Derivada | Faixa de uso de crédito por quartis: Baixo / Médio-baixo / Médio-alto / Alto |
| indice_endividamento | FLOAT | Bronze | Índice de comprometimento de renda com dívidas |
| classif_dividas | VARCHAR | Derivada | Faixa de endividamento por quartis: Baixo / Médio-baixo / Médio-alto / Alto |
| total_emprestimos | INTEGER | Bronze | Número total de empréstimos contratados pelo cliente |
| classif_qtdade_emprestimos | VARCHAR | Derivada | Volume de empréstimos: Baixo / Médio / Alto / Crítico |
| flag_inadimplencia | INTEGER | Bronze | Flag binária de inadimplência: 1 = inadimplente, 0 = adimplente |

# 4. Notas Técnicas e Decisões de Design

| **Decisão** | **Justificativa** |
| --- | --- |
| Quartis dinâmicos com quantile_cont() | Garante que as faixas sejam relativas ao comportamento real da carteira, adaptando-se automaticamente a mudanças na distribuição dos dados. |
| LEFT JOIN nas fontes auxiliares | Preserva o universo completo de clientes da tabela base, evitando perda de registros sem correspondência nas tabelas de flag e totais. |
| CREATE OR REPLACE em dim_risco_credito | Permite reprocessamento seguro sem necessidade de DROP manual; dim_cliente usa CREATE TABLE pois não requer sobrescrita incremental no fluxo atual. |
| Colunas semânticas junto às numéricas | A manutenção das colunas originais (ex: salario_ultimo_mes e classif_salario) permite análise tanto quantitativa quanto qualitativa na camada Gold. |
| Rótulos legíveis (ex: 'Médio-alto') | Facilita a interpretação direta nos relatórios e dashboards da camada Gold sem necessidade de tabelas auxiliares de decodificação. |
