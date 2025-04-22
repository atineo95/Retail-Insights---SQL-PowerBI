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

#what is the average spending per transaction broken down by country
with totalCount as (
	select Country, sum(UnitPrice * Quantity) as totalExpenditure,
	count(distinct InvoiceNo) as transactions
	from online_retail
	group by Country
	)
select Country, 
round(totalExpenditure/transactions, 0) as averageSpendingT
from totalCount
group by Country
order by averageSpendingT desc;


#what is the % of revenue from the top products by country - how concentrated is the revenue? 
with totalExpenditure as (
	select Country, sum(UnitPrice * Quantity) as totalRevenue,
	sum(Quantity) as totalQuantity
	from online_retail
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
	round((r.totalProductRevenue / t.totalRevenue) * 100, 2) as percentRevenue,
	round((r.totalQuantity / t.totalQuantity) * 100, 2) AS percentUnits
	from rankingProducts r join 
	totalExpenditure t on r.Country = t.Country
	) as percentTable 
where rankedProduct <= 3;




#what is the difference between repeat buyers versus casual buyers
with table1 as (
	select count(distinct InvoiceNo) as transactions, CustomerID, Country,
	sum(Quantity * UnitPrice) as Revenue
	from online_retail
	where CustomerID is not null 
	and length(trim(CustomerID)) > 0
	group by Country, CustomerID
),
customerType as (
	select Country, count(CustomerID) as totalCustomers, sum(transactions) as totalTransactions, sum(Revenue) as totalRevenue,
	round(sum(Revenue) / sum(transactions), 0) as avgOrderValue,
	case 
		when transactions >= 5 then 'Engaged'
		else 'Casual'
	end as customerType
	from table1
	group by Country, customerType
),
filtered as (
	select *,
	count(customertype) over (partition by Country) as countTypes
	from customerType
)
select Country, customerType,
round(totalRevenue / sum(totalRevenue) over (partition by country) *100, 0) as percentofRevenue,
round(totalTransactions / sum(totalTransactions) over (partition by country) *100, 0) as percentofTransactions,
round(totalCustomers / sum(totalCustomers) over (partition by country) *100, 0) as percentofCustomers,
avgOrderValue, totalRevenue, totalTransactions
from filtered
where countTypes = 2;