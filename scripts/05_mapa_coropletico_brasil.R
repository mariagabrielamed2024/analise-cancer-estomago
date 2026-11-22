library(tidyverse)
library(geobr)
library(sf)

# 1. Lê a tabela de taxas padronizadas gerada no script 04
taxas_uf <- read_csv("dados/taxas_mortalidade_c16_por_uf_2022.csv", show_col_types = FALSE)

# 2. Baixa o mapa oficial dos estados brasileiros (IBGE via geobr)
mapa_brasil <- read_state(year = 2020, showProgress = FALSE)

# Padroniza nomes para garantir o cruzamento perfeito (ex: "Rio Grande do Norte")
mapa_dados <- mapa_brasil %>%
  mutate(name_state_clean = str_to_title(name_state)) %>%
  mutate(name_state_clean = str_replace_all(name_state_clean, c(" De " = " de ", " Do " = " do ", " Dos " = " dos ", " Da " = " da "))) %>%
  left_join(taxas_uf, by = c("name_state_clean" = "uf"))

# 3. Constrói o mapa coroplético
mapa_c16 <- ggplot(mapa_dados) +
  geom_sf(aes(fill = taxa_padronizada_100k), color = "white", linewidth = 0.3) +
  geom_sf_text(aes(label = abbrev_state), size = 2.8, color = "black", fontface = "bold") +
  scale_fill_viridis_c(
    option = "magma",
    direction = -1,
    name = "Taxa Padronizada\n(por 100 mil hab.)"
  ) +
  labs(
    title = "Mortalidade Padronizada por Câncer de Estômago no Brasil (2022)",
    subtitle = "Taxa ajustada por idade (População Padrão OMS) por Unidade da Federação — CID-10: C16",
    caption = "Fontes: Ministério da Saúde (SIM/DATASUS) e IBGE (Censo 2022 / geobr)"
  ) +
  theme_void(base_size = 12) +
  theme(
    plot.title = element_text(face = "bold", size = 13, hjust = 0.5, margin = margin(t = 10, b = 5)),
    plot.subtitle = element_text(size = 10, hjust = 0.5, color = "gray30", margin = margin(b = 10)),
    plot.caption = element_text(size = 8.5, color = "gray40", margin = margin(t = 10, b = 5)),
    legend.position = "right"
  )

# 4. Salva o mapa em alta resolução
dir.create("graficos", showWarnings = FALSE)
ggsave("graficos/mapa_mortalidade_padronizada_c16.png", plot = mapa_c16, width = 8.5, height = 7, dpi = 300, bg = "white")

message("Mapa coroplético gerado em graficos/mapa_mortalidade_padronizada_c16.png"
