#!/bin/bash

perl sort_ips.pl -sjtu ap -other country
perl sort_ips.pl -sjtu ap -other bgp -sub CN
perl sort_ips.pl -sjtu ap -other gps -res 1 -sub CN
perl sort_ips.pl -sjtu ap -other gps -res 5


perl gen_tm.pl ../processed_data/subtask_parse_sjtu_wifi/sort_ips/sort_ips.ap.country.txt 3600
perl gen_tm.pl ../processed_data/subtask_parse_sjtu_wifi/sort_ips/sort_ips.ap.bgp.sub_CN.txt 3600
perl gen_tm.pl ../processed_data/subtask_parse_sjtu_wifi/sort_ips/sort_ips.ap.gps.1.sub_CN.txt 3600
perl gen_tm.pl ../processed_data/subtask_parse_sjtu_wifi/sort_ips/sort_ips.ap.gps.5.txt 3600


nf=19
ns=400
matlab -r "tm_top('../processed_data/subtask_parse_sjtu_wifi/tm/tm_download.sort_ips.ap.country.txt.3600', ${nf}, ${ns}); exit"
matlab -r "tm_top('../processed_data/subtask_parse_sjtu_wifi/tm/tm_upload.sort_ips.ap.country.txt.3600', ${nf}, ${ns}); exit"

matlab -r "tm_top('../processed_data/subtask_parse_sjtu_wifi/tm/tm_download.sort_ips.ap.bgp.sub_CN.txt.3600', ${nf}, ${ns}); exit"
matlab -r "tm_top('../processed_data/subtask_parse_sjtu_wifi/tm/tm_upload.sort_ips.ap.bgp.sub_CN.txt.3600', ${nf}, ${ns}); exit"

matlab -r "tm_top('../processed_data/subtask_parse_sjtu_wifi/tm/tm_download.sort_ips.ap.gps.1.sub_CN.txt.3600', ${nf}, ${ns}); exit"
matlab -r "tm_top('../processed_data/subtask_parse_sjtu_wifi/tm/tm_upload.sort_ips.ap.gps.1.sub_CN.txt.3600', ${nf}, ${ns}); exit"

matlab -r "tm_top('../processed_data/subtask_parse_sjtu_wifi/tm/tm_download.sort_ips.ap.gps.5.txt.3600', ${nf}, ${ns}); exit"
matlab -r "tm_top('../processed_data/subtask_parse_sjtu_wifi/tm/tm_upload.sort_ips.ap.gps.5.txt.3600', ${nf}, ${ns}); exit"


# cd ../subtask_plot_TM
# bash ./batch_plot_TM.sh
