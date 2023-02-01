--- Cleaning Data in SQL

Select *
From dbo.NSHhousing

--- Standardize Date Format
Select SaleDate, CONVERT (Date, SaleDate)
From dbo.NSHhousing

Update NSHhousing
Set SaleDate = CONVERT(Date, SaleDate)

Alter Table NSHhousing
Add SaleDateConverted Date;

Update dbo.NSHhousing
Set SaleDateConverted = CONVERT(Date, SaleDate)


Select SaleDateConverted, SaleDate
From dbo.NSHhousing


--- Populate Property Address data

SELECT *
FROM dbo.NSHhousing
WHERE PropertyAddress IS NULL
ORDER BY ParcelID

SELECT a.ParcelID, a.PropertyAddress, c.ParcelID, c.PropertyAddress, ISNULL(a.PropertyAddress, c.PropertyAddress)
FROM dbo.NSHhousing a
JOIN dbo.NSHhousing c
	ON a.ParcelID = c.ParcelID
	AND a.[UniqueID ] <> c.[UniqueID ]
WHERE a.PropertyAddress IS NULL

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, c.PropertyAddress)
FROM dbo.NSHhousing a
JOIN dbo.NSHhousing c
	ON a.ParcelID = c.ParcelID
	AND a.[UniqueID ] <> c.[UniqueID ]
	

--- Breaking out Address into individual columns (Address, City, State)
SELECT PropertyAddress
FROM dbo.NSHhousing
--WHERE PropertyAddress IS NULL
--ORDER BY ParcelID

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) as Address
From dbo.NSHhousing

ALTER TABLE NSHhousing
ADD PropertySplitAddress Nvarchar(255);

UPDATE NSHhousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

ALTER TABLE NSHhousing
ADD PropertySplitCity Nvarchar(255);

UPDATE NSHhousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))

SELECT PropertySplitAddress, PropertySplitCity
FROM dbo.NSHhousing


--- Parsing Name of Owner Address
SELECT OwnerAddress
FROM dbo.NSHhousing

SELECT 
PARSENAME (REPLACE(OwnerAddress,',','.'),3)
,PARSENAME (REPLACE(OwnerAddress,',','.'),2)
,PARSENAME (REPLACE(OwnerAddress,',','.'),1)
FROM dbo.NSHhousing

ALTER TABLE NSHhousing
ADD OwnerSplitAddress Nvarchar(255);

ALTER TABLE NSHhousing
ADD OwnerCity Nvarchar(255);

ALTER TABLE NSHhousing
ADD OwnerState Nvarchar(255);

UPDATE NSHhousing
SET OwnerSplitAddress = PARSENAME (REPLACE(OwnerAddress,',','.'),3)

UPDATE NSHhousing
SET OwnerCity = PARSENAME (REPLACE(OwnerAddress,',','.'),2)

UPDATE NSHhousing
SET OwnerState = PARSENAME(REPLACE(OwnerAddress, ',','.'),1)

SELECT  OwnerSplitAddress, OwnerCity, OwnerState
FROM dbo.NSHhousing

--- Change Y and N to Yes and No in "Sold as Vacant" field
SELECT DISTINCT (SoldAsVacant),COUNT(SoldAsVacant)
FROM dbo.NSHhousing
GROUP BY SoldAsVacant
ORDER BY 2

SELECT SoldAsVacant
, CASE WHEN SoldAsVacant ='Y' THEN 'Yes'
	   WHEN SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
FROM dbo.NSHhousing

UPDATE NSHhousing
SET SoldAsVacant = CASE WHEN SoldAsVacant ='Y' THEN 'Yes'
	   WHEN SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END

--- Remove duplicates

WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER () OVER(
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY 
					UniqueID
					) row_num
FROM dbo.NSHhousing
)
DELETE
FROM RowNumCTE
WHERE row_num > 1

SELECT *
FROM RowNumCTE
WHERE row_num >1
---ORDER BY PropertyAddress
---ORDER BY ParcelID


SELECT *
FROM dbo.NSHhousing

--- Delete Unused Columns

SELECT *
FROM dbo.NSHhousing

ALTER TABLE NSHhousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate