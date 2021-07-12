import json, urllib, urllib2
import sys, os, time
import cPickle
import random
import signal
import locale
from datetime import datetime
from operator import itemgetter

#from scipy import * #linspace, polyval, polyfit, sqrt, stats, randn
from scipy import linspace, polyval, polyfit, sqrt, stats, randn
from pylab import * #xlabel, ylabel, plot, title, show , legend
#from pylab import xlabel, ylabel, plot, title, show , legend
import math
from math import *
import numpy

def shuffle_exponents(POP, USR, CIC, FLOW, DEGREE, FRIEND):

	POP += (randn())
	USR += (randn())
	CIC += (randn())
	FLOW += (randn())
	DEGREE += (randn())
	FRIEND += (randn())

	return [POP, USR, CIC, FLOW, DEGREE, FRIEND]


def shuffle_exponents_bound(POP, USR, CIC, FLOW, DEGREE, FRIEND):

        POP = ((random()-0.5)/10) % 2 
        USR = ((random()-0.5)/10) % 2 
        CIC = ((random()-0.5)/10) % 2 
        FLOW = ((random()-0.5)/10) % 2 
        DEGREE = ((random()-0.5)/10) % 2 
        FRIEND = ((random()-0.5)/10) % 2 

        return [POP, USR, CIC, FLOW, DEGREE, FRIEND]



def get_entropy(list1):
	entropy = 0.0
	val1 = set(list1)
	for val in val1:
		px = list1.count(val) / (0.0 + len(list1))
		if px != 0:
			entropy += px * log(px)
	return -1.0*entropy


def get_relative_entropy(list1, list2):
	rel_entropy = 0.0
	val1 = set(list1)
	for val in val1:		
		px = list1.count(val) / (0.0 + len(list1))
		qx = list2.count(val) / (0.0 + len(list2))
		if px != 0 and qx != 0:
			rel_entropy += px * log(px / qx)	
	return rel_entropy

def mylog(num):
	if num > 0:
		return math.log(num)
	else:
		return 0

def make_list(TM1):
	traff1 = []
	for src in TM1:
		for dst in TM1[src]:
			traff1.append(TM1[src][dst])
	return traff1

def make_two_lists2(TM1, TM2):
        all_nodes = set()
        for src in TM1:
                all_nodes.add(src)
                for dst in TM1[src]:
                        all_nodes.add(dst)
        for src in TM2:
                all_nodes.add(src)
                for dst in TM2[src]:
                        all_nodes.add(dst)
        traff_1 = []
        traff_2 = []
        for src in all_nodes:
                for dst in all_nodes:
                        if TM1.has_key(src) and TM1[src].has_key(dst):
                                traff_1.append(TM1[src][dst])
                        else:
                                traff_1.append(0)
                        if TM2.has_key(src) and TM2[src].has_key(dst):
                                traff_2.append(TM2[src][dst])
                        else:
                                traff_2.append(0)
        #size_TM = len(all_nodes)
        #TM_mat1 = array(traff_1).reshape(len(traff_1) / size_TM, size_TM)
        #TM_mat1 = matrix(TM_mat1)
        #TM_mat2 = array(traff_2).reshape(len(traff_2) / size_TM, size_TM)
        #TM_mat2 = matrix(TM_mat2)
        #print TM_mat1.shape, TM_mat2.shape
        return traff_1, traff_2


def make_two_lists(TM1, TM2):
        all_nodes = set()
        for src in TM1:
                all_nodes.add(src)
                for dst in TM1[src]:
                        all_nodes.add(dst)
        for src in TM2:
                all_nodes.add(src)
                for dst in TM2[src]:
                        all_nodes.add(dst)
        traff_1 = []
        traff_2 = []
        for src in all_nodes:
                for dst in all_nodes:
                        if src == dst:
                                traff_1.append(0)
                                traff_2.append(0)
                                continue
                        if TM1.has_key(src) and TM1[src].has_key(dst):
                                traff_1.append(TM1[src][dst])
                        else:
                                traff_1.append(0)
                        if TM2.has_key(src) and TM2[src].has_key(dst):
                                traff_2.append(TM2[src][dst])
                        else:
                                traff_2.append(0)
        #size_TM = len(all_nodes)
        #TM_mat1 = array(traff_1).reshape(len(traff_1) / size_TM, size_TM)
        #TM_mat1 = matrix(TM_mat1)
        #TM_mat2 = array(traff_2).reshape(len(traff_2) / size_TM, size_TM)
        #TM_mat2 = matrix(TM_mat2)
        #print TM_mat1.shape, TM_mat2.shape
        return traff_1, traff_2

def make_matrix(TM_dict):
	all_nodes = set()
	for src in TM_dict:
		all_nodes.add(src)
		for dst in TM_dict[src]:
			all_nodes.add(dst)
	traff_list = []
	for src in all_nodes:
		for dst in all_nodes:
			if src == dst:
				traff_list.append(0)
				continue
			if TM_dict.has_key(src) and TM_dict[src].has_key(dst):
				traff_list.append(TM_dict[src][dst])
			else:
				traff_list.append(0)
	size_TM = len(all_nodes)
	TM = array(traff_list).reshape(len(traff_list) / size_TM, size_TM)
	TM = matrix(TM)
	print TM.shape
	return TM

def matrix_low_rank(A, n=10000):
	u, s, vh = numpy.linalg.svd(A)
	sum_s = sum(s) + 0.0
	top_s = sorted(s, reverse=1)

	topsq_s = []
	for i in range(0, len(top_s)):
		topsq_s.append(pow(top_s[i], 2))
	sumsq_s = sum(topsq_s) + 0.0

	num_sing_val = [0]
	rel_approx_error = [1.0]
	for i in range(1, min(len(top_s), n)):
		num_sing_val.append(i)
		rel_approx_error.append(1.0 - sum(top_s[0:i]) / sum_s)
	return num_sing_val, rel_approx_error	

def matrix_low_rank_sq(A, n=10000):
        u, s, vh = numpy.linalg.svd(A)
        sum_s = sum(s) + 0.0
        top_s = sorted(s, reverse=1)

        topsq_s = []
        for i in range(0, len(top_s)):
                topsq_s.append(pow(top_s[i], 2))
        sumsq_s = sum(topsq_s) + 0.0

        num_sing_val = [0]
        rel_approx_error = [1.0]
        for i in range(1, min(len(top_s), n)):
                num_sing_val.append(i)
                rel_approx_error.append(1.0 - sum(topsq_s[0:i]) / sumsq_s)
        return num_sing_val, rel_approx_error


def matrix_nnz(A, eps=1e-9):
	count = 0
	for i in A:
		#print i
		for j in numpy.array(i)[0]:
			if abs(j) > eps:
				count += 1
	return count 

def matrix_rank(A, eps=1e-9):
	u, s, vh = numpy.linalg.svd(A)
	#print s
	return len([x for x in s if abs(x) > eps])

def get_corr_coef(X_list, Y_list):
	corr_coef = stats.pearsonr(X_list, Y_list)
	return corr_coef[0]


def plot_linear_regress(X_list, Y_list, str_title, str_xlabel, str_ylabel):
	corr_coef = stats.pearsonr(X_list, Y_list)
	str_title = str_title + ' (corr coef=%.2f)' % corr_coef[0]
	print str_title
	(ar, br) = polyfit(X_list, Y_list, 1)
	Y_regress = polyval([ar ,br], X_list)	

	Y_20pos = []
	Y_20neg = []
	for y_val in Y_regress:
		Y_20pos.append(y_val * 1.2)
		Y_20neg.append(y_val * 0.8)

	title(str_title)
	grid('True')
	xlabel(str_xlabel)
	ylabel(str_ylabel)
	plot(X_list, Y_list, 'go')
	plot(X_list, Y_regress, 'r.--')
	plot(X_list, Y_20pos, 'c.--')
	plot(X_list, Y_20neg, 'c.--')
	#legend(['original', 'regression', '+20%', '-20%'])
	show()
	raw_input()


def print_top(dic, n):
        sorted_dic = sorted(dic.items(), key=itemgetter(1), reverse=True)
        n = min(n, len(dic))
        for i in range(0,n):
                print str(i+1) + "\t" + sorted_dic[i][0] + "\t" + str(sorted_dic[i][1])

def force_utf8_hack():
  reload(sys)
  sys.setdefaultencoding('utf-8')
  for attr in dir(locale):
    if attr[0:3] != 'LC_':
      continue
    aref = getattr(locale, attr)
    locale.setlocale(aref, '')
    (lang, enc) = locale.getlocale(aref)
    if lang != None:
      try:
        locale.setlocale(aref, (lang, 'UTF-8'))
      except:
        os.environ[attr] = lang + '.UTF-8'

def total_hours(_timedelta):
	return _timedelta.days * 24.0 + _timedelta.seconds / (60.0 * 60.0) 

def mean(numberList):
        floatNums = [float(x) for x in numberList]
        return sum(floatNums) / len(numberList)

def make_cdf_data_abs(raw_data):
        float_data = []
        for data in raw_data:
                float_data.append(float(data))
        float_data.sort()

        prob = 0
        cdf_data = []
        for data in float_data:
                prob += 1.0 # / len(float_data)
                cdf_data.append(prob)
        return [float_data, cdf_data]

def make_cdf_data(raw_data):
        float_data = []
        for data in raw_data:
                float_data.append(float(data))
        float_data.sort()

        prob = 0
        cdf_data = []
        for data in float_data:
                prob += 1.0 / len(float_data)
                cdf_data.append(prob)

        return [float_data, cdf_data]


def get_world_latlng():
        # open and read file
        # generate lat list and lng list
        fd = open('./world.dat', 'r')
        lat_list = []
        lng_list = []
        for line in fd.readlines():
                if line.find('#') == -1 and len(line) > 1:
                        line = line.rstrip()
                        line = line.split()
                        #print line
                        #print line[0], line[1]
                        lat_list.append(float(line[0]))
                        lng_list.append(float(line[1]))
        #print lat_list
        return [lat_list, lng_list]

def sort_listdir(path):
    """
    Returns the content of a directory by showing directories first
    and then files by ordering the names alphabetically
    """
    dirs = sorted([d for d in os.listdir(path) if os.path.isdir(path + os.path.sep + d)])
    dirs.extend(sorted([f for f in os.listdir(path) if os.path.isfile(path + os.path.sep + f)]))

    return dirs


def is_in_USA(pair1, pair2):
    if len(pair1) != 2 or len(pair2) != 2:
        return False
    lat1 = pair1[0]
    long1 = pair1[1]
    lat2 = pair2[0]
    long2 = pair2[1]

    if lat1 < -90 or lat1 > 90 or lat2 < -90 or lat2 > 90 or long1 < -180 or long1 > 180 or long2 < -180 or long2 > 180:
        return False

    if lat1 < 23.24 or lat1 > 70.72:
   	return False
    if long1 < -169.10 or long1 > -53.43:
	return False
    if lat2 < 23.24 or lat2 > 70.72:
   	return False
    if long2 < -169.10 or long2 > -53.43:
	return False

    return True

def distance_on_sphere(pair1, pair2):

    if len(pair1) != 2 or len(pair2) != 2:
    	return -1

    lat1 = pair1[0]
    long1 = pair1[1]
    lat2 = pair2[0]
    long2 = pair2[1]

    if lat1 < -90 or lat1 > 90 or lat2 < -90 or lat2 > 90 or long1 < -180 or long1 > 180 or long2 < -180 or long2 > 180:
    	return -1

    # Convert latitude and longitude to 
    # spherical coordinates in radians.
    degrees_to_radians = math.pi/180.0
        
    # phi = 90 - latitude
    phi1 = (90.0 - lat1)*degrees_to_radians
    phi2 = (90.0 - lat2)*degrees_to_radians
        
    # theta = longitude
    theta1 = long1*degrees_to_radians
    theta2 = long2*degrees_to_radians
        
    # Compute spherical distance from spherical coordinates.
        
    # For two locations in spherical coordinates 
    # (1, theta, phi) and (1, theta, phi)
    # cosine( arc length ) = 
    #    sin phi sin phi' cos(theta-theta') + cos phi cos phi'
    # distance = rho * arc length
    
    try:
    	cos = (math.sin(phi1)*math.sin(phi2)*math.cos(theta1 - theta2) + math.cos(phi1)*math.cos(phi2))
    	arc = math.acos( cos )
    except:
	return 0

    # Remember to multiply arc by the radius of the earth 
    # in your favorite set of units to get length.
    return arc * 6373 # kilometer
    #return arc * 3960 # mile

# chop the end
def rchop(thestring, ending):
  if thestring.endswith(ending):
    return thestring[:-len(ending)]
  return thestring

# find the first key for given value
def find_key(dic, val):
    """return the key of dictionary dic given the value"""
    return [k for k, v in dic.iteritems() if v == val][0]

# merget two dictionaries
def merge(d1, d2, merge=lambda x,y:y):
    """
    Merges two dictionaries, non-destructively, combining 
    values on duplicate keys as defined by the optional merge
    function.  The default behavior replaces the values in d1
    with corresponding values in d2.  (There is no other generally
    applicable merge strategy, but often you'll have homogeneous 
    types in your dicts, so specifying a merge technique can be 
    valuable.)

    Examples:

    >>> d1
    {'a': 1, 'c': 3, 'b': 2}
    >>> merge(d1, d1)
    {'a': 1, 'c': 3, 'b': 2}
    >>> merge(d1, d1, lambda x,y: x+y)
    {'a': 2, 'c': 6, 'b': 4}

    """
    result = dict(d1)
    for k,v in d2.iteritems():
        if k in result:
            result[k] = merge(result[k], v)
        else:
            result[k] = v
    return result


# Detect Language of given text
def detect_language(
        text,
        userip=None,
        referrer="http://stackoverflow.com/q/4545977/4279",
        api_key=None):        
                              
        query = {'q': text.encode('utf-8') if isinstance(text, unicode) else text}
        if userip: query.update(userip=userip)
        if api_key: query.update(key=api_key)

        url = 'https://ajax.googleapis.com/ajax/services/language/detect?v=1.0&%s'%(urllib.urlencode(query))

        request = urllib2.Request(url, None, headers=dict(Referer=referrer))
        d = json.load(urllib2.urlopen(request))

        if d['responseStatus'] != 200 or u'error' in d['responseData']:
                #raise IOError(d)
                return ''                                                                  
        return [d['responseData']['language'], d['responseData']['confidence']]

