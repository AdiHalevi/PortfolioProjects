/*

Cleaning Data in SQL Queries

*/

SELECT *
FROM NashvilleHousing

---------------------------------------------------------------------------------------------
--Standardize Data Format

SELECT SaleDate, CONVERT(Date,SaleDate)
FROM NashvilleHousing

Update NashvilleHousing
SET SaleDate = CONVERT(Date,SaleDate); 

-----another option

ALTER TABLE NashvilleHousing
Add SaleDateConverted Date

Update NashvilleHousing
SET SaleDateConverted =  CONVERT(Date,SaleDate)

SELECT SaleDateConverted
FROM NashvilleHousing

-----------------------------------------------------------------------------------------------

--Populate Property Adress Data

---we can find the same parcelID in multiple records

SELECT *
FROM NashvilleHousing
ORDER BY ParcelID


SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress
FROM NashvilleHousing a
JOIN NashvilleHousing b
     ON a.ParcelID = b.ParcelID
	 AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null


SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM NashvilleHousing a
JOIN NashvilleHousing b
     ON a.ParcelID = b.ParcelID
	 AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM NashvilleHousing a
JOIN NashvilleHousing b
     ON a.ParcelID = b.ParcelID
	 AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null 

-----------------------------------------------------------------------------------------------------------------------------

----Breaking out Adress into individual Columns (Address, City, State)


SELECT PropertyAddress
FROM NashvilleHousing

SELECT SUBSTRING( PropertyAddress, 1, CHARINDEX(',',  PropertyAddress) - 1) as Address ,
SUBSTRING( PropertyAddress, CHARINDEX(',',  PropertyAddress) +1, LEN(PropertyAddress)) as City
FROM NashvilleHousing


ALTER TABLE NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

Update NashvilleHousing
SET PropertySplitAddress =  SUBSTRING( PropertyAddress, 1, CHARINDEX(',',  PropertyAddress) - 1)

ALTER TABLE NashvilleHousing
Add PropertySplitCity Nvarchar(255);

Update NashvilleHousing
SET PropertySplitCity = SUBSTRING( PropertyAddress, CHARINDEX(',',  PropertyAddress) +1, LEN(PropertyAddress))


SELECT * 
FROM NashvilleHousing



SELECT PARSENAME(REPLACE(OwnerAddress, ',', '.'),3),
       PARSENAME(REPLACE(OwnerAddress, ',', '.'),2),
	   PARSENAME(REPLACE(OwnerAddress, ',', '.'),1)
FROM NashvilleHousing

ALTER TABLE NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)


ALTER TABLE NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)



ALTER TABLE NashvilleHousing
Add OwnerSplitState Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)


SELECT * 
FROM NashvilleHousing

--------------------------------------------------------------------------------------------------------------------------------------------------

-- Change Y and N to Yes and No in "Sold as Vacant" field

SELECT DISTINCT(SoldAsVacant), count(SoldAsVacant)
FROM NashvilleHousing
Group by SoldAsVacant
Order by 2

SELECT SoldAsVacant,
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
     WHEN SoldAsVacant = 'N' THEN 'NO'
	 ELSE SoldAsVacant
	 END
FROM NashvilleHousing

Update NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
     WHEN SoldAsVacant = 'N' THEN 'NO'
	 ELSE SoldAsVacant
	 END

--------------------------------------------------------------------------------------------------

-- Remove Duplicates


WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

From NashvilleHousing
--order by ParcelID
)
--DELETE 
SELECT *
From RowNumCTE
Where row_num > 1
---Order by PropertyAddress


--------------------------------------------------------------------------------------------------------------------------

---Delete Unused Columns

SELECT *
FROM NashvilleHousing

ALTER TABLE NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate


