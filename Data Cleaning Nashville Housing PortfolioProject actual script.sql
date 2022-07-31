/****** Script for SelectTopNRows command from SSMS  ******/
--SELECT TOP (1000) [UniqueID ]
      ,[ParcelID]
      ,[LandUse]
      ,[PropertyAddress]
      ,[SaleDate]
      ,[SalePrice]
      ,[LegalReference]
      ,[SoldAsVacant]
      ,[OwnerName]
      ,[OwnerAddress]
      ,[Acreage]
      ,[TaxDistrict]
      ,[LandValue]
      ,[BuildingValue]
      ,[TotalValue]
      ,[YearBuilt]
      ,[Bedrooms]
      ,[FullBath]
      ,[HalfBath]
 -- FROM [PortfolioProject].[dbo].[NashvilleHousing]

 SELECT *
 FROM PortfolioProject..NashvilleHousing

 --Standardize date format

 Select SaleDate, CONVERT(Date, SaleDate)
 From PortfolioProject..NashvilleHousing

 Update NashvilleHousing
 SET SaleDate = CONVERT(Date, SaleDate) 

 ALTER TABLE NashvilleHousing
 ADD SaleDateConverted Date

  Update NashvilleHousing
 SET SaleDateConverted = CONVERT(Date, SaleDate) 

 Select SaleDateConverted, CONVERT(Date, SaleDate)
 From PortfolioProject..NashvilleHousing

 --Populate Property address data

  Select *
  From PortfolioProject..NashvilleHousing
 -- Where PropertyAddress is null
 order by ParcelID

 
  Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
  From PortfolioProject..NashvilleHousing a
  JOIN PortfolioProject..NashvilleHousing b
  on a.ParcelID = b.ParcelID
  AND a.[UniqueID] <> b.[UniqueID]
  where a.PropertyAddress  is null


  Update a
  SET PropertyAddress =  ISNULL(a.PropertyAddress,b.PropertyAddress)
  From PortfolioProject..NashvilleHousing a
  JOIN PortfolioProject..NashvilleHousing b
  on a.ParcelID = b.ParcelID
  AND a.[UniqueID] <> b.[UniqueID]
    where a.PropertyAddress  is null

--Breaking address into different columns (Address, City, State)
--We introduce CHARINDEX which basically specifies the position of a specific value within the address string
--Also we use the LEN to specify (end of the string) that the character takes the length of the address beginning from what has been specified 

Select PropertyAddress
From PortfolioProject..NashvilleHousing

SELECT 
SUBSTRING(Propertyaddress,1,CHARINDEX(',',PropertyAddress)-1) as Address
, SUBSTRING(Propertyaddress,CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress)) as Address
From PortfolioProject..NashvilleHousing

-- We cannot have two columns with the same name, therefore we need to create additional comulns for the split address and split city. 
--To achieve this we use Alter table and Update statements 

 ALTER TABLE PortfolioProject..NashvilleHousing
 ADD PropertySplitAddress Nvarchar(255);

  UPDATE PorTfolioProject..NashvilleHousing
 SET PropertySplitAddress = SUBSTRING(PropertyAddress,1, CHARINDEX(',', PropertyAddress)-1)


 ALTER TABLE PortfolioProject..NashvilleHousing
 ADD PropertySplitCity Nvarchar(255);

  Update PortfolioProject..NashvilleHousing
 SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))


 Select *

 From PortfolioProject..NAshvilleHousing



  Select *
 From PortfolioProject..NAshvilleHousing




 Select OwnerAddress
 From PortfolioProject..NashvilleHousing

 --Using PARSENAME statement to Split the OwnerAddress Column

 Select
 PARSENAME(REPLACE(OwnerAddress,',','.'),3) 
 ,PARSENAME(REPLACE(OwnerAddress,',','.'),2) 
 ,PARSENAME(REPLACE(OwnerAddress,',','.'),1) 
 From PortfolioProject..NashvilleHousing

 -- Update the tables by using alter statement to input the splitted columns for Owner Address 
 -- First run the alter statement separately before the Update statement to avoid error

 ALTER TABLE PortfolioProject..NashvilleHousing
 ADD OwnerSplitAddress Nvarchar(255);

  UPDATE PorTfolioProject..NashvilleHousing
 SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3) 


 ALTER TABLE PortfolioProject..NashvilleHousing
 ADD OwnerSplitCity Nvarchar(255);

  Update PortfolioProject..NashvilleHousing
 SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2) 



 ALTER TABLE PortfolioProject..NashvilleHousing
 ADD OwnerSplitState Nvarchar(255);

  Update PortfolioProject..NashvilleHousing
 SET OwnerSplitState =PARSENAME(REPLACE(OwnerAddress,',','.'),1)


 Select *
 From PortfolioProject..NAshvilleHousing


 Select Distinct(SoldAsVacant), Count(SoldAsVacant)
  From PortfolioProject..NAshvilleHousing
  Group by SoldAsVacant
  Order by 2

  --The above query output is not uniform hence the next action, using key statements

 Select SoldAsVacant,
  CASE When SoldAsVacant = 'Y' THEN 'Yes'
       When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
From PortfolioProject..NAshvilleHousing

--Update the table to apply the above adjustment to column SoldAsVacant

UPDATE PortfolioProject..NashvilleHousing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
       When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END

--Re-run the previous query to confirm if the update statement is not broken

 Select Distinct(SoldAsVacant), Count(SoldAsVacant)
  From PortfolioProject..NashvilleHousing
  Group by SoldAsVacant
  Order by 2

  -- Removing Duplicates 

  WITH RowNumCTE AS(
  Select *,
    ROW_NUMBER()OVER (
	PARTITION BY ParcelID,
	             PropertyAddress,
				 SalePrice, 
				 SaleDate, 
				 LegalReference
				 ORDER BY
				 UniqueID
				 ) row_num

	From PortfolioProject..NashvilleHousing
	)
	SELECT *
	From RowNumCTE
	where row_num >1
	order by PropertyAddress

	--The above CTE and Partition query will return the rows with duplicates, the delete statement below will help get rid of the duplicates 
	
	WITH RowNumCTE AS(
  Select *,
    ROW_NUMBER()OVER (
	PARTITION BY ParcelID,
	             PropertyAddress,
				 SalePrice, 
				 SaleDate, 
				 LegalReference
				 ORDER BY
				 UniqueID
				 ) row_num

	From PortfolioProject..NashvilleHousing
	)
    DELETE 
	From RowNumCTE
	where row_num >1
	--order by PropertyAddress


--DELETE UNUSED COLUMNS

 Select *
 From PortfolioProject..NashvilleHousing

 ALTER TABLE PortfolioProject..NashvilleHousing
 DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

 
 ALTER TABLE PortfolioProject..NashvilleHousing
 DROP COLUMN SaleDate
