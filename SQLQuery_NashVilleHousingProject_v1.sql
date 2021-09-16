/* Cleaning data with SQL queries Project

Changelog

This file contains the following changes to the project
Version 2.0 (09-16-2021)

New
	- Added column (SaleDateConverted, Address, City, Street)

Changes
	- Changed Date Format (SalesDateConverted : impossible to convert directly, had to create a new column)
	- Removed duplicates
	- Removed columns (OwnerName, OwnerAddress, TaxDistrict, PropertyAddress, SaleDate)
Fixes
	- Removed random whitespaces (Address, Street)
	- Replaced missing addresses by populating data
	- Standardized expressions (LandUse, SoldAsVacant)

*/

SELECT *
FROM NashvilleHousing..nashville_housing;

-- Standardize date format
SELECT SaleDate, SaleDateConverted
FROM NashvilleHousing..nashville_housing

ALTER TABLE nashville_housing
ADD SaleDateConverted date

UPDATE nashville_housing
SET SaleDateConverted = CONVERT(date, SaleDate)

-- Populate Property Address data (replace NULL values)

SELECT *
FROM NashvilleHousing..nashville_housing
WHERE PropertyAddress is null
ORDER BY ParcelID

SELECT a.[UniqueID ], a.ParcelID, a.PropertyAddress, b.[UniqueID ], b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM NashvilleHousing..nashville_housing a
JOIN NashvilleHousing..nashville_housing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM NashvilleHousing..nashville_housing a
JOIN NashvilleHousing..nashville_housing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null

-- Breaking out Address into individuals Columns (Adress, City, State)

SELECT 
	PropertyAddress
	, SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address
	, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) as City
	, 
FROM NashvilleHousing..nashville_housing;

ALTER TABLE nashville_housing
ADD Address nvarchar(255);

UPDATE nashville_housing
SET Address = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1);

ALTER TABLE nashville_housing
ADD City nvarchar(255);

UPDATE nashville_housing
SET City = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress));

ALTER TABLE nashville_housing
ADD Street nvarchar(255);

UPDATE nashville_housing
SET Street =   SUBSTRING(Address, CHARINDEX(' ',Address)+1, LEN(Address));

-- Suppress whitespaces existing at the end of adress names
SELECT 
	Street
	, LEN(Street) as len_street
	, Address
	, LEN (Address) as len_adress
FROM NashvilleHousing..nashville_housing;

UPDATE nashville_housing
SET Street =   TRIM(Street);

UPDATE nashville_housing
SET Address = TRIM(Address);

-- Correct double whitespace existing sometimes in Adress and Street columns
UPDATE nashville_housing
SET Street = REPLACE(Street, '  ', ' ')

UPDATE nashville_housing
SET Address = REPLACE(Address, '  ', ' ')

-- Standardize LandUse names
UPDATE nashville_housing
SET LandUse = 'VACANT RESIDENTIAL LAND'
WHERE LandUse = 'VACANT RES LAND' 
OR LandUse = 'VACANT RESIENTIAL LAND'; 

-- Standardize SoldAsVacant
SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM NashvilleHousing..nashville_housing
GROUP BY SoldAsVacant
ORDER BY SoldAsVacant;

UPDATE nashville_housing
SET SoldAsVacant = 'No'
WHERE SoldAsVacant = 'N' ;

UPDATE nashville_housing
SET SoldAsVacant = 'Yes'
WHERE SoldAsVacant = 'Y' ;

-- Remove Duplicates

DELETE DuplicateTable
FROM
(
SELECT *
	, ROW_NUMBER() OVER(
	PARTITION BY ParcelID
				, PropertyAddress
				, SaleDate
				, LegalReference
	ORDER BY (SELECT NULL)
	) as Duplicates
FROM NashvilleHousing..nashville_housing
)
AS DuplicateTable
WHERE Duplicates > 1;

-- Delete Unused Columns

SELECT *
FROM NashvilleHousing..nashville_housing;

ALTER TABLE nashville_housing
DROP COLUMN OwnerName, OwnerAddress, TaxDistrict, PropertyAddress, SaleDate;