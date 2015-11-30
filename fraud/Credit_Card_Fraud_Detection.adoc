= Credit Card Fraud Detection
:neo4j-version: 2.3.0
:author: Jean Villedieu
:twitter: @jvilledieu
:tags:
:domain: finance
:use-case: fraud-detection

This interactive Neo4j graph tutorial covers a common credit card fraud detection scenario.

:toc:

== Introduction to Problem

Banks, merchants and credit card processors companies lose billions of dollars every year to credit card fraud.
Credit card data can be stolen by criminals using a variety of methods.
Bluetooth-enabled data skimming devices can be placed on the card reader on the pump that dispenses your petrol.
The data might be stolen in a mass breach by hackers of a large retailer, as was the case with Target and Home Depot in recent years.
Sometimes the criminal is simply the clerk at the checkout line at the grocery or in a restaurant, where the victim's card is swiped through a small device or surreptitiously jotted down.

'''

=== Typical Scenario

In December 2013, police in Abington, Pennsylvania arrested two Post Office employees for stealing credit card information and using it to buy more than $50,000 worth of merchandise.
Their scheme was quite typical; here is how they operated:

* the Post Office clerks copied the credit card information of some of their customers while processing transactions;
* they then located these customers' home addresses;
* using the credit card numbers, they would place orders online for goods or gift cards, to be delivered at their victims' home address;
* with goods ordered online, an accomplice would wait at the address to intercept the deliveries;

The pair were apprehended not long after Post Office patron reported a man attempting to intercept one of the packages at his home, but not before the pair had bought Christmas gifts and gone on vacations with the fraudulently obtained information.

'''

== Explanation of Solution

Graph databases can help find credit card thieves faster.
By representing transactions as a graph, we can look for the common denominator in the fraud cases and find the point of origin of the scam.

== Credit Card Fraud Graph Data Model

A series of credit card transactions can be represented as a graph.
Each transaction involves two nodes: a person (the customer) and a merchant.
The nodes are linked by the transaction itself.
A transaction has a date and a status.

Legitimate transactions have the status "Undisputed".
Fraudulent transactions are "Disputed".

The graph data model below represents how the data looks as a graph.

.Credit Card Fraud
image::https://linkurio.us/wp-content/uploads/2014/05/Credit-card-fraud-schema-600x337.png[Credit Card Fraud]

'''

== Sample Data Set

//hide
//setup
[source,cypher]
----
// Create customers
CREATE (Paul:Person {id:'1', name:'Paul', gender:'man', age:'50'})
CREATE (Jean:Person {id:'2', name:'Jean', gender:'man', age:'48'})
CREATE (Dan:Person {id:'3', name:'Dan', gender:'man', age:'23'})
CREATE (Marc:Person {id:'4', name:'Marc', gender:'man', age:'30'})
CREATE (John:Person {id:'5', name:'John', gender:'man', age:'31'})
CREATE (Zoey:Person {id:'6', name:'Zoey', gender:'woman', age:'52'})
CREATE (Ava:Person {id:'7', name:'Ava', gender:'woman', age:'23'})
CREATE (Olivia:Person {id:'8', name:'Olivia', gender:'woman', age:'58'})
CREATE (Mia:Person {id:'9', name:'Mia', gender:'woman', age:'51'})
CREATE (Madison:Person {id:'10', name:'Madison', gender:'woman', age:'37'})

// Create merchants
CREATE (Amazon:Merchant {id:'11', name:'Amazon', street:'2626 Wilkinson Court', address:'San Bernardino, CA 92410'})
CREATE (Abercrombie:Merchant {id:'12', name:'Abercrombie', street:'4355 Walnut Street', age:'San Bernardino, CA 92410'})
CREATE (Wallmart:Merchant {id:'13', name:'Wallmart', street:'2092 Larry Street', age:'San Bernardino, CA 92410'})
CREATE (MacDonalds:Merchant {id:'14', name:'MacDonalds', street:'1870 Caynor Circle', age:'San Bernardino, CA 92410'})
CREATE (American_Apparel:Merchant {id:'15', name:'American Apparel', street:'1381 Spruce Drive', age:'San Bernardino, CA 92410'})
CREATE (Just_Brew_It:Merchant {id:'16', name:'Just Brew It', street:'826 Anmoore Road', age:'San Bernardino, CA 92410'})
CREATE (Justice:Merchant {id:'17', name:'Justice', street:'1925 Spring Street', age:'San Bernardino, CA 92410'})
CREATE (Sears:Merchant {id:'18', name:'Sears', street:'4209 Elsie Drive', age:'San Bernardino, CA 92410'})
CREATE (Soccer_for_the_City:Merchant {id:'19', name:'Soccer for the City', street:'86 D Street', age:'San Bernardino, CA 92410'})
CREATE (Sprint:Merchant {id:'20', name:'Sprint', street:'945 Kinney Street', age:'San Bernardino, CA 92410'})
CREATE (Starbucks:Merchant {id:'21', name:'Starbucks', street:'3810 Apple Lane', age:'San Bernardino, CA 92410'})
CREATE (Subway:Merchant {id:'22', name:'Subway', street:'3778 Tenmile Road', age:'San Bernardino, CA 92410'})
CREATE (Apple_Store:Merchant {id:'23', name:'Apple Store', street:'349 Bel Meadow Drive', age:'Kansas City, MO 64105'})
CREATE (Urban_Outfitters:Merchant {id:'24', name:'Urban Outfitters', street:'99 Strother Street', age:'Kansas City, MO 64105'})
CREATE (RadioShack:Merchant {id:'25', name:'RadioShack', street:'3306 Douglas Dairy Road', age:'Kansas City, MO 64105'})
CREATE (Macys:Merchant {id:'26', name:'Macys', street:'2912 Nutter Street', age:'Kansas City, MO 64105'})

// Create transaction history
CREATE (Paul)-[:HAS_BOUGHT_AT {amount:'986', time:'4/17/2014', status:'Undisputed'}]->(Just_Brew_It)
CREATE (Paul)-[:HAS_BOUGHT_AT {amount:'239', time:'5/15/2014', status:'Undisputed'}]->(Starbucks)
CREATE (Paul)-[:HAS_BOUGHT_AT {amount:'475', time:'3/28/2014', status:'Undisputed'}]->(Sears)
CREATE (Paul)-[:HAS_BOUGHT_AT {amount:'654', time:'3/20/2014', status:'Undisputed'}]->(Wallmart)
CREATE (Jean)-[:HAS_BOUGHT_AT {amount:'196', time:'7/24/2014', status:'Undisputed'}]->(Soccer_for_the_City)
CREATE (Jean)-[:HAS_BOUGHT_AT {amount:'502', time:'4/9/2014', status:'Undisputed'}]->(Abercrombie)
CREATE (Jean)-[:HAS_BOUGHT_AT {amount:'848', time:'5/29/2014', status:'Undisputed'}]->(Wallmart)
CREATE (Jean)-[:HAS_BOUGHT_AT {amount:'802', time:'3/11/2014', status:'Undisputed'}]->(Amazon)
CREATE (Jean)-[:HAS_BOUGHT_AT {amount:'203', time:'3/27/2014', status:'Undisputed'}]->(Subway)
CREATE (Dan)-[:HAS_BOUGHT_AT {amount:'35', time:'1/23/2014', status:'Undisputed'}]->(MacDonalds)
CREATE (Dan)-[:HAS_BOUGHT_AT {amount:'605', time:'1/27/2014', status:'Undisputed'}]->(MacDonalds)
CREATE (Dan)-[:HAS_BOUGHT_AT {amount:'62', time:'9/17/2014', status:'Undisputed'}]->(Soccer_for_the_City)
CREATE (Dan)-[:HAS_BOUGHT_AT {amount:'141', time:'11/14/2014', status:'Undisputed'}]->(Amazon)
CREATE (Marc)-[:HAS_BOUGHT_AT {amount:'134', time:'4/14/2014', status:'Undisputed'}]->(Amazon)
CREATE (Marc)-[:HAS_BOUGHT_AT {amount:'336', time:'4/3/2014', status:'Undisputed'}]->(American_Apparel)
CREATE (Marc)-[:HAS_BOUGHT_AT {amount:'964', time:'3/22/2014', status:'Undisputed'}]->(Wallmart)
CREATE (Marc)-[:HAS_BOUGHT_AT {amount:'430', time:'8/10/2014', status:'Undisputed'}]->(Sears)
CREATE (Marc)-[:HAS_BOUGHT_AT {amount:'11', time:'9/4/2014', status:'Undisputed'}]->(Soccer_for_the_City)
CREATE (John)-[:HAS_BOUGHT_AT {amount:'545', time:'10/6/2014', status:'Undisputed'}]->(Soccer_for_the_City)
CREATE (John)-[:HAS_BOUGHT_AT {amount:'457', time:'10/15/2014', status:'Undisputed'}]->(Sprint)
CREATE (John)-[:HAS_BOUGHT_AT {amount:'468', time:'7/29/2014', status:'Undisputed'}]->(Justice)
CREATE (John)-[:HAS_BOUGHT_AT {amount:'768', time:'11/28/2014', status:'Undisputed'}]->(American_Apparel)
CREATE (John)-[:HAS_BOUGHT_AT {amount:'921', time:'3/12/2014', status:'Undisputed'}]->(Just_Brew_It)
CREATE (Zoey)-[:HAS_BOUGHT_AT {amount:'740', time:'12/15/2014', status:'Undisputed'}]->(MacDonalds)
CREATE (Zoey)-[:HAS_BOUGHT_AT {amount:'510', time:'11/27/2014', status:'Undisputed'}]->(Abercrombie)
CREATE (Zoey)-[:HAS_BOUGHT_AT {amount:'414', time:'1/20/2014', status:'Undisputed'}]->(Just_Brew_It)
CREATE (Zoey)-[:HAS_BOUGHT_AT {amount:'721', time:'7/17/2014', status:'Undisputed'}]->(Amazon)
CREATE (Zoey)-[:HAS_BOUGHT_AT {amount:'353', time:'10/25/2014', status:'Undisputed'}]->(Subway)
CREATE (Ava)-[:HAS_BOUGHT_AT {amount:'681', time:'12/28/2014', status:'Undisputed'}]->(Sears)
CREATE (Ava)-[:HAS_BOUGHT_AT {amount:'87', time:'2/19/2014', status:'Undisputed'}]->(Wallmart)
CREATE (Ava)-[:HAS_BOUGHT_AT {amount:'533', time:'8/6/2014', status:'Undisputed'}]->(American_Apparel)
CREATE (Ava)-[:HAS_BOUGHT_AT {amount:'723', time:'1/8/2014', status:'Undisputed'}]->(American_Apparel)
CREATE (Ava)-[:HAS_BOUGHT_AT {amount:'627', time:'5/20/2014', status:'Undisputed'}]->(Just_Brew_It)
CREATE (Olivia)-[:HAS_BOUGHT_AT {amount:'74', time:'9/4/2014', status:'Undisputed'}]->(Soccer_for_the_City)
CREATE (Olivia)-[:HAS_BOUGHT_AT {amount:'231', time:'7/12/2014', status:'Undisputed'}]->(Wallmart)
CREATE (Olivia)-[:HAS_BOUGHT_AT {amount:'924', time:'10/4/2014', status:'Undisputed'}]->(Soccer_for_the_City)
CREATE (Olivia)-[:HAS_BOUGHT_AT {amount:'742', time:'8/12/2014', status:'Undisputed'}]->(Just_Brew_It)
CREATE (Mia)-[:HAS_BOUGHT_AT {amount:'276', time:'12/24/2014', status:'Undisputed'}]->(Soccer_for_the_City)
CREATE (Mia)-[:HAS_BOUGHT_AT {amount:'66', time:'4/16/2014', status:'Undisputed'}]->(Starbucks)
CREATE (Mia)-[:HAS_BOUGHT_AT {amount:'467', time:'12/23/2014', status:'Undisputed'}]->(MacDonalds)
CREATE (Mia)-[:HAS_BOUGHT_AT {amount:'830', time:'3/13/2014', status:'Undisputed'}]->(Sears)
CREATE (Mia)-[:HAS_BOUGHT_AT {amount:'240', time:'7/9/2014', status:'Undisputed'}]->(Amazon)
CREATE (Mia)-[:HAS_BOUGHT_AT {amount:'164', time:'12/26/2014', status:'Undisputed'}]->(Soccer_for_the_City)
CREATE (Madison)-[:HAS_BOUGHT_AT {amount:'630', time:'10/6/2014', status:'Undisputed'}]->(MacDonalds)
CREATE (Madison)-[:HAS_BOUGHT_AT {amount:'19', time:'7/29/2014', status:'Undisputed'}]->(Abercrombie)
CREATE (Madison)-[:HAS_BOUGHT_AT {amount:'352', time:'12/16/2014', status:'Undisputed'}]->(Subway)
CREATE (Madison)-[:HAS_BOUGHT_AT {amount:'147', time:'8/3/2014', status:'Undisputed'}]->(Amazon)
CREATE (Madison)-[:HAS_BOUGHT_AT {amount:'91', time:'6/29/2014', status:'Undisputed'}]->(Wallmart)
CREATE (Paul)-[:HAS_BOUGHT_AT {amount:'1021', time:'7/18/2014', status:'Disputed'}]->(Apple_Store)
CREATE (Paul)-[:HAS_BOUGHT_AT {amount:'1732', time:'5/10/2014', status:'Disputed'}]->(Urban_Outfitters)
CREATE (Paul)-[:HAS_BOUGHT_AT {amount:'1415', time:'4/1/2014', status:'Disputed'}]->(RadioShack)
CREATE (Paul)-[:HAS_BOUGHT_AT {amount:'1849', time:'12/20/2014', status:'Disputed'}]->(Macys)
CREATE (Marc)-[:HAS_BOUGHT_AT {amount:'1914', time:'7/18/2014', status:'Disputed'}]->(Apple_Store)
CREATE (Marc)-[:HAS_BOUGHT_AT {amount:'1424', time:'5/10/2014', status:'Disputed'}]->(Urban_Outfitters)
CREATE (Marc)-[:HAS_BOUGHT_AT {amount:'1721', time:'4/1/2014', status:'Disputed'}]->(RadioShack)
CREATE (Marc)-[:HAS_BOUGHT_AT {amount:'1003', time:'12/20/2014', status:'Disputed'}]->(Macys)
CREATE (Olivia)-[:HAS_BOUGHT_AT {amount:'1149', time:'7/18/2014', status:'Disputed'}]->(Apple_Store)
CREATE (Olivia)-[:HAS_BOUGHT_AT {amount:'1152', time:'8/10/2014', status:'Disputed'}]->(Urban_Outfitters)
CREATE (Olivia)-[:HAS_BOUGHT_AT {amount:'1884', time:'8/1/2014', status:'Disputed'}]->(RadioShack)
CREATE (Olivia)-[:HAS_BOUGHT_AT {amount:'1790', time:'12/20/2014', status:'Disputed'}]->(Macys)
CREATE (Madison)-[:HAS_BOUGHT_AT {amount:'1925', time:'7/18/2014', status:'Disputed'}]->(Apple_Store)
CREATE (Madison)-[:HAS_BOUGHT_AT {amount:'1374', time:'7/10/2014', status:'Disputed'}]->(Urban_Outfitters)
CREATE (Madison)-[:HAS_BOUGHT_AT {amount:'1368', time:'7/1/2014', status:'Disputed'}]->(RadioShack)
CREATE (Madison)-[:HAS_BOUGHT_AT {amount:'1816', time:'12/20/2014', status:'Disputed'}]->(Macys)

RETURN *
----
//graph

You can download the complete dataset here: https://www.dropbox.com/s/4uij4gs2iyva5bd/credit%20card%20fraud.zip

== Identify the Fraudulent Transactions

We collect all the fraudulent transactions.

[source,cypher]
----
MATCH (victim:Person)-[r:HAS_BOUGHT_AT]->(merchant)
WHERE r.status = "Disputed"
RETURN victim.name AS `Customer Name`, merchant.name AS `Store Name`, r.amount AS Amount, r.time AS `Transaction Time`
ORDER BY `Transaction Time` DESC
----
//output
//table

== Identify the Point of Origin of the Fraud

Now we know which customers and which merchants are involved in our fraud case.
But where is the criminal we are looking for?
What's going to help use here is the transaction date on each fraudulent transaction.

The criminal we are looking for is involved in a legitimate transaction during which he captures his victims credit card numbers.
After that, he can execute his illegitimate transactions.
That means that we not only want the illegitimate transactions but also the transactions happening before the theft.

[source,cypher]
----
MATCH (victim:Person)-[r:HAS_BOUGHT_AT]->(merchant)
WHERE r.status = "Disputed"
MATCH victim-[t:HAS_BOUGHT_AT]->(othermerchants)
WHERE t.status = "Undisputed" AND t.time < r.time
WITH victim, othermerchants, t ORDER BY t.time DESC
RETURN victim.name AS `Customer Name`, othermerchants.name AS `Store Name`, t.amount AS Amount, t.time AS `Transaction Time`
ORDER BY `Transaction Time` DESC
----
//output
//table

== Zero in on the criminal

Now we want to find the common denominator.
Is there a common merchant in all of these seemingly innocuous transactions?
We just have to tweak the Cypher query to sort out the previous results according to the number of times we see each merchant.

[source,cypher]
----
MATCH (victim:Person)-[r:HAS_BOUGHT_AT]->(merchant)
WHERE r.status = "Disputed"
MATCH victim-[t:HAS_BOUGHT_AT]->(othermerchants)
WHERE t.status = "Undisputed" AND t.time < r.time
WITH victim, othermerchants, t ORDER BY t.time DESC
RETURN DISTINCT othermerchants.name AS `Suspicious Store`, count(DISTINCT t) AS Count, collect(DISTINCT victim.name) AS Victims
ORDER BY Count DESC
----
//output
//table

.Where is the thief?
image::https://linkurio.us/wp-content/uploads/2014/05/credit-card-fraud-zoom-600x415.png[Where is the thief?]

In each instance of a fraudulent transaction, the credit card holder had visited Walmart in the days just prior.
We now know the location and the date on which the customer's credit cards numbers were stolen.
With a graph visualization solution like Linkurious, we could inspect the data to confirm our intuition.
Now we can alert the authorities and the merchant on the situation. They should have enough information to take it from there!

For more graph-related use cases, make sure to check the blog of Linkurious: http://linkurio.us/blog

//console
