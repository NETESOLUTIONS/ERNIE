#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Thu Oct 18 11:21:57 2018

@author: siyu
"""

import datetime as dt
from DAIS_mapping import DAIS, Session, engine, Base

class Parser:

    #parser data from text file
    def data_load(self, input_filename):
        #generate database schema
        Base.metadata.create_all(engine)

        #create a new session
        session = Session()
        session.execute("SET search_path TO public")
        session.execute("TRUNCATE TABLE dais")

        dais_data=[]
        with open(input_filename,'r') as f:
            next(f)
            for raw in f:
                record={}
                record['dais_id']=raw.split('|')[1]
                record['source_id']=raw.split('|')[0]
                record['full_name']=raw.split('|')[2]
                record['seq_no']=raw.split('|')[3]
                record['source_filename']='UT_DAISID.txt'
                record['last_updated_time']=dt.datetime.now()
                if len(raw.split('|')[2].split(','))>1:
                    record['last_name']=raw.split('|')[2].split(',')[0].strip()
                    record['first_name']=raw.split('|')[2].split(',')[1].strip()
                else:
                    record['last_name']=raw.split('|')[2].split(',')[0].strip()
                    record['first_name']=None
                dais_data.append(record)


                #Load data into database and close the session
                if len(dais_data)==10000:
                    try:
                        for data in dais_data:
                            row=DAIS(**data)
                            session.add(row)
                        session.commit()
                    except Exception as e:
                        session.rollback()
                        print(str(e))

                    dais_data=[]

            try:
                for data in dais_data:
                    row=DAIS(**data)
                    session.add(row)
                session.commit()
            except Exception as e:
                session.rollback()
                print(str(e))
            finally:
                session.close()

