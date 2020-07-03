Edited notes from Elsevier on Scopus data model:

* The list of document IDs of the cited references are not guaranteed to be unique; it may be for instance that 2 references have the same ID. It is uncommon, but it happens, and we suggest to deduplicate (i.e. only maintain a citation link between two documents once).
    * If you need to maintain the duplicate citation records, I would suggest storing them by a sequence number, i.e. first reference, second reference, etc. This is not explicitly available in the XML, so you would need to create that during loading.
* Not all references that are cited from a document can be found as a Scopus document (for instance, if a white paper is cited that white paper is not available as a separate document in Scopus), but all references should have an SGR. We call the SGRs that are not documents in the database itself “dummy” records. There is no way to discriminate between them based on the ID itself alone, you would either have to look it up (i.e. check if the cited reference is in Scopus, assuming you have all of Scopus and not just a specific time slice) or use the “type” attribute on the reference (should you want to discriminate between them)
* SGRs or SCPs are both long/big integers. We typically only index numerical IDs due to efficiency. They can be converted into the longer Scopus EID string:
    1. If the length of SGR/SCP < 10, left-pad it with zeroes to a 10-digit string, such as: `0004075717`
    2. If the length of SGR/SCP is >= 10, convert it to string as-is, such as: `85074075717`    
    3. Prefix with '2-s2.0-': e.g. `2-s2.0-0004075717`, `2-s2.0-85074075717`
 