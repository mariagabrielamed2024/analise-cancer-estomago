library(tidyverse)
library(scales)

# 1. Lê a base nacional de 10 anos
df <- read_csv("dados/sim_cancer_estomago_brasil_2014_2023.csv", show_col_types = FALSE)

# 2. Prepara dados da série histórica por região
serie_regiao <- df %>%
  filter(!is.na(ano_obito), regiao != "Ignorado") %>%
  count(ano_obito, regiao)

# 3. Gráfico 1: Evolução temporal por Região (2014–2023)
grafico_tendencia <- ggplot(serie_regiao, aes(x = ano_obito, y = n, color = regiao)) +
  geom_line(linewidth = 1.2) +
  geom_point(size = 2.5) +
  scale_x_continuous(breaks = 2014:2023) +
  scale_y_continuous(labels = label_number(big.mark = ".")) +
  scale_color_brewer(palette = "Set1") +
  labs(
    title = "Evolução dos Óbitos por Câncer de Estômago no Brasil (2014–2023)",
    subtitle = "Série histórica decenal estratificada por grande região (CID-10: C16)",
    x = "Ano do Óbito",
    y = "Número Absoluto de Óbitos",
    color = "Região",
    caption = "Fonte: Ministério da Saúde - Sistema de Informações sobre Mortalidade (SIM/DATASUS)"
  ) +
  theme_minimal(base_size = 12) +
  theme(
    plot.title = element_text(face = "bold", size = 13),
    legend.position = "top",
    panel.grid.minor = element_blank(),
    axis.text.x = element_text(angle = 45, hjust = 1)
  )

dir.create("graficos", showWarnings = FALSE)
ggsave("graficos/tendencia_nacional_regioes.png", plot = grafico_tendencia, width = 9, height = 5.5, dpi = 300, bg = "white")

# 4. Análise complementar: Top 5 subcategorias específicas do CID-10 C16
top_subtipos <- df %>%
  count(CAUSABAS, sort = TRUE) %>%
  mutate(percentual = round((n / sum(n)) * 100, 1)) %>%
  slice_head(n = 5)

write_csv(top_subtipos, "dados/resumo_subtipos_c16.csv")
