from django.contrib.auth import authenticate
from django.views.decorators.http import require_http_methods
from django.views.decorators.csrf import csrf_exempt
from django.http import JsonResponse
from .models import StudentInfo, AdminInfo, StorageInfo, ReserveRelation, AuthorityInfo, BorrowRelation
import json

@csrf_exempt
@require_http_methods(["POST"])
def all_view(request):
    # 从请求中获取用户名、动作名和参数
    data = json.loads(request.body.decode('utf-8'))
    username = data.get('username', None)
    action = data.get('action', None)
    parameter = data.get('parameter', None)
    print(username, action, parameter) # 调试用

    # 登录
    if action == 'login':
        # 从请求中获取用户名和密码
        password = parameter.get('password', None)
        if username and password:
            return login(username, password)
        else:
            return JsonResponse({'status': 'error', 'message': 'Invalid username or password'}, status=400)
    # 查询图书
    elif action == 'search_book':
        # 从请求中获取查询关键字
        keyword = parameter.get('keyword', None)
        if keyword:
            return search_book(keyword)
        else:
            return JsonResponse({'status': 'error', 'message': 'Invalid keyword'}, status=400)
    # 预约图书
    elif action == 'reserve_book':
        # 从请求中获取藏书号
        storage_id = parameter.get('storage_id', None)
        if storage_id:
            return reserve_book(username, storage_id)
        else:
            return JsonResponse({'status': 'error', 'message': 'Invalid storage_id'}, status=400)
    # 获取所有学生信息
    elif action == 'get_all_student_info':
        return student_info()
    # 添加新的学生信息
    elif action == 'new_student_info':
        return add_student_info(parameter)
    # 删除学生信息
    elif action == 'delete_student_info':
        return delete_student_info(parameter)
    # 获取所有借阅信息
    elif action == 'get_all_borrow_info':
        return borrow_info()
    # 添加借阅记录
    elif action == 'new_borrow_info':
        return add_borrow_info(parameter)
    # 删除借阅记录
    elif action == 'delete_borrow_info':
        return delete_borrow_info(parameter)
    # 获取所有预约信息
    elif action == 'get_all_reserve_info':
        return reserve_info()
    # 添加预约记录
    elif action == 'new_reserve_info':
        return add_reserve_info(parameter)
    # 删除预约记录
    elif action == 'delete_reserve_info':
        return delete_reserve_info(parameter)
    else:
        return JsonResponse({'status': 'error', 'message': 'Invalid action'}, status=400)


# 登录，返回状态码为200代表成功登录，否则代表登录失败
def login(username, password): 
    # 查询学生表
    student = StudentInfo.objects.filter(student_id=username, login_key=password).first()
    if student:
        return JsonResponse({'status': 'success', 'is_admin': 'false', 'user_id': student.student_id}, status=200)
    # 查询职工表
    admin = AdminInfo.objects.filter(admin_id=username, login_key=password).first()
    if admin:
        return JsonResponse({'status': 'success', 'is_admin': 'true', 'user_id': admin.admin_id}, status=200)
    # 用户名或密码不正确
    return JsonResponse({'status': 'error', 'message': 'Invalid username or password'}, status=400)

# 搜索藏书，查找藏书中是否有书名、作者或出版社包含了关键字
def search_book(keyword):
    # 记录要返回的藏书的藏书号
    storage_id_list = []

    # 记录书名或作者包含关键字的书号
    book_id_list = []
    # 查询书名包含关键字的书号
    book_list = StorageInfo.objects.filter(book_id__book_name__contains=keyword)
    for book in book_list:
        book_id_list.append(book.storage_id)
    # 查询作者包含关键字的书号
    book_list = StorageInfo.objects.filter(book_id__book_author__contains=keyword)
    for book in book_list:
        book_id_list.append(book.storage_id)

    # 查询出版社包含关键字的书号
    book_list = StorageInfo.objects.filter(storage_publish__contains=keyword)
    for book in book_list:
        storage_id_list.append(book.storage_id)
    # 查询书号在book_id_list中的藏书号
    book_list = StorageInfo.objects.filter(storage_id__in=book_id_list)
    for book in book_list:
        storage_id_list.append(book.storage_id)
    
    # 去除重复项
    storage_id_list = list(set(storage_id_list))
    # 返回藏书信息，包括封面图、书号、书名、作者、出版社、出版时间、在馆状态
    storage_info_list = []
    for storage_id in storage_id_list:
        storage = StorageInfo.objects.get(storage_id=storage_id)
        storage_info_list.append({
            'storage_cover': storage.storage_cover.url,
            'storage_id': storage.storage_id,
            'book_id': storage.book_id.book_id,
            'book_name': storage.book_id.book_name,
            'book_author': storage.book_id.book_author,
            'storage_publish': storage.storage_publish,
            'storage_publish_time': storage.storage_publish_time,
            'storage_state': storage.storage_state
        })
        print(storage.book_id.book_id, storage.book_id.book_name, storage.storage_state) # 调试
    return JsonResponse({'status': 'success', 'storage_info_list': storage_info_list}, status=200)

# 预约图书
def reserve_book(username, storage_id):
    # 查询学生表
    student = StudentInfo.objects.filter(student_id=username).first()
    if student:
        # 查询藏书表
        storage = StorageInfo.objects.filter(storage_id=storage_id).first()
        if storage:
            # 查询预约关系表
            reserve = ReserveRelation.objects.filter(student_id=student, storage_id=storage).first()
            if reserve:
                return JsonResponse({'status': 'error', 'message': 'You have reserved this book'}, status=400)
            else:
                # 创建预约关系
                ReserveRelation.objects.create(student_id=student, storage_id=storage)
                return JsonResponse({'status': 'success'}, status=200)
        else:
            return JsonResponse({'status': 'error', 'message': 'Invalid storage_id'}, status=400)
    else:
        return JsonResponse({'status': 'error', 'message': 'Invalid username'}, status=400)
    
# 返回所有学生的信息
def student_info():
    student_info = StudentInfo.objects.all()
    student_info_list = []
    for student in student_info:
        student_info_list.append({
            'student_id': student.student_id,
            'student_name': student.student_name,
            'student_degree': student.student_degree.degree,
            'login_key': student.login_key,
            'student_email': student.student_email
        })
    return JsonResponse({'student_info_list': student_info_list}, status=200)

# 添加新的学生信息
def add_student_info(parameter):
    student_id = parameter.get('student_id', None)
    student_name = parameter.get('student_name', None)
    student_degree = parameter.get('student_degree', None)
    login_key = parameter.get('login_key', None)
    student_email = parameter.get('student_email', None)
    if student_id and student_name and student_degree and login_key and student_email:
        student_degree = AuthorityInfo.objects.filter(degree=student_degree).first()
        if student_degree:
            StudentInfo.objects.create(student_id=student_id, student_name=student_name, student_degree=student_degree, login_key=login_key, student_email=student_email)
            return JsonResponse({'status': 'success'}, status=200)
        else:
            return JsonResponse({'status': 'error', 'message': 'Invalid student_degree'}, status=400)
    else:
        return JsonResponse({'status': 'error', 'message': 'Invalid parameter'}, status=400)

# 删除学生信息
def delete_student_info(parameter):
    student_id = parameter.get('student_id', None)
    if student_id:
        student = StudentInfo.objects.filter(student_id=student_id).first()
        if student:
            student.delete()
            return JsonResponse({'status': 'success'}, status=200)
        else:
            return JsonResponse({'status': 'error', 'message': 'Invalid student_id'}, status=400)
    else:
        return JsonResponse({'status': 'error', 'message': 'Invalid parameter'}, status=400)
    
# 返回所有借阅信息
def borrow_info():
    borrow_info = BorrowRelation.objects.all()
    borrow_info_list = []
    for borrow in borrow_info:
        borrow_info_list.append({
            'student_id': borrow.student_id.student_id,
            'storage_id': borrow.storage_id.storage_id,
            'book_name': borrow.storage_id.book_id.book_name,
            'borrow_date': borrow.borrow_date,  
            'return_date': borrow.return_date
        })
    return JsonResponse({'borrow_info_list': borrow_info_list}, status=200)

# 添加借阅记录
def add_borrow_info(parameter):
    student_id = parameter.get('student_id', None)
    storage_id = parameter.get('storage_id', None)
    borrow_date = parameter.get('borrow_date', None)
    return_date = parameter.get('return_date', None)
    if student_id and storage_id and borrow_date and return_date:
        student = StudentInfo.objects.filter(student_id=student_id).first()
        storage = StorageInfo.objects.filter(storage_id=storage_id).first()
        if student and storage:
            # 检查书籍是否已经被借
            if(storage.storage_state):
                return JsonResponse({'status': 'error', 'message': 'The book has been borrowed'}, status=400)
            # 检查借书人的借阅数量是否已达到上限
            borrow_num = student.student_degree.borrow_num
            borrow_info = BorrowRelation.objects.filter(student_id=student)
            if len(borrow_info) >= borrow_num:
                return JsonResponse({'status': 'error', 'message': 'You have borrowed too many books'}, status=400)
            # 创建借阅关系，并更新藏书状态
            BorrowRelation.objects.create(student_id=student, storage_id=storage, borrow_date=borrow_date, return_date=return_date)
            storage.storage_state = True
            return JsonResponse({'status': 'success'}, status=200)
        else:
            return JsonResponse({'status': 'error', 'message': 'Invalid student_id or storage_id'}, status=400)
    else:
        return JsonResponse({'status': 'error', 'message': 'Invalid parameter'}, status=400)
    
# 删除借阅记录
def delete_borrow_info(parameter):
    storage_id = parameter.get('storage_id', None)
    if storage_id:
        storage = StorageInfo.objects.filter(storage_id=storage_id).first()
        if storage:
            borrow = BorrowRelation.objects.filter(storage_id=storage).first()
            if borrow:
                borrow.delete()
                storage.storage_state = False
                return JsonResponse({'status': 'success'}, status=200)
            else:
                return JsonResponse({'status': 'error', 'message': 'Invalid student_id or storage_id'}, status=400)
        else:
            return JsonResponse({'status': 'error', 'message': 'Invalid student_id or storage_id'}, status=400)
    else:
        return JsonResponse({'status': 'error', 'message': 'Invalid parameter'}, status=400)
    
# 返回所有预约信息
def reserve_info():
    reserve_info = ReserveRelation.objects.all()
    reserve_info_list = []
    for reserve in reserve_info:
        reserve_info_list.append({
            'student_id': reserve.student_id.student_id,
            'storage_id': reserve.storage_id.storage_id,
            'book_name': reserve.storage_id.book_id.book_name
        })
    return JsonResponse({'reserve_info_list': reserve_info_list}, status=200)

# 添加预约记录
def add_reserve_info(parameter):
    student_id = parameter.get('student_id', None)
    storage_id = parameter.get('storage_id', None)
    if student_id and storage_id:
        student = StudentInfo.objects.filter(student_id=student_id).first()
        storage = StorageInfo.objects.filter(storage_id=storage_id).first()
        if student and storage:
            # 检查书籍是否已经被借
            if(storage.storage_state):
                return JsonResponse({'status': 'error', 'message': 'The book has been borrowed'}, status=400)
            # 创建预约关系
            ReserveRelation.objects.create(student_id=student, storage_id=storage)
            return JsonResponse({'status': 'success'}, status=200)
        else:
            return JsonResponse({'status': 'error', 'message': 'Invalid student_id or storage_id'}, status=400)
    else:
        return JsonResponse({'status': 'error', 'message': 'Invalid parameter'}, status=400)
    
# 删除预约记录
def delete_reserve_info(parameter):
    storage_id = parameter.get('storage_id', None)
    if storage_id:
        storage = StorageInfo.objects.filter(storage_id=storage_id).first()
        if storage:
            reserve = ReserveRelation.objects.filter(storage_id=storage).first()
            if reserve:
                reserve.delete()
                return JsonResponse({'status': 'success'}, status=200)
            else:
                return JsonResponse({'status': 'error', 'message': 'Invalid student_id or storage_id'}, status=400)
        else:
            return JsonResponse({'status': 'error', 'message': 'Invalid student_id or storage_id'}, status=400)
    else:
        return JsonResponse({'status': 'error', 'message': 'Invalid parameter'}, status=400)