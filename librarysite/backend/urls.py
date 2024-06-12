from django.urls import path
from django.urls import re_path
from . import views

urlpatterns = [
    path('', views.all_view, name='all'),
]