import cPickle
import gzip

def load_data(FILE_NAME):
	# print 'load data: ' + FILE_NAME
	LOADED_DATA = {}
	try:
		if FILE_NAME.endswith('.gz'):
			# print 'try opening...'
			FILE = gzip.open(FILE_NAME, 'rb')
		else:
			FILE = open(FILE_NAME, 'r')
		LOADED_DATA = cPickle.load(FILE)
		FILE.close()
		# print "DATA LOADED at " + FILE_NAME
	except cPickle.PickleError:
		print cPickle.PickleError
	except IOError:
		print IOError 
	except:
		print "cannot load " + FILE_NAME
		pass	
	return LOADED_DATA

def store_data(FILE_NAME, DATA_TOSTORE):
	try:
		FILE = open(FILE_NAME, 'w+')
		cPickle.dump(DATA_TOSTORE, FILE)
		FILE.close()
		print "DATA STORED at " + FILE_NAME 
	except:
		print "cannot store it!"
		pass

