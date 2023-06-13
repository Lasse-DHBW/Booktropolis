-- Find all customers who have checked out a specific book:
SELECT Book.Title, Customer.FirstName, Customer.LastName
FROM Customer
JOIN Copy ON Customer.CustomerID = Copy.CustomerID
JOIN Book ON Copy.BookID = Book.BookID
WHERE Book.Title = 'Science 101';

-- Get the total number of available copies for a particular book
SELECT Book.Title, COUNT(*) AS "TotalCopies"
FROM Copy
JOIN Book ON Book.BookID = Copy.BookID
WHERE Book.Title = 'Journey to the East' AND Copy.IsReturned = true
GROUP BY Book.Title;

-- Find the top-rated books along with their average ratings:
SELECT Book.Title, AVG(Review.Stars) AS AverageRating, COUNT(Review.BookID) AS ReviewCount
FROM Book
LEFT JOIN Review ON Book.BookID = Review.BookID
GROUP BY Book.BookID
ORDER BY AverageRating DESC;

-- Find the titles of books written by American authors that have received more than three reviews.
SELECT DISTINCT Book.Title
FROM Book
JOIN Write ON Book.BookID = Write.BookID
JOIN Author ON Write.AuthorID = Author.AuthorID
JOIN (
  SELECT BookID, COUNT(*) AS ReviewCount
  FROM Review
  GROUP BY BookID
  HAVING COUNT(*) > 3
) AS ReviewCountTable ON Book.BookID = ReviewCountTable.BookID
WHERE Author.Nationality = 'American';

-- Find all the authors and publisher that have realeased a book after 18.06.2023. List the Name or Lastname and indecate of what type they are.
WITH BooksWithReleaseDate AS (
  SELECT BookID
  FROM Book
  WHERE ReleaseDate > '2014-06-18'
)
SELECT LastName AS Name, 'Author' AS Type
FROM Author
WHERE AuthorID IN (
  SELECT AuthorID
  FROM Write
  WHERE BookID IN (SELECT BookID FROM BooksWithReleaseDate)
)
UNION
SELECT Name, 'Publisher' AS Type
FROM Publisher
WHERE PublisherID IN (
  SELECT PublisherID
  FROM Book
  WHERE BookID IN (SELECT BookID FROM BooksWithReleaseDate)
)
ORDER BY Type ASC;


-- Find all customers  who have reviewed the book they have currently checked out.
SELECT FirstName, LastName
FROM Customer
WHERE CustomerID IN (
  SELECT CustomerID
  FROM Review
)
INTERSECT
SELECT FirstName, LastName
FROM Customer
WHERE CustomerID IN (
  SELECT CustomerID
  FROM Copy
  WHERE IsReturned = false
  AND BookID IN (
    SELECT BookID
    FROM Review
    WHERE CustomerID = Copy.CustomerID
  )
);

-- For each publisher find the number of books they have published in each genre (if there are any) and calculate the average rating for each publisher genre combination
SELECT Publisher.Name AS PublisherName, Book.Genre AS Genre, COALESCE(BookCount.BookCount, 0) AS BookCount, AVG(Review.Stars) AS AverageRating
FROM Publisher
JOIN Book ON Publisher.PublisherID = Book.PublisherID
LEFT JOIN (
    SELECT PublisherID, Genre, COUNT(*) AS BookCount
    FROM Book
    GROUP BY PublisherID, Genre
) AS BookCount ON Publisher.PublisherID = BookCount.PublisherID AND Book.Genre = BookCount.Genre
LEFT JOIN Review ON Book.BookID = Review.BookID
GROUP BY Publisher.PublisherID, Publisher.Name, Book.Genre, BookCount.BookCount
ORDER BY PublisherName;
