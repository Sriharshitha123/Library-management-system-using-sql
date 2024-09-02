select * from tbl_publisher;
desc tbl_publisher;

select * from tbl_borrower;
desc tbl_borrower;

select * from tbl_library_branch;
desc tbl_library_branch;

select * from tbl_book;
desc tbl_book;

select * from tbl_book_copies;
desc tbl_book_copies;

select * from tbl_book_loans;
desc tbl_book_loans;


select * from tbl_book_authors;


SELECT book_authors_AuthorName, COUNT(*)
FROM tbl_book_authors
GROUP BY book_authors_AuthorName
HAVING COUNT(*) > 1;



alter table tbl_book_loans add column new_book_loans_DateOut date;

select * from tbl_book_loans;

update tbl_book_loans 
set new_book_loans_DateOut = str_to_date(book_loans_DateOut,'%c/%e/%Y');


select * from tbl_book_loans;


update tbl_book_loans
set book_loans_DueDate = str_to_date(book_loans_DueDate,'%c/%e/%Y');

select * from tbl_book_loans;


alter table tbl_book_loans drop column new_book_loans_DateOut;

update tbl_book_loans
set book_loans_DateOut = str_to_date(book_loans_DateOut,'%c/%e/%Y');

alter table tbl_book_loans modify column book_loans_DateOut date not null;
alter table tbl_book_loans modify column book_loans_DueDate date not null;

desc tbl_book_loans;