use columbus;

CREATE TABLE Отделы(
	[код_отдела] [bigint] IDENTITY(1,1) NOT NULL PRIMARY KEY CLUSTERED,
	[Название] [nvarchar](60) NOT NULL,
)
GO

CREATE TABLE Сотрудники(
	[код_сотрудника] [bigint] IDENTITY(1,1) NOT NULL PRIMARY KEY CLUSTERED,
	[код_отдела] [bigint] NOT NULL REFERENCES Отделы(код_отдела),
	[Фамилия] [nvarchar](60) NOT NULL,
	[Имя] [nvarchar](60) NOT NULL,
	[Отчество] [nvarchar](60) NOT NULL,
	[ДатаРождения] [date] NOT NULL,
	[Отпуск] [bit] NOT NULL DEFAULT 0,
)
GO
ALTER TABLE Сотрудники
ADD Constraint Un_долж Unique(код_сотрудника, код_отдела)
GO

CREATE TABLE Продукты(
	[код_продукта] [bigint] IDENTITY(1,1) NOT NULL PRIMARY KEY CLUSTERED,
	[Название] [nvarchar](60) NOT NULL,
	[Стоимость] [int] NOT NULL DEFAULT 0,
)
GO

CREATE TABLE Календарь(
	[код_даты] [bigint] IDENTITY(1,1) NOT NULL PRIMARY KEY CLUSTERED,
	[Год] [int] NOT NULL,
	[Месяц] [int] NOT NULL,
)
GO

CREATE TABLE ЕжедневныеПродажи(
	[код_продажи] [bigint] IDENTITY(1,1) NOT NULL PRIMARY KEY CLUSTERED,
	[код_продукта] [bigint] NOT NULL  REFERENCES Продукты(код_продукта),
	[Дата] [date] NOT NULL DEFAULT (getdate()),
	[Количество] [int] NOT NULL DEFAULT 0,
)
GO

CREATE TABLE ЕжемесячныйПланПродаж(
	[id_ежемпланпрод] [bigint] IDENTITY(1,1) NOT NULL PRIMARY KEY CLUSTERED,
	[id_продукта] [bigint] NOT NULL REFERENCES Продукты(код_продукта),
	[Месяц] [bigint] NOT NULL REFERENCES Календарь(код_даты),
	[Количество] [int] NOT NULL DEFAULT 0,
)
GO

INSERT INTO Отделы(Название)
VALUES
('Финансовый отдел'),
('Отдел продаж')

INSERT INTO Сотрудники(код_отдела,Фамилия,Имя,Отчество,ДатаРождения,Отпуск)
VALUES
(1,'Иванов','Иван','Иванович','21.06.1993','False'),
(1,'Петров','Петр','Петрович','23.02.1994','true'),
(1,'Смирнова','Наталья','Львовна','02.09.1999','false'),
(2,'Федорова','Ксения','Викторовна','10.05.1985','true'),
(2,'Юдина','Ольга','Игоревна','30.04.1997','false')

INSERT INTO Продукты(Название,Стоимость) VALUES
('Водонагреватель ATLANTIC VERTIGO STEATITE Essenеtial 50', 17370),
('Водонагреватель Haier ES50V-F1(R)', 19490),
('Газовая плита Гефест 3200-08 К85', 11390),
('Газовая плита Лада Nova CG 32013 W', 9320),
('Стиральная машина Атлант 60У87-000', 18520)

INSERT INTO Календарь(Год,Месяц) VALUES
(2021,1),
(2021,2),
(2021,3),
(2021,4),
(2021,5),
(2021,6),
(2021,7),
(2021,8),
(2021,9),
(2021,10),
(2021,11),
(2021,12)

INSERT INTO ЕжедневныеПродажи(код_продукта, Дата, Количество) VALUES 
(1, '12.01.2021', 3),
(2, '13.01.2021', 2),
(3, '17.01.2021', 5),
(4, '21.01.2021', 8),
(5, '02.02.2021', 3),
(2, '12.02.2021', 3),
(3, '17.02.2021', 2),
(4, '25.02.2021', 8)

INSERT INTO ЕжемесячныйПланПродаж(id_продукта,Месяц,Количество) VALUES
(1, 1, 10),
(2, 1, 10),
(3, 1, 10),
(4, 1, 10),
(5, 1, 10),
(1, 2, 0),
(2, 2, 19),
(3, 2, 13),
(4, 2, 15),
(5, 2, 15)
GO

CREATE TRIGGER ОтделПродажвОтпуске
ON ЕжедневныеПродажи
FOR INSERT
AS
IF NOT EXISTS(
SELECT сотр.Отпуск
FROM Сотрудники сотр INNER JOIN Отделы отд ON сотр.код_отдела = отд.код_отдела
WHERE сотр.код_отдела = 2 AND сотр.Отпуск = 0
GROUP BY сотр.Отпуск
HAVING COUNT(сотр.Отпуск) > 0)
BEGIN
	PRINT 'Все сотрудники в отпуске продажа не возможна'
	ROLLBACK TRANSACTION
END
GO

CREATE PROCEDURE ИтоговыйОтчёт
	@Год int, @Месяц int
	AS
	BEGIN
		SELECT DATEPART(yyyy,ежднпрод.Дата) AS 'Год', DATEPART(mm,ежднпрод.Дата) AS 'Месяц', прод.Название as 'Наименование продукта',
		SUM(ежднпрод.Количество * прод.Стоимость) AS 'Фактическая сумма', 
		SUM(ежемплан.Количество * прод.Стоимость) AS 'Плановая сумма',
		(SUM(ежемплан.Количество * прод.Стоимость) - SUM(ежднпрод.Количество * прод.Стоимость)) as 'Отклонение'
		FROM (Продукты прод INNER JOIN ЕжедневныеПродажи ежднпрод ON  прод.код_продукта = ежднпрод.код_продукта 
		INNER JOIN ЕжемесячныйПланПродаж ежемплан ON прод.код_продукта = ежемплан.id_продукта)
		INNER JOIN Календарь кален ON кален.код_даты = ежемплан.Месяц
		WHERE YEAR(ежднпрод.Дата) = @Год AND MONTH(ежднпрод.Дата) = @Месяц AND ежемплан.Месяц = (
		SELECT к.код_даты
		From Календарь к
		Where к.Год = @Год AND к.Месяц = @Месяц)
		GROUP BY ежднпрод.Дата, прод.Название
	END