## This script will be used to generate xml data that will allow postgres data to be indexed in solr ##

import sys; import re; import subprocess

table='';database='';port='';user='';id_tag='';fields=[]
for i in range(0,len(sys.argv)):
    if sys.argv[i][0]=='-':
        option=sys.argv[i]
        if option[1:] in ['field','f']:
            fields+=[sys.argv[i+1]]
        elif option[1:] in ['id','i']:
            id_tag=sys.argv[i+1]
	elif option[1:] in ['table','t']:
            table=sys.argv[i+1]
        elif option[1:] in ['database','d']:
            database=sys.argv[i+1]
        elif option[1:] in ['port','p']:
            port=sys.argv[i+1]
        elif option[1:] in ['user','U']:
            user=sys.argv[i+1]

# create injection code for db-data-config
db_config_xml_front_end='''
<dataConfig>
  <dataSource type="JdbcDataSource" 
              driver="org.postgresql.Driver"
              url="jdbc:postgresql://localhost:%s/%s" 
              user="%s" />
  <document>\n
'''%(port,database,user)
db_config_xml_fields='''
    <entity name="id" 
            query="select %s '''%(id_tag)+', '.join(f for f in fields)+''' from %s">\n'''%(table)
db_config_xml_fields+='''    <field column="%s" name="id"/>\n'''%(id_tag)
db_config_xml_fields+='\n'.join(['''    <field column="%s" name="%s"/>'''%(f,f) for f in fields])
db_config_xml_backend='''
    </entity>
  </document>
</dataConfig>
'''
db_config_xml=db_config_xml_front_end+db_config_xml_fields+db_config_xml_backend
#print db_config_xml
with open('db-data-config.xml','wb') as db_file:
    db_file.write(db_config_xml)

# create injection code for managed-schema
managed_schema_xml='''   <field name="id" type="string" indexed="true" stored="true" required="true" multiValued="false" />\n'''
managed_schema_xml+='\n'.join(['''   <field name="%s" type="text_general" indexed="true" stored="true" />'''%(f) for f in fields]) 
#print managed_schema_xml
managed_xml=open('managed-schema-temp').read()
managed_xml=re.sub(r'#INSERT_FIELDS#',managed_schema_xml,managed_xml)
with open('managed-schema', 'wb') as ms:
    ms.write(managed_xml)
