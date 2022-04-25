--CLEANING DATA IN SQL QUERIES


select * 
from PortfolioProject#1.dbo.NashvilleHousing;

--Standardize Date Format

use PortfolioProject#1;


--update NashvilleHousing
--set SaleDate = convert(date,saledate);

alter table NashvilleHousing
add SaleDateConverted date;


update NashvilleHousing
set SaleDateConverted = convert(date,saledate);

select SaleDate, SaleDateConverted
from NashvilleHousing;



--Populate Property Address Data


select PropertyAddress
from NashvilleHousing
where PropertyAddress is null
order by ParcelID


--select Nas1.ParcelID, Nas1.PropertyAddress, Nas2.ParcelID, Nas2.PropertyAddress, 
--	ISNULL(Nas2.PropertyAddress,Nas1.PropertyAddress)
--from NashvilleHousing Nas1
--join NashvilleHousing Nas2
--	on Nas1.ParcelID = Nas2.ParcelID
--	and Nas1.[UniqueID ] != Nas2.[UniqueID ]
--where Nas2.PropertyAddress is null

update Nas2
set Nas2.PropertyAddress = ISNULL(Nas2.PropertyAddress,Nas1.PropertyAddress)
from NashvilleHousing Nas1
join NashvilleHousing Nas2
	on Nas1.ParcelID = Nas2.ParcelID
	and Nas1.[UniqueID ] != Nas2.[UniqueID ]
where Nas2.PropertyAddress is null



--Breaking out Address into Individual Columns (Address, City, State)


select PropertyAddress
from NashvilleHousing;

--select PropertyAddress, 
--	substring(PropertyAddress,1,charindex(',',PropertyAddress)-1),
--	substring(PropertyAddress,charindex(',',PropertyAddress)+1,len(PropertyAddress))
--from NashvilleHousing;

alter table NashvilleHousing
add PropertySplitAddress nvarchar(255);

update NashvilleHousing
set PropertySplitAddress = substring(PropertyAddress, 1, charindex(',',PropertyAddress)-1);


alter table NashvilleHousing
add PropertySplitCity nvarchar(255);

update NashvilleHousing
set PropertySplitCity = substring(PropertyAddress, charindex(',',PropertyAddress)+1, len(PropertyAddress));

-------------------------------------

select OwnerAddress
from NashvilleHousing;

--select parsename(replace(OwnerAddress,',','.'), 3),
--	parsename(replace(OwnerAddress,',','.'), 2),
--	parsename(replace(OwnerAddress,',','.'), 1)
--from NashvilleHousing;


alter table NashvilleHousing
add OwnerSplitAddress nvarchar(255);

alter table NashvilleHousing
add OwnerSplitCity nvarchar(255);

alter table NashvilleHousing
add OwnerSplitState nvarchar(255);


update NashvilleHousing
set OwnerSplitAddress = parsename(replace(OwnerAddress,',','.'), 3);

update NashvilleHousing
set OwnerSplitCity = parsename(replace(OwnerAddress,',','.'), 2);

update NashvilleHousing
set OwnerSplitState = parsename(replace(OwnerAddress,',','.'), 1);

select * from NashvilleHousing


--Change Y and N to Yes and No in "Sold as vancant" field

select distinct SoldAsVacant, count(SoldAsVacant)
from NashvilleHousing
group by SoldAsVacant;

select SoldAsVacant,
case when SoldAsVacant = 'Y' then 'Yes'
	when SoldAsVacant = 'N' then 'No'
	else SoldAsVacant
	end
from NashvilleHousing;

update NashvilleHousing
set SoldAsVacant =
	case when SoldAsVacant = 'Y' then 'Yes'
	when SoldAsVacant = 'N' then 'No'
	else SoldAsVacant
	end


--Remove Duplicates


drop table if exists #Temptable1
select * into #Temptable1
from NashvilleHousing;

with dupvaluesCTE
as 
(
select *,
	ROW_NUMBER() over (
	partition by ParcelID, PropertyAddress, SaleDate, SalePrice,LegalReference
	order by UniqueID) as row_num
from #Temptable1
)
delete 
from dupvaluesCTE
where row_num > 1;
select * from #Temptable1;



--Delete Unused Columns


drop table if exists #Temptable2
select * into #Temptable2
from NashvilleHousing;

alter table #Temptable2 
drop column PropertyAddress, SaleDate, OwnerAddress, TaxDistrict;
select * from #Temptable2;
