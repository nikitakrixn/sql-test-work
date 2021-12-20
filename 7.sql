use columbus;

CREATE TABLE ������(
	[���_������] [bigint] IDENTITY(1,1) NOT NULL PRIMARY KEY CLUSTERED,
	[��������] [nvarchar](60) NOT NULL,
)
GO

CREATE TABLE ����������(
	[���_����������] [bigint] IDENTITY(1,1) NOT NULL PRIMARY KEY CLUSTERED,
	[���_������] [bigint] NOT NULL REFERENCES ������(���_������),
	[�������] [nvarchar](60) NOT NULL,
	[���] [nvarchar](60) NOT NULL,
	[��������] [nvarchar](60) NOT NULL,
	[������������] [date] NOT NULL,
	[������] [bit] NOT NULL DEFAULT 0,
)
GO
ALTER TABLE ����������
ADD Constraint Un_���� Unique(���_����������, ���_������)
GO

CREATE TABLE ��������(
	[���_��������] [bigint] IDENTITY(1,1) NOT NULL PRIMARY KEY CLUSTERED,
	[��������] [nvarchar](60) NOT NULL,
	[���������] [int] NOT NULL DEFAULT 0,
)
GO

CREATE TABLE ���������(
	[���_����] [bigint] IDENTITY(1,1) NOT NULL PRIMARY KEY CLUSTERED,
	[���] [int] NOT NULL,
	[�����] [int] NOT NULL,
)
GO

CREATE TABLE �����������������(
	[���_�������] [bigint] IDENTITY(1,1) NOT NULL PRIMARY KEY CLUSTERED,
	[���_��������] [bigint] NOT NULL  REFERENCES ��������(���_��������),
	[����] [date] NOT NULL DEFAULT (getdate()),
	[����������] [int] NOT NULL DEFAULT 0,
)
GO

CREATE TABLE ���������������������(
	[id_������������] [bigint] IDENTITY(1,1) NOT NULL PRIMARY KEY CLUSTERED,
	[id_��������] [bigint] NOT NULL REFERENCES ��������(���_��������),
	[�����] [bigint] NOT NULL REFERENCES ���������(���_����),
	[����������] [int] NOT NULL DEFAULT 0,
)
GO

INSERT INTO ������(��������)
VALUES
('���������� �����'),
('����� ������')

INSERT INTO ����������(���_������,�������,���,��������,������������,������)
VALUES
(1,'������','����','��������','21.06.1993','False'),
(1,'������','����','��������','23.02.1994','true'),
(1,'��������','�������','�������','02.09.1999','false'),
(2,'��������','������','����������','10.05.1985','true'),
(2,'�����','�����','��������','30.04.1997','false')

INSERT INTO ��������(��������,���������) VALUES
('��������������� ATLANTIC VERTIGO STEATITE Essen�tial 50', 17370),
('��������������� Haier ES50V-F1(R)', 19490),
('������� ����� ������ 3200-08 �85', 11390),
('������� ����� ���� Nova CG 32013 W', 9320),
('���������� ������ ������ 60�87-000', 18520)

INSERT INTO ���������(���,�����) VALUES
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

INSERT INTO �����������������(���_��������, ����, ����������) VALUES 
(1, '12.01.2021', 3),
(2, '13.01.2021', 2),
(3, '17.01.2021', 5),
(4, '21.01.2021', 8),
(5, '02.02.2021', 3),
(2, '12.02.2021', 3),
(3, '17.02.2021', 2),
(4, '25.02.2021', 8)

INSERT INTO ���������������������(id_��������,�����,����������) VALUES
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

CREATE TRIGGER �������������������
ON �����������������
FOR INSERT
AS
IF NOT EXISTS(
SELECT ����.������
FROM ���������� ���� INNER JOIN ������ ��� ON ����.���_������ = ���.���_������
WHERE ����.���_������ = 2 AND ����.������ = 0
GROUP BY ����.������
HAVING COUNT(����.������) > 0)
BEGIN
	PRINT '��� ���������� � ������� ������� �� ��������'
	ROLLBACK TRANSACTION
END
GO

CREATE PROCEDURE �������������
	@��� int, @����� int
	AS
	BEGIN
		SELECT DATEPART(yyyy,��������.����) AS '���', DATEPART(mm,��������.����) AS '�����', ����.�������� as '������������ ��������',
		SUM(��������.���������� * ����.���������) AS '����������� �����', 
		SUM(��������.���������� * ����.���������) AS '�������� �����',
		(SUM(��������.���������� * ����.���������) - SUM(��������.���������� * ����.���������)) as '����������'
		FROM (�������� ���� INNER JOIN ����������������� �������� ON  ����.���_�������� = ��������.���_�������� 
		INNER JOIN ��������������������� �������� ON ����.���_�������� = ��������.id_��������)
		INNER JOIN ��������� ����� ON �����.���_���� = ��������.�����
		WHERE YEAR(��������.����) = @��� AND MONTH(��������.����) = @����� AND ��������.����� = (
		SELECT �.���_����
		From ��������� �
		Where �.��� = @��� AND �.����� = @�����)
		GROUP BY ��������.����, ����.��������
	END