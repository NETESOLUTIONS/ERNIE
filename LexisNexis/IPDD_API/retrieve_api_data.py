from zeep import Client
import argparse
import json
import lxml



#TODO: set up argparse arguments
# args - username, password, service reference URL
ipdd_service_reference='http://ipdatadirect.lexisnexis.com/service.svc?wsdl'


# TODO: implement code for scenario 1 below.
# To discuss: whether to actually download XML locally or just stream process batches without local duplication of XML data
client = Client(ipdd_service_reference)
client.service.LogOn()
# NOTE: looks like JSON parsing will be key here when working with the API - parse for the security token and be wary of the expiration


request =  {
    'SecurityToken':'ad0767af-881a-4501-8c5b-47a8056a0a1b',
    'Authority':'US',
    'Number':'6000000',
    'Kind':'A',
}
client.service.RetrievePublication(request)
