library(tidyverse)
library(microdatasus)
library(lubridate)

# 1. Baixa microdados do SIM-DO para TODO O BRASIL (10 anos: 2014 a 2023)
# Nota: Como é uma base nacional de 10 anos, o download pode levar alguns minutos.
dados_brutos <- fetch_datasus(
  year_start = 2014,
  year_end = 2023,
  uf = "all",
  information_system = "SIM-DO"
)

# 2. Decodifica as variáveis do DATASUS
dados_processados <- process_sim(dados_brutos)

# 3. Filtra apenas óbitos por Câncer de Estômago (CID-10: C16) e extrai o Ano e a Região
cancer_estomago_br <- dados_processados %>%
  filter(str_starts(CAUSABAS, "C16")) %>%
  mutate(
    ano_obito = year(ymd(DTOBITO)),
    regiao = case_when(
      munResUf %in% c("Acre", "Amapá", "Amazonas", "Pará", "Rondônia", "Roraima", "Tocantins") ~ "Norte",
      munResUf %in% c("Alagoas", "Bahia", "Ceará", "Maranhão", "Paraíba", "Pernambuco", "Piauí", "Rio Grande do Norte", "Sergipe") ~ "Nordeste",
      munResUf %in% c("Distrito Federal", "Goiás", "Mato Grosso", "Mato Grosso do Sul") ~ "Centro-Oeste",
      munResUf %in% c("Espírito Santo", "Minas Gerais", "Rio de Janeiro", "São Paulo") ~ "Sudeste",
      munResUf %in% c("Paraná", "Rio Grande do Sul", "Santa Catarina") ~ "Sul",
      TRUE ~ "Ignorado"
    )
  ) %>%
  select(ano_obito, IDADE, SEXO, RACACOR, ESC, CAUSABAS, regiao, munResUf, munResNome)

# 4. Salva a base nacional tratada
dir.create("dados", showWarnings = FALSE)
write_csv(cancer_estomago_br, "dados/sim_cancer_estomago_brasil_2014_2023.csv")

message("Coleta nacional concluída! Total de óbitos C16 (2014-2023): ", nrow(cancer_estomago_br))
