from django.contrib import admin
from . import models

admin.site.register(models.BookInfo)
admin.site.register(models.StorageInfo)
admin.site.register(models.AuthorityInfo)
admin.site.register(models.StudentInfo)
admin.site.register(models.DepartmentInfo)
admin.site.register(models.AdminInfo)
admin.site.register(models.BorrowRelation)
admin.site.register(models.ReserveRelation)