-- 2️) Kupní síla – počet jednotek potravin za průměrnou mzdu
SELECT
	odvetvi,
  	MIN(rok) AS prvni_rok,
  	MAX(rok) AS posledni_rok,
  	ROUND(
  		MAX(prumerna_mzda) / MAX(cena_mleka),
  		2
  	) AS mleko_posledni_rok,
  ROUND(
  	MIN(prumerna_mzda) / MIN(cena_mleka),
  	2
  ) AS mleko_prvni_rok,
  ROUND(
  	MAX(prumerna_mzda) / MAX(cena_chleba),
  	2
  ) AS chleba_posledni_rok,
  ROUND(
  	MIN(prumerna_mzda) / MIN(cena_chleba),
  	2
  ) AS chleba_prvni_rok
FROM t_jiri_pozar_project_sql_primary_final
WHERE
	cena_mleka IS NOT NULL
	AND cena_chleba IS NOT NULL
GROUP BY
	odvetvi
ORDER BY 
    -- CASE WHEN použito, aby se řádek CELKEM pro jednotlivé roky neřadil
    -- podle abecedy, ale zařadil se vždy až na konec
	CASE WHEN odvetvi = 'CELKEM' THEN 1 ELSE 0 END,  
	odvetvi;

