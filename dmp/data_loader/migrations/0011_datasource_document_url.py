# -*- coding: utf-8 -*-
# Generated by Django 1.11 on 2017-05-24 14:03
from __future__ import unicode_literals

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('data_loader', '0010_auto_20170518_1221'),
    ]

    operations = [
        migrations.AddField(
            model_name='datasource',
            name='document_url',
            field=models.CharField(default=None, max_length=355, verbose_name='Document URL'),
        ),
    ]