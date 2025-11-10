set merge -union
merge cov_work/scope/* -output merge_dir
load_test merge_dir
load_icf exclude_case_1.icf
report_html *
exit
