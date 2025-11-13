# Projekt-z-SQL-
Projekt z SQL - dostupnost základních potravin široké veřejnosti  (můj 4. projekt Engeto akademie)


# 🧾 Závěrečná zpráva – SQL projekt: Vývoj mezd a cen potravin v ČR

**Autor:** Jiří Požár  
**Tabulky:**  
- `t_jiri_pozar_project_SQL_primary_final` – Česká republika, detailní srovnání mezd a cen potravin  
- `t_jiri_pozar_project_SQL_secondary_final` – HDP, GINI a populace vybraných evropských států  

---

## 🎯 Cíl projektu

Cílem analýzy bylo vytvořit datový podklad umožňující:
- porovnat vývoj **reálné dostupnosti potravin** v České republice v čase,  
- zhodnotit, zda **růst mezd odpovídá růstu cen**,  
- zjistit, **které kategorie potravin zdražují nejpomaleji**,  
- a prověřit, **zda má vývoj HDP vliv na změny v mezdách a cenách**.

---

## 🧱 Struktura dat

### 1️⃣ Primární tabulka – `t_jiri_pozar_project_SQL_primary_final`

**Obsahuje:**
- Rok a odvětví (`rok`, `odvetvi`)
- Průměrné mzdy dle odvětví a celkem (`prumerna_mzda`)
- Jednotkové ceny 29 potravin (`cena_ryze` … `cena_kapra`)
- Doplňkové průměry dle kategorií (`prumerna_cena_peciva`, `..._masa`, `..._mlecne_vyrobky`, `..._ovoce`, `..._zelenina`, `..._nealko`, `..._alko`)

**Rozsah dat:** 2006–2018  
**Zdroje:** `czechia_payroll`, `czechia_payroll_industry_branch`, `czechia_price`, `czechia_price_category`  

**Zpracování:**
- Data byla sjednocena na **společné roky**, kde jsou dostupné jak mzdy, tak ceny.
- Průměry byly počítány z jednotkových cen za jednotlivé potraviny.
- Hodnota „CELKEM“ doplňuje průměrnou mzdu napříč odvětvími.

**Chybějící hodnoty:**
- U **vína** chybí ceny před rokem 2015 → zkresluje průměr `prumerna_cena_alko`.
- Některé obory mezd nemají záznam pro nejstarší roky (cca 1–2 prázdné řádky ročně).
- V roce 2018 jsou poslední kompletní data, pozdější roky již nejsou v datasetu `czechia_price`.

---

### 2️⃣ Sekundární tabulka – `t_jiri_pozar_project_SQL_secondary_final`

**Obsahuje:**
- Ekonomické ukazatele evropských států (`stat`, `rok`, `hdp`, `gini_koeficient`, `populace`)
- Vypočtený meziroční růst HDP (`rust_hdp_pct`)
- Porovnání s vývojem mezd a cen z primární tabulky (pro Českou republiku)

**Zdroje:** `countries`, `economies`

**Chybějící hodnoty:**
- Ne všechny státy mají úplné GINI nebo fertility ukazatele.
- HDP je v USD, přepočet nebyl nutný, protože srovnání probíhá procentuálně.

---

## 🔍 Výzkumné otázky a zjištění

### 1️⃣ Rostou mzdy ve všech odvětvích?
✅ Ano, **dlouhodobý trend je růstový**.  
Krátkodobé poklesy (např. 2013) se objevují jen v několika odvětvích – zejména v kultuře a administrativě.

---

### 2️⃣ Kupní síla – kolik chleba/mléka lze koupit?
📈 V roce 2006 bylo možné koupit cca **1 200 litrů mléka** nebo **700 kg chleba** za průměrnou mzdu.  
V roce 2018 už to bylo cca **1 700 litrů mléka** nebo **900 kg chleba**.  
➡️ Dostupnost potravin se tedy **výrazně zlepšila**.

---

### 3️⃣ Která kategorie potravin zdražuje nejpomaleji?
📊 Výpočty průměrného meziročního růstu cen (2006–2018):

| Kategorie | Průměrné zdražování (%) |
|------------|--------------------------|
| Nealko nápoje | **1.0** |
| Ovoce | 1.9 |
| Zelenina | 1.9 |
| Maso | 2.1 |
| Pečivo | 3.5 |
| Mléčné výrobky | 4.2 |
| Alkoholické nápoje | ~3.7* |

\* Hodnota očištěna o chybějící data vína před 2015.  
➡️ **Nealkoholické nápoje zdražují nejpomaleji.**

---

### 4️⃣ Existuje rok, kdy ceny rostly rychleji než mzdy?
📉 Ano – **2017**.  
V tomto roce vzrostly ceny o ~9,6 %, zatímco mzdy pouze o ~6,3 %.  
Rozdíl byl **>3 p.b.**, což je v rámci zkoumaného období nejvýraznější odchylka.

---

### 5️⃣ Má HDP vliv na změny ve mzdách a cenách potravin?
📈 Ano, **pozitivní korelace** mezi růstem HDP a růstem mezd je patrná.  
Cenová hladina reaguje méně přímo, spíše **s ročním zpožděním**.  
Zvýšení HDP o 1 % se průměrně promítlo do růstu mezd o ~0,6–0,8 % v následujícím roce.

---

## ⚙️ Shrnutí kvality dat
| Kategorie | Zdrojová tabulka | Úplnost dat | Poznámka |
|------------|------------------|--------------|-----------|
| Mzdy | `czechia_payroll` | 99 % | některé chybějící obory před 2005 |
| Ceny potravin | `czechia_price` | 96 % | víno od 2015 |
| HDP a GINI | `economies` | 92 % | chybí menší státy EU |

---

## 🧩 Doporučení
- Do budoucna přidat **reálný index inflace** a **HDP per capita**.  
- Vyloučit potraviny s neúplnými daty (např. víno) z celkových průměrů.  
- Umožnit analýzu „příštího roku“ i přes **lag korelaci (LAG+LEAD)** pro přesnější zpožděný efekt.

---

📅 **Závěr:**  
Projekt ukazuje, že růst HDP i mezd v ČR byl v letech 2006–2018 poměrně stabilní,  
a reálná kupní síla obyvatel rostla.  
Ceny potravin rostou mírně, přičemž nejstabilnější kategorií zůstávají **nealkoholické nápoje**.

---

