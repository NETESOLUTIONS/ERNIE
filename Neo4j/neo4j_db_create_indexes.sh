#!/usr/bin/env bash
echo "Indexing"

cypher-shell <<HEREDOC
CREATE INDEX ON :Publication(node_id);
CREATE INDEX ON :Publication(pub_year, citation_type);

// Wait until index creation finishes. Increase timeOutSeconds to 600. Default = 300.
CALL db.awaitIndexes(600);
HEREDOC
