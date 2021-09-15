## Sentimento dos reviews de usuários sobre restaurantes em lingua inglesa (Tripadivasor) com Knime
[![K](https://img.shields.io/badge/Knime-4.4.1-yellow)](#)

<a href='https://github.com/jamesgilbs/portifolio/tree/main/volatilidade-mve-retornos-ibov'><img src='https://github.com/jamesgilbs/portifolio/blob/main/volatilidade-mve-retornos-ibov/figures/indicator.jpg' align="left" height="139" /></a>

  Este modelo foi elaborado com o software ETL Knime, para estudo de Data Science. O código utilizado para gerar todos resultados abaixo encontra-se no repositório.

### O Problema de Negócio
  Para se entender atráves de reviews de usuários, como está sendo visto o setor de restaurante, foi proposto este projeto, que no caso, avalia como resultado final duas Tag-clouds, uma que representa palavras chaves em uma nuvem aleatória, com grau de relevância determinado por TF-IDF(frequência e raridade) e outra que já demonstra com adjetivos positivos e negativos o sentimento de usuários e a relevância de cada termo no contexto geral da base pesquisada.
  
### Sobre o Tripadvisor
  O Tripadvisor, a maior plataforma de viagens do mundo*, ajuda 463 milhões de viajantes todos os meses** a tornar cada viagem a melhor de todas. Pessoas do mundo todo usam o site e o aplicativo do Tripadvisor para acessar mais de 859 milhões de avaliações e opiniões sobre 8,6 milhões de acomodações, restaurantes, experiências, companhias aéreas e cruzeiros. Seja na fase de planejamento ou durante a viagem, o Tripadvisor é usado para comparar preços baixos de hotéis, voos e cruzeiros, para reservar excursões e atrações badaladas, além de para fazer reservas em ótimos restaurantes. O Tripadvisor, o melhor companheiro de viagem, está disponível em 49 mercados e 28 idiomas. (texto oficial do site)

<p align="center">
  <img width="" height="" src="figures/head.png">
</p>

<p align="center">
  <img width="" height="" src="figures/tail.png">
</p>

<p align="center">
  <img width="85%" height="85%" src="figures/indic.png">
</p>

  O estudo justifica-se pela necessidade de entender o comportamento estatístico do Ibovespa, sobretudo, em momentos de maior incerteza da economia local.

### Autocorrelação
  É verificado se existe correlação entre os valores passados do Ibovespa com valores atuais. Abaixo pode-se notar que não existe indicação dessa correlação contínua de influência passada. Apesar da correlção inicalmente ser forte(próximo de 1) observa-se que com o passar da linha de tempo a correlação fica cada vez mais fraca e demonstra uma desconexão dos valores atuais com os anteriores.

<p align="center">
  <img width="85%" height="85%" src="figures/acf.png">
</p>

  No gráfico de correlação parcial, tem-se uma faixa mais estreita que indica os limites dessa relação. Mesmo pequena existe uma relação anterior que não explica completamente os valores atuais.

<p align="center">
  <img width="85%" height="85%" src="figures/pacf.png">
</p>

### Análise da variação dos retornos
  Verifica-se com os indicadores gerados abaixo, as variações ao longo do tempo dos retornos do ativo.

<p align="center">
  <img width="" height="" src="figures/var.png">
</p>

  Observando que mesmo tendo uma maior queda em 2020 do que em 2008, a queda observada na crise do Covid-19 foi de recuperação mais acelerada, fechando dentro do mesmo ano positivamente.

<p align="center">
  <img width="85%" height="85%" src="figures/ret.png">
</p>

  Observa-se alta volatilidade em momentos de crise.
<p align="center">
  <img width="85%" height="85%" src="figures/retlog.png">
</p>

### O Modelo
  Este é um modelo de previsão de uma série de retornos e das suas volatilidades condicionais (MVE), ambas variáveis possuem componentes estocásticos em suas equações. Foi utilizado a teoria de inferência Bayesiana e algoritmos de simulação MCMC para obter os valores dos parâmetros do modelo.
  A análise gráfica mostra períodos de maior variabilidade na época da crise do subprime, em 2008 e 2009, diante das incertezas no cenário internacionais e em 2020, com a incerteza mundial envolvendo a pandemia do Vírus Corona Covid-19 . No restante da série, observa-se alguns curtos 
períodos de maior variabilidade, no entanto, de menor magnitude, se comparados com os períodos citados anteriormente.

Dados do modelo:

<p align="center">
  <img width="" height="" src="figures/mve.png">
</p>

Volatilidade estimada dos retornos:

<p align="center">
  <img width="85%" height="85%" src="figures/vol.png">
</p>

Para análise dos resíduos:
<p align="center">
  <img width="85%" height="85%" src="figures/resids.png">
</p>
