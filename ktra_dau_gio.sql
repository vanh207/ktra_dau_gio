CREATE DATABASE StudentDB;
USE StudentDB;

-- 1. Bảng Khoa
CREATE TABLE Department (
    DeptID VARCHAR(5) PRIMARY KEY,
    DeptName VARCHAR(50) NOT NULL
);

-- 2. Bảng SinhVien
CREATE TABLE Student (
    StudentID VARCHAR(6) PRIMARY KEY,
    FullName VARCHAR(50),
    Gender VARCHAR(10),
    BirthDate DATE,
    DeptID VARCHAR(5),
    FOREIGN KEY (DeptID) REFERENCES Department(DeptID)
);

-- 3. Bảng MonHoc
CREATE TABLE Course (
    CourseID VARCHAR(6) PRIMARY KEY,
    CourseName VARCHAR(50),
    Credits INT
);

-- 4. Bảng DangKy
CREATE TABLE Enrollment (
    StudentID VARCHAR(6),
    CourseID VARCHAR(6),
    Score DECIMAL(4,2), 
    PRIMARY KEY (StudentID, CourseID),
    FOREIGN KEY (StudentID) REFERENCES Student(StudentID),
    FOREIGN KEY (CourseID) REFERENCES Course(CourseID)
);

-- Chèn dữ liệu mẫu
INSERT INTO Department VALUES
('IT','Information Technology'),
('BA','Business Administration'),
('ACC','Accounting');

INSERT INTO Student VALUES
('S00001','Nguyen An','Male','2003-05-10','IT'),
('S00002','Tran Binh','Male','2003-06-15','IT'),
('S00003','Le Hoa','Female','2003-08-20','BA'),
('S00004','Pham Minh','Male','2002-12-12','ACC'),
('S00005','Vo Lan','Female','2003-03-01','IT'),
('S00006','Do Hung','Male','2002-11-11','BA'),
('S00007','Nguyen Mai','Female','2003-07-07','ACC'),
('S00008','Tran Phuc','Male','2003-09-09','IT');

INSERT INTO Course VALUES
('C00001', 'Database Systems', 3),
('C00002', 'Programming', 4),
('C00003', 'Marketing', 2);

INSERT INTO Enrollment VALUES
('S00001', 'C00001', 8.50),
('S00002', 'C00001', 9.25),
('S00005', 'C00001', 7.75),
('S00008', 'C00001', 8.00),
('S00001', 'C00002', 8.75),
('S00003', 'C00003', 7.00),
('S00006', 'C00003', 6.50);

create view ViewStudentBasic as
select s.StudentID, s.FullName, d.DeptName
from Student s join Department d on s.DeptID=d.DeptID;

create index idxFullName on Student(idxFullName);

DELIMITER //
create procedure GetStudentsIT() 
begin
	select s.StudentID, s.FullName, d.DeptName
	from Student s join Department d on s.DeptID=d.DeptID
    where d.DeptName = 'Information Technology';
end //
DELIMITER ;

call GetStudentsIT();

create view ViewStudentCountByDept as
select d.DeptName,
    COUNT(s.StudentID) AS TotalStudents
from Department d
left join Student s
    on d.DeptID = s.DeptID
group by d.DeptName;

select * from ViewStudentCountByDept;

DELIMITER //
create procedure GetTopScoreStudent(IN varCourseID VARCHAR(6))
begin
	select
        s.StudentID,
        s.FullName,
        c.CourseName,
        e.Score
    from Enrollment e
    join Student s
        on e.StudentID = s.StudentID
    join Course c
        on e.CourseID = c.CourseID
    where e.CourseID = varCourseID
      and e.Score = (
            select MAX(Score)
            from Enrollment
            where CourseID = varCourseID);
end //
DELIMITER ;

call GetTopScoreStudent('C00001');

create view ViewITEnrollmentDB as
select s.StudentID, s.FullName, d.DeptName, e.CourseID, e.Score
from Student s 
join Department d on s.DeptID=d.DeptID
join Enrollment e on s.StudentID = e.StudentID
where d.DeptID = 'IT' and e.CourseID ='C00001';

select * from ViewITEnrollmentDB;

DELIMITER //
create procedure UpdateScoreITDB(IN varStudentID VARCHAR(6),INOUT inoutNewScore DECIMAL(4,2))
begin
	if inoutNewScore > 10 then
		set inoutNewScore = 10;
    end if;
    update ViewITEnrollmentDB
    set Score = inoutNewScore
    where StudentID = varStudentID;
end //
DELIMITER ;

set @newScore = 11;
CALL UpdateScoreITDB('S00001', @newScore);
SELECT @newScore AS FinalScore;
SELECT * FROM ViewITEnrollmentDB;