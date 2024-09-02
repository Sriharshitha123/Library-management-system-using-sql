create database if not exists library_management;

use library_management;

# table 1 publishers creation 
create table tbl_publisher
(publisher_PublisherName varchar(40)  primary key,
publisher_PublisherAddress varchar(255) not null,
publisher_PublisherPhone varchar(30)
);

select * from tbl_publisher;

# table 2 borrower creation
create table tbl_borrower
(borrower_CardNo smallint auto_increment primary key,
borrower_BorrowerName varchar(40) not null,
borrower_BorrowerAddress varchar(255) not null,
borrower_BorrowerPhone varchar(12)
);

select * from tbl_borrower;


# table 3 library branch creation

create table tbl_library_branch
(library_branch_BranchID smallint auto_increment primary key,
library_branch_BranchName varchar(40) not null,
library_branch_BranchAddress varchar(150) not null);

select * from tbl_library_branch;


# table 4 book creation 

create table tbl_book
(book_BookID smallint auto_increment primary key,
book_Title varchar(50) not null,
book_PublisherName varchar(40) not null,
foreign key (book_PublisherName) references tbl_publisher(publisher_PublisherName)
on update CASCADE on Delete CASCADE
);

select * from tbl_book;

# table 5 book_authors creation


create table tbl_book_authors
(book_authors_AuthorID smallint auto_increment primary key,
book_authors_BookID smallint not null,
book_authors_AuthorName varchar(255) not null,
foreign key (book_authors_BookID) references tbl_book(book_BookID)
on update CASCADE on Delete CASCADE
);

select * from tbl_book_authors;


# table 6 book_copies creation

create table tbl_book_copies
(book_copies_CopiesID smallint auto_increment primary key,
book_copies_BookID smallint not null,
book_copies_BranchID smallint not null,
book_copies_No_Of_Copies smallint not null,
foreign key (book_copies_BookID) references tbl_book(book_BookID) 
on update CASCADE on Delete CASCADE,
foreign key (book_copies_BranchID) references tbl_library_branch(library_branch_BranchID) 
on update CASCADE on Delete CASCADE
);

select * from tbl_book_copies;


# table 7 book loans creation

create table tbl_book_loans
(book_loans_LoanID smallint auto_increment primary key,
book_loans_BookID smallint not null,
book_loans_BranchID smallint not null,
book_loans_CardNo smallint not null,
book_loans_DateOut varchar(12) not null,
book_loans_DueDate varchar(12) not null,
foreign key (book_loans_BookID) references tbl_book(book_BookID) 
on update CASCADE on Delete CASCADE,
foreign key (book_loans_BranchID) references tbl_library_branch(library_branch_BranchID) 
on update CASCADE on Delete CASCADE,
foreign key (book_loans_CardNo) references tbl_borrower(borrower_CardNo) 
on update CASCADE on Delete CASCADE
);

select * from tbl_book_loans;


## importing data from csv files

-- 1. publishers              5. book_authors
-- 2. borrower                6. book_copies
-- 3. library branch          7. book loans
-- 4. book

-- Task questions

-- 1. How many copies of the book titled "The Lost Tribe" are owned by the library branch whose name is "Sharpstown"?


select * from tbl_book_copies;

select  book_BookID, book_Title, library_branch_BranchID, 
library_branch_BranchName, book_copies_No_Of_Copies 
from tbl_book_copies bc
inner join tbl_book b
on bc.book_copies_BookID = b.book_BookID
inner join tbl_library_branch lb
on bc.book_copies_BranchID = lb.library_branch_BranchID
where library_branch_BranchName = 'Sharpstown' and book_Title = 'The Lost Tribe';


-- 2. How many copies of the book titled "The Lost Tribe" are owned by each library branch?

select  book_BookID, book_Title, library_branch_BranchID, 
library_branch_BranchName, book_copies_No_Of_Copies 
from tbl_book_copies bc
inner join tbl_book b
on bc.book_copies_BookID = b.book_BookID
inner join tbl_library_branch lb
on bc.book_copies_BranchID = lb.library_branch_BranchID
where book_Title = 'The Lost Tribe';


-- 3. Retrieve the names of all borrowers who do not have any books checked out.

select * from tbl_borrower;
select * from tbl_book_loans;

select borrower_BorrowerName 
from tbl_borrower b
where not exists (select 1 from tbl_book_loans bl where b.borrower_CardNo = bl.book_loans_CardNo);




-- 4. For each book that is loaned out from the "Sharpstown" branch and whose DueDate is 2/3/18,
-- retrieve the book title, the borrower's name, and the borrower's address. 

select book_Title,borrower_BorrowerName,borrower_BorrowerAddress
from tbl_book  b
join tbl_book_loans bl
on b.book_BookID = bl.book_loans_BookID
join tbl_library_branch lb
on bl.book_loans_BranchID = lb.library_branch_BranchID
join tbl_borrower br
on bl.book_loans_CardNo = br.borrower_CardNo
where book_loans_Duedate = '2/3/18' and library_branch_BranchName = 'Sharpstown';


-- 5. For each library branch, retrieve the branch name and the 
-- total number of books loaned out from that branch.

select * from tbl_library_branch;
select * from tbl_book_loans;


select library_branch_BranchName,count(*) as no_of_books_loaned_out
from tbl_library_branch lb
join tbl_book_loans bl
on lb.library_branch_BranchID = bl.book_loans_BranchID
group by library_branch_BranchName;


-- 6. Retrieve the names, addresses, and number of books 
-- checked out for all borrowers who have more than five books checked out.

WITH cte AS
(SELECT b.borrower_BorrowerName,count(book_loans_CardNo) AS no_of_books_checkedout
FROM tbl_borrower b
JOIN tbl_book_loans bl
ON b.borrower_CardNo = bl.book_loans_CardNo
GROUP BY borrower_BorrowerName)
SELECT b.borrower_BorrowerName,borrower_BorrowerAddress,no_of_books_checkedout 
from tbl_borrower b
join cte c
on b.borrower_BorrowerName = c.borrower_BorrowerName
where no_of_books_checkedout > 5;


-- 7. For each book authored by "Stephen King", 
-- retrieve the title and the number of copies owned by the library branch whose name is "Central".

select * from tbl_library_branch;
select * from tbl_book;
select * from tbl_book_copies;

select book_Title,book_copies_No_Of_Copies,library_branch_BranchName
from tbl_library_branch lb
join tbl_book_copies bc 
on lb.library_branch_BranchID = bc.book_copies_BranchID
join tbl_book b
on bc.book_copies_BookID = b.book_BookID
join tbl_book_authors ba
on b.book_BookID = ba.book_authors_BookID
where book_authors_AuthorName = 'Stephen King' and
library_branch_BranchName = 'Central';


-- Additional Analysis
------------------------------
-- 1. retrive the name of the person who has borrowed books from all the library branches
-- 2. Latest checked out book from each library
-- 3. Number of books published by each publisher :
    -- a: Names of the books published by a publisher with highest number of books.



-- 1. retrive the name of the person who has borrowed books from all the library branches

# approach 1  (using having clause)
SELECT b.borrower_BorrowerName,count(distinct bl.book_loans_BranchID) as no_of_branches_borrowed
FROM tbl_borrower b
JOIN tbl_book_loans bl
ON b.borrower_CardNo = bl.book_loans_CardNo
JOIN tbl_library_branch lb
ON bl.book_loans_BranchID = lb.library_branch_BranchID
group by borrower_BorrowerName
having no_of_branches_borrowed = (select count(*) from tbl_library_branch);


# approach 2 (not using having clause)

with cte as
(SELECT distinct borrower_BorrowerName,book_loans_BranchID
FROM tbl_borrower b
JOIN tbl_book_loans bl
ON b.borrower_CardNo = bl.book_loans_CardNo
JOIN tbl_library_branch lb
ON bl.book_loans_BranchID = lb.library_branch_BranchID)
select * from 
(select *, row_number() over(partition by borrower_BorrowerName) as rn
from cte) as derived
where rn = (select count(*) from tbl_library_branch);


# ans : No borrowers who have checkout books from all the libraries.

-- 2. Latest checked out book from each library

select * from tbl_library_branch;
select * from tbl_book_loans;
select * from tbl_book;

with cte as 
(SELECT library_branch_BranchName,book_Title,book_loans_DateOut,dense_rank() over (partition by library_branch_BranchName order by book_loans_DateOut desc) as rn,
ROW_NUMBER() OVER (PARTITION BY library_branch_BranchName ORDER BY book_loans_DateOut DESC) AS row_num
FROM tbl_library_branch lb
JOIN tbl_book_loans bl
ON lb.library_branch_BranchID = bl.book_loans_BranchID
JOIN tbl_book b
ON bl.book_loans_BookID = b.book_BookID)
select * 
From cte
where rn = 1 and row_num = 1;


-- 3. Number of books published by each publisher :
    -- a: Names of the books published by a publisher with highest number of books.
    
select * from tbl_publisher;
select * from tbl_book;

SELECT p.publisher_PublisherName,count(book_Title) as no_of_books_published
FROM tbl_publisher p
JOIN tbl_book b
ON p.publisher_PublisherName = b.book_PublisherName
group by p.publisher_PublisherName;

-- a: Names of the books published by a publisher with highest number of books.



select book_Title
from tbl_book
where book_PublisherName = 
(with cte as
(SELECT p.publisher_PublisherName,count(book_Title) as no_of_books_published
FROM tbl_publisher p
JOIN tbl_book b
ON p.publisher_PublisherName = b.book_PublisherName
group by p.publisher_PublisherName)
select publisher_PublisherName from cte
where no_of_books_published = (select max(no_of_books_published) from cte));














