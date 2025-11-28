-- 3️) Průměrné tempo růstu jednotlivých kategorií potravin
WITH mezirocni AS (
	SELECT
    	rok,
    	ROUND(
    		((prumerna_cena_peciva / LAG(prumerna_cena_peciva) OVER (ORDER BY rok)) - 1) * 100,
    		2
    	) AS pecivo_pct,
    	ROUND(
    		((prumerna_cena_masa / LAG(prumerna_cena_masa) OVER (ORDER BY rok)) - 1) * 100,
    		2
    	) AS maso_pct,
    	ROUND(
    		((prumerna_cena_mlecne_vyrobky / LAG(prumerna_cena_mlecne_vyrobky) OVER (ORDER BY rok)) - 1) * 100,
    		2
    	) AS mlecne_pct,
    	ROUND(
    		((prumerna_cena_ovoce / LAG(prumerna_cena_ovoce) OVER (ORDER BY rok)) - 1) * 100, 
    		2
    	) AS ovoce_pct,
    	ROUND(
    		((prumerna_cena_zelenina / LAG(prumerna_cena_zelenina) OVER (ORDER BY rok)) - 1) * 100,
    		2
    	) AS zelenina_pct,
    	ROUND(
    		((prumerna_cena_nealko / LAG(prumerna_cena_nealko) OVER (ORDER BY rok)) - 1) * 100,
    		2
    	) AS nealko_pct,
    	-- Alko = jen pivo, protože je k dispozici ve všech ročnících
    	ROUND(
    		((cena_piva / LAG(cena_piva) OVER (ORDER BY rok)) - 1) * 100,
    		2
    	) AS alko_pct
  FROM t_jiri_pozar_project_sql_primary_final
  WHERE odvetvi = 'CELKEM'
)
SELECT
	'Pečivo' AS kategorie,
  	ROUND(AVG(pecivo_pct), 2) AS prumerne_zdrazovani
FROM mezirocni
UNION ALL
SELECT 'Maso', ROUND(AVG(maso_pct), 2) FROM mezirocni
UNION ALL
SELECT 'Mléčné výrobky', ROUND(AVG(mlecne_pct), 2) FROM mezirocni
UNION ALL
SELECT 'Ovoce', ROUND(AVG(ovoce_pct), 2) FROM mezirocni
UNION ALL
SELECT 'Zelenina', ROUND(AVG(zelenina_pct), 2) FROM mezirocni
UNION ALL
SELECT 'Nealko nápoje', ROUND(AVG(nealko_pct), 2) FROM mezirocni
UNION ALL
SELECT 'Alkoholické nápoje (pivo)', ROUND(AVG(alko_pct), 2) FROM mezirocni
ORDER BY prumerne_zdrazovani ASC;


