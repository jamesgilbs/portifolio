# Long & Short por Cointegração

Este modelo foi elaborado com linguagem R, no ambiente do RStudio, para investigação do assunto proposto. O código utilizado para gerar todos resultados abaixo encontra-se no repositório.

## O que é Long & Short?
Quando você está comprado em um determinado ativo A na sua carteira que você acredita que vai se valorizar com o tempo, você está long (comprado) nesse ativo.

O oposto disso é estar short (vendido). Nesse caso, você ganha dinheiro quando um determinado ativo B se desvaloriza.

Essas duas operações podem ser performadas separadamente: você pode só estar comprado no ativo A ou apenas vendido no ativo B. Contudo, existe também a possibilidade de se aproveitar as relações entre dois ativos e, com o dinheiro recebido por vender o ativo B, comprar o ativo A. Nesse caso, a operação recebe o nome de Long & Short.

## Séries Estacionárias e Não-Estacionárias
Tradicionalmente, as operações de L&S se baseiam no método da correlação. Esse método busca algum tipo de dependência linear entra duas variáveis independentes. Por exemplo, se dois ativos estão correlacionados, uma variação em um ativo A corresponde a uma variação na mesma direção do ativo B (caso a correlação seja positiva), ou em sentidos opostos (caso a correlação seja negativa).

No entanto, a correlação não leva em consideração a variação dos dados (também chamadas de séries) com o tempo. Para que uma estratégia de Long & Short possa ser aplicada, é preciso determinar se a série é estacionária no tempo.

Uma série estacionária é toda série cujas propriedades estatísticas como média, variância ou covariância não variam com o tempo. Logo, o oposto disso é chamado de série não-estacionária, ou seja, séries que possuem média, variância e covariância dependentes do tempo.

## Dados
Os dados do Índice Bovespa foram coletados no site Yahoo Finance, com recorte temporal de 01/01/2008 a 01/06/2021 (n = 162), valor ajustado(leva em conta dividendos, splits e outros) periodicidade diária.

<p align="center">
  <img width="" height="" src="https://i.imgur.com/UQc2aTX.png">
</p>

## Os pares
Plotagem dos pares para visualmente analisarmos se existe alguma relação entre eles e se os dados em si são estacionários no tempo.
Não existe nenhum tipo de estacionaridade neles. Contudo, a visualização sugere que existe uma relação entre os pares.

<p align="center">
  <img width="75%" height="75%" src="https://i.imgur.com/EiybyZZ.png">
</p>

## Correlação
Nesse exemplo, vemos que existe uma alta correlação entre os ativos da Petrobras no período de tempo que escolhemos para análise. Se fossemos seguir uma estratégia baseado apenas na correlação, esse resultado estaria nos dizendo para prosseguir com a operação.

<p align="center">
  <img width="" height="" src="https://i.imgur.com/y5181Ta.png">
</p> 

Porém, como vimos anteriormente, a correlação de pares não-estacionários na verdade varia com o tempo. Nesse sentido, essa correlação pode deixar de ser verdadeira em um próximo período. Por isso, vamos aprender a calcular se esses ativos estão na verdade.

<p align="center">
  <img width="75%" height="75%" src="https://i.imgur.com/6LVvFiC.png">
</p> 

## Ajuste de um modelo linear
O output da regressão linear nos dará os coeficientes da reta y=βx+by = \beta x + by=βx+b que melhor aproxima os nossos dados.

<p align="center">
  <img width="" height="" src="https://i.imgur.com/tojcS0s.png">
</p> 

## Cálculo do resíduo
O segundo passo é calcularmos o resíduo. Agora que temos o valor previsto de Y, o resíduo (ou erro) pode ser calculado como a diferença entre o ponto previsto (calculado pelo nosso modelo linear) e o ponto observado (o valor observado na realidade).

Agora podemos plotar esse resíduo para checarmos primeiramente se eles são graficamente estacionários. Ou seja, precisamos ver se a média e o desvio padrão do resíduo são constantes.

<p align="center">
  <img width="75%" height="75%" src="https://i.imgur.com/QtNhbdN.png">
</p> 

De fato, parece que o resíduo, diferentemente do comportamento dos ativos, oscila em relação à sua média, entre duas vezes o desvio padrão para cima e para baixo. Como vimos, esse é um dos indicativos de que o resíduo pode ser estacionário. Contudo, alguns podem argumentar que não veem esse resíduo perfeitamente estacionário. E, obviamente, nós tentamos evitar ao máximo critérios subjetivos na análise quantitativa.

## Estacionariedade no resíduo
Existem métodos mais robustos de análise estatística que determinam se uma série é estacionária ou não com uma porcentagem de confiabilidade. Usualmente o teste mais utilizado se chama Augmented Dickey-Fuller.

Além disso, o teste nos retorna o famoso p-value, que basicamente determina a probabilidade do resultado ter sido encontrado por mero acaso.

No nosso exemplo, a confiabilidade é de 99.75%. Como geralmente valores acima de 95% já são suficientes para análise, o resultado então nos confirma que os ativos estão cointegrados com 99.75% de confiabilidade.

<p align="center">
  <img width="" height="" src="https://i.imgur.com/eUcPy7S.png">
</p> 

## Resultado do Modelo de Cointegração
Os ativos sempre variam com o tempo, e podemos tirar essa dependência para aplicarmos modelos estatisticamente consistentes utilizando cointegração.

A cointegração consistem em analisar o resíduo de uma regressão linear entre os ativos e procurar por estacionariedade nele. 
