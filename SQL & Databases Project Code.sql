-- 1.1 Query

SELECT 
  product.ProductId, 
  product.Name, 
  product.ProductNumber, 
  product.Size, 
  product.Color, 
  product.ProductSubcategoryId, 
  productsubcategory.Name AS SubCategory
FROM
  tc-da-1.adwentureworks_db.product AS product
JOIN 
  tc-da-1.adwentureworks_db.productsubcategory AS productsubcategory
USING (ProductSubcategoryId)
ORDER BY
  SubCategory;

-- 1.2 Query

SELECT 
  product.ProductId, 
  product.Name, 
  product.ProductNumber, 
  product.Size, 
  product.Color, 
  product.ProductSubcategoryId, 
  productsubcategory.Name AS SubCategory,
  productcategory.Name AS Category
FROM
  tc-da-1.adwentureworks_db.product AS product
JOIN 
  tc-da-1.adwentureworks_db.productsubcategory AS productsubcategory
ON 
  product.ProductSubcategoryId = productsubcategory.ProductSubcategoryId
JOIN
  tc-da-1.adwentureworks_db.productcategory AS productcategory
ON 
  productcategory.ProductCategoryID = productsubcategory.ProductCategoryID
ORDER BY
  Category;

-- 1.3 Query

SELECT 
  product.ProductId, 
  product.Name, 
  product.ProductNumber, 
  product.Size, 
  product.Color, 
  product.ListPrice,
  product.ProductSubcategoryId, 
  productsubcategory.Name AS SubCategory,
  productcategory.Name AS Category
FROM
  tc-da-1.adwentureworks_db.product AS product
JOIN 
  tc-da-1.adwentureworks_db.productsubcategory AS productsubcategory
ON 
  product.ProductSubcategoryId = productsubcategory.ProductSubcategoryId
JOIN
  tc-da-1.adwentureworks_db.productcategory AS productcategory
ON 
  productcategory.ProductCategoryID = productsubcategory.ProductCategoryID
WHERE 
  product.ListPrice > 2000
  AND product.SellEndDate IS NULL
ORDER BY 
  product.ListPrice DESC;

-- 2.1 Query

SELECT 
  workorderrouting.LocationID,
  COUNT(DISTINCT workorder.WorkOrderID) AS no_work_orders,
  COUNT(DISTINCT workorder.ProductID) AS no_unique_products,
  SUM(workorderrouting.ActualCost) AS actual_cost
FROM
  tc-da-1.adwentureworks_db.workorder AS workorder
JOIN 
  tc-da-1.adwentureworks_db.workorderrouting AS workorderrouting
ON
  workorder.WorkOrderID = workorderrouting.WorkOrderID
WHERE
  workorderrouting.ActualStartDate >= '2004-01-01' AND workorderrouting.ActualStartDate < '2004-02-01'
GROUP BY 
  workorderrouting.LocationID
ORDER BY
  no_work_orders DESC;

-- 2.2 Query

SELECT 
  workorderrouting.LocationID,
  location.Name AS location,
  COUNT(DISTINCT workorder.WorkOrderID) AS no_work_orders,
  COUNT(DISTINCT workorder.ProductID) AS no_unique_products,
  SUM(workorderrouting.ActualCost) AS actual_cost,
  ROUND(AVG(DATE_DIFF(workorderrouting.ActualEndDate, workorderrouting.ActualStartDate, DAY)),2) AS avg_days_diff
FROM
  tc-da-1.adwentureworks_db.workorder AS workorder
JOIN 
  tc-da-1.adwentureworks_db.workorderrouting AS workorderrouting
ON
  workorder.WorkOrderID = workorderrouting.WorkOrderID
JOIN
  tc-da-1.adwentureworks_db.location AS location
ON
  location.LocationID = workorderrouting.LocationID
WHERE
  workorderrouting.ActualStartDate >= '2004-01-01' AND workorderrouting.ActualStartDate < '2004-02-01'
GROUP BY 
  workorderrouting.LocationID, location
ORDER BY
  no_work_orders DESC;

-- 2.3 Query

SELECT 
  workorderrouting.WorkOrderID,
  SUM(workorderrouting.ActualCost) AS actual_cost
FROM
  tc-da-1.adwentureworks_db.workorderrouting AS workorderrouting
WHERE
  workorderrouting.ActualStartDate >= '2004-01-01' AND workorderrouting.ActualStartDate < '2004-02-01'
GROUP BY 
  workorderrouting.WorkOrderID
HAVING 
  SUM(workorderrouting.ActualCost) > 300;

-- 3.1 Query

WITH deduplicated_sales AS (
    SELECT 
        DISTINCT sales_detail.SalesOrderId,
        sales_detail.OrderQty,
        sales_detail.UnitPrice,
        sales_detail.LineTotal,
        sales_detail.ProductId,
        sales_detail.SpecialOfferID
    FROM 
        `tc-da-1.adwentureworks_db.salesorderdetail` AS sales_detail
),
deduplicated_offers AS (
    SELECT 
        DISTINCT ProductID,
        SpecialOfferID,
        ModifiedDate
    FROM 
        `tc-da-1.adwentureworks_db.specialofferproduct`
),
deduplicated_spec_offers AS (
    SELECT 
        DISTINCT SpecialOfferID,
        Category,
        Description
    FROM 
        `tc-da-1.adwentureworks_db.specialoffer`
)

SELECT 
    sales_detail.SalesOrderId,
    sales_detail.OrderQty,
    sales_detail.UnitPrice,
    sales_detail.LineTotal,
    sales_detail.ProductId,
    sales_detail.SpecialOfferID,
    spec_offer_product.ModifiedDate,
    spec_offer.Category,
    spec_offer.Description
FROM 
    deduplicated_sales AS sales_detail
LEFT JOIN 
    deduplicated_offers AS spec_offer_product ON sales_detail.ProductId = spec_offer_product.ProductID AND sales_detail.SpecialOfferID = spec_offer_product.SpecialOfferID
LEFT JOIN 
    deduplicated_spec_offers AS spec_offer ON sales_detail.SpecialOfferID = spec_offer.SpecialOfferID
ORDER BY 
    LineTotal DESC;

-- 3.2 Query

SELECT 
  vendor.VendorID,
  vendor_contact.ContactID, 
  vendor_contact.ContactTypeID, 
  vendor.Name, 
  vendor.CreditRating, 
  vendor.ActiveFlag, 
  address.AddressID,
  address.City
FROM 
  tc-da-1.adwentureworks_db.vendor AS vendor
LEFT JOIN 
  tc-da-1.adwentureworks_db.vendorcontact AS vendor_contact 
ON
  vendor.VendorID = vendor_contact.VendorID 
LEFT JOIN 
  tc-da-1.adwentureworks_db.vendoraddress AS vendor_address 
ON 
  vendor.VendorID = vendor_address.VendorID
LEFT JOIN 
  tc-da-1.adwentureworks_db.address AS address 
ON 
  vendor_address.AddressID = address.AddressID;