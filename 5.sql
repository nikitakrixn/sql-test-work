USE columbus;

CREATE TABLE Product(
	[ProdID] [bigint] IDENTITY(1,1) NOT NULL PRIMARY KEY CLUSTERED,
	[Name] [nvarchar](50) NOT NULL,
	[Price] [numeric](18,5) NOT NULL,
)
GO

CREATE TABLE Sales(
	[Date] [datetime] DEFAULT (getdate()) NOT NULL,
	[ProdID] [bigint] NOT NULL REFERENCES Product(ProdID),
	[Sum] [numeric](18,5) NOT NULL,
)
GO

INSERT INTO Product(Name,Price) 
VALUES 
('Видеокарта GTX-650', 7500),
('Видеокарта GTX-660 ti', 8500),
('Видеокарта GTX-1050 ti', 10500),
('Клавиатура Defender x5d2', 1000),
('Наушники SteelSeries Siberia', 3500),
('Razen kraken 2H', 5500)

INSERT INTO Sales(Date,ProdID,Sum)
VALUES
('18.06.2021 00:00:00',1,7500),
('22.06.2021 00:00:00',2,8500),
('25.06.2021 00:00:00',3,10500),
('22.06.2021 00:00:00',4,1000),
('22.06.2021 00:00:00',5,3500),
('21.06.2021 00:00:00',6,5500),
('21.06.2021 00:00:00',1,7500), 
('21.05.2021 00:00:00',2,8500), 
('21.06.2021 00:00:00',3,10500), 
('21.05.2021 00:00:00',4,1000),
('22.06.2021 00:00:00',5,3500),
('21.05.2021 00:00:00',6,5500)
GO

CREATE VIEW SalesAmount
AS
SELECT TOP(1) p.Name as 'Название продукта', SUM(s.Sum) as 'Сумма'
FROM Product p INNER JOIN Sales s ON p.ProdID = s.ProdID
WHERE MONTH(s.Date) = '6' AND YEAR(s.Date) = '2021'
GROUP BY p.Name
ORDER BY SUM(s.Sum) DESC
GO