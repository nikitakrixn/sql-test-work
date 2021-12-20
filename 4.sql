USE columbus;

/**** ������ ������� ������� ****/
CREATE TABLE CustTable(
	[AccountNum] [bigint] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](50) NOT NULL,
CONSTRAINT [PK_CustTable_AccountNum] PRIMARY KEY CLUSTERED(
	[AccountNum] ASC) ON [PRIMARY])
GO

/**** ������ ������� �������� �� ������� ****/
CREATE TABLE CustTrans(
	[AccountNum] [bigint] NOT NULL,
	[TransDate] [datetime] DEFAULT (getdate()) NOT NULL,
	[Amount] [money] NOT NULL,
CONSTRAINT [FK_CustTrans_AccountNum] FOREIGN KEY ([AccountNum]) 
REFERENCES [dbo].[CustTable] ([AccountNum]) ON DELETE CASCADE ON UPDATE CASCADE)
GO

/**** ��������� ������ � ������� ****/
INSERT INTO CustTable(Name) VALUES ('������'),('�����'),('�����'),('������'),('���������'),('���������')
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

/**** ������������� �������������� ****/
CREATE VIEW ClientsAmount
AS
SELECT trans.AccountNum as '��� �������', clients.Name as '��� �������', SUM(trans.Amount) as '����� ��������'
FROM CustTable clients INNER JOIN CustTrans trans ON clients.AccountNum = trans.AccountNum
GROUP BY trans.AccountNum,clients.Name
GO

/**** ������������� ������� �������� � ������� �� ���� �������� � ������ 2021 ****/
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

/**** ��������� ������� ������� � ������������ ������ �������� �� ��������� ������ ****/
CREATE PROCEDURE ClientAmountMaxPeriod 
	@sPeriod datetime,
	@ePeriod datetime
AS
BEGIN
	SELECT TOP(1) trans.AccountNum as '��� �������', clients.Name as '��� �������', SUM(trans.Amount) as '����� ��������'
	FROM CustTable clients INNER JOIN CustTrans trans ON clients.AccountNum = trans.AccountNum
	WHERE (trans.TransDate BETWEEN @sPeriod AND @ePeriod)
	GROUP BY trans.AccountNum,clients.Name
	ORDER BY '����� ��������' DESC
END
GO

/****���������� ��������� ****/
Exec ClientAmountMaxPeriod '01.01.2021 00:00:00','25.06.2021 00:00:00'