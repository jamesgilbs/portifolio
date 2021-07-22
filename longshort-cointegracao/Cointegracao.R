# Verifica a cointegração de dois ativos para validação de operação Long/Short

#####
#------------------ Configurações ------------------#
#Bibliotecas
#install.packages("GGally")
# install.packages("quantmod")
# install.packages("ggplot2")
library(quantmod)
library(data.table)
library(caTools)
library(tidyverse)
library(ggplot2)
library(tseries)
library(lubridate)
library(GGally)

rm(list = ls())

options(max.print=1000000) # Número de linhas para visualização
options(digits = 8, OutDec = ",") # Configuração decimal

#####
#------------------ Buscando e Plotando os Ativos ------------------#
# Dados e preparação da base
stock <- c("PETR3.SA")
stock2 <- c("PETR4.SA")
startdate <- as.Date("2019-01-01")
enddate <- as.Date("2021-12-31")
periodicidade = "daily"

atv <- getSymbols(stock, src = "yahoo", from = startdate, to = enddate, auto.assign = FALSE, periodicity = periodicidade)
atv2 <- getSymbols(stock2, src = "yahoo", from = startdate, to = enddate, auto.assign = FALSE, periodicity = periodicidade)

atv <- data.frame(atv)
atv <- na.omit(atv)

atv2 <- data.frame(atv2)
atv2 <- na.omit(atv2)

names(atv) <- c("Open", "Hight", "Low", "Close", "Volume", "Ajustado")
names(atv2) <- c("Open", "Hight", "Low", "Close", "Volume", "Ajustado")

rownames(atv)
rownames(atv2)

atv$Date <- rownames(atv)
atv2$Date <- rownames(atv2)

atv$Date <- parse_date_time(atv$Date, "ymd")
atv2$Date <- parse_date_time(atv2$Date, "ymd")

Base <- data.frame(atv$Date, atv$Ajustado, atv2$Ajustado)
names(Base) <- c("DATA", "ATIVO1", "ATIVO2")
summary(Base)

ggplot(Base, aes(DATA)) + 
  geom_line(aes(y = ATIVO1, colour = stock)) + 
  geom_line(aes(y = ATIVO2, colour = stock2)) + 
  xlab("Data") + 
  ylab("R$") + 
  labs(colour = 'Pares:', title = "Gráfico dos Pares")

#####
#------------------ Correlação ------------------#
# Fazendo a Correlação
BaseCor <- Base
BaseCor$DATA <- NULL
knitr::kable(cor(BaseCor))

ggpairs(BaseCor, lower = list(continuous = "smooth"))

#####
#------------------ Regressão linear ------------------#
# Ajustando a regressao
regression <- lm(ATIVO1 ~ ATIVO2, data = Base)
summary(regression)

#####
#------------------ Resíduos ------------------#
# Calculando os residuos
res <- residuals(regression)
plot(res, type = "l", col = "black", main = "Resíduos da regressão", ylab = "Resíduo", xlab = "Amostras")

#####
#------------------ Teste de Dickey-Fuller ------------------#
# Teste se resíduos são estacionários
# A cointegração depende dos resíduos estacionários, p-value no máximo de 0,05 (5%)
# Dickey-Fuller Test
Dfuller <- tseries::adf.test(res) # p-value demonstra a chance de não ser resíduos estacionários
ConfiabilidadeFuller <- Dfuller$p.value
ConfiabilidadeFuller <- (1 - ConfiabilidadeFuller) * 100
Dfuller
paste("Teste Dickey Fuller:", ConfiabilidadeFuller, "% de confiabilidade que são cointegrados")
