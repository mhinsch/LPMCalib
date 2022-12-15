
for year in 2001.0 2011.0 2020.0 2021.0 ; do
	( head -n 1 run_1/log.tsv
	grep -h "^${year}\s" run_*/log.tsv ) > results_${year}.tsv
done
