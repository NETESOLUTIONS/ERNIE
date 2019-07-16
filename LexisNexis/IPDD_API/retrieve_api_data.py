from zeep import Client
import argparse
import json
import lxml


# IPDD returns security token and expiration info
def get_security_token(ipdd_service_reference,username,password):
    client = Client(ipdd_service_reference)
    result = client.service.LogOn()
    expiration = result['Expiration']
    security_token = result['SecurityToken']
    return expiration,security_token

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

if __name__ == "__main__" :
    #TODO: set up argparse arguments
    # args - username, password, service reference URL
    ipdd_service_reference='http://ipdatadirect.lexisnexis.com/service.svc?wsdl'

    # Log on
    expiration,security_token = get_security_token(ipdd_service_reference,args.username,args.password)
    # Check if new/updated publications are available. If so:
    retrieve_batch_info(ipdd_service_reference,security_token,args.dataset,args.datatype)
        # Request the publications
        # Check for batch status of current batch id in a loop with sleep timer
            # If a batch is ready
                # Retrieve the batch
        # Proceed to next batch id if it exists

    # Logoff
