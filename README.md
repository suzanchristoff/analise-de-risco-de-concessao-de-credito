- **FICHA TÉCNICA**
  
    - **CONTEXTO**
        
        Num contexto recente, a descida das taxas de juro no mercado desencadeou um aumento notável na demanda por pedidos de crédito. Os clientes viram este movimento do mercado, como uma oportunidade favorável para financiar grandes compras ou consolidar dívidas existentes, o que elevou o fluxo de pedidos de empréstimo no banco “Super Caja”. A equipe de análise de crédito do banco enfrenta um fardo esmagador devido à análise manual necessária para cada solicitação de empréstimo de clientes individuais. Esta metodologia manual resultou num processo ineficiente e atrasado, que afetou negativamente a eficiência e a velocidade com que os pedidos de empréstimo são processados. A situação tornou-se mais crítica devido à preocupação crescente com a taxa de inadimplência, um problema que afeta cada vez mais o setor financeiro, e aumenta a pressão sobre os bancos para identificar e mitigar riscos associados ao crédito.
        
        Para enfrentar esse desafio, a proposta do banco é a automação do processo de análise de crédito usando técnicas de análise avançadas de dados, com o objetivo de melhorar a eficiência, precisão e rapidez na avaliação de pedidos de crédito. Além disso, o banco já tem uma métrica para identificar clientes com pagamento atrasado, o que poderia ser uma ferramenta valiosa para integrar na classificação de risco no novo sistema automatizado.
        
    - **OBJETIVOS**
        
        O presente projeto teve por objetivo atender às seguintes questões:
        
        - Identificar o perfil de clientes com risco de inadimplência.
        - Montar uma pontuação de crédito através da análise de dados.
        - Avaliar o risco de concessão de crédito.
        - Automatizar e otimizar o processo de análise de crédito para gerenciar e reduzir efetivamente o risco de não pagamento possibilitando assim, classificar os clientes e futuros clientes em diferentes categorias de risco com base na sua probabilidade de inadimplência. Esta classificação permitirá ao banco tomar decisões informadas sobre a quem conceder crédito, reduzindo assim o risco de empréstimos não reembolsáveis.
        - Integrar as métricas definidas, afim de fortalecer a capacidade do modelo de identificar riscos, contribuindo para a solidez financeira e a eficiência operacional do Banco.
        - E ainda, validar ou refutar as seguintes hipóteses:
        1. Pessoas mais jovens correm um risco maior de não pagamento.
        2. Pessoas com mais empréstimos ativos correm maior risco de serem maus pagadores.
        3. Pessoas que atrasaram seus pagamentos por mais de 90 dias correm maior risco de serem maus pagadores.
        - 
        - **DESCRIÇÃO DAS VARIÁVEIS**
            
            
            | **Tabela** | **Variável** | **Descrição** |  |
            | --- | --- | --- | --- |
            | user_info | user id | Número de identificação do cliente (único para cada cliente) |  |
            |  | age | Idade do cliente |  |
            |  | sex | Gênero do cliente |  |
            |  | last month salary | Último salário mensal que o cliente informou ao banco |  |
            |  | number dependents | Número de dependentes |  |
            | loans_outstanding | loan id | Número de identificação do empréstimo (único para cada empréstimo) |  |
            |  | user id | Número de identificação do cliente |  |
            |  | loan type | Tipo de empréstimo (real state = imóveis, others= outros) |  |
            | loans_detail | user id | Número de identificação do cliente |  |
            |  | more 90 days overdue | Número de vezes que o cliente apresentou atraso superior a 90 dias |  |
            |  | using lines not secured personal assets | Quanto o cliente está utilizando em relação ao seu limite de crédito, em linhas que não são garantidas por bens pessoais, como imóveis e automóveis |  |
            |  | number times delayed payment loan 30 59 days | Número de vezes que o cliente atrasou o pagamento de um empréstimo (entre 30 e 59 dias) |  |
            |  | debt ratio | Relação entre dívidas e ativos do cliente. Taxa de endividamento = Dívidas / Patrimonio |  |
            |  | number times delayed payment loan 60 89 days | Número de vezes que o cliente atrasou o pagamento de um empréstimo (entre 60 e 89 dias) |  |
            | default | user id | Número de identificação do cliente |  |
            |  | default flag (variável categórica binária) | Classificação dos clientes inadimplentes (1 para clientes já registrados alguma vez como inadimplentes, 0 para clientes sem histórico de inadimplência) |  |
    - **EQUIPE**
        
        Trabalho realizado individualmente por Suzan Christoff
        
    - **FERRAMENTAS E/OU PLATAFORMAS**
        
        As principais linguagens, ferramentas e tecnologias utilizadas neste projeto foram:
        
        - Google BigQuery: Data warehouse que permite o processamento de grandes volumes de dados.
        - Google Colab: Plataforma para trabalhar com a linguagem de programação Python em Notebooks.
        - Apresentações Google: ferramenta para criação e edição apresentações.
        - Google Looker Studio: ferramenta para criação e edição de painéis e relatórios de dados.
    - **LINGUAGENS**
        - SQL e Python
    - **PROCESSAMENTO E ANÁLISE**
        
        Os dados estavam divididos em 4 tabelas, a primeira com dados do usuário/cliente, a segunda com dados do tipo empréstimo, a terceira com o comportamento de pagamento desses empréstimos, e a quarta com a informação dos clientes já identificados como inadimplentes.
        
        Para dar início a análise, procurou-se entender onde os dados estavam disponíveis, de que tipo eram e como estavam armazenados, para então, saber quais dados seriam necessários para responder às questões levantadas. Em seguida, foi dado início ao processo geral de análise que consistiu nas etapas listadas a seguir.
        
    - **1 PROCESSAMENTO E PREPARAÇÃO DA BASE DE DADOS**
        
        **1 .1  Importação dos dados:** 
        
        Através do Bigquery - serviço de armazenamento e análise de dados  do Google Cloud Platform (GCP), foi criado um projeto de trabalho e um conjunto de dados, onde as tabelas  disponibilizadas foram carregadas.
        
        **1.2  Identificação dos dados nulos:** 
        
        Na tabela que continha as informações dos clientes foram identificados 7.199 valores nulos correspondentes à variável “ salário último mês” e 943 nulos referentes à variável “ número de dependentes”. Na demais tabelas não foram identificados valores nulos.
        
        **1.3  Tratamento dos dados nulos:** 
        
        Por representarem um percentual significativo, optou-se por substituir os valores nulos mencionados pelo valor correspondente à mediana, em ambas as variáveis.
        
        **1.4 Identificação e tratamento dos dados duplicados:**
        
        Não foram identificados qualquer valor em duplicidade
        
        **1.5  Identificação e gestão dos dados fora do escopo:**
        
        Dentre as três variáveis correspondentes ao número de atraso dos clientes, optou-se por manter apenas uma delas (atraso superior a 90 dias), por ter sido verificado que estavam altamente correlacionadas.
        
        **1.6 Identificação e tratamento dados discrepantes nas variáveis categóricas** 
        
        Foi verificado discrepância apenas na variável categórica referente ao tipo de empréstimo contratado , onde foram identificadas duas categorias que representavam o mesmo tipo de empréstimo ('others', e 'OTHER')
        
        **1.7 Verificação e alteração do tipo dos dados**
        
        Ao analisar o tipo de dado armazenado em cada variável, em princípio não foi necessário fazer qualquer tipo de alteração. Optou-se apenas, na composição do dashboard , apresentar os dados que estavam na forma decimal, em valores percentuais.
        
        **1.8 Identificação e tratamento dados discrepantes nas variáveis numéricas**
        
        Utilizando-se dos comandos MAX, MIN e AVG em SQL,  boxplot e comandos em Python para identificação de outliers, optou-se por desconsiderar os outliers extremos em relação as variáveis 'número de vezes que atrasou o pagamento' , 'relacão dividas ativos' e 'uso do limite de crédito’
        
        **1.9 Criação de novas variáveis**
        
        Foram criadas as seguintes variáveis :
        
        - total loans (total empréstimos) - correspondente a soma das duas categorias de empréstimos (imóveis + outros), e necessária para a validação de uma das hipóteses .
        - variáveis correspondentes às faixas de valores de endividamento, de uso de crédito, número de atrasos, idade, salário, número de dependentes - essa divisão foi feita observando-se a distribuição dos dados através do cálculo das medidas descritivas e visualização dos respectivos valores no boxplot ( através da biblioteca matplotlib)
        - variáveis correspondentes à classificação de risco das subdivisões (faixas de valores) de cada variável mencionada no tópico anterior. Para essa classificação, estabeleceu-se duas categorias de risco (baixo e alto), observando-se o valor obtido através do cálculo de probabilidade de inadimplência , bem como o cálculo do risco de crédito de cada grupo.
        - variáveis dummy relacionadas às variáveis de classificação de risco , onde 0 representou clientes considerados de baixo risco e 1 representou clientes de alto risco
        - variável ‘score’ , correspondente à soma das variáveis dummy (0 e 1)
        - variável “classificação do score” , onde a pontuação final de cada cliente foi classificada como risco baixo (pontuações 1 e 2)  , risco moderado (pontuação 3) e risco alto ( pontuações 4 e 5)
        
        **1.10 União das tabelas:** 
        
        O processo inicial de limpeza de dados foi feito através de comandos SQL, após o qual, foram criadas as “visualizações” das tabelas, com os dados já limpos e com o comando de junção “LETF JOIN” foi feita a união das tabelas em uma única tabela denominada “**view_tb_final_dados_integrados.** Tendo essa tabela final, optou-se por dar continuidade ao processo no Google Colab
        
    - **2 PROCESSO DE ANÁLISE EXPLORATÓRIA DOS DADOS**
        - Através da análise exploratória, por meio da visualização de tabelas, gráficos de barras, de dispersão e boxplot, e ainda, através dos cálculos das medidas de tendência central e de dispersão e dos cálculos de correlação foi possível :
        - Identificar que a base de dados era composta por 36.000 clientes, dos quais 60% são homens e 40% são mulheres.
        - Em relação aos salários, observa-se uma distribuição bastante dispersa, com uma média de R$ 6.425,12 e um desvio padrão elevado de R$ 11.614,16. A mediana é de R$ 5.408,00, portanto, metade dos clientes ganham salário abaixo da média.
        - Em relação à distribuição das idades, verificou-se que metade dos clientes tem entre 41 e 63 anos de idade. A idade média observada tanto entre os homens como entre mulheres é de aproximadamente 52 anos
        - Quando analisado o número de dependentes por cliente, verificou-se que uma grande parcela (60,67%) não tem dependentes. 30,34% tem entre 1 e 2 filhos.
        - São apenas duas as nomenclaturas usadas para identificar os tipos de empréstimos realizados pelo banco, a primeira denominada “empréstimos imóveis” e a outra denominada “outros” (para os demais empréstimos).
        - Verificou-se que dos mais de 305.000 empréstimos realizados pelo banco , cerca de 12% apenas são empréstimos imobiliários.
        - O índice geral de inadimplência é de 1,76%, ou seja, de cada 100 clientes, há a probabilidade de quase 2 tornarem-se inadimplentes.
        - Em média, os clientes têm aproximadamente de 8 a 9 empréstimos contratados.
        - Do total de clientes analisados, constatou-se que apenas 363 clientes (1,18%) não têm empréstimos ativos, porém com um alto índice de inadimplência  de 3,03%.
        - Em relação ao atraso em mais de 90 dias,  a maioria dos clientes (95% ) nunca atrasaram seus pagamentos.
        - Em relação à utilização do limite de crédito, metade dos clientes estão usando em torno de 0 A 15% do seu limite de crédito. 25% usam de 16 a 55% do limite disponível. 25% usam mais de 55% do limite de crédito. Foram identificados apenas 173 clientes (0,48%), cujo uso do limite de crédito é considerado extremo, ultrapassando mais de 1,32 vezes o valor disponível como limite de crédito.
        - Quando analisado o nível de endividamento , dos 35.932 clientes, 935 (2,6%) não têm nenhuma dívida. 50% têm até 37% do patrimônio comprometido. 25% têm mais de 87% do patrimônio comprometido. 7.566 clientes (cerca de 21% da amostra) devem valores equivalentes a quase 2 vezes o valor do seu patrimônio.
        - Quanto à análise das possíveis correlações, tanto positivas, quanto negativas entre as variáveis, confirmou-se apenas a multicolinearidade (alta correlação) entre as variáveis relacionadas ao atraso nos pagamentos.
        - Através da análise exploratória, por meio dos gráficos boxplot, foram identificados outliers extremos nas variáveis  'número de vezes que atrasou o pagamento' , 'relacão dividas ativos' e 'uso do limite de crédito’.
        - Após a segmentação dos clientes, com base nas variáveis consideradas e o levantamento dos índices de inadimplência dos respectivos segmentos foi possível identificar e classificar os grupos de maior e menor risco de concessão de crédito, compondo as seguintes tabelas:
        
        ![Untitled](https://prod-files-secure.s3.us-west-2.amazonaws.com/9064d3bc-7db2-42f6-ae31-b1818aad0dd6/7701fb71-4477-48d6-8890-97ee6890df70/e8c359bf-382e-4cf9-8405-ece718238602.png)
        
    - **3 APLICAÇÃO DA TÉCNICA DE ANÁLISE**
        
        As técnicas de análise consistiram em:
        
        - Segmentar os clientes, tendo por base as variáveis idade, salário, número de dependentes, total empréstimos, número de atrasos superior a 90 dias, uso limite crédito e taxa de endividamento
        - Calcular os índices de inadimplência dos grupos segmentados, para tal foi feito o levantamento do número de clientes inadimplentes de cada grupo , dividindo-o pelo total de clientes do mesmo grupo.
        - Calcular o risco de concessão de crédito, para isso, buscou-se dividir o índice de inadimplência de cada segmento de cada variável pelo indicador médio de inadimplência da amostra total, ou seja, dos quase 36 mil clientes
        - Determinação do score de risco
        - Validar a hipótese: para a validação ou refutação das hipóteses, foram utilizados os gráficos bivariados (barras e linhas)
    - **RESULTADOS E CONCLUSÕES**
        
        Como resulto do projeto, consideramos três os principais resultados:
        
        **Identificação do perfil dos clientes de maior risco:**
        
        - Usam mais de 56% do limite de crédito disponível
        - Nível de endividamento alto a extremo, entre 38% a 192%
        - Possuem histórico de atraso nos pagamentos
        - Salário abaixo de $3.908,00
        - Idade entre 21 e 40 anos
        - Têm mais de 3 dependentes
        
        **Score como ferramenta de auxílio na concessão de crédito**
        
        - Clientes que obtiverem 4 pontos ou mais no score são classificados como clientes de RISCO ALTO
        - Clientes que obtiverem 3 pontos são classificados como clientes de RISCO MÉDIO
        - Clientes que obtiverem 1 ou 2 pontos são classificados como clientes de RISCO BAIXO
        
        **Dashboard para consulta de clientes**
        
        - Onde é possível consultar o risco de crédito e o score do cliente
        
        Quanto às hipóteses levantadas:
        
        1. **Os mais jovens correm um risco maior de não pagamento?**  Sim, a análise mostra que pessoas mais jovens apresentam os maiores índices de inadimplência.
        2. **Pessoas com mais empréstimos ativos correm maior risco de serem maus pagadores?**Não, os dados mostram que pessoas com o maior número de empréstimos ativos tem os menores indicadores de inadimplência.
        3. **Pessoas que atrasaram seus pagamentos por mais de 90 dias correm maior risco de serem maus pagadores?** Sim, há uma correlação positiva entre o número de atrasos e o indicador de inadimplência, contudo, o número de clientes que atrasam seus pagamentos representa uma pequena parcela da base de dados.
    - **LIMITAÇÕES E PRÓXIMOS PASSOS**
        
        Durante a análise, como limitações, identificamos a ausência de mais variáveis que podem aprimorar o cálculo do score dos clientes e tornar as decisões de crédito ainda mais informadas, tais como:
        
        - Fontes de Renda Adicionais: Dados sobre outras fontes de renda além do salário podem fornecer uma visão mais precisa da real capacidade de pagamento do cliente.
        - Tempo de Serviço: Indica a estabilidade do cliente em seu emprego, um fator relevante para avaliar o risco de crédito.
        - Patrimônio do Cliente: Informações sobre propriedades e outros ativos podem servir como garantias, aumentando a segurança do crédito.
        - Tempo de Residência: Pode refletir a estabilidade do cliente em sua localização atual.
        - Tempo de Cadastro: Um histórico mais longo pode indicar maior confiabilidade e menor risco.
        - Nível Educacional: Pode estar correlacionado com maior potencial de renda e estabilidade financeira.
        
    
