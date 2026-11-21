library(tidyverse)
library(microdatasus)

# 1. Baixa os microdados reais do SIM (Sistema de Informações sobre Mortalidade)
dados_brutos <- fetch_datasus(
  year_start = 2022,
  year_end = 2023,
  uf = c("DF", "GO"),
  information_system = "SIM-DO"
)

# 2. Traduz os códigos numéricos do DATASUS para texto legível
dados_processados <- process_sim(dados_brutos)

# 3. Filtra apenas os óbitos por Câncer de Estômago (CID-10: C16)
cancer_estomago <- dados_processados %>%
  filter(str_starts(CAUSABAS, "C16")) %>%
  select(DTOBITO, IDADE, SEXO, RACACOR, ESC, CAUSABAS, munResNome, munResUf)

# 4. Cria a pasta 'dados' e salva a tabela limpa
dir.create("dados", showWarnings = FALSE)
write_csv(cancer_estomago, "dados/sim_cancer_estomago_2022_2023.csv")

message("Concluído! Total de registros encontrados: ", nrow(cancer_estomago))
