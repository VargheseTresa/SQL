

--========================================================================================
--	Description: Demonstratets how to query and output XML data
--	Author: Tresa Varghese
--========================================================================================


USE TSQL2016;
Go

------------------------------------------------------------------
--		Creating XML from a query output
------------------------------------------------------------------


--	1. Basic XML output, returning fragments only
SELECT 
     Customer.custid
   , Customer.companyname
   , [Order].orderid
   , [Order].orderdate
FROM Sales.Customers AS Customer
   INNER JOIN Sales.Orders AS [Order]
      ON Customer.custid = [Order].custid
WHERE Customer.custid <= 2
   AND [Order].orderid %2 = 0
ORDER BY 
     Customer.custid
   , [Order].orderid
FOR XML RAW;


-- 2. For fully, and nicely aligned XML replace RAW with AUTO
-- and add definition of namespace

WITH XMLNAMESPACES('ER70761-CustomersOrders' AS co)
SELECT 
     Customer.custid
   , Customer.companyname
   , [Order].orderid
   , [Order].orderdate
FROM Sales.Customers AS Customer
   INNER JOIN Sales.Orders AS [Order]
      ON Customer.custid = [Order].custid
WHERE Customer.custid <= 2
   AND [Order].orderid %2 = 0
ORDER BY 
     Customer.custid
   , [Order].orderid
FOR XML AUTO, ELEMENTS, ROOT('CustomersOrders');


-- Order of elements in SELECT and ORDER BY influences the output as well
WITH XMLNAMESPACES('ER70761-CustomersOrders' AS co)
SELECT 
     Customer.companyname
   , Customer.custid
   , [Order].orderid
   , [Order].orderdate
FROM Sales.Customers AS Customer
   INNER JOIN Sales.Orders AS [Order]
      ON Customer.custid = [Order].custid
WHERE Customer.custid <= 2
   AND [Order].orderid %2 = 0
--ORDER BY 
--     Customer.custid
--   , [Order].orderid
FOR XML AUTO, ELEMENTS, ROOT('CustomersOrders');


------------------------------------------------------------------
--		Shredding of XML
------------------------------------------------------------------

-- Let's reverse it, 
-- RUN ALL STATEMENTS, up to and including sproc to remove the DOM, AT ONCE 
-- Store a fully formated XML in variable
DECLARE @DocHandle AS INT;
DECLARE @XmlDocument AS NVARCHAR(1000);
SET @XmlDocument = N'
<CustomersOrders>
   <Customer custid="1">
      <companyname>Customer NRZBB</companyname>
      <Order orderid="10692">
         <orderdate>2015-10-03T00:00:00</orderdate>
      </Order>
      <Order orderid="10702">
         <orderdate>2015-10-13T00:00:00</orderdate>
      </Order>
      <Order orderid="10952">
         <orderdate>2016-03-16T00:00:00</orderdate>
      </Order>
   </Customer>
   <Customer custid="2">
      <companyname>Customer MLTDN</companyname>
      <Order orderid="10308">
         <orderdate>2014-09-18T00:00:00</orderdate>
      </Order>
      <Order orderid="10926">
         <orderdate>2016-03-04T00:00:00</orderdate>
      </Order>
   </Customer>
</CustomersOrders>';

-- Create an internal representation
EXEC sys.sp_xml_preparedocument @DocHandle OUTPUT, @XmlDocument;

-- Attribute- and element-centric mapping
-- Combining flag 8 with flags 1 and 2
SELECT *
FROM OPENXML (@DocHandle, '/CustomersOrders/Customer', 11)
WITH (custid INT, companyname NVARCHAR(40));

-- Remove the DOM
EXEC sys.sp_xml_removedocument @DocHandle;

-- Now check next one using XQuery
-- Run both DECLARE and SELECT statements together
-- Place XML in variable
DECLARE @x AS XML = N'
<CustomersOrders>
   <Customer custid="1">
      <!-- Comment 111 -->
      <companyname>Customer NRZBB</companyname>
      <Order orderid="10692">
         <orderdate>2015-10-03T00:00:00</orderdate>
      </Order>
      <Order orderid="10702">
         <orderdate>2015-10-13T00:00:00</orderdate>
      </Order>
      <Order orderid="10952">
         <orderdate>2016-03-16T00:00:00</orderdate>
      </Order>
   </Customer>
   <Customer custid="2">
      <!-- Comment 222 -->
      <companyname>Customer MLTDN</companyname>
      <Order orderid="10308">
         <orderdate>2014-09-18T00:00:00</orderdate>
      </Order>
      <Order orderid="10952">
         <orderdate>2016-03-04T00:00:00</orderdate>
      </Order>
   </Customer>
</CustomersOrders>';

-- Now select it
SELECT @x.query
(
   'for $i in CustomersOrders/Customer/Order
    let $j := $i/orderdate
    where $i/@orderid < 10900
    order by ($j)[1]
    return
       <Order-orderid-element>
       <orderid>{data($i/@orderid)}</orderid>
       {$j}
    </Order-orderid-element>'
);
