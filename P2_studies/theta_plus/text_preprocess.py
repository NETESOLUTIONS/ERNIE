import jsd_modules as jm
import pandas as pd
from sqlalchemy import create_engine
from sys import argv

title_abstracts_table = argv[1]
user_name = argv[2]
password = argv[3]

schema = "theta_plus"
sql_scheme = 'postgresql://' + user_name + ':' + password + '@localhost:5432/ernie'
engine = create_engine(sql_scheme)

data_text = pd.read_sql_table(table_name=title_abstracts_table, schema=schema, con=engine)

data_text['all_text'] = data_text["title"] + " " + data_text["abstract_text"]
data_text['processed_all_text'] = data_text["all_text"].swifter.apply(jm.preprocess_text)
data_text['processed_all_text'] = data_text["processed_all_text"].swifter.progress_bar(False).apply(' '.join)
# Use pandas.Series.str.split() to get back original form

# In case the connection times out:
engine = create_engine(sql_scheme)
save_name = title_abstracts_table + '_processed_test'
data_text.to_sql(save_name, con=engine, schema=schema, index=False, if_exists='fail')

print("All Completed.")