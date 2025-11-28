-- 1️) Vývoj mezd podle odvětví (rok → odvětví, CELKEM vždy poslední)
SELECT
	rok,
  	odvetvi,
  	prumerna_mzda,
  	-- meziroční změna mzd (absolutně)
  	ROUND(
		prumerna_mzda
		- LAG(prumerna_mzda) OVER (
			PARTITION BY odvetvi
			ORDER BY rok
		),
		2
	) AS mezirocni_zmena_mzdy,
	-- meziroční růst mzdy (%)
  	ROUND(
  		(
  			prumerna_mzda
  			/ LAG(prumerna_mzda) OVER (
  				PARTITION BY odvetvi
  				ORDER BY rok
  			)
  			- 1
  		) * 100,
  		2
  	) AS mezirocni_rust_mzdy_pct
FROM
	t_jiri_pozar_project_sql_primary_final
ORDER BY
	rok,
  	-- CASE WHEN použito, aby se řádek CELKEM pro jednotlivé roky neřadil
  	-- podle abecedy, ale zařadil se vždy až na konec
  	CASE WHEN odvetvi = 'CELKEM' THEN 1 ELSE 0 END,
  	odvetvi;

