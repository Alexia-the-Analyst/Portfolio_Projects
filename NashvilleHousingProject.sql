/*
Data Cleaning in SQL
*/
select *
from PortfolioProject.dbo.NashvilleHousingProject

-------------------------------------------------------------------
-- Standardize Date Format

Select SaleDate, CONVERT(Date, SaleDate) as SaleDateConverted
from PortfolioProject.dbo.NashvilleHousingProject

UPDATE NashvilleHousingProject
SET SaleDate = CONVERT(Date, SaleDate)

----------------------------------------------------------------
-- Populate Property Address Data
--1. Notice that there are nulls in Property Address, but there are parcelIDs for every address.
Select PropertyAddress
from PortfolioProject.dbo.NashvilleHousingProject
where PropertyAddress is null

-- 2. Joining the table into itself to double check that the null addresses have matching ParcelID.
select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress 
from PortfolioProject.dbo.NashvilleHousingProject a
Join PortfolioProject.dbo.NashvilleHousingProject b
on a.ParcelID = b.ParcelID
and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

-- 3. Use ISNULL to verify what is null and what it needs to be replaced with.
select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress ISNULL(a.PropertyAddress,b.PropertyAddress)
from PortfolioProject.dbo.NashvilleHousingProject a
Join PortfolioProject.dbo.NashvilleHousingProject b
on a.ParcelID = b.ParcelID
and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

-- 4. Update the column
UPDATE a
SET PropertyAddress = ISNULL(A.PropertyAddress,b.PropertyAddress)
from PortfolioProject.dbo.NashvilleHousingProject a
Join PortfolioProject.dbo.NashvilleHousingProject b
on a.ParcelID = b.ParcelID
and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

-----------------------------------------------------------------------
-- Breaking out Address into Individual Columns (Address, City, State)

Select PropertyAddress
from PortfolioProject.dbo.NashvilleHousingProject

Select
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)) as Address
from PortfolioProject.dbo.NashvilleHousingProject

-- Notice that the comma is present in the results, add -1 after the index as indexes provide us with positions
Select
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address
from PortfolioProject.dbo.NashvilleHousingProject

--
Select
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as Address
from PortfolioProject.dbo.NashvilleHousingProject

--Create two new columns and add them 

ALTER TABLE NashvilleHousingProject
Add PropertySplitAddress Nvarchar(255);

Update NashvilleHousingProject
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )


ALTER TABLE NashvilleHousingProject
Add PropertyCity Nvarchar(255);

Update NashvilleHousingProject
SET PropertyCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress))

select *
from PortfolioProject.dbo.NashvilleHousingProject

-- Breaking out OwnerAddress into Individual Columns using Parsename

select OwnerAddress
from PortfolioProject.dbo.NashvilleHousingProject

select
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
From PortfolioProject.dbo.NashvilleHousingProject

-- Alter the tables
ALTER TABLE NashvilleHousingProject
Add OwnerCleanedAddress Nvarchar(255);

ALTER TABLE NashvilleHousingProject
Add OwnerCleanedCity Nvarchar(255);

ALTER TABLE NashvilleHousingProject
Add OwnerCleanedState Nvarchar(255);

--Update the tables
Update NashvilleHousingProject
SET OwnerCleanedAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)

Update NashvilleHousingProject
SET OwnerCleanedCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)

Update NashvilleHousingProject
SET OwnerCleanedState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)

---------------------------------------------------------------------------------

-- Change Y and N to Yes and No in "Sold as Vacant" field

Select distinct(SoldAsVacant), count(SoldAsVacant)
from PortfolioProject.dbo.NashvilleHousingProject
group by SoldAsVacant

Select SoldAsVacant,
CASE
WHEN SoldAsVacant = 'Y' THEN 'Yes'
WHEN SoldAsVacant = 'N' THEN 'No'
ELSE SoldAsVacant
END
from PortfolioProject.dbo.NashvilleHousingProject

-- Table updated to reflect the change
UPDATE NashvilleHousingProject
SET SoldAsVacant = CASE
WHEN SoldAsVacant = 'Y' THEN 'Yes'
WHEN SoldAsVacant = 'N' THEN 'No'
ELSE SoldAsVacant
END

---------------------------------------------------------------------------

-- Remove Duplicates using CTE

--Query to find duplicates
Select *,
ROW_NUMBER() OVER(
PARTITION BY ParcelID, Property Address, SalePrice,SaleDate,LegalReference
ORDER BY UniqueID) Row_Num
from PortfolioProject.dbo.NashvilleHousingProject
Order By ParcelID

--CTE
WITH RowNumCTE AS(
Select *,
ROW_NUMBER() OVER(
PARTITION BY ParcelID, PropertyAddress, SalePrice,SaleDate,LegalReference
ORDER BY UniqueID) Row_Num
from PortfolioProject.dbo.NashvilleHousingProject
)
Select *
From RowNumCTE
where row_num >1
order by PropertyAddress

-- Deleting Duplicates
WITH RowNumCTE AS(
Select *,
ROW_NUMBER() OVER(
PARTITION BY ParcelID, PropertyAddress, SalePrice,SaleDate,LegalReference
ORDER BY UniqueID) Row_Num
from PortfolioProject.dbo.NashvilleHousingProject
)
Delete
From RowNumCTE
where row_num >1
--order by PropertyAddress

----------------------------------------------------------------------------------
-- Delete Unused Columns

ALTER TABLE PortfolioProject.dbo.NashvilleHousingProject
DROP COLUMN OwnerAddress, PropertyAddress

