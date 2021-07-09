# O estudo justifica-se pela necessidade de entender o comportamento estatístico
# do Ibovespa, sobretudo, em momentos de maior incerteza na economia local.
# Utilizado Período de jan/2008 - jun/2021 mensal.

#####
#------------------ Confugurações ------------------#
# Bibliotecas
rm(list=ls())
# install.packages("quantmod") # Retornos
# install.packages("ggplot2")
# install.packages("forecast")
# install.packages("stochvol")
# install.packages("dygraphs")
library(quantmod)
library(ggplot2)
library(forecast)
library(dplyr)
library(stochvol)
library(dygraphs)

options(max.print=1000000) # Número de linhas para visualização
options(digits = 2, OutDec = ",") # Configuração decimal

#####
#------------------ Buscando e Plotando o Ativo ------------------#
# Constantes
stock <- "^BVSP" # stock
start <- "2008-01-01"
end <- "2021-06-25" # Sys.Date() 
periodicidade <- "monthly"

# Busca os dados do Yahoo Finance
dataframe.atv <- getSymbols(stock, src = "yahoo", from = start, to = end, auto.assign = FALSE, periodicity = periodicidade)
names(dataframe.atv)
atv <- na.omit(dataframe.atv) # na.appox na.locf na.omit

# Algumas conferências
head(atv) # Primeiros dados da base
tail(atv) # Últimos dados da base
summary(atv) # Estatísticas descritivas
str(atv) # Estrutura da série

# Plotagem de Indicadores
candleChart(atv, TA=c(addMACD(fast = 12, slow = 26, signal = 9), addVo(), addBBands()), show.grid = TRUE, "last 180 months", theme = chartTheme('white', up.col='white',dn.col='black'))

# Gráfico Interativo
grafico <-cbind(atv[,4])
dygraph(grafico, ylab="Retorno Logaritmo X Estimativa de volatilidade",main=stock) %>%
  dySeries(label = stock) %>%
  dyOptions(colors = c("blue")) %>%
  dyOptions(stackedGraph = TRUE) %>%
  dyAxis("y", label = (paste("Preço de fechamento de", stock))) %>%
  dyOptions(stepPlot = TRUE) %>%
  dyRangeSelector()

#####
#------------------  Análise de Autocorrelação Serial ------------------#
# Análise de autocorrelação do preço
acf(atv[,4])
title(paste("ACF Análise de Autocorrelação Serial de", stock), line = +1)

# Análise de autocorrelação parcial do retorno
acf(atv[,4], type="partial")
title(paste("PACF parcial do log retorno de", stock), line = +1)
  
#####
#------------------ Cálculo dos Retornos ------------------#
# Retorno por período
rD <- (100 * dailyReturn(atv)) # Retorno anual
summary(rD)
rW <- (100 * weeklyReturn(atv)) # Retorno anual
summary(rW)
rM <- (100 * monthlyReturn(atv)) # Retorno anual
summary(rM)
rQ <- (100 * quarterlyReturn(atv)) # Retorno anual
summary(rQ)
rA <- (100 * yearlyReturn(atv)) # Retorno anual
summary(rA)
rA

atvRet <- na.omit(100 * diff(log(atv[,4]))) # Retorno percentual
atvRet <- atvRet[-1,]

# Estatística de retorno
summary(atvRet) # Estatíticas gerais
sd(atvRet) # Desvio padrão

# Gráfico do retorno do período total
plot(atvRet, col="blue", lwd = 2)
title(paste("Retorno ao longo do Período", stock), line = +1)

# Retorno logaritmo ao quadrado do período total
plot(atvRet^2, col="brown", lwd = 2)
title(paste("Retorno Logaritmo ao Quadrado(Cluster de Volatilidade) de", stock), line = +1)

#####
#------------------  Modelo de Volatilidade Estocástica(MVE) ------------------#
# Análise a posteriori com simulação Bayesiana via Markov Chain Monte Carlo(MCMC)
postAtv <- svsample(atvRet) # Distribuição a Priori
summary(postAtv, showlatent=FALSE) # Para ter eacesso aos parâmetros estimados da posteriori
# Stored 10000 MCMC draws after a burn-in of 1000.
# Geardas 10.000 amostras e descartadas as primeiras 1.000.
plot(postAtv) # Densidade marginal (mu(B0) phi(B1) sigma) IC(Intervalo de credibilidade Bayesiana)

#Análise residual do modelo
residAtv<-resid(postAtv) # Probabilidade Quanti-Quantil (Qualidade de ajuste)
plot(residAtv, col="darkblue",cex=0.5)