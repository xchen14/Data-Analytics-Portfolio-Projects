/*
Cleaning Data with SQL Queries

SQL Skills Used: Convert, Update, Delete, Alter, Populating Data, Substrings, Parsenames, CTE's, Temp Tables
*/

Select *
FROM PortfolioProject..NashvilleHousing

-----------------------------------------------------------------------------------------------------------------
-- Standardizing Date Format
Select SaleDate, Convert(Date, SaleDate)
From PortfolioProject..NashvilleHousing

Update NashvilleHousing
SET SaleDate = Convert(Date, SaleDate)

-- Alternative Method
Select SaleDateConverted
From PortfolioProject..NashvilleHousing

ALTER TABLE NashvilleHousing
Add SaleDateConverted Date;

Update NashvilleHousing
SET SaleDateConverted = Convert(Date, SaleDate)

-----------------------------------------------------------------------------------------------------------------
-- Populate Property Address Data
Select PropertyAddress 
From PortfolioProject..NashvilleHousing
Where PropertyAddress is Null 

Select *
From PortfolioProject..NashvilleHousing
Order by ParcelID

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL (a.PropertyAddress, b.PropertyAddress)
From PortfolioProject..NashvilleHousing a
JOIN PortfolioProject..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID] <> b.[UniqueID]
Where a.PropertyAddress is null

Update a
SET PropertyAddress = ISNULL (a.PropertyAddress, b.PropertyAddress)
From PortfolioProject..NashvilleHousing a
JOIN PortfolioProject..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID] <> b.[UniqueID]
Where a.PropertyAddress is null

-----------------------------------------------------------------------------------------------------------------
-- Breaking out Address Into Individual Columns (Address, City, State)
Select PropertyAddress
From PortfolioProject..NashvilleHousing

-- Splitting the PropertyAddress Column to PropertySplitAddress and PropertySplitCity using substrings
SELECT
Substring(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1) as Address
, Substring(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) as City
From PortfolioProject..NashvilleHousing

ALTER TABLE NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

Update NashvilleHousing
SET PropertySplitAddress = Substring(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1)

ALTER TABLE NashvilleHousing
Add PropertySplitCity Nvarchar(255);

Update NashvilleHousing
SET PropertySplitCity = Substring(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress))

Select PropertySplitAddress, PropertySplitCity
From PortfolioProject..NashvilleHousing

-- Splitting the OwnerAddress Column to OwnerSplitAddress and OwnerSplitCity using parse names.
Select OwnerAddress
From PortfolioProject..NashvilleHousing

Select
Parsename (REPLACE(OwnerAddress, ',', '.'),3)
,Parsename (REPLACE(OwnerAddress, ',', '.'),2)
,Parsename (REPLACE(OwnerAddress, ',', '.'),1)
From PortfolioProject..NashvilleHousing

ALTER TABLE NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitAddress = Parsename (REPLACE(OwnerAddress, ',', '.'),3)

ALTER TABLE NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitCity = Parsename (REPLACE(OwnerAddress, ',', '.'),2)

ALTER TABLE NashvilleHousing
Add OwnerSplitState Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitState = Parsename (REPLACE(OwnerAddress, ',', '.'),1)

Select OwnerSplitAddress, OwnerSplitCity, OwnerSplitState
From PortfolioProject..NashvilleHousing
-----------------------------------------------------------------------------------------------------------------
-- Change Y and N to yes and No in "Sold as Vacant" field
Select Distinct (SoldAsVacant), count(SoldAsVacant)
From PortfolioProject..NashvilleHousing
Group by SoldAsVacant
Order by 2

Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'Yes'
		When SoldAsVacant = 'N' THEN 'No'
		Else SoldAsVacant
		END
From PortfolioProject..NashvilleHousing

Update NashvilleHousing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
		When SoldAsVacant = 'N' THEN 'No'
		Else SoldAsVacant
		END

-----------------------------------------------------------------------------------------------------------------
-- Remove Duplicates
WITH RowNumCTE as (
Select *, 
	ROW_NUMBER() OVER (
	Partition by ParcelID,
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
	Order by UniqueID
	) row_num
From PortfolioProject..NashvilleHousing
)

--DELETE
--From RowNumCTE
--Where row_num > 1

Select *
From RowNumCTE
Where row_num > 1
Order by PropertyAddress
-----------------------------------------------------------------------------------------------------------------
-- Delete (Usually not advised unless it's in a temp table)
Select *
From PortfolioProject..NashvilleHousing

Alter Table PortfolioProject..NashvilleHousing
Drop Column OwnerAddress, TaxDistrict, PropertyAddress, SaleDate
