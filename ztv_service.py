 #!/usr/bin/python
 # -*- coding: utf-8 -*-

from datetime import datetime, timedelta
from iso8601 import parse_date
from robot.api import logger


def convert_datetime_to_ztv_format(isodate):
    iso_dt = parse_date(isodate)
    day_string = iso_dt.strftime("%d/%m/%Y %H:%M")
    return day_string

def convert_string_from_dict_dzo(string):
    return {
        u"грн": u"UAH",
        u"True": u"1",
        u"False": u"0",
        u"Відкриті торги": u"aboveThresholdUA",
        u'Початкова класифiкацiя елемента': u'CPV',
        u'Додаткова классификация': u'ДКПП',
        u'з урахуванням ПДВ': True,
        u'без урахуванням ПДВ': False,
        u'Очiкування пропозицiй': u'active.tendering',
        u'Перiод уточнень': u'active.enquires',
        u'Перiод аукцiону (аукцiон)': u'active.auction',
    }.get(string, string)

def adapt_procuringEntity(tender_data):
    tender_data['data']['procuringEntity']['name'] = u"Ольмек"
    return tender_data

def adapt_view_data(value, field_name):
    if field_name == 'value.amount':
        value = float(value.split(' ')[0])
    elif field_name == 'value.currency':
        value = value.split(' ')[1]    
    elif field_name == 'value.valueAddedTaxIncluded':
        value = ' '.join(value.split(' ')[2:])
    elif field_name == 'minimalStep.amount':
        value = float(value.split(' ')[0])
    elif 'unit.name' in field_name:
        value = value.split(' ')[1]
    elif 'quantity' in field_name:
        value = float(value.split(' ')[0])
    elif 'questions' in field_name and '.date' in field_name:
        value = value.split(' - ')[0]
    return convert_string_from_dict_dzo(value)