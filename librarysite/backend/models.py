from django.db import models

# 书籍信息
class BookInfo(models.Model):
    book_id = models.CharField(max_length=10, primary_key=True) # 书号，主键
    book_name = models.CharField(max_length=20) # 书名
    book_author = models.CharField(max_length=20) # 作者

# 藏书信息
class StorageInfo(models.Model):
    storage_id = models.CharField(max_length=10, primary_key=True) # 条形码，主键
    storage_position = models.CharField(max_length=20) # 藏书所在校区
    storage_cover = models.ImageField(upload_to='cover/') # 封面
    book_id = models.ForeignKey(BookInfo, on_delete=models.CASCADE) # 书号，外键
    storage_publish = models.CharField(max_length=20) # 出版社
    storage_publish_time = models.DateField() # 出版时间
    storage_state = models.BooleanField() # 在馆或借出

# 权限信息
class AuthorityInfo(models.Model):
    degree = models.CharField(max_length=10, primary_key=True) # 学历，由此决定权限，主键
    borrow_num = models.IntegerField() # 可借数量

# 学生信息
class StudentInfo(models.Model):
    student_id = models.CharField(max_length=10, primary_key=True) # 学号，主键
    student_name = models.CharField(max_length=20)
    student_degree = models.ForeignKey(AuthorityInfo, on_delete=models.CASCADE)
    login_key = models.CharField(max_length=20)
    student_email = models.EmailField()

# 部门信息
class DepartmentInfo(models.Model):
    department_id = models.CharField(max_length=10, primary_key=True) # 部门编号，主键
    department_name = models.CharField(max_length=20) # 部门名

# 职工信息
class AdminInfo(models.Model):
    admin_id = models.CharField(max_length=10, primary_key=True) # 职工号，主键
    admin_name = models.CharField(max_length=20)
    admin_email = models.EmailField()
    login_key = models.CharField(max_length=20)
    department_id = models.ForeignKey(DepartmentInfo, on_delete=models.CASCADE) # 部门编号，外键

# 借阅关系
class BorrowRelation(models.Model):
    student_id = models.ForeignKey(StudentInfo, on_delete=models.CASCADE) # 学号，外键
    storage_id = models.ForeignKey(StorageInfo, on_delete=models.CASCADE, primary_key=True) # 条形码，外键
    borrow_date = models.DateField() # 借书日期
    return_date = models.DateField() # 应还日期

# 预约关系
class ReserveRelation(models.Model):
    student_id = models.ForeignKey(StudentInfo, on_delete=models.CASCADE) # 学号，外键
    storage_id = models.ForeignKey(StorageInfo, on_delete=models.CASCADE) # 条形码，外键