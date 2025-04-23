-- this script queries an online retail data to help us 
-- discover trends about merchandise across countries
-- Alejandro Tineo 4.21.25

create table online_retail (
    InvoiceNo varchar(20),
    StockCode varchar(20),
    Description text,
    Quantity int,
    InvoiceDate varchar(20),
    UnitPrice decimal(10,2),
    CustomerID varchar(20),
    Country varchar(100)
);

alter table online_retail
add formattedInvoiceDate datetime;

update online_retail
set formattedInvoiceDate = str_to_date(InvoiceDate, '%m/%d/%y %H:%i');

alter table online_retail
drop InvoiceDate;


#we do not want to alter the table further so we will create a new table
#this will deal with transactions that are returned which return with UnitPrice as negative
#also 2 transactions contain negative Quanitites. This will also be removed. 
#we will do additional queries to find how much $ and quantity was returned using the original table
create table cleanedTable as
select*
from online_retail
where UnitPrice > 0 and Quantity > 0


#what is the total spending, total transactions, and average spending per transaction broken down by country
with totalCount as 
(
	select Country, sum(UnitPrice * Quantity) as totalExpenditure,
	count(distinct InvoiceNo) as transactions
	from cleanedTable
	group by Country
)
select Country, totalExpenditure,
round(totalExpenditure/transactions, 0) as averageSpendingT, transactions
from totalCount
group by Country
order by averageSpendingT desc;


#what is the % of revenue from the top products by country - how concentrated is the revenue? 
with totalExpenditure as (
	select Country, sum(UnitPrice * Quantity) as totalRevenue,
	sum(Quantity) as totalQuantity
	from cleanedTable
	group by Country
	),
rankingProducts as 
	(
	select Country, Description, sum(UnitPrice * Quantity) as totalProductRevenue,
	sum(Quantity) as totalQuantity,
	row_number() over (partition by Country order by sum(Quantity) desc) as rankedProduct
	from online_retail 
	group by Country, Description
	)
select Country, Description, rankedProduct, percentRevenue, percentUnits,
ROUND(percentUnits - percentRevenue, 2) AS unitRevGap
from (
	select r.country, r.Description, r.totalProductRevenue, r.rankedProduct, r.totalQuantity,
	round((r.totalProductRevenue / t.totalRevenue), 3) as percentRevenue,
	round((r.totalQuantity / t.totalQuantity), 3) AS percentUnits
	from rankingProducts r join 
	totalExpenditure t on r.Country = t.Country
	) as percentTable 
where rankedProduct <= 3;




#what is the difference between repeat buyers versus casual buyers
with table1 as (
	select count(distinct InvoiceNo) as transactions, CustomerID, Country,
	sum(Quantity * UnitPrice) as Revenue
	from cleanedTable
	where CustomerID is not null 
	and length(trim(CustomerID)) > 0
	group by Country, CustomerID
),
customerType as (
	select Country, count(CustomerID) as totalCustomers, sum(transactions) as totalTransactions, sum(Revenue) as totalRevenue,
	round(sum(Revenue) / sum(transactions), 3) as avgOrderValue,
	case 
		when transactions >= 5 then 'Engaged'
		else 'Casual'
	end as customerType
	from table1
	group by Country, customerType
)
#filtered as (
#	select *,
#	count(customertype) over (partition by Country) as countTypes
#	from customerType
#),
select Country, customerType,
round(totalRevenue / sum(totalRevenue) over (partition by country), 3) as percentofRevenue,
round(totalTransactions / sum(totalTransactions) over (partition by country), 3) as percentofTransactions,
round(totalCustomers / sum(totalCustomers) over (partition by country), 3) as percentofCustomers,
avgOrderValue, totalRevenue, totalTransactions
from customerType;
#where countTypes = 2;


#what is the total revenue per month to see if there are more peaks
with CountryDate as (
	select Country, sum(UnitPrice * Quantity) as totalCountryRevenue, date_format(formattedInvoiceDate, '%b-%Y') as purchaseDate
	from cleanedTable
	group by Country, purchaseDate
)
select *, 
sum(totalCountryRevenue) over (partition by purchaseDate) as totalRevenue
from CountryDate;
