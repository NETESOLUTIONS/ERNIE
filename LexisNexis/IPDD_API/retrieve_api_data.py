from zeep import Client
import argparse
import json
import lxml
from time import sleep


# IPDD returns security token and expiration info
def log_on(ipdd_service_reference,username,password):
    client = Client(ipdd_service_reference)
    result = client.service.LogOn()
    expiration = result['Expiration']
    security_token = result['SecurityToken']
    return expiration,security_token

def log_off(ipdd_service_reference,security_token):
    client = Client(ipdd_service_reference)
    return client.service.LogOff(security_token)

# IPDD returns the number of documents in a batch based on entitlement (or access denied)
def retrieve_batch_info(ipdd_service_reference,security_token,dataset,datatype):
    client = Client(ipdd_service_reference)
    updateRequest = {
        'SecurityToken':security_token,
        'DataSet':dataset,
        'DataType':datatype
    }
    client.service.RetrieveBatchInfo(updateRequest)
    return document_count

# IPDD returns batchList
def request_batch_sized(ipdd_service_reference,security_token,dataset,datatype,batch_size=20000):
    client = Client(ipdd_service_reference)
    updateRequest = {
        'SecurityToken':security_token,
        'DataSet':dataset,
        'DataType':datatype
    }
    client.service.RequestBatchSized(updateRequest,batch_size)
    #need to collect some sort of batch id from each batch in the list of batches here
    return batch_list

# IPDD returns information on batch including Queued, Running, Finished, Failed, Retrieved
def retrieve_batch_status(ipdd_service_reference,security_token,batch_id):
    client = Client(ipdd_service_reference)
    client.service.RetrieveBatchStatus(security_token,batch_id)
    return status_info

# IPDD returns stream containing the data in a single Zip file
# TODO: determine if decompression choices available, alternately, decompress on the fly
def retrieve_batch(ipdd_service_reference,security_token,batch_id,position):
    client = Client(ipdd_service_reference)
    client.service.RetrieveBatch(security_token,batch_id,position)

# TODO: define multithreaded function for parallel calls to parser.sql

if __name__ == "__main__" :
    #TODO: set up argparse arguments
    # args - username, password, service reference URL, batch_size, thread_count, sleep_time, datasets (list accumulator space delimited)
    ipdd_service_reference='http://ipdatadirect.lexisnexis.com/service.svc?wsdl'
    datasets = ['EP','US']
    datatype = 'XML'
    # Log on
    expiration,security_token = log_on(ipdd_service_reference,args.username,args.password)
    # For each type of dataset we are interested in...
    for dataset in args.datasets:
        # Check if new/updated publications are available. If so:
        if retrieve_batch_info(ipdd_service_reference,security_token,dataset,datatype) > 0:
            # Request the publications
            batch_list = request_batch_sized(ipdd_service_reference,security_token,dataset,datatype,batch_size=args.batch_size)
            batch_id = batch_list.pop()
            # Check for batch status of current batch id in a loop with sleep timer
            while retrieve_batch_status(ipdd_service_reference,security_token,batch_id) == "some condition":
                # If a batch is ready
                if batch is ready:
                    # Retrieve the batch
                    retrieve_batch(ipdd_service_reference,security_token,batch_id,position)
                    # Perform parsing by passing returned text data to SQL script
                    # try to pop next batch id, else break the loop
                    try:
                        batch_id = batch_list.pop()
                    except: #TODO: only go to this exception on a null list. For any other error, throw the error.
                        print("No new batches left to consider")
                        break
                # Sleep
                sleep(args.sleep_time)

    # Logoff
    log_off(ipdd_service_reference,security_token)
