/*
Parameter sample:

{
  "input_data": [
    {
      "c1": 1538909,
      "c2": 34547809547,
      "c3": 4243943295
    },
    {
      "c1": 1538909,
      "c2": 34547809547,
      "c3": 38793301
    }
  ]
}
*/

UNWIND $input_data AS row
MATCH (:Publication {node_id: row.c1})<--(p)-->(:Publication {node_id: row.c2}), (p)-->(:Publication {node_id: row.c3})
RETURN row.c1 AS scp1, row.c2 AS scp2, row.c3 AS scp3, COUNT(p) AS f;