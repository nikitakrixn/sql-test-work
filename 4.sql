USE columbus;

/**** Создаёт таблицу Клиенты ****/
CREATE TABLE CustTable(
	[AccountNum] [bigint] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](50) NOT NULL,
CONSTRAINT [PK_CustTable_AccountNum] PRIMARY KEY CLUSTERED(
	[AccountNum] ASC) ON [PRIMARY])
GO

/**** Создаёт таблицу проводки по клиенту ****/
CREATE TABLE CustTrans(
	[AccountNum] [bigint] NOT NULL,
	[TransDate] [datetime] DEFAULT (getdate()) NOT NULL,
	[Amount] [money] NOT NULL,
CONSTRAINT [FK_CustTrans_AccountNum] FOREIGN KEY ([AccountNum]) 
REFERENCES [dbo].[CustTable] ([AccountNum]) ON DELETE CASCADE ON UPDATE CASCADE)
GO

/**** Добавляем данные в таблицу ****/
INSERT INTO CustTable(Name) VALUES ('Никита'),('Мария'),('Ольга'),('Андрей'),('Александр'),('Елизавета')
INSERT INTO CustTrans(AccountNum,TransDate,Amount) 
VALUES 
(1,'21.01.2021 00:00:00', 60000), 
(2,'22.01.2021 00:00:00', 45000), 
(3,'21.03.2021 00:00:00', 60000), 
(4,'25.02.2021 00:00:00', 40000),
(5,'18.01.2021 00:00:00', 80000),
(6,'15.01.2021 00:00:00', 1337),
(1,'22.02.2021 00:00:00', 80000),
(2,'21.01.2021 00:00:00', 60000),
(6,'25.02.2021 00:00:00', 560000),
(4,'25.06.2021 00:00:00', 780000),
(3,'24.08.2021 00:00:00', 120000)
GO

/**** Представление СуммаПроводков ****/
CREATE VIEW ClientsAmount
AS
SELECT trans.AccountNum as 'Код клиента', clients.Name as 'Имя клиента', SUM(trans.Amount) as 'Сумма проводок'
FROM CustTable clients INNER JOIN CustTrans trans ON clients.AccountNum = trans.AccountNum
GROUP BY trans.AccountNum,clients.Name
GO

/**** Представление Выборка клиентов у которых не было операций в Январе 2021 ****/
CREATE VIEW ClientsDateJanuary
AS
SELECT DISTINCT trans.AccountNum
FROM CustTrans trans
WHERE trans.AccountNum NOT IN (
	SELECT trans.AccountNum
	FROM CustTrans trans 
	WHERE (DATEPART(mm, trans.TransDate) = 01) AND (DATEPART(YYYY, trans.TransDate) = 2021)
	)
GO

/**** Процедура Выборка клиента с максимальной суммой проводок за выбранный период ****/
CREATE PROCEDURE ClientAmountMaxPeriod 
	@sPeriod datetime,
	@ePeriod datetime
AS
BEGIN
	SELECT TOP(1) trans.AccountNum as 'Код клиента', clients.Name as 'Имя клиента', SUM(trans.Amount) as 'Сумма проводок'
	FROM CustTable clients INNER JOIN CustTrans trans ON clients.AccountNum = trans.AccountNum
	WHERE (trans.TransDate BETWEEN @sPeriod AND @ePeriod)
	GROUP BY trans.AccountNum,clients.Name
	ORDER BY 'Сумма проводок' DESC
END
GO

/****Выполнение процедуры ****/
Exec ClientAmountMaxPeriod '01.01.2021 00:00:00','25.06.2021 00:00:00'