-- 5) Vliv HDP na mzdy a ceny potravin
WITH
	-- a) Meziroční růst HDP (jeden záznam na rok)
	hdp_vals AS (
		SELECT
    		rok,
   		    hdp::numeric AS hdp
		FROM
			t_jiri_pozar_project_sql_secondary_final
		WHERE
			stat ILIKE '%Czech%'  -- bezpečně najde 'Czechia' nebo 'Czech Republic'
	),
	-- výpočet meziročního růstu HDP
	hdp_changes AS (
  		SELECT
    		rok,
    		(
    			(hdp - LAG(hdp) OVER (ORDER BY rok))
    			/ NULLIF(LAG(hdp) OVER (ORDER BY rok), 0)
   			    * 100
   			 )::numeric AS rust_hdp_pct_raw
  		FROM hdp_vals
	),
	-- b) Roční hodnoty mezd a průměru cen (jeden záznam na rok)
	mzdy_values AS (
		SELECT
    		rok,
   		    prumerna_mzda,
			-- výpočet průměrné ceny z dostupných kategorií
			-- kategorie bez dat nejsou do průměru započteny
    		(
    			  COALESCE(prumerna_cena_peciva,0)
     			+ COALESCE(prumerna_cena_masa,0)
     			+ COALESCE(prumerna_cena_mlecne_vyrobky,0)
     			+ COALESCE(prumerna_cena_ovoce,0)
     			+ COALESCE(prumerna_cena_zelenina,0)
     			+ COALESCE(prumerna_cena_nealko,0)
     			+ COALESCE(prumerna_cena_alko,0)
    		)
    		/
    		NULLIF(
    		-- dělitel je počet kategorií s existující hodnotou
      			 (CASE WHEN prumerna_cena_peciva IS NOT NULL THEN 1 ELSE 0 END
       			+ CASE WHEN prumerna_cena_masa IS NOT NULL THEN 1 ELSE 0 END
       			+ CASE WHEN prumerna_cena_mlecne_vyrobky IS NOT NULL THEN 1 ELSE 0 END
       			+ CASE WHEN prumerna_cena_ovoce IS NOT NULL THEN 1 ELSE 0 END
       			+ CASE WHEN prumerna_cena_zelenina IS NOT NULL THEN 1 ELSE 0 END
       			+ CASE WHEN prumerna_cena_nealko IS NOT NULL THEN 1 ELSE 0 END
       			+ CASE WHEN prumerna_cena_alko IS NOT NULL THEN 1 ELSE 0 END),
       			0
    		)::numeric AS prumerna_cena_sum
  		FROM
  			t_jiri_pozar_project_sql_primary_final
 	    WHERE
 	    	odvetvi = 'CELKEM'
	),
	-- c) Meziroční změny mezd a cen (použití LAG nad ročními hodnotami)
	mzdy_ceny_changes AS (
		SELECT
			rok,
			-- růst mezd    
   		    (
   		    	(prumerna_mzda - LAG(prumerna_mzda) OVER (ORDER BY rok))
    			/ NULLIF(LAG(prumerna_mzda) OVER (ORDER BY rok),0)
    			* 100
    		)::numeric AS rust_mezd_pct_raw,
			-- růst cen potravin    
			(
				(prumerna_cena_sum - LAG(prumerna_cena_sum) OVER (ORDER BY rok))
    			/ NULLIF(LAG(prumerna_cena_sum) OVER (ORDER BY rok),0)
    			* 100
    		)::numeric AS rust_cen_pct_raw
  		FROM
  			mzdy_values
  	)
-- d) Závěrečný přehled + výpočet vlivu HDP
SELECT
	m.rok,
  	ROUND(h.rust_hdp_pct_raw, 2) AS rust_hdp_pct,
  	ROUND(m.rust_mezd_pct_raw, 2) AS rust_mezd_pct,
  	ROUND(m.rust_cen_pct_raw, 2) AS rust_cen_pct,
  	-- rozdíl změny HDP a mezd / cen (aktuální rok)
  	ROUND((m.rust_mezd_pct_raw - h.rust_hdp_pct_raw)::numeric, 2) AS rozdil_mezd_vs_hdp,
  	ROUND((m.rust_cen_pct_raw - h.rust_hdp_pct_raw)::numeric, 2) AS rozdil_cen_vs_hdp,
 	-- vliv HDP na další rok
    -- (pokud HDP výrazně vyroste v roce t+1
  	--  a mzdy/ceny rostly pomalu v roce t
  	--  rozdíl bude kladný)
    --  jedná se tedy o: rust_HDP_{t+1} - rust_mzdy_{t} 
  	ROUND((LEAD(h.rust_hdp_pct_raw) OVER (ORDER BY m.rok) - m.rust_mezd_pct_raw)::numeric, 2)
    AS vliv_hdp_na_mzdy_pristi_rok,
  	ROUND((LEAD(h.rust_hdp_pct_raw) OVER (ORDER BY m.rok) - m.rust_cen_pct_raw)::numeric, 2)
    AS vliv_hdp_na_ceny_pristi_rok
FROM
	mzdy_ceny_changes m
	JOIN hdp_changes h USING (rok)
ORDER BY
	m.rok;



