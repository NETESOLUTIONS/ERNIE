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

# Close IPDD session
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
    client.service.RetrieveBatchInfo(updateRequest) #TODO: check/parse whats returned here
    return document_count

# IPDD returns batchList
def request_batch_sized(ipdd_service_reference,security_token,dataset,datatype,batch_size=20000):
    client = Client(ipdd_service_reference)
    updateRequest = {
        'SecurityToken':security_token,
        'DataSet':dataset,
        'DataType':datatype
    }
    client.service.RequestBatchSized(updateRequest,batch_size) #TODO: check/parse whats returned here
    return batch_list

# IPDD returns information on batch including Queued, Running, Finished, Failed, Retrieved
def retrieve_batch_status(ipdd_service_reference,security_token,batch_id):
    client = Client(ipdd_service_reference)
    client.service.RetrieveBatchStatus(security_token,batch_id)
    return status_info #TODO: check/parse whats returned here

# IPDD returns stream containing the data in a single Zip file
# TODO: determine if decompression choices available, alternately, decompress on the fly
def retrieve_batch(ipdd_service_reference,security_token,batch_id,position):
    client = Client(ipdd_service_reference)
    client.service.RetrieveBatch(security_token,batch_id,position) #TODO: check/parse whats returned here

# TODO: define multithreaded function for parallel calls to parser.sql

if __name__ == "__main__" :
    # Read in available arguments
    parser = argparse.ArgumentParser(description='''
     This script interfaces with the AlphaVantage API, collects data, performs the desired transformations,
      and loads the data into the local PostgreSQL database via a peer connection.
    ''', formatter_class=argparse.RawTextHelpFormatter)
    parser.add_argument('-U','--ipdd_username',help='IPDD API username',type=str,required=True)
    parser.add_argument('-W','--ipdd_password',help='IPDD API password',type=str,required=True)
    parser.add_argument('-R','--ipdd_service_reference',help='IPDD service reference address',type=str,required=True)
    parser.add_argument('-b','--batch_size',help='Desired batch size on API retrievals',type=int,default=20000)
    parser.add_argument('-t','--thread_count',help='Desired number of threads for processing returned data',type=int,default=1)
    parser.add_argument('-s','--sleep_time',help='Amount of ms to sleep in between batch info calls',type=int,default=300000)
    parser.add_argument('-D','--datasets', type=str, nargs='+',help='Space delimited list of target datasets to collect patent data for')
    args = parser.parse_args()
    datatype = 'XML'
    # Log on
    expiration,security_token = log_on(ipdd_service_reference,args.username,args.password)
    # For each type of dataset we are interested in...
    for dataset in args.datasets:
        # Check if new/updated publications are available. If so:
        if retrieve_batch_info(ipdd_service_reference,security_token,dataset,datatype) > 0:
            # Request the publications
            batch_list = request_batch_sized(ipdd_service_reference,security_token,dataset,datatype,batch_size=args.batch_size)
            batch_id = batch_list.pop(0) #update to refer to id specifically
            # Check for batch status of current batch id in a loop with sleep timer
            while retrieve_batch_status(ipdd_service_reference,security_token,batch_id) == "some condition":
                # If a batch is ready
                if batch is ready:
                    # Retrieve the batch
                    retrieve_batch(ipdd_service_reference,security_token,batch_id,position)
                    # Perform parsing by passing returned text data to SQL script
                    # try to pop next batch id, else break the loop
                    try:
                        batch_id = batch_list.pop(0)
                    except: #TODO: only go to this exception on a null list. For any other error, throw the error.
                        print("No new batches left to consider")
                        break
                # Sleep
                sleep(args.sleep_time)

    # Logoff
    log_off(ipdd_service_reference,security_token)
