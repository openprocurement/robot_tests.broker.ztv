*** Settings ***
Library  Selenium2Screenshots
Library  String
Library  DateTime
Library  ztv_service.py

*** Variables ***
${locator.tenderId}  xpath=//div[contains(text(), 'TenderID')]/following-sibling::div/b

*** Keywords ***

Підготувати дані для оголошення тендера
  [Arguments]  ${username}  ${tender_data}
  ${tender_data}=  adapt_procuringEntity  ${tender_data}
  [return]  ${tender_data}

Підготувати клієнт для користувача
  [Arguments]  ${username}
  Open Browser  ${USERS.users['${username}'].homepage}  ${USERS.users['${username}'].browser}  alias=${username}
  Set Window Size  @{USERS.users['${username}'].size}
  Set Window Position  @{USERS.users['${username}'].position}
  Run Keyword If  '${username}' != 'ztv_Viewer'  Login  ${username}

Login
  [Arguments]  ${username}
  Wait Until Page Contains Element  id=loginform-username  10
  Input text  id=loginform-username  ${USERS.users['${username}'].login}
  Input text  id=loginform-password  ${USERS.users['${username}'].password}
  Click Element  name=login-button

###############################################################################################################
######################################    СТВОРЕННЯ ТЕНДЕРУ    ################################################
###############################################################################################################

Створити тендер
  [Arguments]  ${username}  ${tender_data} 
  ${items}=  Get From Dictionary  ${tender_data.data}  items
  Switch Browser  ${username}
  Reload Page
  Wait Until Page Contains Element  xpath=//a[@href="/web/buyer/tenders"]  10
  Click Element  xpath=//a[@href="/web/buyer/tenders"]
  Click Element  xpath=//a[@href="/web/buyer/tender/create"]
  Conv And Select From List By Value  name=Tender[value][valueAddedTaxIncluded]  ${tender_data.data.value.valueAddedTaxIncluded}
  ConvToStr And Input Text  name=Tender[value][amount]  ${tender_data.data.value.amount}
  ConvToStr And Input Text  name=Tender[minimalStep][amount]  ${tender_data.data.minimalStep.amount}
  Select From List By Value  name=Tender[value][currency]  ${tender_data.data.value.currency}
  Input text  name=Tender[title]  ${tender_data.data.title}
  Input text  name=Tender[description]  ${tender_data.data.description}
  Input Date  name=Tender[enquiryPeriod][endDate]  ${tender_data.data.enquiryPeriod.endDate}  
  Input Date  name=Tender[tenderPeriod][startDate]  ${tender_data.data.tenderPeriod.startDate}   
  Input Date  name=Tender[tenderPeriod][endDate]  ${tender_data.data.tenderPeriod.endDate}   
  Додати предмет  ${items[0]}  0
  Click Element  xpath= //button[@class="btn btn-default btn_submit_form"]
  Wait Until Page Contains Element  ${locator.tenderId}  10
  ${tender_uaid}=  Get Text  ${locator.tenderId}  
  [return]  ${tender_uaid}

Додати предмет
  [Arguments]  ${item}  ${index}
  ${index}=  Convert To Integer  ${index}
  Input text  name=Tender[items][${index}][description]  ${item.description}
  Input text  name=Tender[items][${index}][quantity]  ${item.quantity}
  Select From List By Value  name=Tender[items][${index}][unit][code]  ${item.unit.code}
  Click Element  name=Tender[items][${index}][classification][description]
  Input text  id=search  ${item.classification.description}
  Wait Until Page Contains  ${item.classification.description}
  Click Element  xpath=//span[contains(text(),'${item.classification.description}')]
  Click Element  id=btn-ok
  Wait Until Element Is Not Visible  xpath=//div[@class="modal-backdrop fade"]
  Click Element  name=Tender[items][${index}][additionalClassifications][0][description]
  Input text  id=search  ${item.additionalClassifications[0].description}
  Wait Until Page Contains  ${item.additionalClassifications[0].description}
  Click Element  xpath=//div[@id="${item.additionalClassifications[0].id}"]/div/span[contains(text(), '${item.additionalClassifications[0].description}')]
  Click Element  id=btn-ok
  Wait Until Element Is Not Visible  xpath=//div[@class="modal-backdrop fade"]
  Input text  name=Tender[items][${index}][deliveryAddress][countryName]  ${item.deliveryAddress.countryName}
  Input text  name=Tender[items][${index}][deliveryAddress][region]  ${item.deliveryAddress.region}
  Input text  name=Tender[items][${index}][deliveryAddress][locality]  ${item.deliveryAddress.locality}
  Input text  name=Tender[items][${index}][deliveryAddress][streetAddress]  ${item.deliveryAddress.streetAddress}
  Input text  name=Tender[items][${index}][deliveryAddress][postalCode]  ${item.deliveryAddress.postalCode}
  Input Date  name=Tender[items][${index}][deliveryDate][endDate]  ${item.deliveryDate.endDate}
  Select From List By Value  name=Tender[procuringEntity][contactPoint][fio]  11

Завантажити документ
  [Arguments]  ${username}  ${filepath}  ${tender_uaid}
  Switch Browser  ${username}
  Go to  ${USERS.users['${username}'].homepage}
  Click Element  xpath=//a[@title="uk-UA"]
  Click Element  xpath=//a[@href="/web/buyer/tenders"]
  Click Element  xpath=//div[@id="w1"]/div[2]//a[@class="btn btn-success"]   
  Click Element  xpath=//a[contains(text(),'Редагувати')]
  Choose File  name=FileUpload[file]  ${filepath}
  Click Button  xpath=//button[@class="btn btn-default btn_submit_form"]

Пошук тендера по ідентифікатору
  [Arguments]  ${username}  ${tenderID}
  Switch browser  ${username}
  Go To  ${USERS.users['${username}'].homepage}
  Click Element  xpath=//a[@title="uk-UA"]
  Go To  http://ztv.byustudio.in.ua/web/tenders/
  Input text  name=TendersSearch[tender_cbd_id]  ${tenderID}
  Click Element  xpath=//button[@class="btn btn-success top-buffer margin23"]
  Sleep  2
  Click Element  xpath=//a[contains(text(), 'Детальнiше')]
  Wait Until Page Contains  ${tenderID}

Оновити сторінку з тендером
  [Arguments]  ${username}  ${tenderID}
  ztv.Пошук тендера по ідентифікатору  ${username}  ${tenderID}
  Reload Page

Внести зміни в тендер
  [Arguments]  ${username}  ${tenderID}  ${field_name}  ${field_value}
  ztv.Пошук тендера по ідентифікатору  ${username}  ${tenderID}
  Click Element  xpath=//a[contains(text(),'Редагувати')]
  Input text  name=Tender[${field_name}]  ${field_value}
  Click Element  xpath=//button[@class="btn btn-default btn_submit_form"]
  Wait Until Page Contains  ${field_value}  30

###############################################################################################################
############################################    ПИТАННЯ    ####################################################
###############################################################################################################

Задати питання
  [Arguments]  ${username}  ${tender_uaid}  ${question}
  ztv.Пошук тендера по ідентифікатору  ${username}  ${tender_uaid}
  Click Element  xpath=//a[contains(text(), 'Питання')]
  Input Text  name=Question[title]  ${question.data.title}
  Input Text  name=Question[description]  ${question.data.description}
  Click Element  name=question_submit
  Wait Until Page Contains  ${question.data.description}
  
Відповісти на питання
  [Arguments]  ${username}  ${tenderID}  ${question}  ${answer_data}  ${question_id}
  ztv.Пошук тендера по ідентифікатору  ${username}  ${tenderID}
  Click Element  xpath=//a[contains(text(), 'Питання')]
  Wait Until Element Is Visible  name=Tender[0][answer]
  Input text  name=Tender[0][answer]  ${answer_data.data.answer}
  Click Element  name=question_submit
  Wait Until Page Contains  ${answer_data.data.answer}  30
  
###############################################################################################################
###################################    ВІДОБРАЖЕННЯ ІНФОРМАЦІЇ    #############################################
###############################################################################################################

Отримати інформацію із тендера
  [Arguments]  ${username}  ${field_name}
  ${red}=  Evaluate  "\\033[1;31m"
  Run Keyword If  '${field_name}' == 'status'  Reload Page
  ${value}=  Run Keyword If  'unit.code' in '${field_name}'  Log To Console   ${red}\n\t\t\t Це поле не виводиться на ЗТВ
  ...  ELSE IF  'unit' in '${field_name}'  Get Text  xpath=//*[@tid="items.quantity"]
  ...  ELSE IF  'deliveryLocation' in '${field_name}'  Log To Console  ${red}\n\t\t\t Це поле не виводиться на ЗТВ
  ...  ELSE IF  'items' in '${field_name}'  Get Text  xpath=//*[@tid="${field_name.replace('[0]', '')}"]
  ...  ELSE IF  'questions' in '${field_name}'  ztv.Отримати інформацію із запитання  ${field_name}
  ...  ELSE IF  'value' in '${field_name}'  Get Text  xpath=//*[@tid="value.amount"]
  ...  ELSE  Get Text  xpath=//*[@tid="${field_name}"]
  ${value}=  adapt_view_data  ${value}  ${field_name}
  [return]  ${value}
  
Отримати інформацію із запитання
  [Arguments]  ${field_name}
  Click Element  xpath=//a[contains(text(), 'Питання')]
  ${value}=  Get Text  xpath=//*[@tid="${field_name.replace('[0]', '')}"]
  [return]  ${value}
  
###############################################################################################################
#######################################    ПОДАННЯ ПРОПОЗИЦІЙ    ##############################################
###############################################################################################################  
  
Подати цінову пропозицію
  [Arguments]  ${username}  ${tender_uaid}  ${bid}
  ztv.Пошук тендера по ідентифікатору   ${username}  ${tender_uaid}
  ConvToStr And Input Text  xpath=//input[contains(@name, '[value][amount]')]  ${bid.data.value.amount}
  Click Element  xpath=//button[contains(text(), 'Вiдправити')]
  Wait Until Element Is Visible  xpath=//div[contains(@class, 'alert-success')]
  
Скасувати цінову пропозицію
  [Arguments]  ${username}  ${tender_uaid}  ${bid}
  ztv.Пошук тендера по ідентифікатору   ${username}  ${tender_uaid}
  Click Element  name=delete_bids
  Confirm Action
  Capture Page Screenshot
  
Змінити цінову пропозицію
  [Arguments]  ${username}  ${tender_uaid}  ${fieldname}  ${fieldvalue}
  ztv.Пошук тендера по ідентифікатору   ${username}  ${tender_uaid}
  ConvToStr And Input Text  xpath=//input[contains(@name, '[value][amount]')]  ${fieldvalue}
  Click Element  xpath=//button[contains(text(), 'Вiдправити')]
  Wait Until Element Is Visible  xpath=//div[contains(@class, 'alert-success')]
  
Завантажити документ в ставку
  [Arguments]  ${username}  ${path}  ${tender_uaid}  ${doc_type}=documents
  ztv.Пошук тендера по ідентифікатору   ${username}  ${tender_uaid}
  Choose File  name=FileUpload[file]  ${path} 
  Click Element  xpath=//button[contains(text(), 'Вiдправити')]
  Wait Until Element Is Visible  xpath=//div[contains(@class, 'alert-success')]
  
Змінити документ в ставці
  [Arguments]  ${username}  ${path}  ${bidid}  ${docid}
  Sleep  200
  Reload Page
  Choose File  xpath=//div[contains(text(), 'Замiнити')]/form/input  ${path}
  Click Element  xpath=//button[contains(text(), 'Вiдправити')]
  Wait Until Element Is Visible  xpath=//div[contains(@class, 'alert-success')]
  
###############################################################################################################
##############################################    АУКЦІОН    ##################################################
###############################################################################################################

Отримати посилання на аукціон для глядача
  [Arguments]  ${username}  ${tender_uaid}  ${lot_id}=${Empty}
  ztv.Пошук тендера по ідентифікатору   ${username}  ${tender_uaid}
  ${auction_url}  Get Element Attribute  xpath=//a[contains(text(), 'Аукцiон')]@href
  [return]  ${auction_url}
  
Отримати посилання на аукціон для учасника
  [Arguments]  ${username}  ${tender_uaid}
  ztv.Пошук тендера по ідентифікатору   ${username}  ${tender_uaid}
  ${auction_url}  Get Element Attribute  xpath=//a[contains(text(), 'Аукцiон')]@href
  [return]  ${auction_url}
  
###############################################################################################################
  
ConvToStr And Input Text
  [Arguments]  ${elem_locator}  ${smth_to_input}
  ${smth_to_input}=  Convert To String  ${smth_to_input}
  Input Text  ${elem_locator}  ${smth_to_input}
  
Conv And Select From List By Value
  [Arguments]  ${elem_locator}  ${smth_to_select}
  ${smth_to_select}=  Convert To String  ${smth_to_select}
  ${smth_to_select}=  convert_string_from_dict_dzo  ${smth_to_select}
  Select From List By Value  ${elem_locator}  ${smth_to_select}
  
Input Date
  [Arguments]  ${elem_locator}  ${smth_to_input}
  ${smth_to_input}=  convert_datetime_to_ztv_format  ${smth_to_input}
  Input Text  ${elem_locator}  ${smth_to_input}