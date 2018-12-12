import os,sys
import xml.etree.ElementTree as ET
import parser
import psycopg2
import datetime
import pytz

batchsize=1
ncommit=1000
estimate_nrec=None
process_time=0
processing_time_taken=0

def main():
	in_arr=sys.argv

	if '-filename' not in in_arr:
		print('No filename')
		raise NameError('error: file name is not provided')
	else:
		input_filename=in_arr[in_arr.index('-filename')+1]

	#Start time of the script to calculate performance
	start_time=datetime.datetime.now(pytz.timezone('US/Eastern'))

	# Establishing connection to the database for running upsert commands once the parsing is done
	conn = psycopg2.connect("")
	with conn:
		with conn.cursor() as curs:


			with open(input_filename,'r') as f:
				init_buffer_REC = '<?xml version="1.0" encoding="ISO-8859-1"?>'
				#init_buffer_REC = init_buffer_REC + '<!DOCTYPE dblp SYSTEM "dblp.dtd" [<!ENTITY ouml  "&#246;" ><!ENTITY uuml    "&#252;" ><!ENTITY aacute  "&#225;" >]>'
				init_buffer_REC = init_buffer_REC + '<!DOCTYPE dblp SYSTEM "/erniedev_data8/dblp/dblp.dtd">'
				init_buffer_REC = init_buffer_REC + '<dblp>'
				buffer_REC = ''
				counter=0
				is_rec=False
				status=0
				recordNo=0

				for line in f:
					if ('</article' in line) or ('</proceedings' in line) or ('</inproceedings' in line) or ('</book>' in line) or ('</incollection' in line) or ('</phdthesis' in line) or ('</www' in line) or ('</mastersthesis' in line) or ('</data' in line) or ('</person' in line):
						counter=counter+1
						recordNo+=1
						#buffer_REC=''.join([buffer_REC,line])
						if counter==1:
							separate_records=line.split('>')

							buffer_REC=''.join([buffer_REC,separate_records[0]+'>'])
							buffer_REC=''.join([buffer_REC,'</dblp>'])
							#print(buffer_REC)
							
							if recordNo > 4506000:
								r_parser=parser.Parser()
								r_parser.parse(buffer_REC,input_filename,curs)
								status+=1
								if status%ncommit==0:
									commit(conn,status,recordNo)
									status=0
							if len(separate_records) > 1:
								buffer_REC=init_buffer_REC
								buffer_REC=''.join([buffer_REC,separate_records[1]+'>'])
							counter=0
						else:
							buffer_REC=''.join([buffer_REC,line])


					elif ('<article' in line) or ('<proceedings' in line) or ('<inproceedings' in line) or ('<book ' in line) or ('<incollection' in line) or ('<phdthesis' in line) or ('<www' in line) or ('<mastersthesis' in line) or ('<data' in line) or ('<person' in line):
						#print(line)
						buffer_REC=init_buffer_REC
						buffer_REC=''.join([buffer_REC,line])

					else:
						buffer_REC=''.join([buffer_REC,line])

				if conn is not None:
					commit(conn,status,recordNo)
				
	conn.close()
	
	process_time=str(divmod((datetime.datetime.now(pytz.timezone('US/Eastern'))-start_time).total_seconds(),60))
	log_file=open("performance_log.txt",'a')
	log_file.write(process_time)
	log_file.close()
	print(process_time)

def commit(conn, count, recordNo):
    conn.commit()
    print("At publication #" + str(recordNo) + ".", count, "publications have been upserted by this job.")

if __name__=="__main__":
	main()
