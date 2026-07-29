# Pipeline de Dados

O pipeline utiliza uma arquitetura de camadas Bronze, Silver e Gold
(Medallion Architecture), utilizando DuckDB para processamento,
tratamento e transformação dos dados.

## Arquitetura

```text
Fonte
  ↓
Bronze
  ↓
Silver
  ↓
Gold
