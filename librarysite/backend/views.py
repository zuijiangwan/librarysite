from django.contrib.auth import authenticate
from django.views.decorators.http import require_http_methods
from django.views.decorators.csrf import csrf_exempt
from django.http import JsonResponse
from .models import StudentInfo, AdminInfo, StorageInfo
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
    # 主界面获取学生信息
    elif action == 'get_student_info':
        student = StudentInfo.objects.filter(student_id=username).first()
        if student:
            return JsonResponse({'status': 'success', 
                                 'student_id': student.student_id, 
                                 'student_name': student.student_name, 
                                 'student_email': student.student_email
            })
    # 查询图书
    elif action == 'search_book':
        # 从请求中获取查询关键字
        keyword = parameter.get('keyword', None)
        if keyword:
            books = StorageInfo.objects.filter(book_name__contains=keyword)
            return JsonResponse({'status': 'success', 'books': list(books.values())})
        else:
            return JsonResponse({'status': 'error', 'message': 'Invalid keyword'}, status=400)
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