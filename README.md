# 指令说明
前端启动命令：
```shell
flutter run -d edge --web-hostname 127.0.0.1 --web-port 3000
```

后端启动命令：
```shell
py manage.py runserver
```
后端默认跑在8000端口。

后端数据库有更新：
```shell
py manage.py makemigrations backend
py manage.py migrate backend
```