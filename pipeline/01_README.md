# Pipeline de Dados

O pipeline utiliza uma arquitetura de camadas Bronze, Silver e Gold
(Medallion Architecture), utilizando DuckDB para processamento,
tratamento e transformação dos dados.

                    ┌──────────────┐
                    │ Fonte de     │
                    │ dados        │
                    └──────┬───────┘
                           │
                           ▼
                    ┌──────────────┐
                    │   BRONZE     │
                    │ Dados brutos │
                    └──────┬───────┘
                           │
                     DuckDB / SQL
                           │
                           ▼
                    ┌──────────────┐
                    │   SILVER     │
                    │ Dados tratados│
                    └──────┬───────┘
                           │
                     DuckDB / SQL
                           │
                           ▼
                    ┌──────────────┐
                    │    GOLD      │
                    │ Dados        │
                    │ analíticos   │
                    └──────────────┘

### Bronze

Armazena os dados em seu estado bruto, preservando a estrutura
original da fonte.

Ver documentação da camada Bronze

### Silver

Responsável pelo tratamento e padronização dos dados.

Ver documentação da camada Silver

### Gold

Contém os dados transformados e preparados para consumo analítico.

Ver documentação da camada Gold

Tecnologia principal
DuckDB
SQL
