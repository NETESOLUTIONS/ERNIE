#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Thu Oct 18 10:04:09 2018

This is a project to map text file into database

@author: siyu
"""

#import psycopg2
import datetime as dt
from sqlalchemy import create_engine
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy import Column, Integer, String, DateTime
from sqlalchemy.orm import sessionmaker

#Connect to database
engine = create_engine('postgresql+psycopg2:///ernie',echo=True)
Session = sessionmaker(bind=engine)
Base=declarative_base()

#Define table into python class object
class DAIS(Base):
    __tablename__='dais'
    
    dais_id = Column(String, primary_key=True,nullable=False)
    source_id = Column(String, primary_key=True,nullable=False)
    full_name = Column(String)
    last_name = Column(String)
    first_name = Column(String)
    seq_no = Column(Integer,nullable=False)
    source_filename = Column(String)
    last_updated_time = Column(DateTime, onupdate=dt.datetime.now)
    
