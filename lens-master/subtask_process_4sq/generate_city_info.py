######################################################
## Author: Yi-Chao Chen
## 2013.09.20 @ UT Austin
##
## - Input:
##   1. period: 
##      The period of time used to generate a snapshot of Human Traffic Matrix (in days).
##   2. City:
##      The city used to generate Human TM.
##
## - e.g.
##   python generate_city_info.py Manhattan
##
######################################################

import sys
import os
from numpy import array
import numpy
from operator import itemgetter
import locale
# import Gnuplot
from subprocess import call
import re

sys.path.append("../utils")
from data import *
from utils import *
from googlemaps import GoogleMaps


################
## DEBUG
################
DEBUG0 = False       ## Don't show
DEBUG1 = True        ## print for debug
DEBUG2 = True        ## Program Flow
DEBUG3 = False       ## Data hierarchy
DEBUG4 = True        ## Should not happen


################
## Functions
################


################
## Variables
################
INPUT_DIR = '../data/4sq/'
OUTPUT_DIR = '../processed_data/subtask_process_4sq/combined_city_info/'
city = "Manhattan"
city_info = dict()


################
## Input
################
if DEBUG2:
    print sys.argv
if len(sys.argv) == 2:
    city = sys.argv[1]
else:
    print 'wrong number of input: ' + str(len(sys.argv))
    sys.exit(1)

if city == 'Airport':
    FILE_VENUE_DATA = '/4SQ_VENUE_DETAILS_' + city + ".gz"
else:
    FILE_VENUE_DATA = '/4SQ_VENUE_TRENDS_' + city + ".gz"


################
## MAIN starts here
################
if DEBUG2:
    print "city: " + city
    print "-------------"

force_utf8_hack()


#################
## go over all folders and read files
#################
for folder in sort_listdir(INPUT_DIR + city):
    if DEBUG2:
        print
        print 'load: ' + INPUT_DIR + city + '/' + folder + FILE_VENUE_DATA


    m = re.match('(\d+)-(\d+)-(\d+).*(\d+):(\d+):(\d+\.\d+)_' + city, folder)
    if DEBUG0:
        print "  " + str(m.group(1)) + "|||" + str(m.group(2)) + "|||" + str(m.group(3)) + "|||" + str(m.group(4)) + "|||" + str(m.group(5)) + "|||" + str(m.group(6))


    ################
    ## load the file
    ################
    DATA = load_data(INPUT_DIR + city + '/' + folder + FILE_VENUE_DATA)
    for v in DATA['VENUE_INFO']:
        v_info = DATA['VENUE_INFO'][v];

        if DEBUG0:
            print v_info.keys()

        city_venue = dict()
        city_venue['lat']  = v_info['lat']
        city_venue['lng']  = v_info['lng']
        city_venue['id']   = v_info['id']
        city_venue['name'] = v_info['name']
        city_venue['checkinsCount'] = v_info['checkinsCount']
        
        city_info[v] = city_venue


#################
## Output to the file
#################
store_data(OUTPUT_DIR + '4SQ_' + city + '_INFO', city_info)


