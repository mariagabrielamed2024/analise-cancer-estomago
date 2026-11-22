# Análise Epidemiológica Nacional: Câncer de Estômago (CID-10: C16) — DATASUS & IBGE

Estudo epidemiológico desenvolvido em **R** integrando microdados oficiais do Sistema de Informações sobre Mortalidade (**SIM/DATASUS**) e dados demográficos/geográficos do **IBGE**, cobrindo todo o Brasil (2014–2023).

## Pipeline do Projeto
1. `scripts/01_coleta_datasus.R`: Extrai e decodifica os microdados nacionais do SIM-DO (2014–2023) via pacote `microdatasus`, filtrando óbitos por neoplasia maligna do estômago (CID-10: C16).
2. `scripts/02_analise_visual.R`: Gera a estratificação demográfica por faixa etária e sexo.
3. `scripts/03_serie_historica_regioes.R`: Analisa a série histórica decenal por grande região do Brasil e sumariza os subtipos anatômicos mais frequentes.
4. `scripts/04_taxa_padronizada_ibge.R`: Cruza os óbitos com a população residente do Censo 2022 (`sidrar`) e calcula a **Taxa de Mortalidade Padronizada por Idade** (método direto, População Padrão OMS) por 100.000 habitantes.
5. `scripts/05_mapa_coropletico_brasil.R`: Constrói o mapa coroplético das Unidades da Federação (`geobr` / `sf`) evidenciando a distribuição espacial do risco de mortalidade.

## Dependências em R
```r
install.packages(c("tidyverse", "scales", "lubridate", "sidrar", "geobr", "sf", "remotes"))
remotes::install_github("rfsaldanha/microdatasus")
