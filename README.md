<p xmlns:cc="http://creativecommons.org/ns#" xmlns:dct="http://purl.org/dc/terms/"><a property="dct:title" rel="cc:attributionURL" href="https://github.com/calvin-wirawan/INF6027">Analysis of birth trends in England and Wales: Associations with maternal age and levels of deprivation</a> by <a rel="cc:attributionURL dct:creator" property="cc:attributionName" href="https://github.com/calvin-wirawan">Calvin Wirawan</a> is licensed under <a href="https://creativecommons.org/licenses/by/4.0/?ref=chooser-v1" target="_blank" rel="license noopener noreferrer" style="display:inline-block;">CC BY 4.0<img style="height:22px!important;margin-left:3px;vertical-align:text-bottom;" src="https://mirrors.creativecommons.org/presskit/icons/cc.svg?ref=chooser-v1" alt=""><img style="height:22px!important;margin-left:3px;vertical-align:text-bottom;" src="https://mirrors.creativecommons.org/presskit/icons/by.svg?ref=chooser-v1" alt=""></a></p> 

## Analysis of birth trends in England and Wales: <br>Associations with maternal age and levels of deprivation

![Line chart](https://github.com/user-attachments/assets/b2df06a5-72a1-4645-ab5d-df543ee16aa6)

The birth rates in England and Wales have experienced a substantial drop over the past decade, with around 100.000 fewer live births in 2023 compared to 2014. The current figure is the lowest number of live births on record since 1977.[^1]

This project aimed to examine the association between age of mothers and deprivation levels in relation to birth 
count, as well as to provide a forecast of future birth trends in England and Wales. The specific research questions 
were listed as follows:
1. What patterns emerge in the relationship between maternal age and the number of live births in England and Wales?
2. Does deprivation correlate with the incidence of stillbirths in England and Wales? 
3. What are the projected trends in the number of live births in England and Wales over the coming decade?
<br/>

The primary dataset used in the study was obtained from the birth registrations data (2023) provided by the Office for National Statistics:
> https://www.ons.gov.uk/file?uri=/peoplepopulationandcommunity/birthsdeathsandmarriages/livebirths/datasets/birthsinenglandandwalesbirthregistrations/2023/2023birthregistrations.xlsx

Specific to analyse the correlation between deprivation and the incidence of stillbirths, a secondary dataset from the ONS was employed:
> https://www.ons.gov.uk/file?uri=/peoplepopulationandcommunity/birthsdeathsandmarriages/deaths/datasets/childmortalitystatisticschildhoodinfantandperinatalchildhoodinfantandperinatalmortalityinenglandandwales/2022/cim2022deathcohortworkbook.xlsx

The experiment was carried out using R programming language version 4.4.1 (2024-06-14) and software RStudio Desktop 
for macOS version 2024.12.0+467. Besides the R base packages, the following packages were also used: 
- `tidyverse`
- `readxl`
- `ggpubr`
- `ggstatsplot`
- `forecast`
- `Metrics`
- `MetBrewer`
- `ggtext`

> [!TIP]
> Instructions on how to run the code were provided in file: [INSTRUCTION.md](INSTRUCTION.md)
<br/>

### Key Findings

**1. Relationship between maternal age and the number of live births**

![Cycle plot](https://github.com/user-attachments/assets/984fa7b2-0fd8-4697-9f59-e533fbdf6a93)
The green horizontal line represents the average number of live births for each maternal age group. Downward trends were observed in live births happening from mothers aged below 30 years. For older mothers, no major changes observed in terms of birth counts.
<br/>
<br/>

**2. Correlation between deprivation and the incidence of stillbirths**

![Box plot](https://github.com/user-attachments/assets/8979eb44-09a1-4fb8-842a-0b076faadc17)
The plots revealed a linear pattern, implying that the median of stillbirth incidences was highest in areas with low IMD (more deprived) and lowest in areas with high IMD (less deprived).

![Correlation](https://github.com/user-attachments/assets/f255345f-f3c8-47d5-bfb0-9cfba31e9d33)
There was a significant, very strong negative correlation between the IMD and the incidence of stillbirths, r = -0.76, p < 0.001. Provided that the IMD maintains an inverse relation with deprivation levels, it was concluded that as deprivations increased, stillbirth counts were also increased.
<br/>
<br/>

**3. Forecast of future birth trends over the coming decade**

![Forecast Comparison](https://github.com/user-attachments/assets/f8370134-0c69-42ac-8891-8189b49d93a1)
No significant differences were portrayed between the model’s predicted data and actual data.

![Time-series Forecast](https://github.com/user-attachments/assets/bd1042f9-4306-4087-8d2b-0d9dc835cb1a)
Live births in England and Wales were projected to continue experiencing a downward trend over the next decade, in which the number was expected to fall to 44.000 by end of year 2033.

[^1]: https://www.ons.gov.uk/peoplepopulationandcommunity/birthsdeathsandmarriages/livebirths/bulletins/birthsummarytablesenglandandwales/2023
