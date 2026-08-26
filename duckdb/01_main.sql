-- =====================================================
-- Camada main - Tabela 1 - cadasto_clientes
-- =====================================================
CREATE OR REPLACE TABLE 'cadastro_clientes' AS
SELECT *
FROM read_csv('C:\Users\suzan\OneDrive\Documentos\PROJETOS PESSOAIS\FORMAÇÃO E TRABALHO NA ÁREA DE DADOS\PORTFÓLIO PROJETOS DE DADOS\PROJETO 3 - RISCO RELATIVO\dados\dados brutos\user_info.csv',
types = {'user_Id' : 'VARCHAR',
'age': 'INTEGER',
'sex': 'VARCHAR',
'last_month_salary': 'DOUBLE',
'number_dependents': 'INTEGER'}
);

-- =====================================================
-- Camada main - Tabela 2 - carteira_emprestimos
-- =====================================================
CREATE OR REPLACE TABLE 'carteira_emprestimos' AS
SELECT *
FROM read_csv('C:\Users\suzan\OneDrive\Documentos\PROJETOS PESSOAIS\FORMAÇÃO E TRABALHO NA ÁREA DE DADOS\PORTFÓLIO PROJETOS DE DADOS\PROJETO 3 - RISCO RELATIVO\dados\dados brutos\loans_outstanding.csv',
types = {'loan_id' : 'VARCHAR',
'user_id': 'VARCHAR',
'loan_type': 'VARCHAR'}

);

-- =====================================================
-- Camada main - Tabela 3 - detalhes_emprestimos 
-- =====================================================

CREATE OR REPLACE TABLE detalhes_emprestimos AS
SELECT *
FROM read_csv('C:\Users\suzan\OneDrive\Documentos\PROJETOS PESSOAIS\FORMAÇÃO E TRABALHO NA ÁREA DE DADOS\PORTFÓLIO PROJETOS DE DADOS\PROJETO 3 - RISCO RELATIVO\dados\dados brutos\loans_detail.csv',
types = {
'user_Id' : 'VARCHAR',
'more_90_days_overdue': 'BIGINT',
'using_lines_not_secured_personal_assets': 'DOUBLE', 
'number_times_delayed_payment_loan_30_59_days': 'BIGINT', 
'debt_ratio': 'DOUBLE', 
'number_times_delayed_payment_loan_60_89_days': 'BIGINT'});

-- =====================================================
-- Camada main - Tabela 4 - flag_inadimplencia 
-- =====================================================

CREATE OR REPLACE TABLE 'flag_inadimplencia' AS
SELECT *
FROM read_csv('C:\Users\suzan\OneDrive\Documentos\PROJETOS PESSOAIS\FORMAÇÃO E TRABALHO NA ÁREA DE DADOS\PORTFÓLIO PROJETOS DE DADOS\PROJETO 3 - RISCO RELATIVO\dados\dados brutos\default.csv',
types = {'user_Id' : 'VARCHAR',
'default_flag' : 'INTEGER' }
);

