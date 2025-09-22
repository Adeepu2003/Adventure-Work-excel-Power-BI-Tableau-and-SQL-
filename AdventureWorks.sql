create database AdventureWorks;
use AdventureWorks;
SELECT COUNT(*) AS total_rows FROM factinternetsalesnew;

#1. Created View from Sales and ne sales tables
create view  Sales as
select * from factinternetsales
union all
select * from factinternetsalesnew;

select * from sales;


#2.Top 5 Products Sum of Sales
SELECT p.EnglishProductName,SUM(s.OrderQuantity * s.UnitPrice) AS TotalSales
FROM dimproduct p
INNER JOIN sales s ON p.ProductKey = s.ProductKey
GROUP BY p.EnglishProductName
ORDER BY TotalSales DESC
LIMIT 5;

#3.Top 5 Product with Profit
select p.EnglishProductName,sum((s.orderquantity*s.unitprice)-(s.productstandardcost*s.orderquantity)) as profit
from dimproduct p
inner join sales s on p.productkey=s.productkey
group by p.Englishproductname 
order by profit desc
limit 5;

#4.Region and Country Wise Total Sales
select t.SalesTerritoryregion,t.Salesterritorycountry,sum(s.orderquantity*s.unitprice) as TotalSales
from dimsalesterritory t
inner join sales s on t.salesterritorykey=s.salesterritorykey
group by t.SalesTerritoryregion,t.Salesterritorycountry
order by TotalSales desc;

#5.Top 10 Customers with Sales
select c.firstname,c.lastname,sum(s.orderquantity*s.unitprice) as Totalsales
from dimcustomer c 
inner join sales s on c.customerkey=s.customerkey
group by c.firstname,c.lastname
order by Totalsales desc
limit 10;

#6. Customers Who Purchased Products with Unitprice>1000
select Distinct c.customerkey,c.firstname,c.lastname,p.Englishproductname,s.unitprice
from sales s inner join
dimcustomer c on s.customerkey=c.customerkey
inner join dimproduct p on s.productkey=p.productkey
where s.unitprice>1000
order by s.unitprice;

#7.Products with Orderder more than 50 with less profit as 5000
select p.englishproductname,sum(s.orderquantity) as TotalOrder,sum((s.orderquantity*s.unitprice)-(s.orderquantity*s.productstandardcost)) as profit
from sales s inner join 
dimproduct p on s.productkey=p.productkey
group by p.englishproductname
having Totalorder>50 and profit<5000
order by Totalorder desc;

#8.Products with Highest margin %
select p.Englishproductname,Round(Avg((s.unitprice-s.productstandardcost)/s.unitprice)*100,2) as Profitmarginpercent
from sales s inner join
dimproduct p on
s.productkey=p.productkey
group by p.englishproductname
order by profitMarginpercent desc
limit 10;

#9.Monthly Revenue ,Tax and Freight
select d.calendaryear,d.EnglishMonthname,sum(s.orderquantity*s.unitprice) as TotalRevenue,
sum(s.TaxAmt) as TaxAmmount,sum(s.Freight) As FreigtAmmount
from sales s inner join
dimdate d on s.orderdatekey=d.datekey
group by  d.calendaryear,d.EnglishMonthname
order by  d.calendaryear,d.EnglishMonthname;


#10.Customer Segmentation as Platinum,Gold,Silver and Bronze based on their Spendature
with customer_spending as (
select c.customerkey,c.firstname,c.lastname,sum(s.extendedamount) as totalspend
from sales s
join dimcustomer c on s.customerkey = c.customerkey
group by c.customerkey, c.firstname, c.lastname
)
select cs.customerkey,cs.firstname,cs.lastname,cs.totalspend,
case 
when cs.totalspend >= 10000 then 'platinum'
when cs.totalspend >= 5000 then 'gold'
when cs.totalspend >= 1000 then 'silver'
else 'bronze'
end as customersegment
from 
customer_spending cs
order by 
cs.totalspend desc;


#11. Ranking Subcategory wise Profit
select ps.Englishproductsubcategoryname,
sum((s.orderquantity*s.unitprice)-(s.productstandardcost*s.orderquantity)) as profit,
rank() over (order by sum((s.orderquantity*s.unitprice)-(s.productstandardcost*s.orderquantity)) desc) as profit_rank
from sales s
join dimproduct p on s.productkey=p.productkey
join dimproductsubcategory ps on 
p.productsubcategorykey=ps.productsubcategorykey
group by ps.Englishproductsubcategoryname ;

#12.Sales Growth Year over year
call yoy_sales_growth;

#13. Sales Profit Tax and Freight Summary year wise using Stored Procedure
call sales_wise_summary(2014);