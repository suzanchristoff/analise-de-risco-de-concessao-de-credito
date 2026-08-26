COPY gold.base_analise TO 'dados/dados_prontos/base_analise.parquet' (FORMAT PARQUET);
COPY gold.segmentos_risco TO 'dados/dados_prontos/segmentos_risco.parquet' (FORMAT PARQUET);
COPY gold.score_clientes TO 'dados/dados_prontos/score_clientes.parquet' (FORMAT PARQUET);
