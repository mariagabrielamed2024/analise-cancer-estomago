library(tidyverse)
library(scales)

# 1. Lê os dados reais salvos pelo primeiro script
df <- read_csv("dados/sim_cancer_estomago_2022_2023.csv", show_col_types = FALSE)

# 2. Limpa e cria as faixas etárias
df_limpo <- df %>%
  mutate(idade_num = as.numeric(IDADE)) %>%
  filter(!is.na(idade_num), SEXO %in% c("Masculino", "Feminino")) %>%
  mutate(
    faixa_etaria = cut(
      idade_num,
      breaks = c(0, 39, 49, 59, 69, 79, 120),
      labels = c("< 40 anos", "40-49 anos", "50-59 anos", "60-69 anos", "70-79 anos", "80+ anos")
    )
  )

# 3. Conta os óbitos por faixa etária e sexo
resumo <- df_limpo %>%
  count(faixa_etaria, SEXO)

# 4. Cria o gráfico
grafico <- ggplot(resumo, aes(x = faixa_etaria, y = n, fill = SEXO)) +
  geom_col(position = "dodge", width = 0.7) +
  geom_text(aes(label = n), position = position_dodge(width = 0.7), vjust = -0.5, size = 3.5) +
  scale_fill_manual(values = c("Feminino" = "#E07A5F", "Masculino" = "#3D405B")) +
  scale_y_continuous(expand = expansion(mult = c(0, 0.15))) +
  labs(
    title = "Óbitos por Câncer de Estômago (CID-10: C16) — DF e GO",
    subtitle = "Distribuição real por faixa etária e sexo (2022–2023)",
    x = "Faixa Etária",
    y = "Número de Óbitos",
    fill = "Sexo",
    caption = "Fonte: Ministério da Saúde - SIM/DATASUS"
  ) +
  theme_minimal(base_size = 12) +
  theme(
    plot.title = element_text(face = "bold", size = 13),
    legend.position = "top",
    panel.grid.minor = element_blank()
  )

# 5. Cria a pasta 'graficos' e salva a imagem
dir.create("graficos", showWarnings = FALSE)
ggsave("graficos/obitos_c16_datasus.png", plot = grafico, width = 8.5, height = 5.5, dpi = 300, bg = "white")
