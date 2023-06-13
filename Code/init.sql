-- Create Author table
CREATE TABLE Author (
  AuthorID SERIAL PRIMARY KEY,
  FirstName VARCHAR(255),
  LastName VARCHAR(255),
  Gender VARCHAR(10),
  Birthdate DATE,
  Nationality VARCHAR(255),
  Artistname VARCHAR(255)
);

-- Create Address table
CREATE TABLE Address (
  AddressID SERIAL PRIMARY KEY,
  Street VARCHAR(255),
  City VARCHAR(255),
  PostalCode VARCHAR(20),
  State VARCHAR(255)
);

-- Create Publisher table
CREATE TABLE Publisher (
  PublisherID SERIAL PRIMARY KEY,
  Name VARCHAR(255),
  Email VARCHAR(255),
  Website VARCHAR(255),
  AddressID INT UNIQUE,
  FOREIGN KEY (AddressID) REFERENCES Address(AddressID) ON DELETE SET NULL
);

-- Create Customer table
CREATE TABLE Customer (
  CustomerID SERIAL PRIMARY KEY,
  FirstName VARCHAR(255),
  LastName VARCHAR(255),
  Email VARCHAR(255),
  Phonenumber VARCHAR(20),
  Birthdate DATE,
  AddressID INT UNIQUE,
  FOREIGN KEY (AddressID) REFERENCES Address(AddressID) ON DELETE SET NULL
);

-- Create Building table
CREATE TABLE Building (
  BuildingID SERIAL PRIMARY KEY,
  FloorNumber INT,
  WheelchairAccessibility BOOLEAN,
  AddressID INT UNIQUE,
  FOREIGN KEY (AddressID) REFERENCES Address(AddressID) ON DELETE CASCADE
);

-- Create Staffmember table
CREATE TABLE Staffmember (
  StaffmemberID SERIAL PRIMARY KEY,
  FirstName VARCHAR(255),
  LastName VARCHAR(255),
  Salary DECIMAL(10, 2),
  AvailableVacationDays INT,
  BuildingID INT,
  AddressID INT UNIQUE,
  FOREIGN KEY (BuildingID) REFERENCES Building(BuildingID) ON DELETE SET NULL,
  FOREIGN KEY (AddressID) REFERENCES Address(AddressID) ON DELETE CASCADE
);

-- Create Book table
CREATE TABLE Book (
  BookID SERIAL PRIMARY KEY,
  Title VARCHAR(255),
  Genre VARCHAR(255),
  ReleaseDate DATE,
  Keyword VARCHAR(255),
  PublisherID INT,
  FOREIGN KEY (PublisherID) REFERENCES Publisher(PublisherID) ON DELETE SET NULL
);

-- Create Copy table
CREATE TABLE Copy (
  CopyID SERIAL PRIMARY KEY,
  BookID INT,
  CustomerID INT,
  CheckoutDate DATE,
  DueDate DATE,
  IsReturned BOOLEAN,
  BuildingID INT,
  FloorNumber INT,
  ShelfNumber INT,
  FOREIGN KEY (BookID) REFERENCES Book(BookID) ON DELETE CASCADE,
  FOREIGN KEY (CustomerID) REFERENCES Customer(CustomerID) ON DELETE SET NULL,
  FOREIGN KEY (BuildingID) REFERENCES Building(BuildingID) ON DELETE SET NULL
);

-- Create Write table
CREATE TABLE Write (
  AuthorID INT,
  BookID INT,
  PRIMARY KEY (AuthorID, BookID),
  FOREIGN KEY (AuthorID) REFERENCES Author(AuthorID) ON DELETE CASCADE,
  FOREIGN KEY (BookID) REFERENCES Book(BookID) ON DELETE CASCADE
);

-- Create Review table
CREATE TABLE Review (
  BookID INT,
  CustomerID INT,
  Stars INT,
  Text VARCHAR(255),
  PRIMARY KEY (BookID, CustomerID),
  FOREIGN KEY (BookID) REFERENCES Book(BookID) ON DELETE CASCADE,
  FOREIGN KEY (CustomerID) REFERENCES Customer(CustomerID) ON DELETE SET NULL
);

-- Stored procedure to handle the ReturnStatus logic
CREATE OR REPLACE FUNCTION UpdateReturnStatus() RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
  IF (NEW.IsReturned = True) THEN
    NEW.CheckoutDate := NULL;
    NEW.DueDate := NULL;
  ELSIF (NEW.IsReturned = False) THEN
    NEW.CheckoutDate := CURRENT_DATE;
    NEW.DueDate := CURRENT_DATE + INTERVAL '30 days';
  END IF;
  RETURN NEW;
END;
$$;

CREATE TRIGGER tr_UpdateReturnStatus
BEFORE UPDATE ON Copy
FOR EACH ROW
EXECUTE PROCEDURE UpdateReturnStatus();

-- Insert into Address table
INSERT INTO Address (AddressID, Street, City, PostalCode, State) VALUES 
(1, '123 Elm Street', 'New York', '10001', 'New York'),
(2, '456 Pine Avenue', 'Los Angeles', '90001', 'California'),
(3, '789 Oak Boulevard', 'Chicago', '60007', 'Illinois'),
(4, '987 Maple Lane', 'Seattle', '98101', 'Washington'),
(5, '321 Cedar Road', 'Houston', '77002', 'Texas'),
(6, '654 Birch Street', 'San Francisco', '94101', 'California'),
(7, '890 Willow Avenue', 'Miami', '33101', 'Florida'),
(8, '234 Oakwood Drive', 'Denver', '80201', 'Colorado'),
(9, '567 Walnut Lane', 'Boston', '02101', 'Massachusetts'),
(10, '876 Pinecrest Road', 'Atlanta', '30301', 'Georgia'),
(11, '109 Maple Street', 'Dallas', '75201', 'Texas'),
(12, '432 Cedar Avenue', 'Philadelphia', '19101', 'Pennsylvania'),
(13, '753 Elmwood Avenue', 'Phoenix', '85001', 'Arizona'),
(14, '246 Pine Street', 'San Diego', '92101', 'California'),
(15, '987 Oakwood Lane', 'Portland', '97201', 'Oregon'),
(16, '320 Maple Road', 'New Orleans', '70112', 'Louisiana'),
(17, '901 Cedar Avenue', 'Nashville', '37201', 'Tennessee'),
(18, '567 Pine Street', 'Dallas', '75201', 'Texas'),
(19, '890 Elmwood Avenue', 'Atlanta', '30301', 'Georgia'),
(20, '123 Maple Road', 'Seattle', '98101', 'Washington');

-- Insert into Building table
INSERT INTO Building (BuildingID, FloorNumber, WheelchairAccessibility, AddressID) VALUES 
(1, 5, TRUE, 18),
(2, 2, FALSE, 19),
(3, 1, TRUE, 20);

-- Insert into Author table
INSERT INTO Author (AuthorID, FirstName, LastName, Gender, Birthdate, Nationality, Artistname) VALUES 
(1, 'John', 'Doe', 'Male', '1980-01-01', 'American', 'JDoe'),
(2, 'Jane', 'Doe', 'Female', '1985-01-01', 'British', 'Jadoe'),
(3, 'James', 'Smith', 'Male', '1975-01-01', 'Canadian', 'JSmith'),
(4, 'Emily', 'Williams', 'Female', '1990-03-15', 'Australian', 'EWilliams'),
(5, 'Michael', 'Johnson', 'Male', '1988-06-20', 'American', 'MJohnson');

-- Insert into Publisher table
INSERT INTO Publisher (PublisherID, Name, Email, Website, AddressID) VALUES 
(1, 'PubHouse', 'contact@pubhouse.com', 'www.pubhouse.com', 1),
(2, 'BookWorm Inc.', 'info@bookworm.com', 'www.bookworm.com', 2),
(3, 'Literature Ltd.', 'support@literature.com', 'www.literature.com', 3),
(4, 'NovelVerse Publishing', 'info@novelverse.com', 'www.novelverse.com', 4);

-- Insert into Customer table
INSERT INTO Customer (CustomerID, FirstName, LastName, Email, Phonenumber, Birthdate, AddressID) VALUES 
(1, 'Jane', 'Smith', 'jane.smith@example.com', '+123456789', '1990-01-01', 5),
(2, 'Sam', 'Johnson', 'sam.johnson@example.com', '+234567890', '1988-01-01', 6),
(3, 'Sara', 'Williams', 'sara.williams@example.com', '+345678901', '1992-01-01', 7),
(4, 'Mark', 'Brown', 'mark.brown@example.com', '+456789012', '1995-03-15', 8),
(5, 'Emma', 'Davis', 'emma.davis@example.com', '+567890123', '1991-06-20', 9),
(6, 'Alex', 'Wilson', 'alex.wilson@example.com', '+678901234', '1993-09-25', 10),
(7, 'Oliver', 'Taylor', 'oliver.taylor@example.com', '+789012345', '1994-12-10', 11),
(8, 'Sophia', 'Miller', 'sophia.miller@example.com', '+890123456', '1989-04-05', 12);

-- Insert into Staffmember table
INSERT INTO Staffmember (StaffmemberID, FirstName, LastName, Salary, AvailableVacationDays, BuildingID, AddressID) VALUES 
(1, 'Mark', 'Johnson', 50000.00, 20, 1, 13),
(2, 'Anna', 'Miller', 55000.00, 18, 1, 14),
(3, 'Jacob', 'Brown', 60000.00, 15, 2, 15),
(4, 'Emily', 'Davis', 52000.00, 17, 3, 16);

-- Insert into Book table
INSERT INTO Book (BookID, Title, Genre, ReleaseDate, Keyword, PublisherID) VALUES 
(1, 'Journey to the East', 'Adventure', '2000-01-01', 'adventure', 1),
(2, 'Science 101', 'Education', '2005-01-01', 'education, 101', 2),
(3, 'Cooking Made Easy', 'Cookbook', '2010-01-01', 'cookbook', 3),
(4, 'The Enigma of Elysium', 'Mystery', '2016-08-12', 'Elysium', 3),
(5, 'Quantum Chronicles: Beyond Time', 'Science Fiction', '2022-02-28', 'quantum', 4),
(6, 'The Culinary Alchemist', 'Cookbook', '2013-11-05', 'alchemist', 1),
(7, 'A Brush with Destiny', 'Biography', '2017-04-20', 'destiny', 2),
(8, 'Shadows of Serendipity', 'Fantasy', '2019-10-15', 'serendipity', 3),
(9, 'The Art of Deception', 'Thriller', '2014-06-18', 'art', 4),
(10, 'Whispers of the Moon', 'Poetry', '2011-09-08', 'moon', 1);

-- Insert into Copy table
INSERT INTO Copy (CopyID, BookID, CustomerID, CheckoutDate, DueDate, IsReturned, BuildingID, FloorNumber, ShelfNumber) VALUES 
(1, 1, 1, '2023-05-12', '2023-06-11', FALSE, 1, 1, 1),
(2, 1, NULL, NULL, NULL, TRUE, 2, 2, 2),
(3, 1, NULL, NULL, NULL, TRUE, 3, 3, 3),
(4, 2, 3, '2023-01-04', '2023-02-03', FALSE, 1, 1, 2),
(5, 3, 4, '2023-01-05', '2023-02-04', FALSE, 2, 2, 1),
(6, 4, NULL, NULL, NULL, TRUE, 3, 3, 5),
(7, 4, NULL, NULL, NULL, TRUE, 1, 1, 2),
(8, 4, 6, '2023-03-08', '2023-04-07', FALSE, 2, 2, 5),
(9, 5, NULL, NULL, NULL, TRUE, 3, 3, 2),
(10, 6, NULL, NULL, NULL, TRUE, 1, 1, 3),
(11, 6, 2, '2023-03-11', '2023-04-09', FALSE, 2, 2, 6),
(12, 6, 4, '2023-05-12', '2023-06-10', FALSE, 3, 1, 2),
(13, 7, 5, '2023-05-13', '2023-06-11', FALSE, 1, 1, 4),
(14, 7, 8, '2023-03-14', '2023-04-23', FALSE, 2, 2, 3),
(15, 8, NULL, NULL, NULL, TRUE, 3, 2, 3),
(16, 8, NULL, NULL, NULL, TRUE, 1, 1, 5),
(17, 9, 4, '2023-01-17', '2023-01-16', FALSE, 2, 1, 1),
(18, 10, NULL, NULL, NULL, TRUE, 3, 3, 6),
(19, 10, 6, '2023-05-19', '2023-06-18', FALSE, 1, 1, 6),
(20, 10, 7, '2023-05-20', '2023-06-19', FALSE, 2, 1, 2);

-- Insert into Write table
INSERT INTO Write (AuthorID, BookID) VALUES 
(1, 1),
(2, 2),
(3, 3),
(4, 4),
(5, 5),
(1, 6),
(2, 7),
(3, 8),
(4, 9),
(5, 10),
(1, 3),
(2, 5),
(5,9);

-- Insert into Review table
INSERT INTO Review (BookID, CustomerID, Stars, Text) VALUES 
(1, 1, 5, 'An adventurous journey that will keep you hooked!'),
(2, 2, 4, 'A fascinating exploration of scientific concepts.'),
(3, 3, 3, 'Simple and delicious recipes for everyday cooking.'),
(4, 4, 5, 'An enigmatic and thrilling mystery you won''t be able to put down.'),
(5, 5, 4, 'A mind-bending science fiction adventure through time and space.'),
(6, 6, 3, 'Unleash your inner culinary alchemist with this magical cookbook.'),
(7, 7, 5, 'A captivating biography that paints a vivid portrait of destiny.'),
(8, 8, 4, 'Enter a world of shadows and serendipity in this enchanting fantasy.'),
(9, 1, 3, 'A gripping thriller that will keep you guessing until the very end.'),
(10, 2, 5, 'Whispered words of beauty and emotion in this captivating poetry collection.'),
(1, 3, 4, 'A heartwarming tale of friendship and resilience.'),
(2, 4, 3, 'An introspective journey into the depths of the human psyche.'),
(3, 6, 5, 'A poignant memoir that will touch your soul.'),
(4, 5, 4, 'An epic historical saga filled with passion and drama.'),
(5, 7, 2, 'A disappointing read that fell short of expectations.'),
(6, 8, 5, 'An empowering self-help book that will change your life.'),
(7, 1, 4, 'A thought-provoking exploration of existential themes.'),
(8, 2, 3, 'A light and entertaining romance for a cozy evening.'),
(9, 3, 5, 'A masterfully crafted thriller with unexpected twists.'),
(10, 4, 2, 'A poorly written novel that lacked depth and originality.'),
(1, 2, 4, 'A thrilling page-turner that will keep you on the edge of your seat.'),
(2, 3, 3, 'An informative guide to mastering the art of negotiation.'),
(3, 4, 5, 'A heartwarming story about the power of love and forgiveness.'),
(4, 8, 2, 'A disappointing sequel that failed to live up to the original.'),
(5, 6, 4, 'An inspiring memoir of overcoming adversity and achieving success.'),
(6, 7, 5, 'A beautifully written literary masterpiece that explores the human condition.'),
(7, 8, 3, 'A lighthearted and humorous novel perfect for a weekend read.'),
(8, 6, 4, 'A thought-provoking philosophical inquiry into the nature of existence.'),
(9, 8, 2, 'A confusing and poorly structured book with undeveloped characters.'),
(10, 1, 5, 'A captivating historical fiction that transports you to another era.'),
(1, 7, 4, 'A thrilling and suspenseful story with unexpected twists.'),
(3, 2, 5, 'A must-read cookbook with mouthwatering recipes for every occasion.'),
(5, 3, 4, 'A mind-bending sci-fi adventure that will leave you pondering the nature of reality.');


-- CustomerCheckoutView
CREATE VIEW CustomerCheckoutView AS
SELECT 
    Copy.CopyID AS CopyID,
    Customer.FirstName AS CustomerFirstName,
    Customer.LastName AS CustomerLastName,
    Book.Title AS BookTitle,
    string_agg(Author.FirstName || ' ' || Author.LastName, ', ') AS Authors,
    Copy.DueDate AS DueDate
FROM 
    Customer 
JOIN 
    Copy ON Customer.CustomerID = Copy.CustomerID
JOIN 
    Book ON Copy.BookID = Book.BookID
JOIN 
    Write ON Book.BookID = Write.BookID
JOIN 
    Author ON Write.AuthorID = Author.AuthorID
GROUP BY
    Copy.CopyID,
    Customer.FirstName,
    Customer.LastName,
    Book.Title,
    Copy.DueDate
ORDER BY DueDate;

-- BookAuthorPublisherView
CREATE MATERIALIZED VIEW BookAuthorPublisherMaterializedView AS
SELECT 
    Book.Title AS BookTitle,
    Author.FirstName AS AuthorFirstName,
    Author.LastName AS AuthorLastName,
    Publisher.Name AS PublisherName
FROM 
    Book 
JOIN 
    Write ON Book.BookID = Write.BookID
JOIN 
    Author ON Write.AuthorID = Author.AuthorID
JOIN 
    Publisher ON Book.PublisherID = Publisher.PublisherID;


-- Index on Book.Title for fast retrieval of books by title
CREATE INDEX idx_book_title ON Book (Title);

-- Index on Copy.BookID for efficient joining with Book table
CREATE INDEX idx_copy_bookid ON Copy (BookID);

-- Index on Copy.CustomerID for efficient joining with Customer table
CREATE INDEX idx_copy_customerid ON Copy (CustomerID);

-- Index on Review.BookID for efficient joining with Book table
CREATE INDEX idx_review_bookid ON Review (BookID);

