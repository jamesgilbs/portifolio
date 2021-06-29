# Modelo de Volatilidade Estocástica relacionada ao retono dos Últimos anos do IBOV

## A Incerteza
A necessidade de entender a volatilidade tornou-se mais urgente com a evolução da economia 
moderna. O grau de incerteza e os riscos endógenos e exógenos ao mercado, sobretudo financeiro, 
demandavam que as análises se debruçassem também sobre a dispersão condicional dos indicadores.

Os riscos exógenos são, em sua maioria, inerentes ao negócio, a cultura da região onde ocorre a 
operação da organização e obviamente os fenômenos naturais locais. Os riscos endógenos muitas 
vezes são associados a questões de processo, escolha estratégica por uma tecnologia em 
detrimento de outra, questões políticas, conflitos internos, depreciação de ativos, 
conscientização e cooperação dos funcionários.

Alguns exemplos de riscos comuns são: interrupção da produção, perda de informações, intervenção 
de agente regulador, perda de competitividade, intervenção fiscal, integridade física de 
funcionários, contaminação do produto, impacto ambiental dentre dezenas de outros que vão 
possuir mais ou menos influência em cada organização e tipo de negócio.

## Dados
Os dados do Índice Bovespa foram coletados no site Yahoo Finance, com recorte temporal de 01/01/2008 a 01/06/2021 (n = 162), e periodicidade mensal.

<span style="display:block;text-align:center">![](https://i.imgur.com/TicsIYp.png)</span>

<span style="display:block;text-align:center">![](https://i.imgur.com/JouAPya.png)</span>

O Índice Bovespa ou IBOVESPA é um indicador representativo de uma carteira teórica das ações 
mais negociadas na Bolsa e, de modo geral, consegue captar o comportamento médio das cotações 
diárias na Bovespa. 

<span style="display:block;text-align:center">![](https://i.imgur.com/9q24YRw.png)</span>

O estudo justifica-se pela necessidade de entender o comportamento estatístico do Ibovespa, 
sobretudo, em momentos de maior incerteza da economia local.

## Autocorrelação
É verificado se existe correlação entre os valores passados do Ibovespa com valores atuais. Abaixo pode-se notar que não existe indicação dessa correlação contínua de influência passada com a atual.

<span style="display:block;text-align:center">![](https://i.imgur.com/zitq9NF.png)</span>

<span style="display:block;text-align:center">![](https://i.imgur.com/YjbJH2l.png)</span>

## Análise da variação dos retornos
Verifica-se com os indicadores gerados abaixo, as variações ao longo do tempo dos retornos do ativo.

<span style="display:block;text-align:center">![](https://i.imgur.com/GnGeMli.png)</span>

<span style="display:block;text-align:center">![](https://i.imgur.com/BVDwhs9.png)</span>

Observa-se alta volatilidade em momentos de crise.

<span style="display:block;text-align:center">![](https://i.imgur.com/gGU7CSx.png)</span>

## O Modelo
Este é um modelo de previsão de uma série de retornos e das suas volatilidades condicionais (MVE), ambas variáveis possuem componentes estocásticos em suas equações. Foi utilizado a teoria de 
inferência Bayesiana e algoritmos de simulação MCMC para obter os valores dos parâmetros do 
modelo.

<span style="display:block;text-align:center">![](https://i.imgur.com/gyx5fTC.png)</span>

A análise gráfica mostra períodos de maior variabilidade na época da crise do subprime, em 2008 
e 2009, diante das incertezas no cenário internacionais e em 2020, com a incerteza mundial 
envolvendo a pandemia do Vírus Corona Covid-19 . No restante da série, observa-se alguns curtos 
períodos de maior variabilidade, no entanto, de menor magnitude, se comparados com os períodos 
citados anteriormente.

Dados do modelo:

<span style="display:block;text-align:center">![](https://i.imgur.com/F5MPRNg.png)</span>

Volatilidade estimada dos retornos:

<span style="display:block;text-align:center">![](https://i.imgur.com/DyzPqUL.png)</span>

Para análise dos resíduos:

<span style="display:block;text-align:center">![](https://i.imgur.com/M3uxrW9.png)</span>

