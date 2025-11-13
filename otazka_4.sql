-- 4️) Porovnání růstu cen a mezd
WITH rust AS (
  SELECT
    rok,
    ROUND((AVG(prumerna_mzda) / LAG(AVG(prumerna_mzda)) OVER (ORDER BY rok) - 1) * 100, 2) AS rust_mezd_pct,
    ROUND((AVG(prumerna_cena_peciva + prumerna_cena_masa + prumerna_cena_mlecne_vyrobky + prumerna_cena_ovoce + prumerna_cena_zelenina) /
           LAG(AVG(prumerna_cena_peciva + prumerna_cena_masa + prumerna_cena_mlecne_vyrobky + prumerna_cena_ovoce + prumerna_cena_zelenina)) OVER (ORDER BY rok) - 1) * 100, 2)
           AS rust_cen_pct
  FROM t_jiri_pozar_project_sql_primary_final
  WHERE odvetvi = 'CELKEM'
  GROUP BY rok
)
SELECT
  rok,
  rust_cen_pct,
  rust_mezd_pct,
  (rust_cen_pct - rust_mezd_pct) AS rozdil_pct,
  CASE WHEN (rust_cen_pct - rust_mezd_pct) > 10 THEN 'ANO' ELSE 'NE' END AS vyrazny_narust_cen_vs_mzdy
FROM rust
ORDER BY rok;
