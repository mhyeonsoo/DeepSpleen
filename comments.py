import sys
import getopt
import dicom
import os

#total = len(sys.argv)
#print("the total number of args is :%d " % total)
#print("argues are %s %s",sys.argv[0],sys.argv[1])
try:
	ds = dicom.read_file(sys.argv[1])
	ds.PatientID = "01-100-C3D1"
	Subject_id = ds.PatientID
	#Subject_id_modi = Subject_id.replace("-", "_")
	#Session_id = Subject_id
	Session_id = Subject_id+"-baseline"
	#Session_id_modi = Session_id.replace("-", "_")
	cmd_for_Pcomments = 'dcmodify -i "(0010,4000)=Project:HEM1538 Subject:'+Subject_id+' Session:'+Session_id+'" '+sys.argv[1] 
	os.system(cmd_for_Pcomments)
	#ds.PatientComments="Project:HEM1538 Subject:"+Subject_id+" Session:"+Session_id
	# = Project:HEM1538 Subject:ds.PatientName Session:ds.PatientID
	print(sys.argv[1]+" is commented")
except:
#if (ds.SeriesDescription == 'Dose Report' or ds.SeriesDescription or 'Exam/Series Text Page' or ds.SeriesDescription == 'Screen Save'):
	print sys.argv[1]+"is not a real image file"

# call back


