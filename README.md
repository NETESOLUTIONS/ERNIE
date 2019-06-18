# Welcome to ERNIE
<img align="left" src="ERNIE.png" width="250" height="200" border="120">

## _Netelabs has a position open for a Data Engineer https://shar.es/a0Cfis to work on ERNIE._

Enhanced Research Network Informatics Environment (ERNIE) originates from a thought experiment (inspired by Williams et al. Cell 163:21-23, 2015) intended to address the research assessment problem as well as prior experience in building a database of linked data for internal use by a federal agency. This idea grew into an effort to create ERNIE as a knowledge resource for research assessment that would be available to the broader community. ERNIE is designed and developed by NET ESolutions Corporation (NETE). 

We _are not connected_ with https://github.com/thunlp/ERNIE, which contains source code for a language representation model. However, we have exchanged cordial communications with the thunlp/ERNIE folks and wished them the same success taht we aspire to.

ERNIE is a data platform with associated workflows that enables the discovery and analysis of collaboration networks in scientific research.  In its first phase of development, ERNIE was [tested](https://doi.org/10.1101/371955) with case studies spanning drug development, medical devices/diagnostics, behavioral interventions, and solutions for drug discovery. The focus of these case studies was substance abuse. 

Emphasis is placed on the use of Open Source technologies. At present, ERNIE resides in a PostgreSQL 11 database in 
Centos 7.4 VMs in the Microsoft Azure cloud. The data in ERNIE are drawn in through custom ETL processes from both 
publicly available and commercial sources. Additional servers provide Solr and Neo4J support and a Spark cluster is provisioned as needed.  Initial server infrastructure has been set up, core data have been scraped, leased, parsed, loaded, and partially curated and beta-user studies are under way. The project team will add additional data sources as and when they become available. The infrastructure and data model is continuously upgraded as we add new data sources and prune out less useful ones.

 We have recently used a combination of PostgreSQL and Spark to conduct large scale Monte Carlo simulations for co-citation analysis and results will be posted soon.

We recently formalized a partnering agreement with [Elsevier](https://www.elsevier.com). As of July 1, 2019 we will have completed transition from Web of Science to  Scopus as the bibliographic backbone of ERNIE. Similarly for patents, we will be using using IPDD from [LexisNexis](https://www.lexisnexis.com/en-us/gateway.page) instead of the Derwent Patent Citation Index.

This project has been funded in part as a Fast Track Small Business Innovative Research award with Federal funds from the National Institute on Drug Abuse, National Institutes of Health, US Department of Health and Human Services. In Feb 2018, Phase I was completed. Phase II has since been awarded and commenced on Sept 30, 2018. Phase II is focused on building a user comunity and 'productionizing' the platform. We gratefully acknowledge constructive critique and advice from the Program staff at NIDA.
 
This repo was created in Aug 2017, we wrote up an acccompanying article in 2018 that is sitting on BioRxiv. The citation for the article is 
```
@article{keserci_ernie:_2018,
	title = {{ERNIE}: {A} {Data} {Platform} for {Research} {Assessment}},
	url = {https://www.biorxiv.org/content/early/2018/07/19/371955},
	doi = {10.1101/371955},
	abstract = {},
	journal = {bioRxiv},
	author = {Keserci, Samet and Davey, Avon and Pico, Alexander R. and Korobskiy, Dmitriy 
	and Chacko, George},
	year = {2018}
}
```
