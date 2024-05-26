
/*

Cleaning Data in SQL Queries

*/


--Check the overall data
--
SELECT *
FROM Portfolio..NashvilleHousing
--


--Standardize Date Format
--
SELECT SaleDate, CONVERT(Date,SaleDate)
FROM Portfolio..NashvilleHousing

ALTER TABLE Portfolio..NashvilleHousing
Add SaleDateConverted Date;

UPDATE Portfolio..NashvilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate)

SELECT SaleDate, SaleDateConverted
FROM Portfolio..NashvilleHousing
--


--Populate PropertyAddress Data
--
SELECT *
FROM Portfolio..NashvilleHousing
WHERE PropertyAddress is null
ORDER BY ParcelID
--
SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM Portfolio..NashvilleHousing as a
JOIN Portfolio..NashvilleHousing as b
  ON a.ParcelID = b.ParcelID
  AND a.[UniqueID ]<> b.[UniqueID ]
WHERE a.PropertyAddress is null
--
UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM Portfolio..NashvilleHousing as a
JOIN Portfolio..NashvilleHousing as b
  ON a.ParcelID = b.ParcelID
  AND a.[UniqueID ]<> b.[UniqueID ]
WHERE a.PropertyAddress is null
--


--Breaking out Address into Individual Columns (Address, City, State)
--
SELECT *
FROM Portfolio..NashvilleHousing
--
--Use SUBSTRING for PropertyAddress
--
SELECT
SUBSTRING(PropertyAddress, 1,CHARINDEX(',', PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) as City
FROM Portfolio..NashvilleHousing
--
ALTER TABLE Portfolio..NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

UPDATE Portfolio..NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1,CHARINDEX(',', PropertyAddress)-1)

ALTER TABLE Portfolio..NashvilleHousing
Add PropertySplitCity Nvarchar(255);

UPDATE Portfolio..NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))
--
--Use PARSENAME for OwnerAddress
--
SELECT 
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1) as OwnerAddressState,
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2) as OwnerAddressCity,
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3) as OwnerAddressStreet
FROM Portfolio..NashvilleHousing
--
ALTER TABLE Portfolio..NashvilleHousing
Add OwnerAddressStreet Nvarchar(255),
    OwnerAddressCity Nvarchar(255),
    OwnerAddressState Nvarchar(255);

UPDATE Portfolio..NashvilleHousing
SET OwnerAddressStreet = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

UPDATE Portfolio..NashvilleHousing
SET OwnerAddressCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

UPDATE Portfolio..NashvilleHousing
SET OwnerAddressState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
--


--Change (Y/N) to (Yes/No) in SoldAsVacant 
--
SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM Portfolio..NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2 desc

SELECT SoldAsVacant,
CASE when SoldAsVacant = 'Y' then 'Yes'
     when SoldAsVacant = 'N' then 'NO'
	 ELSE SoldAsVacant
	 END
FROM Portfolio..NashvilleHousing

UPDATE NashvilleHousing
SET SoldAsVacant = 
CASE when SoldAsVacant = 'Y' then 'Yes'
     when SoldAsVacant = 'N' then 'NO'
	 ELSE SoldAsVacant
	 END
--


--Remove Duplicates (!not on raw data!)
--
WITH RowNumCTE as 
	(
	SELECT *,
	ROW_NUMBER() OVER (PARTITION BY ParcelID,
	PropertyAddress,
	SalePrice,
	SaleDate,
	LegalReference
	ORDER BY UniqueID
	) as row_num
FROM Portfolio..NashvilleHousing
)
SELECT *
--DELETE
FROM RowNumCTE
WHERE row_num > 1
--


--Delete Unused Columns (!not on raw data!)
--
SELECT *
FROM Portfolio..NashvilleHousing

ALTER TABLE Portfolio..NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress ,SaleDate
--
