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

