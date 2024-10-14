USE PortfolioProject;
------------------------------------------------------------------

-- Cleaning Data in SQL Queries

select *
from PortfolioProject..NashvilleHousing


------------------------------------------------------------------

-- standardize date format

select saleDateConverted, convert(date, SaleDate)
from PortfolioProject..NashvilleHousing

update PortfolioProject..NashvilleHousing
set SaleDate = convert(date, SaleDate)

alter table PortfolioProject..NashvilleHousing
add saleDateConverted date;

update PortfolioProject..NashvilleHousing
set saleDateConverted = convert(date, SaleDate)


------------------------------------------------------------------

-- populate property adress data

select *
from PortfolioProject..NashvilleHousing
--where PropertyAddress is null
order by ParcelID


select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
from PortfolioProject..NashvilleHousing as a
join PortfolioProject..NashvilleHousing as b
on a.ParcelID = b.ParcelID
and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null


update a
set PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
from PortfolioProject..NashvilleHousing as a
join PortfolioProject..NashvilleHousing as b
on a.ParcelID = b.ParcelID
and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

------------------------------------------------------------------

-- breaking out Adress into Individual Columns (Adress, City, State)

select PropertyAddress
from PortfolioProject..NashvilleHousing
--where PropertyAddress is null
-- order by ParcelID

select 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Adress,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as Country

from PortfolioProject..NashvilleHousing


alter table PortfolioProject..NashvilleHousing
add PropertySplitAddress Nvarchar(255);

update PortfolioProject..NashvilleHousing
set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

alter table PortfolioProject..NashvilleHousing
add PropertySplitCity Nvarchar(255);

update PortfolioProject..NashvilleHousing
set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))

select *
from PortfolioProject..NashvilleHousing



select OwnerAddress
from PortfolioProject..NashvilleHousing


select 
PARSENAME(replace(OwnerAddress, ',', '.'), 3),
PARSENAME(replace(OwnerAddress, ',', '.'), 2),
PARSENAME(replace(OwnerAddress, ',', '.'), 1)
from PortfolioProject..NashvilleHousing



alter table PortfolioProject..NashvilleHousing
add OwnerSplitAdress Nvarchar(255);

update PortfolioProject..NashvilleHousing
set OwnerSplitAdress = PARSENAME(replace(OwnerAddress, ',', '.'), 3)

alter table PortfolioProject..NashvilleHousing
add OwnerSplitCity Nvarchar(255);

update PortfolioProject..NashvilleHousing
set OwnerSplitCity = PARSENAME(replace(OwnerAddress, ',', '.'), 2)

alter table PortfolioProject..NashvilleHousing
add OwnerSplitState Nvarchar(255);

update PortfolioProject..NashvilleHousing
set OwnerSplitState = PARSENAME(replace(OwnerAddress, ',', '.'), 1)


select *
from PortfolioProject..NashvilleHousing

------------------------------------------------------------------

-- change Y and N to Yes and No in "Sold as Vacant" field

select distinct(SoldAsVacant), count(SoldAsVacant)
from PortfolioProject..NashvilleHousing
group by SoldAsVacant
order by 2



select SoldAsVacant,
CASE when SoldAsVacant = 'Y' then 'Yes'
	when SoldAsVacant = 'N' then 'No'
	else SoldAsVacant
	end
from PortfolioProject..NashvilleHousing



update PortfolioProject..NashvilleHousing
set SoldAsVacant = CASE when SoldAsVacant = 'Y' then 'Yes'
	when SoldAsVacant = 'N' then 'No'
	else SoldAsVacant
	end



------------------------------------------------------------------

-- Remove Duplicates

with RowNumCTE as(
select *, ROW_NUMBER() over (
partition by ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference
order by UniqueID
) row_num
From NashvilleHousing
--order by ParcelID
)


select *
from RowNumCTE
where row_num > 1
--order by PropertyAddress


select ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference
from PortfolioProject..NashvilleHousing




------------------------------------------------------------------

-- Delete Unused Columns

select *
from PortfolioProject..NashvilleHousing

alter table PortfolioProject..NashvilleHousing
drop column OwnerAddress, TaxDistrict, PropertyAddress, SaleDate