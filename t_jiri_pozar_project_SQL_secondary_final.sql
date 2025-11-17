-- ==================================================
-- 📊 Projekt SQL – Sekundární tabulka
-- Autor: Jiří Požár
-- Název: t_jiri_pozar_project_sql_secondary_final
-- Popis: Dodatečná data o dalších evropských státech
-- ==================================================


DROP TABLE IF EXISTS t_jiri_pozar_project_sql_secondary_final;

CREATE TABLE t_jiri_pozar_project_sql_secondary_final AS
SELECT
    c.country AS stat,
    c.capital_city AS hlavni_mesto,
    c.currency_name AS mena,
    e.year AS rok,
    e.gdp AS hdp,
    ROUND(
        ((e.gdp - LAG(e.gdp) OVER (PARTITION BY e.country ORDER BY e.year))
        / NULLIF(LAG(e.gdp) OVER (PARTITION BY e.country ORDER BY e.year), 0) * 100)::numeric,
        2
    ) AS rust_hdp_pct,
    e.gini AS gini_koeficient,
    e.population AS populace,
    c.life_expectancy AS stredni_delka_zivota,
    c.region_in_world AS region
FROM economies e
JOIN countries c 
    ON e.country = c.country
WHERE c.region_in_world LIKE '%Europe%'
  AND e.year BETWEEN 2006 AND 2018
ORDER BY c.country, e.year;



-- zobrazení tabulky
--SELECT * FROM t_jiri_pozar_project_sql_secondary_final; 



 
