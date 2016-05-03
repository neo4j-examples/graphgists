export GUIDES=../neo4j-guides

rm -rf html
mkdir html

$GUIDES/run.sh index.adoc html/index.html +1 http://guides.neo4j.com/graphgists

s3cmd put -P html/index.html s3://guides.neo4j.com/graphgists

#. http://neo4j.com/graphgist/9d627127-003b-411a-b3ce-f8d3970c2afa[Bank Fraud Detection]

$GUIDES/run.sh fraud/bank-fraud-detection.adoc html/fraud

#. http://neo4j.com/graphgist/56c4ceb8-0af1-4d36-b14c-aaa482dc2abc[Books Management Graph]

$GUIDES/run.sh uc-search/books.adoc html/books

#. http://neo4j.com/graphgist/ec65c2fa-9d83-4894-bc1e-98c475c7b57a[Analyzing Offshore Leaks]

$GUIDES/run.sh fraud/Offshore_Leaks_and_Azerbaijan.adoc html/leaks

#. http://neo4j.com/graphgist/306bb0c7-9820-4c29-9835-15625e4e9f96[Network Dependency Graph]

$GUIDES/run.sh networkITmanagment/NetworkDataCenterManagement1.adoc html/network

#. http://neo4j.com/graphgist/4cea8113-30e9-46bc-bbb0-06236a9bd8b9[Job Recommendation System]

$GUIDES/run.sh recommendation/Competence_Management.adoc html/jobs

s3cmd put -P --recursive html/* s3://guides.neo4j.com/graphgists/
