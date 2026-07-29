# 1. Visão Geral

Na camada Silver foi realizado o enriquecimento  e a padronização dos dados brutos provenientes da camada Bronze. Nesta etapa, os dados foram transformados com lógicas de negócio, categorizações analíticas e derivações semânticas com o intuito de formar a base para a modelagem dimensional, realizada na camada Gold.

| **Projeto** | Super Caja Bank — Análise de Risco de Crédito |
| --- | --- |
| **Camada** | Silver (Refined / Enriquecida) |
| **Arquitetura** | Medallion (Bronze → Silver → Gold) |
| **Engine** | DuckDB |
| **Schema** | silver |
| **Banco de dados** | banco-super-caja |
| **Tabelas desta camada** | dim_cliente  |  dim_risco_credito |
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
