-- ===========================================
-- 📊 Projekt SQL – Primární tabulka
-- Autor: Jiří Požár
-- Název: t_jiri_pozar_project_sql_primary_final
-- Popis: Sjednocená data o mzdách a cenách potravin v ČR
-- ===========================================

-- a️) ceny potravin
DROP TABLE IF EXISTS tmp_ceny;
CREATE TEMP TABLE tmp_ceny AS
SELECT
  EXTRACT(YEAR FROM cp.date_from)::int AS rok,
  -- jednotlivé potraviny
  ROUND(AVG(CASE WHEN pc.code = 111101 THEN cp.value END)::numeric, 2) AS cena_ryze,
  ROUND(AVG(CASE WHEN pc.code = 111201 THEN cp.value END)::numeric, 2) AS cena_mouky,
  ROUND(AVG(CASE WHEN pc.code = 111301 THEN cp.value END)::numeric, 2) AS cena_chleba,
  ROUND(AVG(CASE WHEN pc.code = 111303 THEN cp.value END)::numeric, 2) AS cena_peciva,
  ROUND(AVG(CASE WHEN pc.code = 111602 THEN cp.value END)::numeric, 2) AS cena_testovin,
  ROUND(AVG(CASE WHEN pc.code = 112101 THEN cp.value END)::numeric, 2) AS cena_hoveziho,
  ROUND(AVG(CASE WHEN pc.code = 112201 THEN cp.value END)::numeric, 2) AS cena_veproveho,
  ROUND(AVG(CASE WHEN pc.code = 112401 THEN cp.value END)::numeric, 2) AS cena_kurete,
  ROUND(AVG(CASE WHEN pc.code = 112704 THEN cp.value END)::numeric, 2) AS cena_salamu,
  ROUND(AVG(CASE WHEN pc.code = 114201 THEN cp.value END)::numeric, 2) AS cena_mleka,
  ROUND(AVG(CASE WHEN pc.code = 114401 THEN cp.value END)::numeric, 2) AS cena_jogurtu,
  ROUND(AVG(CASE WHEN pc.code = 114501 THEN cp.value END)::numeric, 2) AS cena_eidamu,
  ROUND(AVG(CASE WHEN pc.code = 114701 THEN cp.value END)::numeric, 2) AS cena_vajec,
  ROUND(AVG(CASE WHEN pc.code = 115101 THEN cp.value END)::numeric, 2) AS cena_masla,
  ROUND(AVG(CASE WHEN pc.code = 115201 THEN cp.value END)::numeric, 2) AS cena_tuku,
  ROUND(AVG(CASE WHEN pc.code = 116103 THEN cp.value END)::numeric, 2) AS cena_bananu,
  ROUND(AVG(CASE WHEN pc.code = 116101 THEN cp.value END)::numeric, 2) AS cena_pomerancu,
  ROUND(AVG(CASE WHEN pc.code = 116104 THEN cp.value END)::numeric, 2) AS cena_jablek,
  ROUND(AVG(CASE WHEN pc.code = 117101 THEN cp.value END)::numeric, 2) AS cena_rajcat,
  ROUND(AVG(CASE WHEN pc.code = 117103 THEN cp.value END)::numeric, 2) AS cena_paprik,
  ROUND(AVG(CASE WHEN pc.code = 117106 THEN cp.value END)::numeric, 2) AS cena_mrkve,
  ROUND(AVG(CASE WHEN pc.code = 117401 THEN cp.value END)::numeric, 2) AS cena_brambor,
  ROUND(AVG(CASE WHEN pc.code = 118101 THEN cp.value END)::numeric, 2) AS cena_cukru,
  ROUND(AVG(CASE WHEN pc.code = 122102 THEN cp.value END)::numeric, 2) AS cena_mineralky,
  ROUND(AVG(CASE WHEN pc.code = 212101 THEN cp.value END)::numeric, 2) AS cena_vina,
  ROUND(AVG(CASE WHEN pc.code = 213201 THEN cp.value END)::numeric, 2) AS cena_piva,
  ROUND(AVG(CASE WHEN pc.code = 2000001 THEN cp.value END)::numeric, 2) AS cena_kapra,
  -- průměrné ceny kategorií
  ROUND(AVG(CASE WHEN pc.code IN (111301,111303,111602) THEN cp.value END)::numeric, 2) AS prumerna_cena_peciva,
  ROUND(AVG(CASE WHEN pc.code IN (112101,112201,112401,112704,2000001) THEN cp.value END)::numeric, 2) AS prumerna_cena_masa,
  ROUND(AVG(CASE WHEN pc.code IN (114201,114401,114501,114701,115101,115201) THEN cp.value END)::numeric, 2) AS prumerna_cena_mlecne_vyrobky,
  ROUND(AVG(CASE WHEN pc.code IN (116101,116103,116104) THEN cp.value END)::numeric, 2) AS prumerna_cena_ovoce,
  ROUND(AVG(CASE WHEN pc.code IN (117101,117103,117106,117401) THEN cp.value END)::numeric, 2) AS prumerna_cena_zelenina,
  ROUND(AVG(CASE WHEN pc.code IN (122102) THEN cp.value END)::numeric, 2) AS prumerna_cena_nealko,
  ROUND(AVG(CASE WHEN pc.code IN (212101,213201) THEN cp.value END)::numeric, 2) AS prumerna_cena_alko
FROM czechia_price cp
JOIN czechia_price_category pc
	ON cp.category_code = pc.code
GROUP BY EXTRACT(YEAR FROM cp.date_from)::int
ORDER BY rok;

-- b️) průměrné mzdy
DROP TABLE IF EXISTS tmp_mzdy;
CREATE TEMP TABLE tmp_mzdy AS
SELECT
	p.payroll_year::int AS rok,
    ib.name AS odvetvi,
    ROUND(AVG(p.value)::numeric, 2) AS prumerna_mzda
FROM czechia_payroll p
LEFT JOIN czechia_payroll_industry_branch ib
	ON p.industry_branch_code = ib.code
WHERE p.value_type_code = 5958
GROUP BY p.payroll_year::int, ib.name
UNION ALL
SELECT
	p.payroll_year::int AS rok,
  	'CELKEM' AS odvetvi,
    ROUND(AVG(p.value)::numeric, 2) AS prumerna_mzda
FROM czechia_payroll p
WHERE p.value_type_code = 5958
GROUP BY p.payroll_year::int
ORDER BY rok, odvetvi;

-- c️) finální tabulka: sjednocená data
DROP TABLE IF EXISTS t_jiri_pozar_project_sql_primary_final;
CREATE TABLE t_jiri_pozar_project_sql_primary_final AS
SELECT
	m.rok,
    m.odvetvi,
    m.prumerna_mzda,

    c.cena_ryze,
    c.cena_mouky,
    c.cena_chleba,
    c.cena_peciva,
    c.cena_testovin,
    c.cena_hoveziho,
    c.cena_veproveho,
    c.cena_kurete,
    c.cena_salamu,
    c.cena_mleka,
    c.cena_jogurtu,
    c.cena_eidamu,
    c.cena_vajec,
    c.cena_masla,
    c.cena_tuku,
    c.cena_bananu,
    c.cena_pomerancu,
    c.cena_jablek,
    c.cena_rajcat,
    c.cena_paprik,
    c.cena_mrkve,
    c.cena_brambor,
    c.cena_cukru,
    c.cena_mineralky,
    c.cena_vina,
    c.cena_piva,
    c.cena_kapra,

    c.prumerna_cena_peciva,
  	c.prumerna_cena_masa,
  	c.prumerna_cena_mlecne_vyrobky,
  	c.prumerna_cena_ovoce,
  	c.prumerna_cena_zelenina,
  	c.prumerna_cena_nealko,
  	c.prumerna_cena_alko
FROM tmp_mzdy m
JOIN tmp_ceny c
  ON m.rok = c.rok
WHERE m.odvetvi IS NOT NULL -- odstranění prázdných odvětví
ORDER BY
  m.rok,
  CASE WHEN m.odvetvi = 'CELKEM' THEN 2 ELSE 1 END,
  m.odvetvi;
    
-- d️) kontrola výsledku
SELECT
	rok,
  	COUNT(*) AS pocet_radku,
  	MIN(prumerna_mzda) AS min_mzda,
  	MAX(prumerna_mzda) AS max_mzda
FROM t_jiri_pozar_project_sql_primary_final
GROUP BY rok
ORDER BY rok;