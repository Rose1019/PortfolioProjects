/* GUIDED PROJECT ON DATA CLEANING- ALEX THE ANALYST
   
   DATA SET - Nashville Housing 
   
   Website: https://www.kaggle.com/datasets/tmthyjames/nashville-housing-data

1> We have converted the dataset CSV format to .xlsx format whihc would help to connect to MSsql
2> Using the option 'SQL server 2019 import and export' option we can import the data from excel to sql.
*/

***********************************************************************************************************************************

---- To fetch the Nashville housing data ----
select *
from Nashvillehousing;

---- To get the date column from the table ----
select [Sale Date]
from Nashvillehousing;

---- 1> To clean the DATE column ----
---- Standardize the date format
---- Since there is no need of time in sale date column, 
---- We need to remove the time and convert the column from datetime format to date format.


---- Selecting the date column and use CONVERT() function to convert the Sale date column (DATATYPE- datetime) to date data type.
select [Sale Date] ,CONVERT(date,[Sale Date])
from PortfolioProject..Nashvillehousing;

---- To add the new column to the Nashville table using ALTER query
Alter table Nashvillehousing
Add SaleConvertedDate date;

---- To update the new column
update Nashvillehousing
SET SaleConvertedDate = CONVERT(date,[Sale Date]);

Select *
from Nashvillehousing;

---- 2> Populate property address data
---- To check whether all the property address are not null
---- If the values are NULL
---- Logic : 
----		*Do the self join for Nashville housing table, 
----        *Using ISNULL() check if the property address of table a is NULL, if it is null then populate the property address of table b
----		*if they satisfy the following confitions -> parcel id columns is equal and Unnamed columns is not equal 


select *
from PortfolioProject..Nashvillehousing
where [Property Address] is null
order by [Parcel ID];

select a.[Parcel ID],a.[Property Address],b.[Parcel ID],b.[Property Address],
ISNULL(a.[Property Address],b.[Property Address])
from PortfolioProject..Nashvillehousing a
JOIN PortfolioProject..Nashvillehousing b
on
a.[Parcel ID]=b.[Parcel ID] and 
a.[Unnamed: 0]<>b.[Unnamed: 0]
where a.[Property Address] is null;

Update a
SET [Property Address] = ISNULL(a.[Property Address],b.[Property Address])
from PortfolioProject..Nashvillehousing a
JOIN PortfolioProject..Nashvillehousing b
on
a.[Parcel ID]=b.[Parcel ID] and 
a.[Unnamed: 0]<>b.[Unnamed: 0]
where a.[Property Address] is null;



select [Property Address],[Property City]
from PortfolioProject..Nashvillehousing
--where [Property Address] is null;


--- 3> Change Y and N to Yes and No respectively in SoldAsVacant column

---- To check how may are N's,Y's,No's,Yes's ----

select  COUNT([Sold As Vacant])
from PortfolioProject..Nashvillehousing
group by [Sold As Vacant];

---- Using CASE..When Then function ----
select [Sold As Vacant],
CASE 
	when [Sold As Vacant] = 'Y' then 'Yes'
	when [Sold As Vacant] = 'N' then 'No'
	ELSE Sold As Vacant
END
from PortfolioProject..Nashvillehousing;


---  4> To identify Duplicates
---		Not a best practice to remove the duplicates in data
---		using CTE and Windows function to identify the duplicates

With RowNumCTE as
(
 select *,
 ROW_NUMBER() over( PARTITION by [Parcel ID],
								 [Property Address],
								 [Sale Price],
								 [Sale Date],
								 [Legal Reference]
					Order by [Unnamed: 0]
                    ) as row_num
from PortfolioProject..Nashvillehousing
) 

select *
from RowNumCTE
where row_num=1;


---- 5> Delete Unused columns

Select *
from PortfolioProject..Nashvillehousing;

Alter table PortfolioProject..Nashvillehousing
drop column [F1],[Sale Date],[Tax District];