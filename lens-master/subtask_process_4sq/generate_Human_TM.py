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
##   python generate_Human_TM.py 1 Austin
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
## process_data
##   output user_hist
def process_data():
    if len(DATA) == 0:
        return

    if DEBUG3:
        print DATA.keys()
    
    this_user = set([])

    #####
    ## get venue data: venues, checkins
    if city == 'Airport' or city == 'SXSW':
        _DATA_ = DATA['VENUE_DATA']
    else:
        _DATA_ = DATA['VENUE_DETAIL']

    for v in _DATA_:

        v_data = _DATA_[v]
        
        #####
        ## get venue data: lat, lng, name, id
        v_info = DATA_INFO[v]

        if DEBUG3:
            #print v_data
            print "  " + str(v_data.keys())

        #####
        ## get "userid" in "checkins"
        for u in v_data['checkins']:
            c_data = v_data['checkins'][u]
            
            if DEBUG3:
                print "    " + str(c_data.keys())

            total_user.add(c_data['userid'])
            this_user.add(c_data['userid']) 
            
            if DEBUG3:
                print "  " + str(v_info.keys())
            
            #####
            ## now we have: <userid, lat, lng, ts, venue, venue_id> in c_data
            c_data['lat'] = v_info['lat']
            c_data['lng'] = v_info['lng']
        
            if v_info.has_key('name'):
                c_data['venue'] = v_info['name']
                c_data['venue_id'] = v_info['id']
            else:
                if DEBUG4:
                    print "XXX: the venue does not have a name!!!!"
                    sys.exit(1)

                c_data['venue'] = city
                c_data['venue_id'] = 0

            if not user_hist.has_key(c_data['userid']):
                ci_dict = dict()
                ci_dict[c_data['ts']] = c_data
                user_hist[c_data['userid']] = ci_dict
            else:
                user_hist[c_data['userid']][c_data['ts']] = c_data

    if DEBUG2:
        print 'user len: ' + str(len(this_user))
        print 'total user: ' + str(len(total_user))
## end process_data
################


################
## generate_TM
def generate_TM():
    TM = dict()
    # Venues = dict()
    for uid in user_hist:
        if len(user_hist[uid]) < 2:
            continue

        sort_hist = sorted(user_hist[uid].items(), key=itemgetter(0)) #, reverse=True)
        hl = len(sort_hist)
        for i in range(0,hl-1):
            src = sort_hist[i][1]['venue_id']
            dst = sort_hist[i+1][1]['venue_id']
            
            # TM
            if not TM.has_key(src):
                dests = dict()
                dests[dst] = 1
                TM[src] = dests
            else:
                if not TM[src].has_key(dst):
                    TM[src][dst] = 1
                else:
                    TM[src][dst] += 1
            
            # Venues
            # if not Venues.has_key(src):
            #     Venues[src] = sort_hist[i][1]['lat'] + 90 + sort_hist[i][1]['lng'] + 180
            # if not Venues.has_key(dst):
            #     Venues[dst] = sort_hist[i+1][1]['lat'] + 90 + sort_hist[i+1][1]['lng'] + 180

    # sort_venues = sorted(Venues.items(), key=itemgetter(1))
    f_TM = open(OUTPUT_DIR + 'TM_' + city + '_period' + str(period) + '_' + str(period_cnt) + '.txt', 'w')
    al = len(sort_venues)
    for i in range(al):
        src = sort_venues[i][0]
        if not TM.has_key(src):
            for j in range(al):
                f_TM.write("0, ")
        else:
            for j in range(al):
                dst = sort_venues[j][0]
                if not TM[src].has_key(dst):
                    f_TM.write("0, ")
                else:
                    f_TM.write(str(TM[src][dst]) + ", ")
        f_TM.write("\n")
    f_TM.write("\n") 
    f_TM.close()
## end generate_TM
################


################
## map_lat_lng_to_line
def map_lat_lng_to_line(lat, lng):
    return lat + 90 + lng + 180
    # return (lat + 90) + (lng + 180) * 400
## map_lat_lng_to_line
################

################################################################################

################
## Constant
################


################
## Variables
################
INPUT_VENUE_INFO_DIR = '../data/4sq/city_info/'
INPUT_VENUE_DATA_DIR = ''
OUTPUT_DIR = '../processed_data/subtask_process_4sq/TM/'
FILE_VENUE_DATA = ''

total_user = set([])
user_hist = dict()
period = 1 
city = "Airport"


################
## Input
################
if DEBUG2:
    print sys.argv
if len(sys.argv) == 2:
    period = int(sys.argv[1])
    city = "Airport"
elif len(sys.argv) == 3:
    period = int(sys.argv[1])
    city = sys.argv[2]
else:
    print 'wrong number of input: ' + str(len(sys.argv))
    sys.exit(1)

INPUT_VENUE_DATA_DIR = '../data/4sq/' + city + '/'
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
## read City Info
#################
DATA_INFO = load_data(INPUT_VENUE_INFO_DIR + '4SQ_' + city + '_INFO')

## Venues: (<id> <location - used for sorting> <venue>)
Venues = []
for v in DATA_INFO:
    ## sort by (lat, lng)
    # Venues.append( (DATA_INFO[v]['id'], map_lat_lng_to_line(float(DATA_INFO[v]['lat']), float(DATA_INFO[v]['lng']) ), v) )
    ## sort by popularity
    Venues.append( (DATA_INFO[v]['id'], float(DATA_INFO[v]['checkinsCount']), v) )

## sorted by the location of the venues
# sort_venues = sorted(Venues, key=itemgetter(1))
sort_venues = sorted(Venues, key=itemgetter(1), reverse=True)

## write sorted venues to the file
fh = open(OUTPUT_DIR + city + '_sorted.txt', 'w')
al = len(sort_venues)
for i in range(al):
    v = sort_venues[i][2]
    if not ('city' in DATA_INFO[v].keys()):
        if DEBUG0:
            print DATA_INFO[v].keys()
            print "  " + str(DATA_INFO[v]['name'])

        str_tmp = str(DATA_INFO[v]['name']) + '|||' + str(DATA_INFO[v]['lat']) + "|||" + str(DATA_INFO[v]['lng']) + "|||" + str(DATA_INFO[v]['checkinsCount'])
    else:
        str_tmp = str(DATA_INFO[v]['city']) + '|||' + str(DATA_INFO[v]['lat']) + "|||" + str(DATA_INFO[v]['lng']) + "|||" + str(DATA_INFO[v]['checkinsCount'])
    # print str_tmp
    fh.write(str_tmp + '\n')
fh.close()

if DEBUG2:
    print "done load venues info: " + str(len(DATA_INFO))


#################
# go over all folders and read files
#################
if DEBUG2:
    print "go over all folders and read files\n"

## Each folder stores different period of data.
## To get snapshots of TM, we need to parse the folder name
pre_date = -1
period_timedelta = datetime.timedelta(period)
period_cnt = 0
for folder in sort_listdir(INPUT_VENUE_DATA_DIR):
    if DEBUG2:
        print
        print folder
        # print os.listdir(INPUT_VENUE_DATA_DIR + folder)

    m = re.match('(\d+)-(\d+)-(\d+).*(\d+):(\d+):(\d+\.\d+)_' + city, folder)
    if DEBUG0:
        print "    " + str(m.group(1)) + "|||" + str(m.group(2)) + "|||" + str(m.group(3)) + "|||" + str(m.group(4)) + "|||" + str(m.group(5)) + "|||" + str(m.group(6))

    if pre_date == -1:
        ## the first snapshot
        pre_date = datetime.date(int(m.group(1)), int(m.group(2)), int(m.group(3)))
        if DEBUG0:
            print pre_date
    else:
        new_date = datetime.date(int(m.group(1)), int(m.group(2)), int(m.group(3)))
        diff_time = new_date - pre_date
        if DEBUG0:
            print diff_time

        if diff_time >= period_timedelta:
            ## We have got all data for the previous snapshot in "user_hist".
            ## Generate and output TM of current snapshot.
            if DEBUG1:
                print ">>>>>>>> new period"

            generate_TM()
            period_cnt += 1
            user_hist = dict()
            pre_date = new_date

    ## read the data of the current folder
    DATA = load_data(INPUT_VENUE_DATA_DIR + folder + FILE_VENUE_DATA)
    process_data()

generate_TM()
period_cnt += 1
    
sys.exit(1)





