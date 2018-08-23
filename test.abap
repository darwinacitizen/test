*--------------------------------------------------------------------------*
* Program Name    : YDC_TEST                                               *
* Title           : Test program for trial and error coding                *
* Author          : Darwin Chellam                                         *
* Date            : 22/03/2017                                             *
*--------------------------------------------------------------------------*
* Purpose         : To test different worst cases and feasibility study    *
*--------------------------------------------------------------------------*
* Input           : Anything and everything, mostly hard coded or in debug *
* Output          : Dumps, exceptions, error messages and sometimes nothing*
*--------------------------------------------------------------------------*
REPORT ydc_test.

DATA: lv_url TYPE string,
      lv_length TYPE i,
      lv_string TYPE string,
      lv_filename TYPE string.

DATA: lt_xml        TYPE swxmlcont.
DATA: lv_xml_string TYPE string.
DATA: lv_size       TYPE i.

lv_url = 'https://wwwcie.ups.com/webservices/Rate'.

lv_filename = 'C:\Users\dchellam\Documents\upstest.xml'.

CALL FUNCTION 'GUI_UPLOAD'
    EXPORTING
      filename            = lv_filename
      filetype            = 'BIN'
      has_field_separator = ' '
      header_length       = 0
    IMPORTING
      filelength          = lv_size
    TABLES
      data_tab            = lt_xml
    EXCEPTIONS
      OTHERS              = 1.


CALL FUNCTION 'SCMS_BINARY_TO_STRING'
    EXPORTING
      input_length = lv_size
    IMPORTING
      text_buffer  = lv_xml_string
    TABLES
      binary_tab   = lt_xml
    EXCEPTIONS
      failed       = 1
      OTHERS       = 2.
  IF sy-subrc <> 0.

  ENDIF.


  DATA(lref_xml) = NEW cl_xml_document( ).

  CALL METHOD lref_xml->parse_string
    EXPORTING
      stream = lv_xml_string.



CALL METHOD cl_http_client=>create_by_url(
  EXPORTING
    url    = lv_url
  IMPORTING
    client = DATA(lref_client) ).

CALL METHOD lref_client->request->set_header_field
  EXPORTING
    name  = '~request_method'
    value = 'POST'.


CALL METHOD lref_client->request->set_header_field
  EXPORTING
    name  = '~server_protocol'
    value = 'HTTP/1.1'.

CALL METHOD lref_client->request->set_header_field
  EXPORTING
    name  = 'Content-Type'
    value = 'text/xml'.

CALL METHOD lref_client->request->set_header_field
  EXPORTING
    name  = 'HOST'
    value = 'wwwcie.ups.com'.

 lv_string = lv_xml_string.

call method lref_client->request->set_cdata
  exporting
    data   = lv_string
    offset = 0
    length = lv_length.

call method lref_client->send
    exceptions
      http_communication_failure = 1
      http_invalid_state         = 2.

  call method lref_client->receive
    exceptions
      http_communication_failure = 1
      http_invalid_state         = 2
      http_processing_failed     = 3.


 DATA(lv_res_string) = lref_client->response->get_cdata( ).

 WRITE lv_res_string.
