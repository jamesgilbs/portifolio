#Web Scraping in R
#https://www.outspokenmarket.com/blog
#Leandro Guerra

library('rvest')

#Insira a URL alvo - Informaçoes Balanço Açoes - Petr4
url <- 'http://bvmf.bmfbovespa.com.br/pt-br/mercados/acoes/empresas/ExecutaAcaoConsultaInfoEmp.asp?CodCVM=9512&ViewDoc=1&AnoDoc=2019&VersaoDoc=1&NumSeqDoc=83238#a'

#Le o codigo HTML da url indicada
site <- read_html(url)

#Escolhe qual o elemento HTML para coletar - resultado em HTML
info_Balanco_HTML <- html_nodes(site,'table')

#Converte o HTML para texto
info_Balanco <- html_text(info_Balanco_HTML)

#Visualizacao do Texto
head(info_Balanco,20)


#Como melhorar a visualizaçao e captura das tabelas?
head(info_Balanco_HTML)

#Escolhemos as tabelas 3, 4 e 5
lista_tabelas <- site %>%
  html_nodes("table") %>%
  .[3:5] %>%
  html_table(fill = TRUE)

#Visualizaçao
str(lista_tabelas)

head(lista_tabelas[[1]], 10)
head(lista_tabelas[[2]], 10)
head(lista_tabelas[[3]], 10)

View(lista_tabelas[[1]])
View(lista_tabelas[[2]])
View(lista_tabelas[[3]])

#Atribuiçao
BP <- lista_tabelas[[1]]
DR <- lista_tabelas[[2]]
DFC <- lista_tabelas[[3]]
