library(tidyverse)
library(sidrar)

# 1. Lê os dados nacionais de óbitos (2014-2023) e filtra o ano do último Censo/Estimativa (ex: 2022)
df_obitos <- read_csv("dados/sim_cancer_estomago_brasil_2014_2023.csv", show_col_types = FALSE) %>%
  filter(ano_obito == 2022, !is.na(IDADE), munResUf != "Ignorado") %>%
  mutate(
    idade_num = as.numeric(IDADE),
    faixa_etaria = cut(
      idade_num,
      breaks = c(-1, 19, 29, 39, 49, 59, 69, 79, 130),
      labels = c("0-19", "20-29", "30-39", "40-49", "50-59", "60-69", "70-79", "80+")
    )
  )

# Conta óbitos por UF e faixa etária em 2022
obitos_uf_idade <- df_obitos %>%
  filter(!is.na(faixa_etaria)) %>%
  count(munResUf, faixa_etaria, name = "obitos")

# 2. Busca população oficial por UF e idade no IBGE (Censo 2022 - Tabela SIDRA 9514)
pop_ibge_bruta <- get_sidra(
  x = 9514,
  variable = 93,
  period = "2022",
  geo = "State",
  classific = c("c287"), # Grupo de idade
  category = list(c287 = c(93070, 93084, 93085, 93086, 93087, 93088, 93089, 93090, 93091, 93092, 93093, 93094, 93095, 93096, 93097, 93098, 100362))
)

# Padroniza as faixas etárias do IBGE para bater com as do SIM
pop_ibge <- pop_ibge_bruta %>%
  select(uf = `Unidade da Federação`, grupo_idade = `Idade`, populacao = Valor) %>%
  mutate(
    faixa_etaria = case_when(
      grupo_idade %in% c("0 a 4 anos", "5 a 9 anos", "10 a 14 anos", "15 a 19 anos") ~ "0-19",
      grupo_idade %in% c("20 a 24 anos", "25 a 29 anos") ~ "20-29",
      grupo_idade %in% c("30 a 34 anos", "35 a 39 anos") ~ "30-39",
      grupo_idade %in% c("40 a 44 anos", "45 a 49 anos") ~ "40-49",
      grupo_idade %in% c("50 a 54 anos", "55 a 59 anos") ~ "50-59",
      grupo_idade %in% c("60 a 64 anos", "65 a 69 anos") ~ "60-69",
      grupo_idade %in% c("70 a 74 anos", "75 a 79 anos") ~ "70-79",
      TRUE ~ "80+"
    )
  ) %>%
  group_by(uf, faixa_etaria) %>%
  summarise(populacao = sum(populacao, na.rm = TRUE), .groups = "drop")

# 3. Tabela da População Padrão Mundial da OMS (pesos proporcionais para ajuste direto)
pop_padrao_oms <- tibble(
  faixa_etaria = c("0-19", "20-29", "30-39", "40-49", "50-59", "60-69", "70-79", "80+"),
  peso_oms = c(0.347, 0.160, 0.145, 0.125, 0.098, 0.068, 0.039, 0.018)
)

# 4. Calcula Taxa Bruta e Taxa Padronizada por 100.000 habitantes
taxas_estados <- pop_ibge %>%
  left_join(obitos_uf_idade, by = c("uf" = "munResUf", "faixa_etaria")) %>%
  left_join(pop_padrao_oms, by = "faixa_etaria") %>%
  mutate(
    obitos = replace_na(obitos, 0),
    taxa_especifica = (obitos / populacao) * 100000,
    taxa_ponderada = taxa_especifica * peso_oms
  ) %>%
  group_by(uf) %>%
  summarise(
    total_obitos = sum(obitos),
    populacao_total = sum(populacao),
    taxa_bruta_100k = round((total_obitos / populacao_total) * 100000, 2),
    taxa_padronizada_100k = round(sum(taxa_ponderada), 2),
    .groups = "drop"
  ) %>%
  arrange(desc(taxa_padronizada_100k))

# Salva a tabela final de indicadores epidemiológicos
write_csv(taxas_estados, "dados/taxas_mortalidade_c16_por_uf_2022.csv")
message("Taxas padronizadas calculadas com sucesso!")
