#!/bin/bash

city="Manhattan"
date
echo "  "${city}
python generate_city_info.py ${city}
rm ~/anomaly_compression/data/4sq/city_info/4SQ_${city}_INFO
ln -s  ~/anomaly_compression/processed_data/subtask_process_4sq/combined_city_info/4SQ_${city}_INFO ~/anomaly_compression/data/4sq/city_info/4SQ_${city}_INFO 


city="Austin"
date
echo "  "${city}
python generate_city_info.py ${city}
rm ~/anomaly_compression/data/4sq/city_info/4SQ_${city}_INFO
ln -s  ~/anomaly_compression/processed_data/subtask_process_4sq/combined_city_info/4SQ_${city}_INFO ~/anomaly_compression/data/4sq/city_info/4SQ_${city}_INFO 


city="San_Francisco"
date
echo "  "${city}
python generate_city_info.py ${city}
rm ~/anomaly_compression/data/4sq/city_info/4SQ_${city}_INFO
ln -s  ~/anomaly_compression/processed_data/subtask_process_4sq/combined_city_info/4SQ_${city}_INFO ~/anomaly_compression/data/4sq/city_info/4SQ_${city}_INFO 

