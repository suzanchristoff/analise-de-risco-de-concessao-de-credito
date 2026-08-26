## Análise de Risco de Crédito — Pipeline End-to-End 

Projeto de análise de risco de crédito, realizado de ponta a ponta, usando DuckDB e SQL para transformar dados brutos de clientes e empréstimos em segmentos de risco, indicadores de risco relativos e uma pontuação de risco no nível do cliente.

**`Stack:** DuckDB · SQL · DBeaver · Python ( Google Colab) · Power BI · DAX`

---

## 1. Visão Geral

Este projeto desenvolve um pipeline analítico completo para avaliação de risco de crédito. Dados brutos de clientes, empréstimos e inadimplência são ingeridos e transformados usando DuckDB por meio de uma arquitetura em camadas baseada nas camadas Main, Bronze, Silver e Gold. Os conjuntos finais de dados analíticos são usados para calcular taxas de inadimplência, razões de risco relativas e um score de risco a nível de cliente.

---

## 2. Problema de negócio

> As instituições financeiras precisam identificar os perfis de clientes associados a um risco de crédito mais alto para apoiar a avaliação de crédito, o monitoramento e a gestão da carteira.
> 

### Pergunta-chave

> Quais características de clientes e de crédito estão associadas a um maior risco de inadimplência, e como essas características podem ser combinadas em uma pontuação de risco do cliente que seja fácil de entender?
> 

## 3. Objetivos

- Identificar os perfis de clientes associados a taxas mais altas de inadimplência;
- Calcular o risco relativo entre os diferentes segmentos de clientes;
- Transformar variáveis financeiras e comportamentais brutas em características analíticas;
- Desenvolver uma pontuação de risco (score de crédito) que permita avaliar e classificar o risco de crédito individual de cada cliente com base em suas características financeiras e comportamentais.
- Criar um pipeline de dados reproduzível usando DuckDB e SQL.

# Hipóteses levantadas

- As seguintes hipóteses foram levantadas:
    1. Pessoas mais jovens correm maior risco de não pagamento
    2. Pessoas com mais empréstimos ativos têm maior risco de inadimplência
    3. Pessoas que atrasaram pagamentos por mais de 90 dias têm maior risco de inadimplência

---

## 4. Fonte de dados

Os dados levantados foram obtidos a partir dos seguintes arquivos:

| Nome do arquivo | Descrição | Total de registros iniciais |
| --- | --- | --- |
| `user_info**.csv/cadastro_clientes**` | Dados cadastrais dos clientes (idade, gênero, salário, dependentes) | 36.000 |
| `loans_outstanding**.csv/carteira_emprestimos**` | Dados referentes aos empréstimos ativos por cliente, se do tipo imóveis ou outros | 305.335 |
| `loans_detail**.csv/detalhes_emprestimos**` | Contém dados relacionados ao comportamento de pagamento dos clientes , como número de atrasos, uso percentual do limite de crédito e nível de endividamento , ou seja, percentual que as dívidas representam em relação ao patrimônio do cliente. | 36.000 |
| `default.csv/flag_inadimplencia` | Flag de inadimplência, onde 0 indica que é o cliente está adimplente e 1 indica que está inadimplente. | 36.000 |

---

## 5. Ferramentas, linguagens e tecnologias

| Ferramenta/Tecnologia | Uso |
| --- | --- |
| **DuckDB** | Armazenamento, consultas SQL e limpeza de dados |
| **Google Colab + Python** | Análise exploratória e visualizações  |
| **Power BI** | Dashboard interativo para consulta de risco por cliente |
| **Canva** | Design dashboard e apresentação dos resultados |

**Linguagens:** SQL · Python

**Bibliotecas Python:** `pandas` · `matplotlib` · `seaborn`

---

## 6. Arquitetura e pipeline de dados

O projeto foi concebido como um pipeline analítico de ponta a ponta, usando DuckDB e SQL para ingerir, transformar e organizar dados brutos de clientes e crédito em conjuntos de dados prontos para análise de risco de crédito e visualização. 

O pipeline segue uma arquitetura em camadas composta pelas camadas Main, Bronze, Silver e Gold, sendo que cada camada tem uma responsabilidade específica no processo de transformação de dados.

Os conjuntos de dados finais construídos na camada Gold são exportados no formato Parquet e servem como fonte de dados para a camada analítica e o dashboard de risco de três páginas.

### 6.1 Visão geral

![Diagrama pipeline risco credito.png](imagens/Diagrama_pipeline_risco_credito.png)

### 6.2 Arquitetura em camadas

- Main : Arquivos CSV brutos são importados para o DuckDB sem transformação, preservando a fonte original.
- Bronze: Os dados são padronizados e regras iniciais de qualidade são aplicadas, incluindo renomeação de colunas, normalização de categorias e criação de sinais de qualidade dos dados.
- Silver: Dimensões de clientes e características de risco de crédito são criadas, incluindo faixas etárias, classificações de renda, classificações de inadimplência, utilização de crédito e classificações de dívida.
- Gold: Conjuntos de dados analíticos são criados para segmentação de risco, análise de risco relativo e pontuação no nível do cliente.

> Para uma descrição detalhada das transformações, data quality, feature engineering  e implementação em SQL camada por camada, veja a [Documentação de Transformação de Dados.](docs/pipeline_transformacao_dados)
> 

## 7. Metodologia do cálculo do risco relativo

A aplicação desta metodologia teve por objetivo identificar quais segmentos de clientes apresentam maior propensão à inadimplência, comparando cada grupo contra o comportamento médio da carteira.

#### 7.1 Segmentação dos clientes

Os clientes foram agrupados segundo 7 variáveis: idade, salário, número de dependentes, total de empréstimos, número de atrasos superiores a 90 dias, uso do limite de crédito e taxa de endividamento.

#### 7.2 Índice de inadimplência por segmento

Para cada grupo de cada variável, calculou-se:

![image.png](Documenta%C3%A7%C3%A3o%20Projeto%20An%C3%A1lise%20de%20Risco%20de%20Cr%C3%A9dito/image.png)

#### 7.3 Risco relativo (relative risk)

O risco relativo de cada segmento foi obtido comparando seu índice de inadimplência contra o índice médio da amostra total (~36 mil clientes):

![image.png](Documenta%C3%A7%C3%A3o%20Projeto%20An%C3%A1lise%20de%20Risco%20de%20Cr%C3%A9dito/image%201.png)

**Interpretação:**

- Risco relativo = 1 → o segmento tem a mesma taxa de inadimplência da carteira geral
- Risco relativo > 1 → o segmento é mais arriscado que a média (ex: 1.8 = 80% mais propenso à inadimplência)
- Risco relativo < 1 → o segmento é mais seguro que a média

Essa é a métrica clássica de **razão de risco** (risk ratio), usada em epidemiologia e adaptada aqui para concessão de crédito — permite comparar segmentos de escalas diferentes numa métrica só, normalizada pelo baseline da população.

## 8. Score de risco

| Score | Perfil de risco |
| --- | --- |
| 0 | Risco muito baixo |
| 1–2 | Baixo risco |
| 3 | Risco médio |
| 4–5 | Alto risco |

## 9. Resultados

Clientes classificados como **alto risco** tendem a apresentar:

- Uso acima de **56%** do limite de crédito disponível
- Nível de endividamento **alto a extremo** (38% a 192% do patrimônio)
- **Histórico de atrasos** nos pagamentos
- Salário **abaixo de R$ 3.908**
- Idade entre **21 e 40 anos**
- **Mais de 3 dependentes**

## 10. Insights

Principais descobertas sobre os **36.000 clientes** da base:

- **Gênero:** 60% homens · 40% mulheres
- **Salário:** média de R$ 6.425 · mediana de R$ 5.408 · alto desvio padrão (R$ 11.614)
- **Idade:** metade dos clientes entre 41 e 63 anos · média de ~52 anos
- **Dependentes:** 60,67% sem dependentes
- **Empréstimos:** média de 8–9 por cliente · apenas 12% são imobiliários
- **Inadimplência geral:** **1,76%**
- **Atrasos > 90 dias:** 95% nunca atrasaram
- **Uso do limite de crédito:** 50% usam até 15% do limite disponível
- **Endividamento:** 25% dos clientes têm mais de 87% do patrimônio comprometido

## 11. Dashboard & BI

#### 11.1 Indicadores de inadimplência

> Fornece uma visão geral dos indicadores de inadimplência entre os segmentos de clientes, permitindo comparar as taxas de inadimplência e o risco relativo entre diferentes perfis demográficos e relacionados ao crédito.
> 

![image.png](imagens/dashboard1.png)

#### 11.2 Perfis de risco

> Fornece uma visão geral da distribuição do perfil de risco dos clientes com base na estrutura de pontuação de risco, permitindo que os usuários identifiquem a concentração de clientes nas categorias de risco muito baixo, baixo, médio e alto.
> 

![image.png](imagens/dashboard2.png)

#### 11.3 Detalhamento do cliente

> Permite aos usuários analisar individualmente cada cliente e verificar seu perfil de risco e os indicadores de risco usados na estrutura de pontuação.
> 

![image.png](imagens/dashboard3.png)

## 12. Estrutura do Repositório

```sql
project/
│
├── data/
│   ├── raw/
│   └── processed/
│
├── duckdb/
│   ├── 01_main.sql
│   ├── 02_bronze.sql
│   ├── 03_silver.sql
│   └── 04_gold.sql
│
├── notebooks/
│   ├── 01_eda.ipynb
│   ├── 02_risk_analysis.ipynb
│   └── 03_visualization.ipynb
│
├── docs/
│
└── README.md
```

## 13. Como Reproduzir

```sql
# 1. Clone o repositório

git clone https://github.com/<seu-usuario>/super-caja-bank.git

# 2. Rode os scripts SQL na ordem: main -> bronze -> silver -> gold

# (via DBeaver conectado a um arquivo DuckDB local, ou duckdb CLI)

# 3. Exporte as tabelas Gold para Parquet

# (ver notebooks/exploracao_gold_para_parquet.ipynb)

# 4. Abra powerbi/super_caja_bank.pbix e aponte para data/gold/*.parquet
```

## 14. Limitações e próximos passos

O modelo pode ser aprimorado com a inclusão de variáveis adicionais:

- **Fontes de renda adicionais** — visão mais precisa da capacidade de pagamento
- **Tempo de serviço** — indicador de estabilidade no emprego
- **Patrimônio do cliente** — possibilidade de uso como garantia
- **Tempo de residência** — proxy de estabilidade pessoal
- **Tempo de cadastro no banco** — indicador de confiabilidade histórica
- **Nível educacional** — correlacionado com potencial de renda

---

## 15. Documentos adicionais

[Dicionário dos dados originais](Documenta%C3%A7%C3%A3o%20Projeto%20An%C3%A1lise%20de%20Risco%20de%20Cr%C3%A9dito/Dicion%C3%A1rio%20dos%20dados%20originais%203c8207fbe913809997f9ce99dc7001e8.md)

[Pipeline transformação dos dados](docs/pipeline_transformacao_dados)

[Check list tratamento inicial dos dados](Documenta%C3%A7%C3%A3o%20Projeto%20An%C3%A1lise%20de%20Risco%20de%20Cr%C3%A9dito/Check%20list%20tratamento%20inicial%20dos%20dados%203c8207fbe9138085baf8fbd5d01c7c0e.md)

[Consultas SQL](Documenta%C3%A7%C3%A3o%20Projeto%20An%C3%A1lise%20de%20Risco%20de%20Cr%C3%A9dito/Consultas%20SQL%203c8207fbe91380418a33dc2634d2791b.md)

[Documentação detalhada arquitetura e pipeline](Documenta%C3%A7%C3%A3o%20Projeto%20An%C3%A1lise%20de%20Risco%20de%20Cr%C3%A9dito/Documenta%C3%A7%C3%A3o%20detalhada%20arquitetura%20e%20pipeline%203c6207fbe9138091be6feb889382826c.md)

## Sobre

Projeto desenvolvido por Suzan, em transição de carreira para Analytics Engineering, com background em gestão administrativo-financeira em varejo/e-commerce.

📫 [LinkedIn](https://www.linkedin.com/in/suzanchristoff/)
