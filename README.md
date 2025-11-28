## Projekt-z-SQL
**Dostupnost základních potravin široké veřejnosti**   
**(můj 4. projekt Engeto akademie)**

# Závěrečná zpráva – SQL projekt: Vývoj mezd a dostupnosti potravin v ČR

**Autor:** Jiří Požár  
**Tabulky:**  
- `t_jiri_pozar_project_SQL_primary_final` – Česká republika, detailní srovnání mezd a cen potravin  
- `t_jiri_pozar_project_SQL_secondary_final` – HDP, GINI a populace vybraných evropských států  

---

## Cíl projektu

Cílem analýzy bylo vytvořit robustní datový podklad umožňující zjistit údaje
o dostupnosti potravin vzhledem k průměrným příjmům v čase (v rámci ČR).
Připravit tabulku s HDP, GINI koeficientem a populací dalších evropských států v čase.  
Dále odpovědět na otázky:
- zda v čase rostou mzdy ve všech odvětvích a zda se zlepšuje dostupnost základních potravin
- která kategorie potravin zdražuje v čase nejpomaleji
- zda jsou v některých letech výrazně vyšší nárůsty cen potravin oproti růstu mezd
- zda mají změny v HDP vliv na změny ve mzdách a cenách potravin.

---

##  Struktura dat

### 1. Primární tabulka – `t_jiri_pozar_project_SQL_primary_final`

**Obsahuje:**
- Rok a odvětví (`rok`, `odvetvi`)
- Průměrné mzdy dle odvětví a celkem (`prumerna_mzda`)
- Jednotkové ceny 27 potravin (`cena_ryze` … `cena_kapra`)
- Doplňkové průměry dle kategorií (`prumerna_cena_peciva`, `..._masa`, `..._mlecne_vyrobky`, `..._ovoce`, `..._zelenina`, `..._nealko`, `..._alko`)

**Rozsah dat:** 2006–2018  
**Zdroje:** `czechia_payroll`, `czechia_payroll_calculation`, `czechia_payroll_industry_branch`, `czechia_payroll_unit`, `czechia_payroll_value_type`, `czechia_price`, `czechia_price_category`  

**Zpracování:**
- Data byla sjednocena na **společné roky**, kde jsou dostupné jak mzdy, tak ceny.
- Průměry byly počítány z jednotkových cen za jednotlivé potraviny.
- Hodnota **„CELKEM“** doplňuje průměrnou mzdu napříč odvětvími.

**Chybějící hodnoty:**
- U **vína** chybí ceny před rokem 2015 → zkresluje průměr `prumerna_cena_alko`.
- Některé obory mezd nemají záznam pro nejstarší roky         (cca 1–2 prázdné řádky ročně).
- V roce 2018 jsou poslední kompletní data, pozdější roky již nejsou v datasetu `czechia_price`.

---

### 2. Sekundární tabulka – `t_jiri_pozar_project_SQL_secondary_final`

**Obsahuje:**
- Demografické údaje evropských zemí
(`stat`, `rok`, `populace`, `stredni_delka_zivota`, `region`)
- Ekonomické ukazatele evropských zemmí (`hdp`, `gini_koeficient`, )
- Vypočtený meziroční růst HDP (`rust_hdp_pct`)

**Rozsah dat:** 2006–2018
**Zdroje:** `countries`, `economies`

**Chybějící hodnoty:**
- Ne všechny státy mají úplné GINI nebo fertility ukazatele.
- HDP je v USD, přepočet nebyl nutný, protože srovnání probíhá procentuálně.

---

##  Výzkumné otázky a zjištění

### 1. Rostou v průběhu let mzdy ve všech odvětvích, nebo v některých klesají?

Krátkodobé poklesy se objevují jen v několika odvětvích v některých letech. Výjimkou je rok 2013,
kdy došlo k poklesu mezd téměř ve všech odvětvích i v celkovém průměru.

Mzdy tedy nerostou vždy, ale **dlouhodobý trend je růstový**.  

---

### 2. Kolik je možné si koupit litrů mléka a kilogramů chleba za první a poslední srovnatelné období v dostupných datech cen a mezd?
V roce 2006 (první srovnatelné období z dostupných dat) bylo možné koupit cca **1 432 litrů mléka** nebo **1283 kg chleba** za průměrnou mzdu.  

V roce 2018 (poslední srovnatelné období z dostupných dat) už to bylo cca **1 569 litrů mléka**
nebo **1340 kg chleba**.  

Dostupnost potravin se tedy **mírně zlepšila**.

---

### 3. Která kategorie potravin zdražuje nejpomaleji? (je u ní nejnižší percentuální meziroční nárůst)

Výpočteny průměrného meziroční růsty cen (2006–2018):

| Kategorie | Průměrné zdražování (%) |
|------------|--------------------------|
| Nealko nápoje | **1.0** |
| Ovoce | 1.9 |
| Zelenina | 1.9 |
| Maso | 2.1 |
| Pečivo | 3.5 |
| Mléčné výrobky | 4.2 |
| Alkoholické nápoje | ~2.9* |

\* Hodnota očištěna o chybějící data vína před 2015. 

Kategorie potravin která zdražuje nejpomaleji jsou **Nealkoholické nápoje**.

---

### 4. Existuje rok, ve kterém byl meziroční nárůst cen potravin výrazně vyšší než růst mezd? (větší než 10%)

Dle dostupných dat byl rokem s největším nárůstem cen oproti růstu mezd **rok 2013**.
V tomto roce vzrostly ceny o ~5,4 %, zatímco mzdy poklesly o ~1,5 %.  
Rozdíl byl **>6,9 p.b.**, což je v rámci zkoumaného období nejvýraznější odchylka.

Znamená to tedy, že rok kdy by odchylka byla větší než +10% **neexistuje**.

---

### 5. Má HDP vliv na změny ve mzdách a cenách potravin?
 
**HDP** vykazuje **pozitivní korelaci** s růstem mezd (částečně, s časovým zpožděním).  
**Vliv HDP** na ceny potravin **je slabší** a více rozkolísaný; často se ceny reagují opožděně.

### Poznámka:
U výpočtů „vliv HDP na změnu mezd“ a „vliv HDP na změnu cen potravin v následujícím roce“ je použit analytický princip posunu dat pomocí funkce LEAD(). Ta umožňuje porovnat růst HDP v daném roce s růstem mezd či cen v roce následujícím. Aby bylo možné tuto hodnotu vypočítat, musí mít dataset k dispozici také údaje o HDP v následujícím roce.
Protože dostupná data končí rokem 2018, nelze pro něj vypočítat hodnoty:
vliv HDP 2018 na růst mezd v roce 2019
vliv HDP 2018 na růst cen v roce 2019
Z tohoto důvodu jsou ve výsledné tabulce pro rok 2018 u obou těchto ukazatelů uvedeny hodnoty NULL. Nejedná se o chybu, ale o očekávané a metodicky správné chování odpovídající nedostupnosti dat pro další rok.

---

###  Shrnutí kvality dat
| Kategorie | Zdrojová tabulka | Úplnost dat | Poznámka |
|------------|------------------|--------------|-----------|
| Mzdy | `czechia_payroll` | 99 % | některé chybějící obory před 2005 |
| Ceny potravin | `czechia_price` | 96 % | víno od 2015 |
| HDP a GINI | `economies` | 92 % | chybí menší státy EU |

---

### Doporučení
- Do budoucna přidat **reálný index inflace** a **HDP per capita**.  
- Vyloučit potraviny s neúplnými daty (např. víno) z celkových průměrů.  
- Umožnit analýzu „příštího roku“ i přes **lag korelaci (LAG+LEAD)** pro přesnější zpožděný efekt.

---

### **Závěr:**  
Projekt ukazuje, že růst HDP i mezd v ČR byl v letech 2006–2018 poměrně stabilní 
a reálná kupní síla obyvatel rostla.  
Ceny potravin rostou mírně, přičemž nejstabilnější kategorií zůstávají **nealkoholické nápoje**.

---

