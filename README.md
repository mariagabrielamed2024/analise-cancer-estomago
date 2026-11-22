# Análise Epidemiológica Nacional: Câncer de Estômago (CID-10: C16) — DATASUS

Estudo exploratório desenvolvido em **R** utilizando microdados oficiais do Sistema de Informações sobre Mortalidade (**SIM/DATASUS**), abrangendo todo o território nacional no período de **2014 a 2023**.

## Estrutura do Projeto
* `scripts/01_coleta_datasus.R`: Extrai e decodifica os microdados nacionais do SIM-DO (2014–2023) via pacote `microdatasus`, filtrando óbitos por neoplasia maligna do estômago (CID-10: C16).
* `scripts/02_analise_visual.R`: Gera a estratificação demográfica por faixa etária e sexo.
* `scripts/03_serie_historica_regioes.R`: Analisa a série histórica de 10 anos por grande região do Brasil e sumariza os subtipos anatômicos mais frequentes (ex: C16.0 Cárdia, C16.9 Estômago não especificado).

## Como Executar
1. Instale os pacotes necessários:
   ```r
   install.packages(c("tidyverse", "scales", "lubridate", "remotes"))
   remotes::install_github("rfsaldanha/microdatasus")
   ```
2. Execute os scripts na ordem numérica (`01` -> `02` -> `03`).
