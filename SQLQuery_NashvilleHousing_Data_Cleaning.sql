/*
Data Cleaning using SQL
NashvilleHousing Dataset Obtained from Kaggle
Environment:- Microsoft SQL Server
*/

--------------------------------------------------------------------------------------------------------
--Data Cleaning in SQL

SELECT *
FROM PortfolioProject1.dbo.NashvilleHousing

--------------------------------------------------------------------------------------------------------

--Standardizing Date Format

ALTER TABLE NashvilleHousing
ADD SaleDateConverted Date;

UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate)

SELECT SaleDateConverted, CONVERT(Date,SaleDate)
FROM PortfolioProject1.dbo.NashvilleHousing

--------------------------------------------------------------------------------------------------------

--Populate Property Address Data

--Searching for a trend to populate that particular column
Select *
From PortfolioProject1.dbo.NashvilleHousing
Where PropertyAddress is null
order by ParcelID

--
SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM PortfolioProject1.dbo.NashvilleHousing a
JOIN PortfolioProject1.dbo.NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM PortfolioProject1.dbo.NashvilleHousing a
JOIN PortfolioProject1.dbo.NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

--------------------------------------------------------------------------------------------------------

--Splitting Full Address into Individual columns as Address, City and State

SELECT PropertyAddress
FROM PortfolioProject1.dbo.NashvilleHousing

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) AS Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) AS City
FROM PortfolioProject1.dbo.NashvilleHousing

ALTER TABLE PortfolioProject1.dbo.NashvilleHousing
ADD PropertySplitAddress NVARCHAR(255);

UPDATE PortfolioProject1.dbo.NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

ALTER TABLE PortfolioProject1.dbo.NashvilleHousing
ADD PropertySplitCity NVARCHAR(255);

UPDATE PortfolioProject1.dbo.NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))

--After the successful creation of the two columns we can clearly see the the PropertyAddress split into two parts
--at the end of the table

SELECT *
FROM PortfolioProject1.dbo.NashvilleHousing

--NOW!! I am doing the same thing as above but this time using PARSENAME method for the OwnerAddress splitting

SELECT PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)
, PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)
, PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
FROM PortfolioProject1.dbo.NashvilleHousing


ALTER TABLE PortfolioProject1.dbo.NashvilleHousing
ADD OwnerSplitAddress NVARCHAR(255);

UPDATE PortfolioProject1.dbo.NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

ALTER TABLE PortfolioProject1.dbo.NashvilleHousing
ADD OwnerSplitCity NVARCHAR(255);

UPDATE PortfolioProject1.dbo.NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

ALTER TABLE PortfolioProject1.dbo.NashvilleHousing
ADD OwnerSplitState NVARCHAR(255);

UPDATE PortfolioProject1.dbo.NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)


SELECT *
FROM PortfolioProject1.dbo.NashvilleHousing

--------------------------------------------------------------------------------------------------------

--Changing Y and N to Yes and No in "Sold As Vacant" field

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM PortfolioProject1.dbo.NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2


SELECT SoldAsVacant
,CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	  WHEN SoldAsVacant = 'N' THEN 'No'
	  ELSE SoldAsVacant
	  END
FROM PortfolioProject1.dbo.NashvilleHousing

UPDATE PortfolioProject1.dbo.NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	  WHEN SoldAsVacant = 'N' THEN 'No'
	  ELSE SoldAsVacant
	  END

--------------------------------------------------------------------------------------------------------

--Removing Duplicates

--The below query deletes all the duplicate rows(104 rows in this data) using a CTE
--Although in professional workspace it is not recommended to delete data from the raw source unless we have a copy
WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
		     PropertyAddress,
                     SalePrice,
                     SaleDate,
		     LegalReference
	ORDER BY
                    UniqueID
                    )row_num

FROM PortfolioProject1.dbo.NashvilleHousing
)
DELETE
FROM RowNumCTE
WHERE row_num > 1

-- The below query checks if there is any duplicate data remaining as it returns none so no duplicate data.
WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
		     PropertyAddress,
                     SalePrice,
                     SaleDate,
		     LegalReference
	 ORDER BY
                    UniqueID
                    )row_num

FROM PortfolioProject1.dbo.NashvilleHousing
)
SELECT *
FROM RowNumCTE
WHERE row_num > 1

--------------------------------------------------------------------------------------------------------

--Delete Unused columns

SELECT *
FROM PortfolioProject1.dbo.NashvilleHousing

ALTER TABLE PortfolioProject1.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, SaleDate, PropertyAddress
