USE master;
GO

IF DB_ID(N'CRM_Matusiak_Patryk') IS NOT NULL
    DROP DATABASE CRM_Matusiak_Patryk;
GO

CREATE DATABASE CRM_Matusiak_Patryk
ON
(
    NAME = 'CRM_Matusiak_Patryk',
    FILENAME = 'D:\StudiaSerwerMS\MSSQL16.MSSQLSERVER\MSSQL\DATA\CRM_Matusiak_Patryk.mdf',
    SIZE = 10MB,
    MAXSIZE = 200MB,
    FILEGROWTH = 5MB
)
LOG ON
(
    NAME = 'CRM_Matusiak_Patryk_log',
    FILENAME = 'D:\StudiaSerwerMS\MSSQL16.MSSQLSERVER\MSSQL\DATA\CRM_Matusiak_Patryk_log.ldf',
    SIZE = 5MB,
    MAXSIZE = 100MB,
    FILEGROWTH = 5MB
);
GO

USE CRM_Matusiak_Patryk;
GO

SET XACT_ABORT ON;

BEGIN TRANSACTION CRM_Matusiak_Patryk;

DROP TABLE IF EXISTS dbo.Klient
GO
CREATE TABLE [Klient] (
    [ID_Klienta] INT NOT NULL PRIMARY KEY,
    [Imie] VARCHAR(30) NOT NULL,
    [Nazwisko] VARCHAR(50) NOT NULL,
    [Adres] VARCHAR(50) NOT NULL,
    [Nazwa_firmy] VARCHAR(50) NOT NULL,
    [Branza] VARCHAR(30) NOT NULL,
    [Email] VARCHAR(30) NOT NULL,
    [Telefon] VARCHAR(9) NOT NULL,
    [Miasto] VARCHAR(30) NOT NULL,
    [Kod_pocztowy] VARCHAR(6) NOT NULL,
    [NIP] VARCHAR(10) NOT NULL
);

DROP TABLE IF EXISTS dbo.Historia_interakcji
GO
CREATE TABLE [Historia_interakcji] (
    [ID_Historii_Interakcji] INT NOT NULL PRIMARY KEY,
    [Data_rozpoczecia] SMALLDATETIME NOT NULL,
    [Data_zakonczenia] SMALLDATETIME NOT NULL,
    [Rodzaj_interakcji] VARCHAR(50) NOT NULL,
    [Notatka] VARCHAR(255) NULL
);

DROP TABLE IF EXISTS dbo.Pracownicy
GO
CREATE TABLE [Pracownicy] (
    [ID_Pracownika] INT NOT NULL PRIMARY KEY,
    [ID_Historii_Interakcji] INT NOT NULL,
    [Imie] VARCHAR(30) NOT NULL,
    [Nazwisko] VARCHAR(50) NOT NULL,
    [Email] VARCHAR(30) NOT NULL,
    [Rola] VARCHAR(30) NOT NULL,
    CONSTRAINT [FK_Pracownicy_ID_Historii_Interakcji] FOREIGN KEY ([ID_Historii_Interakcji]) REFERENCES [Historia_interakcji] ([ID_Historii_Interakcji])
);

DROP TABLE IF EXISTS dbo.Biezace_interakcje
GO
CREATE TABLE [Biezace_interakcje] (
    [ID_Biezacej_Interakcji] INT NOT NULL PRIMARY KEY,
    [ID_Pracownika] INT NOT NULL,
    [Data_rozpoczecia] SMALLDATETIME NOT NULL,
    [Rodzaj_interakcji] VARCHAR(50) NOT NULL,
    [Notatka] VARCHAR(255) NULL,
    [Status] VARCHAR(15) NOT NULL,
    CONSTRAINT [FK_Biezace_interakcje_ID_Pracownika] FOREIGN KEY ([ID_Pracownika]) REFERENCES [Pracownicy] ([ID_Pracownika])
);

DROP TABLE IF EXISTS dbo.Uzytkownicy
GO
CREATE TABLE [Uzytkownicy] (
    [ID_Uzytkownika] INT NOT NULL PRIMARY KEY,
    [ID_Pracownika] INT NOT NULL,
    [Nazwa] VARCHAR(35) NOT NULL,
    [Haslo] VARCHAR(50) NOT NULL,
    [Status] VARCHAR(15) NOT NULL,
    CONSTRAINT [FK_Uzytkownicy_ID_Pracownika] FOREIGN KEY ([ID_Pracownika]) REFERENCES [Pracownicy] ([ID_Pracownika])
);

DROP TABLE IF EXISTS dbo.Uprawnienia
GO
CREATE TABLE [Uprawnienia] (
    [ID_Uprawnienia] INT NOT NULL PRIMARY KEY,
    [ID_Uzytkownika] INT NOT NULL,
    [Rola] VARCHAR(30) NOT NULL,
    [Opis] VARCHAR(255) NOT NULL,
    CONSTRAINT [FK_Uprawnienia_ID_Uzytkownika] FOREIGN KEY ([ID_Uzytkownika]) REFERENCES [Uzytkownicy] ([ID_Uzytkownika])
);

DROP TABLE IF EXISTS dbo.Uslugi
GO
CREATE TABLE [Uslugi] (
    [ID_Uslugi] INT NOT NULL PRIMARY KEY,
    [ID_Klienta] INT NOT NULL,
    [ID_Biezacej_Interakcji] INT NOT NULL,
    [Nazwa] VARCHAR(50) NOT NULL,
    [Cena] MONEY NOT NULL,
    [Opis] VARCHAR(255) NOT NULL,
    CONSTRAINT [FK_Uslugi_ID_Klienta] FOREIGN KEY ([ID_Klienta]) REFERENCES [Klient] ([ID_Klienta]),
    CONSTRAINT [FK_Uslugi_ID_Biezacej_Interakcji] FOREIGN KEY ([ID_Biezacej_Interakcji]) REFERENCES [Biezace_interakcje] ([ID_Biezacej_Interakcji])
);

DROP TABLE IF EXISTS dbo.Integracja
GO
CREATE TABLE [Integracja] (
    [ID_Integracji] INT NOT NULL PRIMARY KEY,
    [ID_Uslugi] INT NOT NULL,
    [Nazwa] VARCHAR(50) NOT NULL,
    [Opis] VARCHAR(255) NOT NULL,
    [Status] VARCHAR(15) NOT NULL,
    [Endpoint] VARCHAR(255) NOT NULL,
    CONSTRAINT [FK_Integracja_ID_Uslugi] FOREIGN KEY ([ID_Uslugi]) REFERENCES [Uslugi] ([ID_Uslugi])
);
COMMIT TRANSACTION CRM_Matusiak_Patryk;




-- Triggery

-- Sprawdzanie poprawności wprowadzonego imienia klienta
CREATE TRIGGER Check_Valid_Name_Klient
ON dbo.Klient
AFTER INSERT, UPDATE
AS
BEGIN
    IF EXISTS (
        SELECT 1
        FROM inserted
        WHERE NOT ([Imie] LIKE '[A-Z][a-z]%' AND [Imie] NOT LIKE '%[^a-zA-Z]%')
    )
    BEGIN
        RAISERROR ('Niepoprawny format imienia klienta. Imię powinno zaczynać się wielką literą i nie zawierać cyfr ani znaków specjalnych.', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END;    
END;
GO

-- Sprawdzanie poprawności wprowadzonego nazwiska klienta
CREATE TRIGGER Check_Valid_Surame_Klient
ON dbo.Klient
AFTER INSERT, UPDATE
AS
BEGIN
    IF EXISTS (
        SELECT 1
        FROM inserted
        WHERE NOT ([Nazwisko] LIKE '[A-Z][a-z]%' AND [Nazwisko] NOT LIKE '%[^a-zA-Z]%')
    )
    BEGIN
        RAISERROR ('Niepoprawny format nazwiska klienta. Nazwisko powinno zaczynać się wielką literą i nie zawierać cyfr ani znaków specjalnych.', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END;    
END;
GO

-- Sprawdzanie poprawności numeru telefonu klienta
CREATE TRIGGER Check_Valid_Phone_Klient
ON dbo.Klient
AFTER INSERT, UPDATE
AS
BEGIN
    IF EXISTS (
        SELECT 1
        FROM inserted
        WHERE NOT ([Telefon] LIKE '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]')
    )
    BEGIN
        RAISERROR ('Niepoprawny format numeru telefonu klienta. Numer telefonu powinien składać się z 9 cyfr.', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END;    
END;
GO

-- Sprawdzanie poprawności emaila klienta
CREATE TRIGGER Check_Valid_Email_Klient
ON dbo.Klient
AFTER INSERT, UPDATE
AS
BEGIN
    IF EXISTS (
        SELECT 1
        FROM inserted
        WHERE NOT ([Email] LIKE '%_@__%.__%')
    )
    BEGIN
        RAISERROR ('Niepoprawny format adresu email klienta', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END;    
END;
GO

-- Sprawdzanie poprawności kodu pocztowego klienta
CREATE TRIGGER Check_Valid_PostalCode_Klient
ON dbo.Klient
AFTER INSERT, UPDATE
AS
BEGIN
    IF EXISTS(
        SELECT 1
        FROM inserted
        WHERE NOT ([Kod_pocztowy] LIKE '[0-9][0-9]-[0-9][0-9][0-9]')
    )
    BEGIN
        RAISERROR ('Niepoprawny format kodu pocztowego klienta. Kod pocztowy powinien być w formacie 00-000.', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END;
END;
GO

-- Sprawdzanie poprawności numeru NIP klienta
CREATE TRIGGER Check_Valid_PostalCode_Klient
ON dbo.Klient
AFTER INSERT, UPDATE
AS
BEGIN
    IF EXISTS(
        SELECT 1
        FROM inserted
        WHERE NOT ([NIP] LIKE '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]')
    )
    BEGIN
        RAISERROR ('Niepoprawny format NIP-u klienta. NIP powinien składać się wyłącznie z cyfr', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END;
END;
GO  

-- Sprawdzanie czy wprowadzona cena nie jest ujemna
CREATE TRIGGER Check_valid_Price_Uslugi
ON dbo.Uslugi
AFTER INSERT, UPDATE
AS
BEGIN
    IF EXISTS(
        SELECT 1
        FROM inserted
        WHERE [Cena] < 0
    )
    BEGIN
        RAISERROR('Cena nie może być ujemna', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END;
END;
GO        

-- Sprawdzenie poprawności statusu
CREATE TRIGGER Check_Valid_Status_Interakcje
ON dbo.Integracja
AFTER INSERT, UPDATE
AS
BEGIN 
    IF EXISTS(
        SELECT 1
        FROM inserted
        WHERE NOT ([Status] COLLATE Latin1_General_BIN LIKE '%[a-zA-Z]%')
    )
    BEGIN
        RAISERROR ('Niepoprawny format statusu integracji. Status powinien składać się wyłącznie z liter.', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END;
END;
GO

-- Sprawdzenie poprawności statusu
CREATE TRIGGER Check_Valid_Status_Biezace_interakcje
ON dbo.Biezace_interakcje
AFTER INSERT, UPDATE
AS
BEGIN 
    IF EXISTS(
        SELECT 1
        FROM inserted
        WHERE NOT ([Status] COLLATE Latin1_General_BIN LIKE '%[a-zA-Z]%')
    )
    BEGIN
        RAISERROR ('Niepoprawny format statusu biezacej integracji. Status powinien składać się wyłącznie z liter.', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END;
END;
GO

-- Sprawdzanie poprawności wprowadzonej daty
CREATE OR ALTER TRIGGER Check_Valid_StartDate_Biezace_interakcje
ON dbo.Biezace_interakcje
AFTER INSERT, UPDATE
AS
BEGIN 
    IF EXISTS(
        SELECT 1
        FROM inserted
        WHERE TRY_CAST([Data_rozpoczecia] AS DATE) IS NULL
    )
    BEGIN
        RAISERROR ('Niepoprawny format daty rozpoczęcia interakcji. Data powinna być w formacie yyyy-mm-dd', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END;
END;
GO


-- Sprawdzanie poprawności imienia pracownika
CREATE TRIGGER Check_Valid_Name_Pracownik
ON dbo.Pracownicy
AFTER INSERT, UPDATE
AS
BEGIN
    IF EXISTS (
        SELECT 1
        FROM inserted
        WHERE NOT ([Imie] LIKE '[A-Z][a-z]%' AND [Imie] NOT LIKE '%[^a-zA-Z]%')
    )
    BEGIN
        RAISERROR ('Niepoprawny format imienia pracownika. Imię powinno zaczynać się wielką literą i nie zawierać cyfr ani znaków specjalnych.', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END;    
END;
GO

-- Sprawdzanie poprawności imienia pracownika
CREATE TRIGGER Check_Valid_Surname_Pracownik
ON dbo.Pracownicy
AFTER INSERT, UPDATE
AS
BEGIN
    IF EXISTS (
        SELECT 1
        FROM inserted
        WHERE NOT ([Nazwisko] LIKE '[A-Z][a-z]%' AND [Nazwisko] NOT LIKE '%[^a-zA-Z]%')
    )
    BEGIN
        RAISERROR ('Niepoprawny format nazwiska pracownika. Nazwisko powinno zaczynać się wielką literą i nie zawierać cyfr ani znaków specjalnych.', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END;    
END;
GO

-- Sprawdzenie poprawności emaila pracownika
CREATE TRIGGER Check_Valid_Email_Pracownik
ON dbo.Pracownicy
AFTER INSERT, UPDATE
AS
BEGIN
    IF EXISTS (
        SELECT 1
        FROM inserted
        WHERE NOT ([Email] LIKE '%_@__%.__%')
    )
    BEGIN
        RAISERROR ('Niepoprawny format adresu email pracownika', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END;    
END;
GO

-- Sprawdzenie poprawności wprowadzonych dat oraz czy data rozpoczęcia nie 
-- jest późniejsza od daty zakończenia
CREATE TRIGGER Check_Valid_StartDate_Historia_interakcji
ON dbo.Historia_interakcji
AFTER INSERT, UPDATE
AS
BEGIN 
    IF EXISTS(
        SELECT 1
        FROM inserted
        WHERE NOT (TRY_CAST([Data_rozpoczecia] AS DATE) IS NOT NULL AND TRY_CAST([Data_zakonczenia] AS DATE) IS NOT NULL)
    )
    BEGIN
        RAISERROR ('Niepoprawny format daty w historii interakcji. Data rozpoczęcia i zakończenia powinny być w formacie yyyy-mm-dd', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END;

    IF EXISTS(
        SELECT 1
        FROM inserted
        WHERE TRY_CAST([Data_rozpoczecia] AS DATE) > TRY_CAST([Data_zakonczenia] AS DATE)
    )
    BEGIN
        RAISERROR ('Data rozpoczęcia nie może być późniejsza niż data zakończenia', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END;
END;
GO

-- Sprawdzenie poprawności statusu
CREATE TRIGGER Check_Valid_Status_Uzytkownicy
ON dbo.Uzytkownicy
AFTER INSERT, UPDATE
AS
BEGIN 
    IF EXISTS(
        SELECT 1
        FROM inserted
        WHERE NOT ([Status] COLLATE Latin1_General_BIN LIKE '%[a-zA-Z]%')
    )
    BEGIN
        RAISERROR ('Niepoprawny format statusu użytkownika. Status powinien składać się wyłącznie z liter.', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END;
END;
GO

-- Widoki

-- Wyświetlanie klientów i ich usług
CREATE VIEW vw_ClientServices AS
SELECT 
    K.ID_Klienta,
    K.Imie,
    K.Nazwisko,
    K.Nazwa_firmy,
    K.Branza,
    U.ID_Uslugi,
    U.Nazwa AS Nazwa_Uslugi,
    U.Cena,
    U.Opis AS Opis_Uslugi
FROM 
    Klient K
    JOIN Uslugi U ON K.ID_Klienta = U.ID_Klienta;


-- Widok z aktualnymi interakcjami pracowników
CREATE VIEW vw_CurrentEmployeeInteractions AS
SELECT 
    BI.ID_Biezacej_Interakcji,
    P.ID_Pracownika,
    P.Imie,
    P.Nazwisko,
    BI.Data_rozpoczecia,
    BI.Rodzaj_interakcji,
    BI.Notatka,
    BI.Status
FROM 
    Biezace_interakcje BI
    JOIN Pracownicy P ON BI.ID_Pracownika = P.ID_Pracownika;


-- Historia interakcji z klientem
CREATE VIEW vw_ClientInteractionHistory AS
SELECT 
    HI.ID_Historii_Interakcji,
    K.ID_Klienta,
    K.Imie,
    K.Nazwisko,
    HI.Data_rozpoczecia,
    HI.Data_zakonczenia,
    HI.Rodzaj_interakcji,
    HI.Notatka
FROM 
    Historia_interakcji HI
    JOIN Uslugi U ON HI.ID_Historii_Interakcji = U.ID_Biezacej_Interakcji
    JOIN Klient K ON U.ID_Klienta = K.ID_Klienta;

-- Uprawnienia użytkowników
CREATE VIEW vw_UserPermissions AS
SELECT 
    U.ID_Uzytkownika,
    U.Nazwa,
    U.Status,
    UP.Rola,
    UP.Opis
FROM 
    Uzytkownicy U
    JOIN Uprawnienia UP ON U.ID_Uzytkownika = UP.ID_Uzytkownika;

-- Integracje z usługami
CREATE VIEW vw_ServiceIntegrations AS
SELECT 
    I.ID_Integracji,
    I.Nazwa AS Nazwa_Integracji,
    I.Opis AS Opis_Integracji,
    I.Status,
    I.Endpoint,
    U.ID_Uslugi,
    U.Nazwa AS Nazwa_Uslugi,
    K.ID_Klienta,
    K.Nazwa_firmy
FROM 
    Integracja I
    JOIN Uslugi U ON I.ID_Uslugi = U.ID_Uslugi
    JOIN Klient K ON U.ID_Klienta = K.ID_Klienta;

-- Procedury

-- Dodawanie nowego klienta
CREATE PROCEDURE sp_AddClient
    @ID_Klienta int,
    @Imie VARCHAR(30),
    @Nazwisko VARCHAR(50),
    @Adres VARCHAR(50),
    @Nazwa_firmy VARCHAR(50),
    @Branza VARCHAR(30),
    @Email VARCHAR(30),
    @Telefon VARCHAR(9),
    @Miasto VARCHAR(30),
    @Kod_pocztowy VARCHAR(6),
    @NIP VARCHAR(10)
AS
BEGIN
    INSERT INTO Klient (ID_Klienta,Imie, Nazwisko, Adres, Nazwa_firmy, Branza, Email, Telefon, Miasto, Kod_pocztowy, NIP)
    VALUES (@ID_Klienta, @Imie, @Nazwisko, @Adres, @Nazwa_firmy, @Branza, @Email, @Telefon, @Miasto, @Kod_pocztowy, @NIP);
END;

-- Aktualizacja informacji o kliencie
CREATE PROCEDURE sp_UpdateClient
    @ID_Klienta INT,
    @Imie VARCHAR(30),
    @Nazwisko VARCHAR(50),
    @Adres VARCHAR(50),
    @Nazwa_firmy VARCHAR(50),
    @Branza VARCHAR(30),
    @Email VARCHAR(30),
    @Telefon VARCHAR(9),
    @Miasto VARCHAR(30),
    @Kod_pocztowy VARCHAR(6),
    @NIP VARCHAR(10)
AS
BEGIN
    UPDATE Klient
    SET Imie = @Imie,
        Nazwisko = @Nazwisko,
        Adres = @Adres,
        Nazwa_firmy = @Nazwa_firmy,
        Branza = @Branza,
        Email = @Email,
        Telefon = @Telefon,
        Miasto = @Miasto,
        Kod_pocztowy = @Kod_pocztowy,
        NIP = @NIP
    WHERE ID_Klienta = @ID_Klienta;
END;

-- Usuwanie klienta
CREATE PROCEDURE sp_DeleteClient
    @ID_Klienta INT
AS
BEGIN
    DELETE FROM Klient
    WHERE ID_Klienta = @ID_Klienta;
END;

-- Dodawanie nowej interakcji
CREATE PROCEDURE sp_AddInteraction
    @ID_Pracownika INT,
    @Data_rozpoczecia SMALLDATETIME,
    @Rodzaj_interakcji VARCHAR(50),
    @Notatka VARCHAR(255),
    @Status VARCHAR(15)
AS
BEGIN
    INSERT INTO Biezace_interakcje (ID_Pracownika, Data_rozpoczecia, Rodzaj_interakcji, Notatka, Status)
    VALUES (@ID_Pracownika, @Data_rozpoczecia, @Rodzaj_interakcji, @Notatka, @Status);
END;

-- Raport o aktywnych usługach klienta
CREATE PROCEDURE sp_GetActiveClientServices
    @ID_Klienta INT
AS
BEGIN
    SELECT 
        U.ID_Uslugi,
        U.Nazwa AS Nazwa_Uslugi,
        U.Cena,
        U.Opis AS Opis_Uslugi,
        BI.Status
    FROM 
        Uslugi U
        JOIN Biezace_interakcje BI ON U.ID_Biezacej_Interakcji = BI.ID_Biezacej_Interakcji
    WHERE 
        U.ID_Klienta = @ID_Klienta AND
        BI.Status = 'Aktywny';
END;

-- Dodawanie nowego pracownika
CREATE PROCEDURE sp_AddEmployee
    @ID_Historii_Interakcji INT,
    @Imie VARCHAR(30),
    @Nazwisko VARCHAR(50),
    @Email VARCHAR(30),
    @Rola VARCHAR(30)
AS
BEGIN
    INSERT INTO Pracownicy (ID_Historii_Interakcji, Imie, Nazwisko, Email, Rola)
    VALUES (@ID_Historii_Interakcji, @Imie, @Nazwisko, @Email, @Rola);
END;

-- Dodawanie nowej usługi
CREATE PROCEDURE sp_AddService
    @ID_Klienta INT,
    @ID_Biezacej_Interakcji INT,
    @Nazwa VARCHAR(50),
    @Cena MONEY,
    @Opis VARCHAR(255)
AS
BEGIN
    INSERT INTO Uslugi (ID_Klienta, ID_Biezacej_Interakcji, Nazwa, Cena, Opis)
    VALUES (@ID_Klienta, @ID_Biezacej_Interakcji, @Nazwa, @Cena, @Opis);
END;

-- Aktualizacja roli oraz opisu uprawnień
CREATE PROCEDURE sp_UpdatePermission
    @ID_Uprawnienia INT,
    @Rola VARCHAR(30),
    @Opis VARCHAR(255)
AS
BEGIN
    UPDATE Uprawnienia
    SET Rola = @Rola,
        Opis = @Opis
    WHERE ID_Uprawnienia = @ID_Uprawnienia;
END;

-- WSAD DO BAZY DANYCH

-- Dodawanie rekordów do tabeli Klient
INSERT INTO Klient (ID_Klienta, Imie, Nazwisko, Adres, Nazwa_firmy, Branza, Email, Telefon, Miasto, Kod_pocztowy, NIP) VALUES
(1, 'Jan', 'Kowalski', 'ul. Kwiatowa 1', 'Firma A', 'IT', 'jan.kowalski@firmaA.pl', '123456789', 'Warszawa', '00-001', '1234567890'),
(2, 'Anna', 'Nowak', 'ul. Różana 2', 'Firma B', 'Budownictwo', 'anna.nowak@firmaB.pl', '234567890', 'Kraków', '30-002', '0987654321'),
(3, 'Piotr', 'Wiśniewski', 'ul. Słoneczna 3', 'Firma C', 'Handel', 'piotr.wisniewski@firmaC.pl', '345678901', 'Gdańsk', '80-003', '1122334455'),
(4, 'Ewa', 'Wójcik', 'ul. Lipowa 4', 'Firma D', 'Finanse', 'ewa.wojcik@firmaD.pl', '456789012', 'Wrocław', '50-004', '2233445566'),
(5, 'Krzysztof', 'Kamiński', 'ul. Dębowa 5', 'Firma E', 'Medycyna', 'krzysztof.kaminski@firmaE.pl', '567890123', 'Poznań', '60-005', '3344556677');

-- Dodawanie rekordów do tabeli Historia_interakcji
INSERT INTO Historia_interakcji (ID_Historii_Interakcji, Data_rozpoczecia, Data_zakonczenia, Rodzaj_interakcji, Notatka) VALUES
(1, '2024-01-01', '2024-01-10', 'Spotkanie', 'Spotkanie w sprawie nowego projektu'),
(2, '2024-02-01', '2024-02-10', 'Telefon', 'Rozmowa telefoniczna dotycząca umowy'),
(3, '2024-03-01', '2024-03-10', 'Email', 'Wysłano ofertę współpracy'),
(4, '2024-04-01', '2024-04-10', 'Spotkanie', 'Omówienie warunków kontraktu'),
(5, '2024-05-01', '2024-05-10', 'Telefon', 'Ustalenie szczegółów zamówienia');

-- Dodawanie rekordów do tabeli Pracownicy
INSERT INTO Pracownicy (ID_Pracownika, ID_Historii_Interakcji, Imie, Nazwisko, Email, Rola) VALUES
(1, 1, 'Adam', 'Nowak', 'adam.nowak@firma.pl', 'Manager'),
(2, 2, 'Beata', 'Kowalska', 'beata.kowalska@firma.pl', 'Specjalista'),
(3, 3, 'Cezary', 'Wiśniewski', 'cezary.wisniewski@firma.pl', 'Konsultant'),
(4, 4, 'Dorota', 'Wójcik', 'dorota.wojcik@firma.pl', 'Asystent'),
(5, 5, 'Edward', 'Kamiński', 'edward.kaminski@firma.pl', 'Dyrektor');

-- Dodawanie rekordów do tabeli Biezace_interakcje
INSERT INTO Biezace_interakcje (ID_Biezacej_Interakcji, ID_Pracownika, Data_rozpoczecia, Rodzaj_interakcji, Notatka, Status) VALUES
(1, 1, '2024-06-01', 'Spotkanie', 'Pierwsze spotkanie z klientem', 'W trakcie'),
(2, 2, '2024-07-02', 'Telefon', 'Omówienie warunków współpracy', 'Zakończone'),
(3, 3, '2024-08-03', 'Email', 'Wysłanie oferty', 'Oczekiwanie'),
(4, 4, '2024-09-04', 'Spotkanie', 'Prezentacja produktu', 'W trakcie'),
(5, 5, '2024-10-05', 'Telefon', 'Ustalenie szczegółów zamówienia', 'Zakończone');

-- Dodawanie rekordów do tabeli Uzytkownicy
INSERT INTO Uzytkownicy (ID_Uzytkownika, ID_Pracownika, Nazwa, Haslo, Status) VALUES
(1, 1, 'anowak', 'password123', 'Aktywny'),
(2, 2, 'bkowalska', 'password456', 'Nieaktywny'),
(3, 3, 'cwisniewski', 'password789', 'Aktywny'),
(4, 4, 'dwojcik', 'password012', 'Nieaktywny'),
(5, 5, 'ekaminski', 'password345', 'Aktywny');

-- Dodawanie rekordów do tabeli Uprawnienia
INSERT INTO Uprawnienia (ID_Uprawnienia, ID_Uzytkownika, Rola, Opis) VALUES
(1, 1, 'Administrator', 'Pełny dostęp do systemu'),
(2, 2, 'Użytkownik', 'Ograniczony dostęp do wybranych funkcji'),
(3, 3, 'Moderator', 'Może zarządzać treściami'),
(4, 4, 'Gość', 'Dostęp tylko do podglądu'),
(5, 5, 'Użytkownik', 'Ograniczony dostęp do wybranych funkcji');

-- Dodawanie rekordów do tabeli Uslugi
INSERT INTO Uslugi (ID_Uslugi, ID_Klienta, ID_Biezacej_Interakcji, Nazwa, Cena, Opis) VALUES
(1, 1, 1, 'Usługa A', 100.00, 'Opis usługi A'),
(2, 2, 2, 'Usługa B', 200.00, 'Opis usługi B'),
(3, 3, 3, 'Usługa C', 300.00, 'Opis usługi C'),
(4, 4, 4, 'Usługa D', 400.00, 'Opis usługi D'),
(5, 5, 5, 'Usługa E', 500.00, 'Opis usługi E');

-- Dodawanie rekordów do tabeli Integracja
INSERT INTO Integracja (ID_Integracji, ID_Uslugi, Nazwa, Opis, Status, Endpoint) VALUES
(1, 1, 'Integracja A', 'Opis integracji A', 'Aktywny', 'https://endpointA.com'),
(2, 2, 'Integracja B', 'Opis integracji B', 'Nieaktywny', 'https://endpointB.com'),
(3, 3, 'Integracja C', 'Opis integracji C', 'Aktywny', 'https://endpointC.com'),
(4, 4, 'Integracja D', 'Opis integracji D', 'Nieaktywny', 'https://endpointD.com'),
(5, 5, 'Integracja E', 'Opis integracji E', 'Aktywny', 'https://endpointE.com');
