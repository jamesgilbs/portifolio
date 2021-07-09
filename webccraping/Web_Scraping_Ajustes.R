#Web Scraping in R
#https://www.outspokenmarket.com/blog
#Leandro Guerra

library('rvest')

#Insira a URL alvo - Ajuste Derivativos - Pregao
url <- 'http://www2.bmf.com.br/pages/portal/bmfbovespa/lumis/lum-ajustes-do-pregao-ptBR.asp'

#Le o codigo HTML da url indicada
site <- read_html(url)

#Escolhe qual o elemento HTML para coletar - resultado em HTML
info_Ajuste_HTML <- html_nodes(site,'table')

#Converte o HTML para texto
info_Ajuste <- html_text(info_Ajuste_HTML)

#Visualizacao do Texto
head(info_Ajuste,20)

#Como melhorar a visualizaçao e captura das tabelas?
head(info_Ajuste_HTML)

lista_tabela <- site %>%
  html_nodes("table") %>%
  html_table(fill = TRUE)

#Visualizaçao
str(lista_tabela)

head(lista_tabela[[1]], 10)

View(lista_tabela[[1]])

#Atribuiçao
AJUSTE <- lista_tabela[[1]]

