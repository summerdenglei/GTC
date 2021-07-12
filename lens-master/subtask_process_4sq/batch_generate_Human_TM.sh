#!/bin/bash

city="Airport"
date
echo "  "${city}
for period in 1 10 20 ; do
    echo "  "${period}
    python generate_Human_TM.py ${period} ${city}
done


city="Austin"
date
echo "  "${city}
for period in 1 5 10 20 ; do
    echo "  "${period}
    python generate_Human_TM.py ${period} ${city}
done


city="Manhattan"
date
echo "  "${city}
for period in 1 5 10 20 ; do
    echo "  "${period}
    python generate_Human_TM.py ${period} ${city}
done


city="San_Francisco"
date
echo "  "${city}
for period in 1 5 10 20 ; do
    echo "  "${period}
    python generate_Human_TM.py ${period} ${city}
done

