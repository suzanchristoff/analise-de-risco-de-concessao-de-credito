# Análise de Risco de Crédito — Score e Classificação de Clientes

**Super Caja Bank | Análise de Dados | Suzan Christoff**

---

## Contexto

Com a recente queda das taxas de juros, o banco **Super Caja** registrou um aumento expressivo na demanda por crédito. Para lidar com o volume crescente de solicitações e a pressão sobre a taxa de inadimplência, o banco identificou a necessidade de **automatizar e otimizar** o processo de análise de crédito, substituindo a avaliação manual por uma abordagem baseada em dados.

---

## Objetivos

- Identificar o **perfil de clientes com risco de inadimplência**
- Construir um **score de crédito** baseado em análise de dados
- **Avaliar o risco** de concessão de crédito por segmento
- **Classificar clientes** em categorias de risco (baixo, médio e alto)
- Integrar métricas existentes do banco para fortalecer o modelo
- Validar ou refutar as seguintes hipóteses:
    1. Pessoas mais jovens correm maior risco de não pagamento
    2. Pessoas com mais empréstimos ativos têm maior risco de inadimplência
    3. Pessoas que atrasaram pagamentos por mais de 90 dias têm maior risco de inadimplência

---

## Fonte de Dados

O dataset é composto por **4 tabelas**:

| Tabela | Descrição |
| --- | --- |
| `user_info` | Dados cadastrais do cliente (idade, gênero, salário, dependentes) |
| `loans_outstanding` | Empréstimos ativos por cliente (tipo: imóveis ou outros) |
| `loans_detail` | Comportamento de pagamento (atrasos, uso de crédito, endividamento) |
| `default` | Flag de inadimplência (0 = adimplente, 1 = inadimplente) |

---

## Ferramentas e Tecnologias

| Ferramenta | Uso |
| --- | --- |
| **Google BigQuery** | Armazenamento, consultas SQL e limpeza de dados |
| **Google Colab + Python** | Análise exploratória, visualizações e engenharia de features |
| **Google Looker Studio** | Dashboard interativo para consulta de risco por cliente |
| **Google Apresentações** | Apresentação dos resultados |

**Linguagens:** SQL · Python

**Bibliotecas Python:** `pandas` · `matplotlib` · `seaborn`

---

## Etapas do Projeto

### 1. Processamento e Preparação dos Dados

- **Nulos identificados e tratados:** 7.199 nulos em `last_month_salary` e 943 em `number_dependents` → substituídos pela **mediana**
- **Duplicados:** nenhum identificado
- **Outliers:** tratados nas variáveis de atraso de pagamento, taxa de endividamento e uso do limite de crédito
- **Inconsistências categóricas:** unificação das categorias `'others'` e `'OTHER'` na variável `loan_type`
- **Correlação:** identificada alta correlação (multicolinearidade) entre as variáveis de atraso → mantida apenas a variável `more_90_days_overdue`
- **Junção:** tabelas unidas via `LEFT JOIN` em SQL, gerando a view `view_tb_final_dados_integrados`

### 2. Análise Exploratória dos Dados (EDA)

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

### 3. Engenharia de Features e Score de Risco

Foram criadas variáveis de segmentação e risco para as seguintes dimensões:

| Dimensão | Tipo de Variável Criada |
| --- | --- |
| Idade | Faixas etárias + classificação de risco |
| Salário | Faixas salariais + classificação de risco |
| Nº de dependentes | Faixas + classificação de risco |
| Total de empréstimos | Contagem consolidada + classificação de risco |
| Atrasos > 90 dias | Segmentação + classificação de risco |
| Uso do limite de crédito | Faixas percentuais + classificação de risco |
| Taxa de endividamento | Faixas + classificação de risco |

Para cada dimensão, foi calculado:

- **Probabilidade de inadimplência** por grupo
- **Risco relativo** = índice do grupo ÷ índice médio geral
- **Variável dummy** (0 = baixo risco · 1 = alto risco)
- **Score final** = soma das dummies (0 a 7 pontos)

---

## Score e Classificação de Risco

| Score | Classificação |
| --- | --- |
| 1–2 pontos | Risco Baixo |
| 3 pontos | Risco Moderado |
| 4–5 pontos | Risco Alto |

---

## Perfil dos Clientes de Maior Risco

Clientes classificados como **alto risco** tendem a apresentar:

- Uso acima de **56%** do limite de crédito disponível
- Nível de endividamento **alto a extremo** (38% a 192% do patrimônio)
- **Histórico de atrasos** nos pagamentos
- Salário **abaixo de R$ 3.908**
- Idade entre **21 e 40 anos**
- **Mais de 3 dependentes**

---

## Validação das Hipóteses

| Hipótese | Resultado |
| --- | --- |
| Pessoas mais jovens têm maior risco de inadimplência | **Confirmada** — faixas etárias mais jovens apresentam os maiores índices |
| Mais empréstimos ativos = maior risco de inadimplência | **Refutada** — clientes com mais empréstimos têm os *menores* indicadores |
| Atrasos > 90 dias correlacionam com inadimplência | **Confirmada** — correlação positiva, embora esse grupo seja minoria na base |

---

## Dashboard

Foi desenvolvido um painel interativo no **Google Looker Studio** que permite:

- Consultar o **score de risco** de clientes individuais
- Visualizar o **perfil de inadimplência** por segmento
- Apoiar decisões de concessão de crédito em tempo real

---

## Limitações e Próximos Passos

O modelo pode ser aprimorado com a inclusão de variáveis adicionais:

- **Fontes de renda adicionais** — visão mais precisa da capacidade de pagamento
- **Tempo de serviço** — indicador de estabilidade no emprego
- **Patrimônio do cliente** — possibilidade de uso como garantia
- **Tempo de residência** — proxy de estabilidade pessoal
- **Tempo de cadastro no banco** — indicador de confiabilidade histórica
- **Nível educacional** — correlacionado com potencial de renda

---

> *Projeto desenvolvido individualmente como parte do portfólio de análise de dados.*
>
