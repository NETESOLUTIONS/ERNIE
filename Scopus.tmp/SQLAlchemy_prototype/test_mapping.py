#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Tue Mar  5 15:11:13 2019

@author: siyu
"""

#import psycopg2
#import datetime as dt
from sqlalchemy import create_engine
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy import Column, Integer, String
from sqlalchemy.orm import sessionmaker

#Connect to database
engine = create_engine('postgresql+psycopg2:///ernie',echo=True)
Session = sessionmaker(bind=engine)
Base=declarative_base()

#Define table into python class object
class scopus_documents(Base):
    __tablename__='scopus_documents'
    scopus_id = Column(String,primary_key=True, nullable=False)
    pmid=Column(String)
    title = Column(String)
    publication_name = Column(String)
    document_type=Column(String)
    issn = Column(String)
    volume = Column(String)
    first_page = Column(String)
    last_page = Column(String)
    publication_year = Column(Integer)
    publication_month = Column(Integer)
    publication_day = Column(Integer)
    doi = Column(String)

class scopus_authors(Base):
    __tablename__='scopus_authors'
    scopus_id = Column(String,primary_key=True, nullable=False)
    author_id = Column(String,primary_key=True,nullable=False)
    author_initial=Column(String)
    author_surname = Column(String)
    author_indexed_name= Column(String)
    seq=Column(String)

class scopus_references(Base):
    __tablename__='scopus_references'
    scopus_id = Column(String,primary_key=True,nullable=False)
    ref_id=Column(String,primary_key=True,nullable=False)
    source_title=Column(String)
    publication_year = Column(String)

class scopus_addresses(Base):
    __tablename__='scopus_addresses'
    scopus_id = Column(String,primary_key=True,nullable=False)
    afid=Column(String,primary_key=True,nullable=False)
    organization=Column(String)
    city=Column(String)
    country = Column(String)
