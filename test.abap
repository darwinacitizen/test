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

*  DATA: lt_key TYPE /bobf/t_frw_key,
*        lt_executioninfo_tr TYPE /scmtms/t_tor_exec_tr_k.
*
*  DATA(lref_svrmgr_tor) = /bobf/cl_tra_serv_mgr_factory=>get_service_manager( /scmtms/if_tor_c=>sc_bo_key ).
*
*
*  APPEND INITIAL LINE TO lt_key ASSIGNING FIELD-SYMBOL(<lfs_key>).
*  <lfs_key>-key = '005056B837D41ED6B9FE8B1681BDC0C7'.
*
*  lref_svrmgr_tor->retrieve_by_association(
*    EXPORTING
*      it_key            = lt_key
*      iv_association    = /scmtms/if_tor_c=>sc_association-root-executioninformation_tr
*      iv_fill_data      = abap_true
*      iv_node_key       = /scmtms/if_tor_c=>sc_node-root
*    IMPORTING
*      et_data           = lt_executioninfo_tr ).
*
*  IF lt_executioninfo_tr IS NOT INITIAL.
*
*  ENDIF.

*
*  DATA: gv_city TYPE ad_mc_city,
*        gv_city1 TYPE ad_city1.
*
*  SELECT-OPTIONS: s_city FOR gv_city,
*                  s_city1 FOR gv_city1.
*
*  IF s_city[] IS NOT INITIAL OR
*     s_city1[] IS NOT INITIAL.
*  ENDIF.


*  DATA: lref_exec_tr  TYPE REF TO /scmtms/s_tor_exec_tr_k,
*        lt_modification   TYPE /bobf/t_frw_modification,
*        lt_exec_tr_key    TYPE /bobf/t_frw_key,
*        lt_failed_key     TYPE /bobf/t_frw_key.
*
*  "Getting service manager instance
*  DATA(lref_srvmgr_tor)  = /bobf/cl_tra_serv_mgr_factory=>get_service_manager( /scmtms/if_tor_c=>sc_bo_key ).
*
*  "Getting transaction manager instance
*  DATA(lref_tramgr_tor)  = /bobf/cl_tra_trans_mgr_factory=>get_transaction_manager( ).
*
*  lref_exec_tr = NEW #( ).
*
*  "Populate the execution information details
*  lref_exec_tr->key             = lref_srvmgr_tor->get_new_key( ).
*  lref_exec_tr->event_code      = 'Z_PGI'. "Event code for PGI
*  lref_exec_tr->root_key        = '005056B837D41ED6B8CBF67BEFFB80C7'. "/SCMTMS/TOR-ROOT-key
*  lref_exec_tr->torstopuuid     = '005056B837D41ED6B8CBF67BEFFB9097'. "/SCMTMS/TOR-STOP-key
*
*  "Get the modification record
*  /scmtms/cl_mod_helper=>mod_create_single(
*    EXPORTING
*      is_data            = lref_exec_tr->*
*      iv_node            = /scmtms/if_tor_c=>sc_node-executioninformation_tr
*      iv_key             = lref_exec_tr->key
*      iv_root_key        = lref_exec_tr->root_key
*      iv_association     = /scmtms/if_tor_c=>sc_association-root-executioninformation_tr
*      iv_source_node     = /scmtms/if_tor_c=>sc_node-root
*      iv_parent_key      = lref_exec_tr->root_key
*    IMPORTING
*      es_mod             = DATA(ls_modification) ).
*
*  APPEND ls_modification TO lt_modification.
*
*  "Call modify method to create the execution information
*  lref_srvmgr_tor->modify(
*    EXPORTING
*      it_modification    = lt_modification
*    IMPORTING
*      eo_change          = DATA(lref_change)
*      eo_message         = DATA(lref_message) ).
*
*  "Get the exection information record key for executing the report event action
*  APPEND INITIAL LINE TO lt_exec_tr_key ASSIGNING FIELD-SYMBOL(<lfs_exec_tr_key>).
*  <lfs_exec_tr_key>-key = lref_exec_tr->key.
*
*  "Report the event
*  lref_srvmgr_tor->do_action(
*    EXPORTING
*      it_key             = lt_exec_tr_key
*      iv_act_key         = /scmtms/if_tor_c=>sc_action-executioninformation_tr-report_event
*    IMPORTING
*      et_failed_key      = lt_failed_key
*      eo_change          = lref_change
*      eo_message         = lref_message ).
*
*  IF lt_failed_key IS INITIAL.
*
*    "Saving the changes for persistence
*    "SAVE METHOD WOULD TRIGGER COMMIT WORK AND SHOULDN'T BE CALLED INSIDE ENHANCEMENTS
*    "SAVE WOULD BE AUTOMATICALLY TAKEN CARE IN ENHANCEMENTS
*    lref_tramgr_tor->save(
*      IMPORTING
*        ev_rejected     = DATA(lv_rejected)
*        eo_change       = lref_change
*        eo_message      = lref_message ).
*
*    IF lv_rejected IS INITIAL.
*      "Successfully reported the event
*    ELSE.
*      "Error handling
*    ENDIF.
*
*  ENDIF.

*  DATA: lt_frw_key TYPE /BOBF/T_FRW_KEY,
*        lt_common TYPE /BOFU/T_BUPA_COMMON_K.
*
*  APPEND INITIAL LINE TO lt_frw_key ASSIGNING FIELD-SYMBOL(<lfs_frw_key>).
*  <lfs_frw_key>-key = '005056B837D41ED6B8CBF67BEFFB80C7'.
*
*  DATA(lref_srvmgr_bp)    = /bobf/cl_tra_serv_mgr_factory=>get_service_manager( iv_bo_key = /bofu/if_bupa_constants=>sc_bo_key ).
*  DATA(lref_srvmgr_tmbp)  = /bobf/cl_tra_serv_mgr_factory=>get_service_manager( iv_bo_key = /scmtms/if_bp_c=>sc_bo_key ).
*
*  lref_srvmgr_bp->retrieve_by_association(
*    EXPORTING
*      iv_node_key     = /bofu/if_bupa_constants=>sc_node-root
*      it_key          = lt_frw_key
*      iv_fill_data    = abap_true
*      iv_edit_mode    = /bobf/if_conf_c=>sc_edit_read_only
*      iv_association  = /bofu/if_bupa_constants=>sc_association-root-common
*    IMPORTING
*      et_data   =   lt_common ).
*
*  READ TABLE lt_common ASSIGNING FIELD-SYMBOL(<lfs_common>) INDEX 1.
*  IF sy-subrc IS INITIAL.
*    WRITE <lfs_common>-name1.
*  ENDIF.

*   lo_srvmgr->retrieve_by_association(
*     EXPORTING
*       iv_node_key    = /bofu/if_bupa_constants=>sc_node-root
*       iv_association = /bofu/if_bupa_constants=>sc_association-root-common
*       it_key         = it_bupa_key
*       iv_fill_data   = abap_true
*       iv_edit_mode   = /bobf/if_conf_c=>sc_edit_read_only
*     IMPORTING
*       et_data        = lt_bupa_cmn ).

*
*"Local variable declarations
*DATA: lv_sfir_id TYPE /scmtms/sfir_id.
*
*lv_sfir_id = '00000000008100000055'.
*
*zcl_tst_dc=>get_sfir_root(
* EXPORTING
*   im_v_sfir_id = lv_sfir_id
* IMPORTING
*   ex_s_sfir_root = DATA(ls_sfir_id) ).

*TABLES: adrc.
*
*SELECT-OPTIONS: s_city FOR adrc-city1."MATCHCODE OBJECT CLCITYNAME." gv_city MATCHCODE OBJECT ad_city1.


*  SELECT
*    *
*    FROM tvarvc
*    INTO TABLE @DATA(lt_tvarvc).
*  IF sy-subrc IS INITIAL.
*    DELETE lt_tvarvc WHERE NOT name CP 'Z*'.
*  ENDIF.
*
*
*  DATA: ls_tor_root TYPE /scmtms/s_tor_root_k,
*        lt_modification TYPE /bobf/t_frw_modification.
*
*  ls_tor_root-key = '005056B837D41ED88E94C5B7CEC320CA'.
*  ls_tor_root-tsp_set_by_srvc = 'MA'.
*
*  /scmtms/cl_mod_helper=>mod_update_single(
*    EXPORTING
*      is_data             = ls_tor_root
*      iv_autofill_fields  = abap_false
*      iv_bo_key           = /scmtms/if_tor_c=>sc_bo_key
*      iv_key              = ls_tor_root-key
*      iv_node             = /scmtms/if_tor_c=>sc_node-root
*    IMPORTING
*      es_mod              = DATA(ls_modification) ).
*
*  APPEND /scmtms/if_tor_c=>sc_node_attribute-root-tsp_set_by_srvc TO ls_modification-changed_fields.
*
*  APPEND ls_modification to lt_modification.
*
*  DATA(lv_svrmgr) = /bobf/cl_tra_serv_mgr_factory=>get_service_manager( iv_bo_key = /scmtms/if_tor_c=>sc_bo_key ).
*
*  lv_svrmgr->modify(
*    EXPORTING
*      it_modification = lt_modification ).
*
*  DATA(lv_tramgr) = /bobf/cl_tra_trans_mgr_factory=>get_transaction_manager( ).
*
*      "Saving the changes for persistence
*      lv_tramgr->save(
*        IMPORTING
*          ev_rejected     = DATA(lv_rejected)
*          eo_change       = DATA(lref_change)
*          eo_message      = DATA(lref_message) ).
*
*
*IF sy-subrc IS INITIAL.
*
*ENDIF.


*CONVERT DATE sy-datum
*            TIME sy-uzeit
*      INTO TIME STAMP DATA(lv_timestamp)
*      TIME ZONE sy-zonlo.
*
*DATA: lref_parameter TYPE REF TO /SCMTMS/S_TOR_ROOT_A_ASGN_TSP.
*
*  DATA: ls_tsp_assign TYPE /SCMTMS/s_TOR_TSP_ASSIGNMENT,
*        lt_tor_key    TYPE /bobf/t_frw_key,
*        lt_carrier    TYPE /BOFU/T_BUPA_ROOT_K.
*
*  "Getting service manager instance
*  DATA(lref_srvmgr)  = /bobf/cl_tra_serv_mgr_factory=>get_service_manager( /scmtms/if_tor_c=>sc_bo_key ).
*
*  "Getting transaction manager instance
*  DATA(lref_tramngr) = /bobf/cl_tra_trans_mgr_factory=>get_transaction_manager( ).
*
*   APPEND INITIAL LINE TO lt_tor_key ASSIGNING FIELD-SYMBOL(<lfs_key>).
*    <lfs_key>-key = '005056B837D41ED884CBC0825A15C0C9'. "FO: 6500001583
*
*  lref_srvmgr->retrieve_by_association(
*    EXPORTING
*      it_key          = lt_tor_key
*      iv_association  = /scmtms/if_tor_c=>sc_association-root-bo_tsp_root
*      iv_fill_data    = abap_true
*      iv_node_key     = /scmtms/if_tor_c=>sc_node-root
*    IMPORTING
*      et_data         = lt_carrier ).
*
*  "Preparing the parameters
*    lref_parameter                  = NEW #( ).
*    lref_parameter->TSP_KEY         = '005056B837D41ED6B8CBF67BEFFB80C7'.   "Carrier: 500002
**    lref_parameter->TSP_KEY         = '005056B837D41ED6B8CC0F1E0172A0C7'.   "Carrieri: 500004
*    lref_parameter->SET_BY_SERVICE  = 'DV'.
**    ls_tsp_assign-tor_key        = ''.
**    ls_tsp_assign-tsp_key        = ''.
**    INSERT ls_tsp_assign INTO TABLE lref_parameter->tsp_assignment.
**    INSERT INITIAL LINE TO lref_parameter->tsp_assignment ASSIGNING FIELD-SYMBOL(<lfs_tsp_assign>).
*
*
*    lref_srvmgr->do_action(
*      EXPORTING
*        is_parameters   = lref_parameter
*        it_key          = lt_tor_key
*        iv_act_key      = /scmtms/if_tor_c=>sc_action-root-assign_tsp
*      IMPORTING
*        eo_change       = DATA(lref_change)
*        eo_message      = DATA(lref_message)
*        et_failed_key   = DATA(lt_failed_keys) ).
*
*
*    IF lt_failed_keys IS INITIAL.
*      "Saving the changes for persistence
*      lref_tramngr->save(
*        IMPORTING
*          ev_rejected     = DATA(lv_rejected)
*          eo_change       = lref_change
*          eo_message      = lref_message ).
*    ENDIF.

*  DATA: lt_route_det TYPE zttm_transit_time.
*
*
*  APPEND INITIAL LINE TO lt_route_det ASSIGNING FIELD-SYMBOL(<lfs_route_det>).
*
*
*  CALL FUNCTION 'ZFM_TM_F131_TRANSIT_TIME'
*    CHANGING
*      ct_route_det       = lt_route_det
*            .
*
*  WRITE: / 'end of program'.


*TABLES /scmtms/d_torrot.
*
*SELECT-OPTIONS: s_torid FOR /scmtms/d_torrot-tor_id.
*
*
***Service Manager
*
*  DATA: lref_srvmgr TYPE REF TO /bobf/if_tra_service_manager.
*
*  "Getting service manager instance for TOR
*  lref_srvmgr  = /bobf/cl_tra_serv_mgr_factory=>get_service_manager( /scmtms/if_tor_c=>sc_bo_key ).
*
*
***Query
*
*  DATA: lt_tor_key  TYPE /bobf/t_frw_key,
*        lt_selparam TYPE /bobf/t_frw_query_selparam.
*
*  "Populate query selection parameters
*  LOOP AT s_torid ASSIGNING FIELD-SYMBOL(<lfs_torid>).
*    APPEND INITIAL LINE TO lt_selparam ASSIGNING FIELD-SYMBOL(<lfs_selparam>).
*    <lfs_selparam>-attribute_name = /scmtms/if_tor_c=>sc_query_attribute-root-root_elements-tor_id.
*    <lfs_selparam>-sign           = <lfs_torid>-sign.
*    <lfs_selparam>-option         = <lfs_torid>-option.
*    <lfs_selparam>-low            = <lfs_torid>-low.
*    <lfs_selparam>-high           = <lfs_torid>-high.
*  ENDLOOP.
*
*  "Query the business object for keys
*  lref_srvmgr->query(
*    EXPORTING
*      iv_query_key                = /scmtms/if_tor_c=>sc_query-root-root_elements
*      it_selection_parameters     = lt_selparam
*      iv_fill_data                = abap_false
*    IMPORTING
*      et_key                      = lt_tor_key ).
*
***Alternative Keys
*
*  DATA: lt_torid      TYPE /scmtms/t_tor_id,
*        lt_btd_altkey TYPE /scmtms/t_base_document.
*
*  LOOP AT s_torid ASSIGNING <lfs_torid>.
*    APPEND <lfs_torid>-low TO lt_torid.
*  ENDLOOP.
*
*  lref_srvmgr->convert_altern_key(
*    EXPORTING
*      iv_node_key           = /scmtms/if_tor_c=>sc_node-root
*      iv_altkey_key         = /scmtms/if_tor_c=>sc_alternative_key-root-tor_id
**     iv_target_altkey_key  = /scmtms/if_tor_c=>sc_alternative_key-root-base_document
*      it_key                = lt_torid
*    IMPORTING
**     et_key                = lt_btd_altkey
*      et_result             = DATA(lt_result) ).
*
*
***Retrieve
*
*  DATA: lt_tor_root   TYPE /scmtms/t_tor_root_k,
*        lt_failed_key TYPE /bobf/t_frw_key.
*
*  "Retrieve the root nodes of the TOR
*  lref_srvmgr->retrieve(
*    EXPORTING
*      it_key            = lt_tor_key
*      iv_fill_data      = abap_true
*      iv_node_key       = /scmtms/if_tor_c=>sc_node-root
*    IMPORTING
*      et_data           = lt_tor_root
*      et_failed_key     = lt_failed_key ).
*
***Retrieve by association
*
*  DATA: lt_tor_item   TYPE /scmtms/t_tor_item_tr_k.
*
*  "Retrieve TOR item nodes using association
*  lref_srvmgr->retrieve_by_association(
*    EXPORTING
*      it_key          = lt_tor_key
*      iv_association  = /scmtms/if_tor_c=>sc_association-root-item_tr
*      iv_fill_data    = abap_true
*      iv_node_key     = /scmtms/if_tor_c=>sc_node-root
*    IMPORTING
*      et_data         = lt_tor_item
*      et_failed_key   = lt_failed_key ).
*
***Do Action
*
*  lref_srvmgr->do_action(
*    EXPORTING
*      it_key          = lt_tor_key
*      iv_act_key      = /scmtms/if_tor_c=>sc_action-root-report_pending_events
*    IMPORTING
*      et_failed_key   = lt_failed_key
*      eo_message      = DATA(lref_message)
*      eo_change       = DATA(lref_change) ).
*
***Modify
*
*  DATA: lref_tor_root   TYPE REF TO /scmtms/s_tor_root_k,
*        ls_modification TYPE        /bobf/s_frw_modification,
*        lt_modification TYPE        /bobf/t_frw_modification.
*
*  "Create node data with required data
*  CREATE DATA lref_tor_root.
*  READ TABLE lt_tor_root REFERENCE INTO lref_tor_root INDEX 1.
*  lref_tor_root->labeltxt = 'TESTING MODIFY'.
*
*  "Create modification record
*  ls_modification-node        = /scmtms/if_tor_c=>sc_node-root.
*  ls_modification-change_mode = /bobf/if_frw_c=>sc_modify_update. "U
*  ls_modification-key         = lref_tor_root->key.
*  ls_modification-data        = lref_tor_root.
*  APPEND /scmtms/if_tor_c=>sc_node_attribute-root-labeltxt TO ls_modification-changed_fields.
*
*  "Modify the node
*  lref_srvmgr->modify(
*    EXPORTING
*      it_modification = lt_modification
*    IMPORTING
*      eo_message      = lref_message
*      eo_change       = lref_change ).
*
*
***Transaction Manager
*  DATA: lref_tramgr TYPE REF TO /bobf/if_tra_transaction_mgr,
*        lt_rej_bo_key TYPE /bobf/t_frw_key2.
*
*  "Getting Transaction Manager instance
*  lref_tramgr = /bobf/cl_tra_trans_mgr_factory=>get_transaction_manager( ).
*
*  "Call Save method to get data persisted
*  lref_tramgr->save(
*    IMPORTING
*      ev_rejected         = DATA(lv_rejected)
*      eo_change           = lref_change
*      eo_message          = lref_message
*      et_rejecting_bo_key = lt_rej_bo_key ).
*
*  "Rollback the changes of the current transaction
*  lref_message = lref_tramgr->cleanup( ).


*  DATA: lv_grwt_lb_sum        TYPE                   /scmtms/qua_gro_wei_val,
*        lv_round_grwt         TYPE                   /scmtms/qua_gro_wei_val,
*        lv_wt_per_sku         TYPE                   /scmtms/qua_gro_wei_val,
*        lv_line_quantity      TYPE                   string,
*        lv_qua_base_int       TYPE                   i.
*
*  TRY .
*
*
*  lv_qua_base_int = lv_line_quantity.
*
*  IF lv_line_quantity GT 1.
*
*    lv_qua_base_int = 1.
*
*  ENDIF.
*
*  IF lv_grwt_lb_sum LT '0.05'.
*
*    lv_wt_per_sku = '0.05' / lv_line_quantity.
*
*    lv_round_grwt = lv_wt_per_sku * lv_line_quantity.
*
*    IF lv_round_grwt LT '0.05'.
*
*      lv_round_grwt = '0.05' - lv_round_grwt.
*
*      lv_wt_per_sku = lv_wt_per_sku + lv_round_grwt.
*
*    ENDIF.
*
*  ENDIF.
*
*   CATCH cx_root.
*
*  ENDTRY.



*  DATA: lref_parameter TYPE REF TO /SCMTMS/S_TOR_ROOT_A_ASGN_TSP.
*
*  DATA: ls_tsp_assign TYPE /SCMTMS/s_TOR_TSP_ASSIGNMENT,
*        lt_tor_key    TYPE /bobf/t_frw_key.
*
*  "Getting service manager instance
*  DATA(lref_srvmgr)  = /bobf/cl_tra_serv_mgr_factory=>get_service_manager( /scmtms/if_tor_c=>sc_bo_key ).
*
*  "Getting transaction manager instance
*  DATA(lref_tramngr) = /bobf/cl_tra_trans_mgr_factory=>get_transaction_manager( ).
*
*  "Preparing the parameters
*    lref_parameter                  = NEW #( ).
*    lref_parameter->TSP_KEY         = '005056B837D41ED6B8CBF67BEFFB80C7'.   "500002
**    lref_parameter->TSP_KEY         = '005056B837D41ED6B8CC0F1E0172A0C7'.   "500004
*    lref_parameter->SET_BY_SERVICE  = 'DV'.
**    ls_tsp_assign-tor_key        = ''.
**    ls_tsp_assign-tsp_key        = ''.
**    INSERT ls_tsp_assign INTO TABLE lref_parameter->tsp_assignment.
**    INSERT INITIAL LINE TO lref_parameter->tsp_assignment ASSIGNING FIELD-SYMBOL(<lfs_tsp_assign>).
*
*    APPEND INITIAL LINE TO lt_tor_key ASSIGNING FIELD-SYMBOL(<lfs_key>).
*    <lfs_key>-key = '005056B837D41ED884CBC0825A15C0C9'.
*
*    lref_srvmgr->do_action(
*      EXPORTING
*        is_parameters   = lref_parameter
*        it_key          = lt_tor_key
*        iv_act_key      = /scmtms/if_tor_c=>sc_action-root-assign_tsp
*      IMPORTING
*        eo_change       = DATA(lref_change)
*        eo_message      = DATA(lref_message)
*        et_failed_key   = DATA(lt_failed_keys) ).
*
*
*    IF lt_failed_keys IS INITIAL.
*      "Saving the changes for persistence
*      lref_tramngr->save(
*        IMPORTING
*          ev_rejected     = DATA(lv_rejected)
*          eo_change       = lref_change
*          eo_message      = lref_message ).
*    ENDIF.

*DATA: lv_string TYPE string,
*      lv_tdline TYPE tdline,
*      lv_space(1) TYPE c VALUE ' '.
*
*lv_string = lv_tdline = 'Hello# World'.
*
*REPLACE ALL OCCURRENCES OF '#' IN lv_string WITH lv_space.
*REPLACE ALL OCCURRENCES OF '#' IN lv_tdline WITH 'b'.
*
*WRITE: lv_string,
*       lv_tdline.

*  TYPES: BEGIN OF gty_party_rco,
*          party_rco TYPE /SCMTMS/PARTY_ROLE_CODE,
*         END OF gty_party_rco.
*
*  TYPES: gty_t_party_rco TYPE STANDARD TABLE OF gty_party_rco WITH EMPTY KEY.
*
*   DATA: lv_start(3) TYPE n VALUE 1,
*         lv_end(3)   TYPE n VALUE 3.
*
*   DATA(lt_itab) =  VALUE gty_t_party_rco( FOR i = lv_start THEN i + 1 WHILE i <= lv_end ( party_rco = |ZM| && i ) ) .

*   cl_demo_output=>write(
*        VALUE gty_party_rco(
*          FOR j = 11 THEN j + 10 WHILE j < 40
*          ( party_rco = 'abc' ) ) ).

*TYPES:
*      BEGIN OF line,
*        col1 TYPE /SCMTMS/PARTY_ROLE_CODE,
*      END OF line,
*      itab TYPE STANDARD TABLE OF line WITH EMPTY KEY.
*
*    DATA(lt_itab) =
*        VALUE itab(
*          FOR j = 11 THEN j + 10 WHILE j < 40
*          ( col1 = 'ZM' ) ).

*   WRITE 'success'.
*  DATA: lt_key  TYPE /bobf/t_frw_key.
*
*  DATA(lv_svrmgr_tor) = /bobf/cl_tra_serv_mgr_factory=>get_service_manager( /scmtms/if_tor_c=>sc_bo_key ).
*
*  APPEND INITIAL LINE TO lt_key ASSIGNING FIELD-SYMBOL(<lfs_key>).
*  <lfs_key>-key = '005056B837D41ED7B5D4F2658175E0C9'. "FO 6100001052
*
*  lv_svrmgr_tor->retrieve_by_association(
*    EXPORTING
*      it_key          = lt_key
*      iv_association  = /scmtms/if_tor_c=>sc_association-root-bo_trq_root_all
**     iv_fill_data    = abap_true
*      iv_node_key     = /scmtms/if_tor_c=>sc_node-root
*    IMPORTING
*      et_key_link     = DATA(lt_key_link) ).
*
*
*  DATA: lv_torcat TYPE /scmtms/tor_category.
*  select-OPTIONS s_torcat FOR lv_torcat.
*
*  DATA: lt_torcat TYPE STANDARD TABLE OF /scmtms/tor_category.
*
*  DATA: lv_timestamp TYPE tzntstmps.
*
*  CONVERT DATE sy-datum TIME sy-uzeit INTO
*        TIME STAMP lv_timestamp TIME ZONE sy-zonlo.
*
*  WRITE lv_timestamp.
*
*  lv_torcat = 'TO'.
*  APPEND lv_torcat TO lt_torcat.
*
*  lv_torcat = 'FO'.
*  APPEND lv_torcat TO lt_torcat.
*
*  lv_torcat = 'FU'.
*  APPEND lv_torcat TO lt_torcat.
*
*  lv_torcat = 'FB'.
*  APPEND lv_torcat TO lt_torcat.
*
*  LOOP AT lt_torcat ASSIGNING FIELD-SYMBOL(<lfs_torcat>) WHERE TABLE_LINE IN s_torcat.
*
*    WRITE <lfs_torcat>.
*
*  ENDLOOP.
*
*
*  DATA: lt_location_guids TYPE /scmtms/t_guid.
*
*
*
*  /scmtms/cl_loc_helper=>get_locations_by_guids(
*    EXPORTING
*      it_location_guids     = lt_location_guids
*    IMPORTING
*      et_locations          = DATA(lt_locations) ).
*
*  IF lt_locations IS INITIAL.
*    WRITE 'Success'.
*  ENDIF.



*DATA: lt_keys         TYPE /bobf/t_frw_key,
*        lt_dtr_parties   TYPE /scmtms/t_trq_party_k,
*        lt_fdoc          TYPE /scmtms/t_tor_root_k,
*        lt_modification TYPE /bobf/t_frw_modification,
*
*        ls_dtr_party   TYPE /scmtms/s_trq_party_k.
*
*
*  APPEND INITIAL LINE TO lt_keys ASSIGNING FIELD-SYMBOL(<lfs_key>).
*  <lfs_key>-key = '005056B837D41ED7B8B42A9674F8A0C9'.   "DTR 3200001189 Type ZDT1
*
*  DATA(lref_svrmgr_trq) = /bobf/cl_tra_serv_mgr_factory=>get_service_manager( /scmtms/if_trq_c=>sc_bo_key ).
*
*  "Retrive all parties
*  lref_svrmgr_trq->retrieve_by_association(
*    EXPORTING
*      it_key          = lt_keys
*      iv_association  = /scmtms/if_trq_c=>sc_association-root-tor_root_fdoc
*      iv_fill_data    = abap_true
*      iv_node_key     = /scmtms/if_trq_c=>sc_node-root
*    IMPORTING
*      et_data         = lt_fdoc ).
*
*  IF lt_fdoc IS NOT INITIAL.
*    write 'Success'.
*  ENDIF.

*DATA: lt_fu_key1 TYPE /bobf/t_frw_key,
*      lt_fu_root1 TYPE /scmtms/t_tor_root_k.
*
*DATA: lv_timezone(5) TYPE c,
*      lv_timestamp TYPE /SCMTMS/CARRIER_CONF_START.
*
*convert date '20171201' time '000000' into time stamp lv_timestamp time zone lv_timezone.
*
*CONVERT TIME STAMP lv_timestamp TIME ZONE lv_timezone INTO DATE DATA(lv_date) TIME DATA(lv_time).
*
*DATA(lref_svrmgr_tor1) = /bobf/cl_tra_serv_mgr_factory=>get_service_manager( /scmtms/if_tor_c=>sc_bo_key ).
*
*APPEND INITIAL LINE TO lt_fu_key1 ASSIGNING FIELD-SYMBOL(<lfs_fu_key1>).
*  <lfs_fu_key1>-key = '005056B837D41ED7B2F3E86FE59740C9'.
*
*lref_svrmgr_tor1->retrieve(
*    EXPORTING
*      iv_node_key       = /scmtms/if_tor_c=>sc_node-root
*      it_key            = lt_fu_key1
*    IMPORTING
*      et_data           = lt_fu_root1 ).
*
*  EXPORT root = lt_fu_root1 TO MEMORY ID '005056B837D41ED7B2F3E86FE59740C9'.
*
*  CLEAR lt_fu_root1.
*
*  IMPORT root = lt_fu_root1 FROM MEMORY ID '005056B837D41ED7B2F3E86FE59740C9'.
*
*DATA: lv_string TYPE char120,
*      lv_tor_id TYPE /scmtms/tor_id VALUE '4567890123',
*      lv_scac   TYPE scacd      VALUE 'ABCD',
*      lv_tspid  TYPE char10  VALUE '500002',
*      lv_amount TYPE bp_amnt VALUE 231,
*      lv_currkey TYPE waers   VALUE 'USD',
*      lv_amount_c(18) TYPE c.
*
*WRITE lv_amount TO lv_amount_c NO-GROUPING CURRENCY lv_currkey RIGHT-JUSTIFIED.
*
*lv_string+1  = lv_tor_id.
*lv_string+12 = ':'.
*lv_string+14 = lv_tspid.
*lv_string+25 = '-'.
*lv_string+27 = lv_scac.
*lv_string+34 = '-'.
*lv_string+36 = lv_amount.
*lv_string+46 = lv_currkey.
*
**DATA: lv_amount TYPE /scmtms/amount.
*
*  CALL FUNCTION 'CONVERT_TO_LOCAL_CURRENCY'
*    EXPORTING
**     CLIENT                  = SY-MANDT
*      date                    = sy-datum
*      foreign_amount          = '1000.00'
*      foreign_currency        = 'USD'
*      local_currency          = 'INR'
**     RATE                    = 0
**     TYPE_OF_RATE            = 'M'
**     READ_TCURR              = 'X'
*   IMPORTING
**     EXCHANGE_RATE           =
**     FOREIGN_FACTOR          =
*     LOCAL_AMOUNT            = lv_amount
**     LOCAL_FACTOR            =
**     EXCHANGE_RATEX          =
**     FIXED_RATE              =
**     DERIVED_RATE_TYPE       =
*   EXCEPTIONS
*     NO_RATE_FOUND           = 1
*     OVERFLOW                = 2
*     NO_FACTORS_FOUND        = 3
*     NO_SPREAD_FOUND         = 4
*     DERIVED_2_TIMES         = 5
*     OTHERS                  = 6
*            .
*  IF sy-subrc <> 0.
** Implement suitable error handling here
*  ENDIF.
*
*
*"Local variable declarations
*  DATA:             lv_mtr            TYPE /scmtms/transmeanstypecode,                              "Means of Transport
*                    lv_gro_wei_lb     TYPE /scmtms/qua_gro_wei_val,                                 "Gross weight in LB
*                    lv_fo_type        TYPE /scmtms/tor_type.                                        "Freight Order type
*
*  "Local workarea declarations
*  DATA:             ls_fo_info        TYPE /scmtms/s_tor_fo_info,                                   "FO information
*                    ls_fu_root        TYPE /scmtms/s_tor_root_k,                                    "FU Root data
*                    ls_fo_root        TYPE /scmtms/s_tor_root_k,                                    "FO Root data
*                    ls_fo_item        TYPE /scmtms/s_tor_item_tr_k.
*
*  "Local table declarations
*  DATA:             lt_fo_stop        TYPE /scmtms/t_tor_stop_k,                                    "FO Stop data
*                    lt_fo_succ        TYPE /scmtms/t_tor_stop_succ_k,                               "FO Stop successor data
*                    lt_fo_item        TYPE /scmtms/t_tor_item_tr_k,                                 "FO Item TR data
*                    lt_fo_root        TYPE /scmtms/t_tor_root_k,                                    "FO Root data
*                    lt_modification   TYPE /bobf/t_frw_modification,                                "Modification table
*                    lt_fo_key         TYPE /bobf/t_frw_key,                                         "FO key
*                    lt_tspchrg_data   TYPE /scmtms/t_tcc_root_k,                                    "Transportation charges
*                    lt_failed_key     TYPE /bobf/t_frw_key.                                         "Failed keys
*
*  "Local reference declarations
*  DATA:             lref_message      TYPE REF TO /bobf/if_frw_message,                             "Message object reference
*                    lref_param_per_cs TYPE REF TO /scmtms/s_tor_root_a_perfor_cs.                   "Parameters for carrier selection
*
*  "Local constant declarations
*  CONSTANTS:        lc_unit_lb        TYPE meins                      VALUE 'LB',                   "UoM          : LB    - Pound
*                    lc_mtr_zp_ltl     TYPE /scmtms/transmeanstypecode VALUE 'ZP_LTL',               "MTR          : ZP_LTL- Lessthan Truck Load
*                    lc_mtr_zp_tl      TYPE /scmtms/transmeanstypecode VALUE 'ZP_TL',                "MTR          : ZP_TL - Truck Load
*                    lc_trmod_1        TYPE /scmtms/booktrmo           VALUE '1',                    "Trans Mode   : 1     - Road
*                    lc_torcat_to      TYPE /scmtms/tor_category       VALUE 'TO',                   "TOR category : TO    - Freight Order
*                    lc_gro_wei_10k    TYPE /scmtms/qua_gro_wei_val    VALUE 10000,                  "Gross Weight : 10000 - 10000 Pounds
*                    lc_calc_status_02 TYPE /scmtms/tcc_calc_status    VALUE '02'.                   "Calc Status  : 02    - Calculated
*
**  SUBMIT ydc_test WITH p_fu_key EQ '005056B837D41ED7B2F3E86FE59740C9'.
*
*PARAMETERS: p_fu_key TYPE /BOBF/CONF_KEY NO-DISPLAY.
*
*
*  "Get the Freight Order Type based on the Mode of Transport
*  /scmtms/cl_tor_helper_root=>get_def_tor_type_for_category(
*    EXPORTING
*      iv_tor_category = lc_torcat_to
*      iv_tor_booktrmo = lc_trmod_1
*    IMPORTING
*      ev_def_tor_type = lv_fo_type ).
*
*  "Populate FO information
*  ls_fo_info-mtr        = 'ZP_LTL'.
*  ls_fo_info-trmodcat   = lc_trmod_1.
*
*    ls_fo_info-loc_src_key        = '005056B837D41ED6B8C98FE7872B40C7'."'005056B837D41ED78DADB33A911820C7'.
*    ls_fo_info-adr_loc_src_key    = '005056B837D41ED6B8C98FE7872B40C7'."'005056B837D41ED78DADB33A911820C7'.
*    ls_fo_info-pickup_start_date  = '20171122060000'.
*
*    ls_fo_info-loc_dst_key        = '005056B837D41ED6B8CAB1DEE392A0C7'.
*    ls_fo_info-adr_loc_dst_key    = '005056B837D41ED6B8CAB1DEE392A0C7'.
*    ls_fo_info-delivery_end_date  = '20171123060000'.
*
*
*  "Create Freight Order
*  /scmtms/cl_tor_factory=>create_tor_tour(
*    EXPORTING
**     iv_do_modify            = abap_true
*      iv_tor_type             = lv_fo_type
*      iv_create_initial_stage = abap_true
*      iv_creation_type        = /scmtms/if_tor_const=>sc_creation_type-manual
*      is_fo_info              = ls_fo_info
*    IMPORTING
*      et_mod                  = lt_modification
*      es_tor_root             = ls_fo_root
*      et_tor_item             = lt_fo_item
*      et_tor_stop             = lt_fo_stop
*      et_tor_stop_succ        = lt_fo_succ
*    CHANGING
*      co_message              = lref_message ).
*
*  "Getting the FO key
*  APPEND INITIAL LINE TO lt_fo_key ASSIGNING FIELD-SYMBOL(<lfs_fo_key>).
*  <lfs_fo_key>-key = ls_fo_root-key.
*
*  "Set FO as subcontracting relevant
*  READ TABLE lt_modification ASSIGNING FIELD-SYMBOL(<lfs_modification>) WITH KEY key = ls_fo_root-key.
*  IF sy-subrc IS INITIAL.
*    FIELD-SYMBOLS: <lfs_fo_root1> TYPE /scmtms/s_tor_root_k.
*    ASSIGN <lfs_modification>-data->* TO <lfs_fo_root1>.
*    <lfs_fo_root1>-pln_sct_rel = /scmtms/if_tor_const=>sc_subcontr_relevance-relevant.
*    <lfs_fo_root1>-labeltxt    = 'E372FO'.
*  ENDIF.
*
*  "Creating a service manager reference for TOR
*  DATA(lref_svrmgr_tor) = /bobf/cl_tra_serv_mgr_factory=>get_service_manager( /scmtms/if_tor_c=>sc_bo_key ).
**
*  lref_svrmgr_tor->modify(
*    EXPORTING
*      it_modification = lt_modification ).
*
** Addition for adding item
*  "FU with package - 005056B837D41ED7B2F3E86FE59740C9
*  CLEAR lt_modification.
*
*  DATA: ls_param_add_fu_by_fuid TYPE REF TO /scmtms/s_tor_a_add_elements,
*        lt_item_tr        TYPE /scmtms/t_tor_item_tr_k,
*        lt_fu_key         TYPE /bobf/t_frw_key,
*        lt_item_key       TYPE /bobf/t_frw_key,
*        lt_fo_item1       TYPE /scmtms/t_tor_item_tr_k.
*
*  APPEND INITIAL LINE TO lt_fu_key ASSIGNING FIELD-SYMBOL(<lfs_fu_key>).
*  <lfs_fu_key>-key = '005056B837D41ED7B2F3E86FE59740C9'.
*
*  lref_svrmgr_tor->retrieve_by_association(
*    EXPORTING
*      iv_node_key       = /scmtms/if_tor_c=>sc_node-root
*      it_key            = lt_fu_key
*      iv_association    = /scmtms/if_tor_c=>sc_association-root-item_tr
*      iv_fill_data      = abap_true
*    IMPORTING
*      et_data           = lt_item_tr
*      et_failed_key     = lt_failed_key ).
*
*  READ TABLE lt_fo_item INTO DATA(ls_fo_item_main) INDEX 1.
*
*  LOOP AT lt_item_tr ASSIGNING FIELD-SYMBOL(<lfs_item_tr>) WHERE item_cat EQ 'PRD'.
*
*    CLEAR ls_fo_item.
*
*    ls_fo_item-root_key             = ls_fo_root-key.
*    ls_fo_item-parent_key           = ls_fo_root-key.
*
*    ls_fo_item-item_parent_key      = ls_fo_item_main-key.
*    ls_fo_item-src_stop_key         = ls_fo_item_main-src_stop_key.
*    ls_fo_item-des_stop_key         = ls_fo_item_main-des_stop_key.
*
*    ls_fo_item-item_cat             = <lfs_item_tr>-item_cat.
*    ls_fo_item-item_descr           = <lfs_item_tr>-item_descr.
*    ls_fo_item-main_cargo_item      = <lfs_item_tr>-main_cargo_item.
*
*    ls_fo_item-gro_wei_val          = <lfs_item_tr>-gro_wei_val.
*    ls_fo_item-gro_wei_uni          = <lfs_item_tr>-gro_wei_uni.
*    ls_fo_item-net_wei_val          = <lfs_item_tr>-net_wei_val.
*    ls_fo_item-net_wei_uni          = <lfs_item_tr>-net_wei_uni.
*    ls_fo_item-qua_pcs_val          = <lfs_item_tr>-qua_pcs_val.
*    ls_fo_item-qua_pcs_uni          = <lfs_item_tr>-qua_pcs_uni.
*    ls_fo_item-qua_pcs2_val         = <lfs_item_tr>-qua_pcs2_val.
*    ls_fo_item-qua_pcs2_uni         = <lfs_item_tr>-qua_pcs2_uni.
*    ls_fo_item-amt_gdsv_val         = <lfs_item_tr>-amt_gdsv_val.
*    ls_fo_item-amt_gdsv_cur         = <lfs_item_tr>-amt_gdsv_cur.
*
*    ls_fo_item-product_id           = <lfs_item_tr>-product_id.
*    ls_fo_item-prd_key              = <lfs_item_tr>-prd_key.
*    ls_fo_item-prd_transp_grp       = <lfs_item_tr>-prd_transp_grp.
*    ls_fo_item-transsrvlvl_code     = <lfs_item_tr>-transsrvlvl_code.
*
*    APPEND ls_fo_item TO lt_fo_item1.
*
*  ENDLOOP.
*
*  /scmtms/cl_mod_helper=>mod_create_multi(
*    EXPORTING
*      it_data        = lt_fo_item1
*      iv_node        = /scmtms/if_tor_c=>sc_node-item_tr
*      iv_source_node = /scmtms/if_tor_c=>sc_node-root
*      iv_association = /scmtms/if_tor_c=>sc_association-root-item_tr
*    CHANGING
*      ct_mod         = lt_modification ).
*
*   lref_svrmgr_tor->modify(
*    EXPORTING
*      it_modification = lt_modification ).

*  CREATE DATA ls_param_add_fu_by_fuid.
*
*  ls_param_add_fu_by_fuid->string = '4100036590'. "'005056B837D41ED7B2F3E86FE59740C9'.
*
*  lref_svrmgr_tor->do_action(
*    EXPORTING
*      iv_act_key      = /scmtms/if_tor_c=>sc_action-root-add_fu_by_fuid
*      it_key          = lt_fo_key
*      is_parameters   = ls_param_add_fu_by_fuid
*    IMPORTING
*      eo_message      = lref_message
*      et_failed_key   = lt_failed_key ).

*
*  lref_svrmgr_tor->retrieve_by_association(
*    EXPORTING
*      iv_node_key       = /scmtms/if_tor_c=>sc_node-root
*      it_key            = lt_fo_key
*      iv_association    = /scmtms/if_tor_c=>sc_association-root-item_tr
*      iv_fill_data      = abap_true
*    IMPORTING
*      et_data           = lt_item_tr
*      et_failed_key     = lt_failed_key ).
*
*
*
*
** End of adding item
*
*  "Build parameters for carrier selection
*  lref_param_per_cs = NEW #( ).
*  lref_param_per_cs->cs_prof_id = 'Z_CRS_SEL_AND_ASSIGN'.
*
*  "Perform carrier selection for the newly created FO
*  lref_svrmgr_tor->do_action(
*     EXPORTING
*       iv_act_key       = /scmtms/if_tor_c=>sc_action-root-perform_carrier_selection
*       it_key           = lt_fo_key
*       is_parameters    = lref_param_per_cs
*     IMPORTING
*       eo_message       = lref_message
*       et_failed_key    = lt_failed_key ).
*
*  "Read the new FO root data for selected carrier details
*  lref_svrmgr_tor->retrieve(
*    EXPORTING
*      iv_node_key       = /scmtms/if_tor_c=>sc_node-root
*      it_key            = lt_fo_key
*    IMPORTING
*      et_data           = lt_fo_root
*      et_failed_key     = lt_failed_key ).
*
*  "Perform charge calculation
*  lref_svrmgr_tor->do_action(
*    EXPORTING
*      iv_act_key        = /scmtms/if_tor_c=>sc_action-root-calc_transportation_charges
*      it_key            = lt_fo_key
*    IMPORTING
*      eo_message        = lref_message
*      et_failed_key     = lt_failed_key ).
*
*    "Read the new FO root data for selected carrier details
*  lref_svrmgr_tor->retrieve(
*    EXPORTING
*      iv_node_key       = /scmtms/if_tor_c=>sc_node-root
*      it_key            = lt_fo_key
*    IMPORTING
*      et_data           = lt_fo_root
*      et_failed_key     = lt_failed_key ).
*
*  "Retrieve transportation charges
*  lref_svrmgr_tor->retrieve_by_association(
*    EXPORTING
*      iv_node_key       = /scmtms/if_tor_c=>sc_node-root
*      it_key            = lt_fo_key
*      iv_association    = /scmtms/if_tor_c=>sc_association-root-transportcharges
*      iv_fill_data      = abap_true
*    IMPORTING
*      et_data           = lt_tspchrg_data
*      et_failed_key     = lt_failed_key ).
*
*
*
*
*  "Read the calculated amount
*  READ TABLE lt_tspchrg_data ASSIGNING FIELD-SYMBOL(<lfs_tspchrg_data>) WITH TABLE KEY root_key COMPONENTS root_key = ls_fo_root-key.
*  IF sy-subrc IS INITIAL.
*    IF <lfs_tspchrg_data>-calc_status EQ lc_calc_status_02.
*      ls_fu_root-zz_ds_amount   = '0.000820'.
*      ls_fu_root-zz_ds_currcode = 'USD'.
*    ENDIF.
*  ENDIF.
*
*  "Read the new FO root data for selected carrier details
*  lref_svrmgr_tor->retrieve(
*    EXPORTING
*      iv_node_key       = /scmtms/if_tor_c=>sc_node-root
*      it_key            = lt_fo_key
*    IMPORTING
*      et_data           = lt_fo_root
*      et_failed_key     = lt_failed_key ).
*
*  "Reading the FO root data
*  READ TABLE lt_fo_root ASSIGNING FIELD-SYMBOL(<lfs_fo_root>) INDEX 1.
*  IF sy-subrc IS INITIAL.
*    ls_fu_root-zz_ds_mtr      = <lfs_fo_root>-mtr.
*    ls_fu_root-zz_ds_tspid    = <lfs_fo_root>-tspid.
*    ls_fu_root-zz_ds_tsp_scac = <lfs_fo_root>-tsp_scac.
*  ENDIF.
*
*  ls_fu_root-key = '005056B837D41ED7A5E18E07E6B760C9'.
*
*  IF ls_fu_root IS NOT INITIAL.
*
*    DATA: ls_test_372   TYPE ztest_372.
*
*    ls_test_372-db_key          = ls_fu_root-key.
*    ls_test_372-zz_ds_amount    = ls_fu_root-zz_ds_amount.
*    ls_test_372-zz_ds_currcode  = ls_fu_root-zz_ds_currcode.
*    ls_test_372-zz_ds_mtr       = ls_fu_root-zz_ds_mtr.
*    ls_test_372-zz_ds_tspid     = ls_fu_root-zz_ds_tspid.
*    ls_test_372-zz_ds_tsp_scac  = ls_fu_root-zz_ds_tsp_scac.
*
*    MODIFY ztest_372 FROM ls_test_372.

****"Local variable declarations
****  DATA:             lv_mtr            TYPE /scmtms/transmeanstypecode,                              "Means of Transport
****                    lv_gro_wei_lb     TYPE /scmtms/qua_gro_wei_val,                                 "Gross weight in LB
****                    lv_fo_type        TYPE /scmtms/tor_type.                                        "Freight Order type
****
****  "Local workarea declarations
****  DATA:             ls_fo_info        TYPE /scmtms/s_tor_fo_info,                                   "FO information
****                    ls_fu_root        TYPE /scmtms/s_tor_root_k,                                    "FU Root data
****                    ls_fo_root        TYPE /scmtms/s_tor_root_k.                                    "FO Root data
****
****  "Local table declarations
****  DATA:             lt_fo_stop        TYPE /scmtms/t_tor_stop_k,                                    "FO Stop data
****                    lt_fo_succ        TYPE /scmtms/t_tor_stop_succ_k,                               "FO Stop successor data
****                    lt_fo_item        TYPE /scmtms/t_tor_item_tr_k,                                 "FO Item TR data
****                    lt_fo_root        TYPE /scmtms/t_tor_root_k,                                    "FO Root data
****                    lt_modification   TYPE /bobf/t_frw_modification,                                "Modification table
****                    lt_fo_key         TYPE /bobf/t_frw_key,                                         "FO key
****                    lt_tspchrg_data   TYPE /scmtms/t_tcc_root_k,                                    "Transportation charges
****                    lt_failed_key     TYPE /bobf/t_frw_key.                                         "Failed keys
****
****  "Local reference declarations
****  DATA:             lref_message      TYPE REF TO /bobf/if_frw_message,                             "Message object reference
****                    lref_param_per_cs TYPE REF TO /scmtms/s_tor_root_a_perfor_cs.                   "Parameters for carrier selection
****
****  "Local constant declarations
****  CONSTANTS:        lc_unit_lb        TYPE meins                      VALUE 'LB',                   "UoM          : LB    - Pound
****                    lc_mtr_zp_ltl     TYPE /scmtms/transmeanstypecode VALUE 'ZP_LTL',               "MTR          : ZP_LTL- Lessthan Truck Load
****                    lc_mtr_zp_tl      TYPE /scmtms/transmeanstypecode VALUE 'ZP_TL',                "MTR          : ZP_TL - Truck Load
****                    lc_trmod_1        TYPE /scmtms/booktrmo           VALUE '1',                    "Trans Mode   : 1     - Road
****                    lc_torcat_to      TYPE /scmtms/tor_category       VALUE 'TO',                   "TOR category : TO    - Freight Order
****                    lc_gro_wei_10k    TYPE /scmtms/qua_gro_wei_val    VALUE 10000,                  "Gross Weight : 10000 - 10000 Pounds
****                    lc_calc_status_02 TYPE /scmtms/tcc_calc_status    VALUE '02'.                   "Calc Status  : 02    - Calculated
****
****
****  "Get the Freight Order Type based on the Mode of Transport
****  /scmtms/cl_tor_helper_root=>get_def_tor_type_for_category(
****    EXPORTING
****      iv_tor_category = lc_torcat_to
****      iv_tor_booktrmo = lc_trmod_1
****    IMPORTING
****      ev_def_tor_type = lv_fo_type ).
****
****  "Populate FO information
****  ls_fo_info-mtr        = 'ZP_TL'.
****  ls_fo_info-trmodcat   = lc_trmod_1.
****
****    ls_fo_info-loc_src_key        = '005056B837D41ED6B8C98FE7872B40C7'.
****    ls_fo_info-adr_loc_src_key    = '005056B837D41ED6B8C98FE7872B40C7'.
****    ls_fo_info-pickup_start_date  = '20171118060000'.
****
****    ls_fo_info-loc_dst_key        = '005056B837D41ED6B8CAB1DEE392A0C7'.
****    ls_fo_info-adr_loc_dst_key    = '005056B837D41ED6B8CAB1DEE392A0C7'.
****    ls_fo_info-delivery_end_date  = '20171119060000'.
****
****
****  "Create Freight Order
****  /scmtms/cl_tor_factory=>create_tor_tour(
****    EXPORTING
*****     iv_do_modify            = abap_true
****      iv_tor_type             = lv_fo_type
****      iv_create_initial_stage = abap_true
****      iv_creation_type        = /scmtms/if_tor_const=>sc_creation_type-manual
****      is_fo_info              = ls_fo_info
****    IMPORTING
****      et_mod                  = lt_modification
****      es_tor_root             = ls_fo_root
****      et_tor_item             = lt_fo_item
****      et_tor_stop             = lt_fo_stop
****      et_tor_stop_succ        = lt_fo_succ
****    CHANGING
****      co_message              = lref_message ).
****
****  "Getting the FO key
****  APPEND INITIAL LINE TO lt_fo_key ASSIGNING FIELD-SYMBOL(<lfs_fo_key>).
****  <lfs_fo_key>-key = ls_fo_root-key.
****
****  "Set FO as subcontracting relevant
****  READ TABLE lt_modification ASSIGNING FIELD-SYMBOL(<lfs_modification>) WITH KEY key = ls_fo_root-key.
****  IF sy-subrc IS INITIAL.
****    FIELD-SYMBOLS: <lfs_fo_root1> TYPE /scmtms/s_tor_root_k.
****    ASSIGN <lfs_modification>-data->* TO <lfs_fo_root1>.
****    <lfs_fo_root1>-pln_sct_rel = /scmtms/if_tor_const=>sc_subcontr_relevance-relevant.
****    <lfs_fo_root1>-labeltxt    = 'E372FO'.
****  ENDIF.
****
****  "Creating a service manager reference for TOR
****  DATA(lref_svrmgr_tor) = /bobf/cl_tra_serv_mgr_factory=>get_service_manager( /scmtms/if_tor_c=>sc_bo_key ).
*****
****  lref_svrmgr_tor->modify(
****    EXPORTING
****      it_modification = lt_modification ).
****
****  "Build parameters for carrier selection
****  lref_param_per_cs = NEW #( ).
****  lref_param_per_cs->cs_prof_id = 'Z_CRS_SEL_AND_ASSIGN'.
****
****  "Perform carrier selection for the newly created FO
****  lref_svrmgr_tor->do_action(
****     EXPORTING
****       iv_act_key       = /scmtms/if_tor_c=>sc_action-root-perform_carrier_selection
****       it_key           = lt_fo_key
****       is_parameters    = lref_param_per_cs
****     IMPORTING
****       eo_message       = lref_message
****       et_failed_key    = lt_failed_key ).
****
****  "Read the new FO root data for selected carrier details
****  lref_svrmgr_tor->retrieve(
****    EXPORTING
****      iv_node_key       = /scmtms/if_tor_c=>sc_node-root
****      it_key            = lt_fo_key
****    IMPORTING
****      et_data           = lt_fo_root
****      et_failed_key     = lt_failed_key ).
****
****  "Perform charge calculation
****  lref_svrmgr_tor->do_action(
****    EXPORTING
****      iv_act_key        = /scmtms/if_tor_c=>sc_action-root-calc_transportation_charges
****      it_key            = lt_fo_key
****    IMPORTING
****      eo_message        = lref_message
****      et_failed_key     = lt_failed_key ).
****
****    "Read the new FO root data for selected carrier details
****  lref_svrmgr_tor->retrieve(
****    EXPORTING
****      iv_node_key       = /scmtms/if_tor_c=>sc_node-root
****      it_key            = lt_fo_key
****    IMPORTING
****      et_data           = lt_fo_root
****      et_failed_key     = lt_failed_key ).
****
****  "Retrieve transportation charges
****  lref_svrmgr_tor->retrieve_by_association(
****    EXPORTING
****      iv_node_key       = /scmtms/if_tor_c=>sc_node-root
****      it_key            = lt_fo_key
****      iv_association    = /scmtms/if_tor_c=>sc_association-root-transportcharges
****      iv_fill_data      = abap_true
****    IMPORTING
****      et_data           = lt_tspchrg_data
****      et_failed_key     = lt_failed_key ).
****
****
****
****
****  "Read the calculated amount
****  READ TABLE lt_tspchrg_data ASSIGNING FIELD-SYMBOL(<lfs_tspchrg_data>) WITH TABLE KEY root_key COMPONENTS root_key = ls_fo_root-key.
****  IF sy-subrc IS INITIAL.
****    IF <lfs_tspchrg_data>-calc_status EQ lc_calc_status_02.
****      ls_fu_root-zz_ds_amount   = '0.000820'.
****      ls_fu_root-zz_ds_currcode = 'USD'.
****    ENDIF.
****  ENDIF.
****
****  "Read the new FO root data for selected carrier details
****  lref_svrmgr_tor->retrieve(
****    EXPORTING
****      iv_node_key       = /scmtms/if_tor_c=>sc_node-root
****      it_key            = lt_fo_key
****    IMPORTING
****      et_data           = lt_fo_root
****      et_failed_key     = lt_failed_key ).
****
****  "Reading the FO root data
****  READ TABLE lt_fo_root ASSIGNING FIELD-SYMBOL(<lfs_fo_root>) INDEX 1.
****  IF sy-subrc IS INITIAL.
****    ls_fu_root-zz_ds_mtr      = <lfs_fo_root>-mtr.
****    ls_fu_root-zz_ds_tspid    = <lfs_fo_root>-tspid.
****    ls_fu_root-zz_ds_tsp_scac = <lfs_fo_root>-tsp_scac.
****  ENDIF.
****
****  ls_fu_root-key = '005056B837D41ED7A5E18E07E6B760C9'.
****
****  IF ls_fu_root IS NOT INITIAL.
****
****    DATA: ls_test_372   TYPE ztest_372.
****
****    ls_test_372-db_key          = ls_fu_root-key.
****    ls_test_372-zz_ds_amount    = ls_fu_root-zz_ds_amount.
****    ls_test_372-zz_ds_currcode  = ls_fu_root-zz_ds_currcode.
****    ls_test_372-zz_ds_mtr       = ls_fu_root-zz_ds_mtr.
****    ls_test_372-zz_ds_tspid     = ls_fu_root-zz_ds_tspid.
****    ls_test_372-zz_ds_tsp_scac  = ls_fu_root-zz_ds_tsp_scac.
****
****    MODIFY ztest_372 FROM ls_test_372.

*    CLEAR lt_modification.
*    APPEND INITIAL LINE TO lt_modification ASSIGNING <lfs_modification>.
*
*    "Get modification record for FU
*    /scmtms/cl_mod_helper=>mod_update_single(
*      EXPORTING
*        is_data            = ls_fu_root
*        iv_node            = /scmtms/if_tor_c=>sc_node-root
*        iv_autofill_fields = abap_false
*      IMPORTING
*        es_mod             = <lfs_modification> ).
*
*    "Prepare modification record for FU root for updating direct shipment amount
*    APPEND zif_tmboe372_ltl_ftl_cost_op_c=>sc_node_attribute-root-zz_ds_mtr       TO <lfs_modification>-changed_fields.
*    APPEND zif_tmboe372_ltl_ftl_cost_op_c=>sc_node_attribute-root-zz_ds_tspid     TO <lfs_modification>-changed_fields.
*    APPEND zif_tmboe372_ltl_ftl_cost_op_c=>sc_node_attribute-root-zz_ds_tsp_scac  TO <lfs_modification>-changed_fields.
*    APPEND zif_tmboe372_ltl_ftl_cost_op_c=>sc_node_attribute-root-zz_ds_amount    TO <lfs_modification>-changed_fields.
*    APPEND zif_tmboe372_ltl_ftl_cost_op_c=>sc_node_attribute-root-zz_ds_currcode  TO <lfs_modification>-changed_fields.
*
*
*    "Modify the FU
*    lref_svrmgr_tor->modify(
*      EXPORTING
*        it_modification   = lt_modification ).

*    DATA(lref_tramngr) = /bobf/cl_tra_trans_mgr_factory=>get_transaction_manager( ).

"Saving the changes for persistence
*  lref_tramngr->save( ).

*  ENDIF.

*
*  "Read the calculated amount
*  READ TABLE lt_tspchrg_data ASSIGNING FIELD-SYMBOL(<lfs_tspchrg_data>) WITH TABLE KEY root_key COMPONENTS root_key = ls_fo_root-key.
*  IF sy-subrc IS INITIAL.
*    IF <lfs_tspchrg_data>-calc_status EQ lc_calc_status_02.
*      ls_fu_root-zz_ds_amount   = <lfs_tspchrg_data>-net_amount.
*      ls_fu_root-zz_ds_currcode = <lfs_tspchrg_data>-doc_currency.
*    ENDIF.
*  ENDIF.

*  "Read the new FO root data for selected carrier details
*  lref_svrmgr_tor->retrieve(
*    EXPORTING
*      iv_node_key       = /scmtms/if_tor_c=>sc_node-root
*      it_key            = lt_fo_key
*    IMPORTING
*      et_data           = lt_fo_root
*      et_failed_key     = lt_failed_key ).

*  "Reading the FO root data
*  READ TABLE lt_fo_root ASSIGNING FIELD-SYMBOL(<lfs_fo_root>) INDEX 1.
*  IF sy-subrc IS INITIAL.
*    ls_fu_root-zz_ds_mtr      = <lfs_fo_root>-mtr.
*    ls_fu_root-zz_ds_tspid    = <lfs_fo_root>-tspid.
*    ls_fu_root-zz_ds_tsp_scac = <lfs_fo_root>-tsp_scac.
*  ENDIF.

*  IF ls_fu_root IS NOT INITIAL.
*
*    CLEAR lt_modification.
*    APPEND INITIAL LINE TO lt_modification ASSIGNING <lfs_modification>.
*
*    "Prepare modification record for FU root for updating direct shipment amount
*    APPEND zif_tmboe372_ltl_ftl_cost_op_c=>sc_node_attribute-root-zz_ds_mtr       TO <lfs_modification>-changed_fields.
*    APPEND zif_tmboe372_ltl_ftl_cost_op_c=>sc_node_attribute-root-zz_ds_tspid     TO <lfs_modification>-changed_fields.
*    APPEND zif_tmboe372_ltl_ftl_cost_op_c=>sc_node_attribute-root-zz_ds_tsp_scac  TO <lfs_modification>-changed_fields.
*    APPEND zif_tmboe372_ltl_ftl_cost_op_c=>sc_node_attribute-root-zz_ds_amount    TO <lfs_modification>-changed_fields.
*    APPEND zif_tmboe372_ltl_ftl_cost_op_c=>sc_node_attribute-root-zz_ds_currcode  TO <lfs_modification>-changed_fields.
*
*    "Get modification record for FU
*    /scmtms/cl_mod_helper=>mod_update_single(
*      EXPORTING
*        is_data            = ls_fu_root
*        iv_node            = /scmtms/if_tor_c=>sc_node-root
*      IMPORTING
*        es_mod             = <lfs_modification> ).
*
*    "Modify the FU
*    lref_svrmgr_tor->do_modify(
*      EXPORTING
*        it_modification   = lt_modification ).
*
*  ENDIF.


*DATA: lv_val1 TYPE char5 VALUE 'test',
*      lv_val2 TYPE char5.
*
*SET PARAMETER ID 'test1' FIELD lv_val1.
*
*get PARAMETER ID 'test1' FIELD lv_val2.
*
*DATA: lv_amount TYPE /scmtms/amount,
*      lv_amt_out TYPE BP_AMNT,
*      lv_string   TYPE string.
*
*  TRY.
*  CALL METHOD cl_gdt_conversion=>amount_outbound
*    EXPORTING
*      im_value         = lv_amount
*      im_currency_code = ''
*    IMPORTING
*      ex_value         = lv_amt_out
**      ex_currency_code =
*      .
*
*  lv_string = lv_amt_out.
*   CATCH cx_gdt_conversion .
*  ENDTRY.
*
*  WRITE 'TEST'.


* DATA: lv_in TYPE /scmtms/quantity,
*       lv_out TYPE /scmtms/quantity,
*       lv_uom_in TYPE meins,
*       lv_uom_out TYPE meins.
*
* CALL FUNCTION 'UNIT_CONVERSION_SIMPLE'
*            EXPORTING
*              input                      = lv_in
*              unit_in                    = lv_uom_in
*              unit_out                   = lv_uom_out
*            IMPORTING
*              output                     = lv_out
*            EXCEPTIONS
*              conversion_not_found       = 1
*              division_by_zero           = 2
*              input_invalid              = 3
*              output_invalid             = 4
*              overflow                   = 5
*              type_invalid               = 6
*              units_missing              = 7
*              unit_in_not_found          = 8
*              unit_out_not_found         = 9
*              OTHERS                     = 10.
*          IF sy-subrc IS INITIAL.
*
*          endif.

*TYPES: BEGIN OF gty_test,
*        data TYPE REF TO data,
*       END OF gty_test,
*
*       gty_t_test TYPE TABLE OF gty_test.
*
*  DATA: lv_obj  TYPE REF TO /scmtms/tor_id,
*        lt_obj  TYPE gty_t_test.
*
*  DO 5 TIMES.
*
*    lv_obj = NEW #( ).
*
*    lv_obj->* = sy-index.
*
*    APPEND INITIAL LINE TO lt_obj ASSIGNING FIELD-SYMBOL(<lfs_obj>).
*    CREATE DATA <lfs_obj>-data TYPE REF TO /scmtms/tor_id.
*    <lfs_obj>-data = lv_obj.
*
*  ENDDO.
*
*
*DATA ls_tor_event TYPE zttm_tor_event.
*
*CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
*  EXPORTING
*    input         = '6100000975'
* IMPORTING
*   OUTPUT        = ls_tor_event-tor_id.
*
*ls_tor_event-event_code = 'Z_PGR'.
*
*INSERT INTO zttm_tor_event VALUES ls_tor_event.
*
*CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'.
*
*DATA: lt_dbkey_from_trqrot TYPE /bobf/t_frw_key,
*      lt_fu_key TYPE /bobf/t_frw_key,
*      lt_fo_key TYPE /bobf/t_frw_key,
*      lt_tor_root_fu TYPE /scmtms/t_tor_root_k,
*      lt_tor_root_fo TYPE /scmtms/t_tor_root_k,
*      ls_request_flag TYPE /scmtms/s_pln_reqflg_tor,
*      lt_tor_exec   TYPE /scmtms/t_tor_exec_k.
*
*
*DATA(lref_srvmngr_trq) = /bobf/cl_tra_serv_mgr_factory=>get_service_manager( iv_bo_key = /scmtms/if_trq_c=>sc_bo_key ).
*
* lref_srvmngr_trq->retrieve_by_association(
*   EXPORTING
*     iv_node_key             = /scmtms/if_trq_c=>sc_node-root                      " Node
*     it_key                  = lt_dbkey_from_trqrot                                " Key Table
*     iv_association          = /scmtms/if_trq_c=>sc_association-root-tor_root_fu " Association
*     iv_fill_data            = abap_true
*   IMPORTING
*     et_data                 = lt_tor_root_fu ).
*
* LOOP AT lt_tor_root_fu ASSIGNING FIELD-SYMBOL(<lfs_tor_root_fu>).
*   APPEND INITIAL LINE TO lt_fu_key ASSIGNING FIELD-SYMBOL(<lfs_fu_key>).
*   <lfs_fu_key>-key = <lfs_tor_root_fu>-key.
* ENDLOOP.
*
* DATA(lref_srvmngr_tor) = /bobf/cl_tra_serv_mgr_factory=>get_service_manager( iv_bo_key = /scmtms/if_tor_c=>sc_bo_key ).
*
* lref_srvmngr_tor->retrieve_by_association(
*   EXPORTING
*     iv_node_key             = /scmtms/if_tor_c=>sc_node-root                      " Node
*     it_key                  = lt_fu_key                                " Key Table
*     iv_association          = /scmtms/if_tor_c=>sc_association-root-capa_tor " Association
*     iv_fill_data            = abap_true
*   IMPORTING
*     et_data                 = lt_tor_root_fo ).
*
* LOOP AT lt_tor_root_fo ASSIGNING FIELD-SYMBOL(<lfs_tor_root_fo>).
*   APPEND INITIAL LINE TO lt_fo_key ASSIGNING FIELD-SYMBOL(<lfs_fo_key>).
*   <lfs_fo_key>-key = <lfs_tor_root_fo>-key.
* ENDLOOP.
*
*  lref_srvmngr_tor->retrieve_by_association(
*   EXPORTING
*     iv_node_key             = /scmtms/if_tor_c=>sc_node-root                      " Node
*     it_key                  = lt_fo_key                                " Key Table
*     iv_association          = /scmtms/if_tor_c=>sc_association-root-exec_valid " Association
*     iv_fill_data            = abap_true
*   IMPORTING
*     et_data                 = lt_tor_exec ).
*
* ls_request_flag-tor_exec = abap_true.
*
* CALL METHOD /scmtms/cl_pln_bo_data=>get_tor_data
*   EXPORTING
*     it_key                   = lt_fo_key
**     is_request_flags         = ls_request_flag
*   CHANGING
*     ct_tor_exec              = lt_tor_exec.
*
*
*
* WRITE 'TEst'.


*DATA ls_tor_event TYPE zttm_tor_event.
*
*CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
*  EXPORTING
*    input         = '6100000546'
* IMPORTING
*   OUTPUT        = ls_tor_event-tor_id.
*
*ls_tor_event-event_code = 'Z_PGI'.
*
*INSERT INTO zttm_tor_event VALUES ls_tor_event.


*
*DATA: lv_amount TYPE /scmtms/amount,
*      lv_fraction TYPE /scmtms/amount.
*
*lv_amount = '5'.
*
*  lv_fraction = lv_amount mod 1.
*  IF lv_fraction IS NOT INITIAL.
*    WRITE 'Fraction'.
*  ELSE.
*    WRITE 'Not a Fraction'.
*  ENDIF.

*DATA: lt_key                TYPE                   /bobf/t_frw_key,                  "Keys
*      lt_req_tor            TYPE                   /scmtms/t_tor_root_k.
*
*  DATA(lref_srvmgr)     = /bobf/cl_tra_serv_mgr_factory=>get_service_manager( /scmtms/if_tor_c=>sc_bo_key ).
*
*  CALL METHOD lref_srvmgr->retrieve_by_association
*    EXPORTING
*      iv_node_key    = /scmtms/if_tor_c=>sc_node-root
*      it_key         = lt_key
*      iv_association = /scmtms/if_tor_c=>sc_association-root-req_tor
*      iv_fill_data   = abap_true
*    IMPORTING
*      et_data        = lt_req_tor.
*
*TYPES: lty_t_carr TYPE RANGE OF bu_partner,
*       lty_t_locno TYPE RANGE OF /SAPAPO/LOCNO,
*       lty_t_product TYPE RANGE OF /SCMTMS/PRODUCT_ID.
*
*DATA : lt_r_oscocarr TYPE lty_t_carr,
*       lt_r_locno    TYPE lty_t_locno,
*       lt_r_product  TYPE lty_t_product,
*       lv_carrier    TYPE bu_partner.
*
*SELECT
*    *
*    FROM tvarvc
*    INTO TABLE @DATA(lt_osco_carriers)
*    WHERE name EQ 'ZI0118_OSCO'.
*  IF sy-subrc IS INITIAL.
*    SORT lt_osco_carriers BY low.
*  ENDIF.
*
*  LOOP AT lt_osco_carriers ASSIGNING FIELD-SYMBOL(<lfs_osco_carriers>).
*    APPEND INITIAL LINE TO lt_r_product ASSIGNING FIELD-SYMBOL(<lfs_r_product>).
*    CALL FUNCTION 'CONVERSION_EXIT_MDLP1_INPUT'
*          EXPORTING
*            input       = <lfs_osco_carriers>-high
*          IMPORTING
*            output      = <lfs_r_product>-high
*          EXCEPTIONS
*            input_error = 1
*            OTHERS      = 2.
*    APPEND INITIAL LINE TO lt_r_oscocarr ASSIGNING FIELD-SYMBOL(<lfs_r_oscocarr>).
*    <lfs_r_oscocarr>-sign   = <lfs_osco_carriers>-sign.
*    <lfs_r_oscocarr>-option = <lfs_osco_carriers>-opti.
*    <lfs_r_oscocarr>-low    = <lfs_osco_carriers>-low.
*    <lfs_r_oscocarr>-high   = <lfs_osco_carriers>-high.
*  ENDLOOP.
*
*  IF lv_carrier NOT IN lt_r_oscocarr.
*    WRITE 'True'.
*  ELSE.
*    WRITE 'False'.
*  ENDIF.
*


*DATA: lv_input(50)  TYPE c,
*      lv_output     TYPE /scmtms/tor_id.
*TRY .
*
*
*CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
*  EXPORTING
*    input         = lv_input
* IMPORTING
*    OUTPUT        = lv_output.
*CATCH cx_root.
*
*ENDTRY.
*
*  DATA: lt_key            TYPE          /bobf/t_frw_key,
*        lt_failed_key     TYPE          /bobf/t_frw_key,
*        lref_parameter    TYPE REF TO   /scmtms/s_tend_a_accrej_req,
*        lref_change       TYPE REF TO   /bobf/if_tra_change,
*        lref_message      TYPE REF TO   /bobf/if_frw_message.
*
*  DATA(lref_srvmgr)     = /bobf/cl_tra_serv_mgr_factory=>get_service_manager( /scmtms/if_tor_c=>sc_bo_key ).
*
*  APPEND INITIAL LINE TO lt_key ASSIGNING FIELD-SYMBOL(<lfs_key>).
*
*  <lfs_key>-key = '005056B837D41ED7A6C5DE19959880C9'.
*
*  lref_parameter = NEW #( ).
*
*  lref_parameter->no_check    = abap_true.
*  lref_parameter->submit_now  = abap_true.
*  APPEND INITIAL LINE TO lref_parameter->t_param ASSIGNING FIELD-SYMBOL(<lfs_param>).
*  <lfs_param>-tend_req_key = '005056B837D41ED7A6C5DE19959880C9'.
*
*  CALL METHOD lref_srvmgr->do_action
*  EXPORTING
*    iv_act_key    = /scmtms/if_tor_c=>sc_action-tenderingrequest-accept_request
*    it_key        = lt_key
*    is_parameters = lref_parameter
*  IMPORTING
*    eo_change     = lref_change
*    eo_message    = lref_message
*    et_failed_key = lt_failed_key.
*
*  DATA(lref_tramngr) = /bobf/cl_tra_trans_mgr_factory=>get_transaction_manager( ).
*
*  "Saving the changes for persistence
*  lref_tramngr->save(
*    IMPORTING
*      eo_change       = lref_change
*      eo_message      = lref_message ).
*
*  WRITE: 'Success'.

*DATA: lref_trqroot      TYPE REF TO   /scmtms/s_trq_root_k,
*      lt_key            TYPE          /bobf/t_frw_key,
*      lt_trq_root_data  TYPE          /scmtms/t_trq_root_k,
*      lt_trq_item_data  TYPE          /scmtms/t_trq_item_k,
*      lt_modification   TYPE          /bobf/t_frw_modification.
*
*
*"Get instance of service manager for TRQ
*DATA(lref_srvmgr)     = /bobf/cl_tra_serv_mgr_factory=>get_service_manager( /scmtms/if_trq_c=>sc_bo_key ).
*
*APPEND INITIAL LINE TO lt_key ASSIGNING FIELD-SYMBOL(<lfs_key>).
*<lfs_key>-key = '005056B837D41ED6B9FBC4694E8720C7'.  "GUID for OTR: 3100000010
*
*CALL METHOD lref_srvmgr->retrieve
*  EXPORTING
*    iv_node_key = /scmtms/if_trq_c=>sc_node-root
*    it_key      = lt_key
*  IMPORTING
*    et_data     = lt_trq_root_data.
*
*CALL METHOD lref_srvmgr->retrieve_by_association
*  EXPORTING
*    iv_node_key    = /scmtms/if_trq_c=>sc_node-root
*    it_key         = lt_key
*    iv_association = /scmtms/if_trq_c=>sc_association-root-item
*    iv_fill_data   = abap_true
*    iv_edit_mode   = /bobf/if_conf_c=>sc_edit_read_only
*  IMPORTING
*    et_data        = lt_trq_item_data.
*
*lref_trqroot = NEW #( ).
*
*lref_trqroot->key = '005056B837D41ED6B9FBC4694E8720C7'.  "GUID for OTR: 3100000010
*lref_trqroot->blk_plan  = abap_true.
*lref_trqroot->brc_plan  = '05'.
*
*"Creating modification record for TRQ ROOT changes
*APPEND INITIAL LINE TO lt_modification ASSIGNING FIELD-SYMBOL(<lfs_modification>).
*
*IF <lfs_modification> IS ASSIGNED.
*
*  <lfs_modification>-node            = /scmtms/if_trq_c=>sc_node-root.
*  <lfs_modification>-change_mode     = /bobf/if_frw_c=>sc_modify_update.
*  <lfs_modification>-source_node     = lref_trqroot->key.
*  <lfs_modification>-key             = lref_trqroot->key.
*  <lfs_modification>-data            = lref_trqroot.
*
*  "Changed fields are also passed, so that other values are preserved
*  APPEND /scmtms/if_trq_c=>sc_node_attribute-root-blk_plan TO <lfs_modification>-changed_fields.
*  APPEND /scmtms/if_trq_c=>sc_node_attribute-root-brc_plan TO <lfs_modification>-changed_fields.
*
*ENDIF.
*
*
*"Modifying the changes
*IF lt_modification IS NOT INITIAL.
*
*  DATA: lref_changetrq  TYPE REF TO /bobf/if_tra_change,
*        lref_messagetrq TYPE REF TO /bobf/if_frw_message.
*
*  lref_srvmgr->modify(
*    EXPORTING
*      it_modification = lt_modification
*    IMPORTING
*      eo_change       = lref_changetrq
*      eo_message      = lref_messagetrq ).
*
*  DATA(lref_tramngr) = /bobf/cl_tra_trans_mgr_factory=>get_transaction_manager( ).
*
*  "Saving the changes for persistence
*  lref_tramngr->save(
*    IMPORTING
*      eo_change       = lref_changetrq
*      eo_message      = lref_messagetrq ).
*ENDIF.

*
*
*DATA: lv_string TYPE string.
*
*CONCATENATE 'Hello' 'World' 'Test' INTO lv_string SEPARATED BY cl_abap_char_utilities=>cr_lf.
*
*WRITE lv_string.
*
*RETURN.
*
**
*DATA: lt_route_det TYPE zttm_route_determination,
*      ls_route_det TYPE zstm_route_determination.
*
*ls_route_det-posnr  = '000010'.
*ls_route_det-vstel  = '2002'.
*ls_route_det-kunnr  = '0010000007'.
*ls_route_det-vsbed  = '51'.
*ls_route_det-matnr  = '4000873'.
*ls_route_det-brgew  = 12000.
*ls_route_det-gewei  = 'LB'.
*
*APPEND ls_route_det TO lt_route_det.
*
*CALL FUNCTION 'ZFM_TM_I343_ROUTE_DETRMINATION'
*  CHANGING
*    ct_route_det = lt_route_det.
*
*DATA:   lv_matnr   TYPE matnr,
*        lv_product TYPE /sapapo/matnr.
*
*CALL FUNCTION 'CONVERSION_EXIT_PRODU_INPUT'
*  EXPORTING
*    input        = lv_matnr
*  IMPORTING
*    output       = lv_product
*  EXCEPTIONS
*    length_error = 1
*    OTHERS       = 2.
*IF sy-subrc IS INITIAL.
*
*ENDIF.
*
*"Local declarations
*DATA:             "lref_srvmgr             TYPE REF TO   /bobf/if_tra_service_manager,
*  lt_tspchrg_key          TYPE          /bobf/t_frw_key,
*  "lt_key                  TYPE          /bobf/t_frw_key,
*  lt_chrgitm_key          TYPE          /bobf/t_frw_key,
*  lt_itmchrgele_key       TYPE          /bobf/t_frw_key,
*  lv_node_key             TYPE          /bobf/obm_node_key,
*  lv_assoc_key            TYPE          /bobf/obm_assoc_key,
*  lv_chrgitm_node_key     TYPE          /bobf/obm_node_key,
*  lv_chrgitm_assoc_key    TYPE          /bobf/obm_assoc_key,
*  lv_itmchrgele_node_key  TYPE          /bobf/obm_node_key,
*  lv_itmchrgele_assoc_key TYPE          /bobf/obm_assoc_key,
*  lt_itmchrgele           TYPE          /scmtms/t_tcc_trchrg_element_k,
*  lref_itmchrgele         TYPE REF TO   /scmtms/s_tcc_trchrg_element_k,
*  "lt_modification         TYPE          /bobf/t_frw_modification,
*  lv_pack_curr_in         TYPE p DECIMALS 6.
*
*"Local Constants declarations
*DATA:             lc_isocd_usd            TYPE isocd          VALUE 'USD'.
*
*"Get instance of server manager
*lref_srvmgr     = /bobf/cl_tra_serv_mgr_factory=>get_service_manager( /scmtms/if_tor_c=>sc_bo_key ).
*
*APPEND INITIAL LINE TO lt_key ASSIGNING <lfs_key>.
*
*"TEST execution for FO : 6100000835
*<lfs_key>-key = '005056B837D41ED79FD68FE96B2BA0C9'.
*
*"Retrieve transportation charge key for the TOR
*CALL METHOD lref_srvmgr->retrieve_by_association
*  EXPORTING
*    iv_node_key    = /scmtms/if_tor_c=>sc_node-root
*    it_key         = lt_key
*    iv_association = /scmtms/if_tor_c=>sc_association-root-transportcharges
*    iv_fill_data   = abap_false
*    iv_edit_mode   = /bobf/if_conf_c=>sc_edit_read_only
*  IMPORTING
*    et_target_key  = lt_tspchrg_key.
*
*"Get runtime association and node keys for ChargeItem
*CALL METHOD /scmtms/cl_common_helper=>get_do_keys_4_rba
*  EXPORTING
*    iv_host_bo_key      = /scmtms/if_tor_c=>sc_bo_key
*    iv_host_do_node_key = /scmtms/if_tor_c=>sc_node-transportcharges
*    iv_do_node_key      = /scmtms/if_tcc_trnsp_chrg_c=>sc_node-chargeitem
*    iv_do_assoc_key     = /scmtms/if_tcc_trnsp_chrg_c=>sc_association-root-chargeitem
*  IMPORTING
*    ev_node_key         = lv_chrgitm_node_key
*    ev_assoc_key        = lv_chrgitm_assoc_key.
*
*"Retrieve ChargeItem keys
*CALL METHOD lref_srvmgr->retrieve_by_association
*  EXPORTING
*    iv_node_key    = /scmtms/if_tor_c=>sc_node-transportcharges
*    it_key         = lt_tspchrg_key
*    iv_association = lv_chrgitm_assoc_key
*    iv_fill_data   = abap_false
*    iv_edit_mode   = /bobf/if_conf_c=>sc_edit_read_only
*  IMPORTING
*    et_target_key  = lt_chrgitm_key.
*
*"Get runtime association and node keys for ChargeItem
*CALL METHOD /scmtms/cl_common_helper=>get_do_keys_4_rba
*  EXPORTING
*    iv_host_bo_key      = /scmtms/if_tor_c=>sc_bo_key
*    iv_host_do_node_key = /scmtms/if_tor_c=>sc_node-transportcharges
*    iv_do_node_key      = /scmtms/if_tcc_trnsp_chrg_c=>sc_node-itemchargeelement
*    iv_do_assoc_key     = /scmtms/if_tcc_trnsp_chrg_c=>sc_association-chargeitem-itemchargeelement
*  IMPORTING
*    ev_node_key         = lv_itmchrgele_node_key
*    ev_assoc_key        = lv_itmchrgele_assoc_key.
*
*"Retrieve ItemChargeElement keys
*CALL METHOD lref_srvmgr->retrieve_by_association
*  EXPORTING
*    iv_node_key    = lv_chrgitm_node_key
*    it_key         = lt_chrgitm_key
*    iv_association = lv_itmchrgele_assoc_key
*    iv_fill_data   = abap_true
*    iv_edit_mode   = /bobf/if_conf_c=>sc_edit_read_only
*  IMPORTING
*    et_target_key  = lt_itmchrgele_key
*    et_data        = lt_itmchrgele.
*
*"Creating the change record for ItemChargeElement
*CREATE DATA lref_itmchrgele.
*
*"Reading the second line for ZLINE
*READ TABLE lt_itmchrgele_key ASSIGNING FIELD-SYMBOL(<lfs_itmchrgele_key>) INDEX 3.
*IF sy-subrc IS INITIAL.
*  lref_itmchrgele->key       = <lfs_itmchrgele_key>-key.
*ENDIF.
*
*lref_itmchrgele->calc_amount  = 100.
*lref_itmchrgele->rate_amount  = 100.
*
*TRY.
*    "Convert currency into internal format
*    lv_pack_curr_in = lref_itmchrgele->calc_amount.
*    CALL METHOD cl_gdt_conversion=>amount_inbound
*      EXPORTING
*        im_value         = lv_pack_curr_in
*        im_currency_code = lc_isocd_usd
*        im_use_rounding  = abap_true
*      IMPORTING
*        ex_value         = lref_itmchrgele->calc_amount.
*  CATCH cx_gdt_conversion.
*    CLEAR lref_itmchrgele->calc_amount.
*ENDTRY.
*
*TRY.
*    "Convert currency into internal format
*    lv_pack_curr_in = lref_itmchrgele->rate_amount.
*    CALL METHOD cl_gdt_conversion=>amount_inbound
*      EXPORTING
*        im_value         = lv_pack_curr_in
*        im_currency_code = lc_isocd_usd
*        im_use_rounding  = abap_true
*      IMPORTING
*        ex_value         = lref_itmchrgele->rate_amount.
*  CATCH cx_gdt_conversion.
*    CLEAR lref_itmchrgele->rate_amount.
*ENDTRY.
*
*"Assigning the same amount to other amount fields.
*lref_itmchrgele->rate_amount = lref_itmchrgele->calc_amount.
*lref_itmchrgele->amount      = lref_itmchrgele->calc_amount.
*lref_itmchrgele->amountlcl   = lref_itmchrgele->calc_amount.
*
*
*"Creating modification record for Item Charge element associating with the Charge Item
*APPEND INITIAL LINE TO lt_modification ASSIGNING <lfs_modification>.
*
*IF <lfs_modification> IS ASSIGNED.
*
*  <lfs_modification>-association     = lv_itmchrgele_assoc_key.
*  <lfs_modification>-node            = lv_itmchrgele_node_key.
*  <lfs_modification>-change_mode     = /bobf/if_frw_c=>sc_modify_update.
*  <lfs_modification>-source_node     = lv_chrgitm_node_key.
*  <lfs_modification>-key             = lref_itmchrgele->key.
*  <lfs_modification>-data            = lref_itmchrgele.
*  READ TABLE lt_chrgitm_key ASSIGNING FIELD-SYMBOL(<lfs_chrgitm_key>) INDEX 1.
*  IF sy-subrc IS INITIAL.
*    <lfs_modification>-source_key    = <lfs_chrgitm_key>-key.
*  ENDIF.
*
*  "Changed fields are also passed, so that other values are preserved
*  APPEND /scmtms/if_tcc_trnsp_chrg_c=>sc_node_attribute-itemchargeelement-calc_amount TO <lfs_modification>-changed_fields.
*  APPEND /scmtms/if_tcc_trnsp_chrg_c=>sc_node_attribute-itemchargeelement-rate_amount TO <lfs_modification>-changed_fields.
*  APPEND /scmtms/if_tcc_trnsp_chrg_c=>sc_node_attribute-itemchargeelement-amount      TO <lfs_modification>-changed_fields.
*  APPEND /scmtms/if_tcc_trnsp_chrg_c=>sc_node_attribute-itemchargeelement-amountlcl   TO <lfs_modification>-changed_fields.
*
*ENDIF.
*
*"Modifying the changes
*IF lt_modification IS NOT INITIAL.
*
*  DATA: lref_change  TYPE REF TO /bobf/if_tra_change,
*        lref_message TYPE REF TO /bobf/if_frw_message.
*
*  lref_srvmgr->modify(
*    EXPORTING
*      it_modification = lt_modification
*    IMPORTING
*      eo_change       = lref_change
*      eo_message      = lref_message ).
*
*  DATA(lref_tramgr) = /bobf/cl_tra_trans_mgr_factory=>get_transaction_manager( ).
*
*  "Saving the changes for persistence
*  lref_tramgr->save(
*    IMPORTING
*      eo_change       = lref_change
*      eo_message      = lref_message ).
*ENDIF.
*
*
*
*
*
**  DATA: lt_tor_stop TYPE /scmtms/t_tor_stop_k.
**
**  CALL METHOD /scmtms/cl_pln_bo_data=>get_tor_data
**    EXPORTING
**      iv_key           = '005056B837D41ED79BE8DCD32DAC80C7'
**    CHANGING
**      ct_tor_stop      = lt_tor_stop.
**
**DATA: lt_request  TYPE /scmtms/t_lddd_didu_request,
**      ls_request  TYPE /scmtms/s_lddd_didu_request,
**      lt_result   TYPE /scmtms/t_lddd_didu_result,
**      lt_message  TYPE /scmtms/t_lddd_message,
**      lr_loc_no   TYPE /scmtms/cl_loc_helper=>ty_t_locno_range,
**      ls_loc_no   LIKE LINE OF lr_loc_no,
**      lt_location TYPE /scmtms/cl_loc_helper=>ty_t_loc.
**
**ls_loc_no-sign          = 'I'.
**ls_loc_no-option        = 'EQ'.
**ls_loc_no-low           = 'SP2002'.
**APPEND ls_loc_no TO lr_loc_no.
**ls_loc_no-low           = '0020000632'.
**APPEND ls_loc_no TO lr_loc_no.
**
**
**CALL METHOD /scmtms/cl_loc_helper=>get_locations_by_locno(
**  EXPORTING
**    it_locno_range      = lr_loc_no
**  IMPORTING
**     et_locations       = lt_location ).
**
**ls_request-request_id   = 1.
**ls_request-loc_fr       = lt_location[ 1 ]-locuuid.
**ls_request-loc_to       = lt_location[ 2 ]-locuuid.
**ls_request-det_option   = '2'.
**ls_request-strategy     = 'Z_DDD_PCM'.
**APPEND ls_request TO lt_request.
**
**
**CALL METHOD /scmtms/cl_lane_dist_dur_det=>determine_distance_duration(
**    EXPORTING
**      it_request = lt_request
**    IMPORTING
**      et_result  = lt_result
**      et_message = lt_message ).

*DATA: lv_char40 TYPE char40,
*      lv_string TYPE string,
*      lv_assign TYPE string,
*      lo_object TYPE REF TO zcl_tst_dc,
*      ls_out    TYPE /scmtms/cpx_transp_doc_req_msg,
*      lv_dat    TYPE sy-datum.
*
*lv_dat = sy-datum.
*WRITE lv_dat DD/MM/YYYY.
*
*CREATE OBJECT lo_object.
*
*  DO 5 TIMES.
*
*    lv_char40 = lv_string = lv_assign.
*
*    CALL METHOD lo_object->convert_spl_char_to_xml_entity( CHANGING cs_out = ls_out ).
*
*    CALL METHOD lo_object->convert_spl_char_in_field( CHANGING cs_field_value = lv_char40 ).
*
*    CALL METHOD lo_object->convert_spl_char_in_field( CHANGING cs_field_value = lv_string ).
*
*
*  ENDDO.



*DATA: lv_quantity   TYPE /scmtms/quantity,
*      lv_qua_out    TYPE zde_pal_count,
*      lv_int        TYPE i,
*      lv_tmz        TYPE timezone,
*      ls_e1edk02    TYPE e1edk02,
*      ls_errormsg   TYPE zttm_errormsg,
*      lv_char100    TYPE char100,
*      lv_url        TYPE saeuri,
*      lv_objid      TYPE sdokobject,
*      lv_string1     TYPE string.
*
*DESCRIBE FIELD lv_string1 TYPE lv_char100.
**DESCRIBE FIELD lv_string LENGTH lv_int IN CHARACTER MODE.
*
*WRITE:/ lv_char100.
*WRITE:/.
*
*lv_objid-class = 'BS_ATF_DOC'.
*lv_objid-objid = '005056B837D41ED78EE40AB7BC1AC0C7'.
*
*
*CALL FUNCTION 'SDOK_PHIO_GET_URL_FOR_GET'
*  EXPORTING
*    object_id                        = lv_objid
**   REQUESTED_COMPONENTS             =
**   CLIENT                           = SY-MANDT
**   STANDARD_URL_ONLY                =
**   DATA_PROVIDER_URL_ONLY           =
**   WEB_APPLIC_SERVER_URL_ONLY       =
**   URL_LIFETIME                     =
**   URL_USED_AT                      =
**   NO_CACHE                         =
*  IMPORTING
**    URLS                             = lv_url
*   DOCUMENT_URL                     = lv_url
** EXCEPTIONS
**   NOT_EXISTING                     = 1
**   NOT_AUTHORIZED                   = 2
**   NO_CONTENT                       = 3
**   BAD_STORAGE_TYPE                 = 4
**   NO_URLS_AVAILABLE                = 5
**   OTHERS                           = 6
*          .
*IF sy-subrc <> 0.
** Implement suitable error handling here
*ENDIF.
*
*write:/ lv_url.
*
*write:/.
*
*
*lv_char100 = 'ABCD & test & world'.
*
*PERFORM give_length USING lv_char100.
*
*DESCRIBE FIELD lv_char100 LENGTH lv_int IN CHARACTER MODE.
*
*WRITE:/ lv_int.
*
*ls_errormsg-msg_class = 'ZTM'.
*ls_errormsg-msg_no    = '020'.
*ls_errormsg-return_message = 'Invalid FO/BOL number'.
*
*INSERT zttm_errormsg FROM ls_errormsg.
*CALL FUNCTION 'DB_COMMIT'.
*
*ls_e1edk02-qualf = 'xyz'.
*
*WRITE ls_e1edk02.
*
*CALL METHOD /scmtms/cl_common_helper=>loc_key_get_timezone
*  EXPORTING
*    iv_loc_key    = '005056B837D41ED6B8C97B80AD05A0C7'
*  RECEIVING
*    rv_timezone   = lv_tmz.
*
*
*CALL METHOD zcl_tst_dc=>update_stop_dates
*EXPORTING
*  iv_tor_key           = '005056B837D41ED792C0153681A040C7'
*  iv_dept_conf_date    = '20170627010000'
*  iv_dept_conf_date_lt = abap_true
*  iv_arrv_conf_date    = '20170629070000'
*  iv_arrv_conf_date_lt = abap_true.
*
*lv_qua_out = 1.
*TRY .
*  lv_qua_out = lv_qua_out * lv_int.
*  lv_qua_out = lv_qua_out / 0.
*CATCH cx_sy_arithmetic_error.
*  lv_qua_out = 0.
*ENDTRY.
*
*
*lv_quantity = '0.0200000000000'.
*
*CALL FUNCTION 'CONVERSION_EXIT_QTYRN_OUTPUT'
*  EXPORTING
*    input         = lv_quantity
* IMPORTING
*   output        = lv_qua_out
*          .
*
*
*
*DATA: lv_tor_key TYPE /bobf/conf_key VALUE '005056B837D41ED792C0153681A040C7',
*      ls_osco_res TYPE zoscorate_soap_out1,
*      lref_obj    TYPE REF TO zcl_tm_i118_osco_connectship.
*
*CREATE OBJECT lref_obj.
*
**CALL METHOD lref_obj->get_stored_osco_response
**  EXPORTING
**    im_v_tor_key       = lv_tor_key
**  IMPORTING
**    ex_s_osco_response = ls_osco_res.
*
*
*DATA: lv_uom TYPE msehi,
*      lv_uom1 TYPE char10.
*
*CALL FUNCTION 'UNIT_OF_MEASURE_ISO_TO_SAP'
*  EXPORTING
*    iso_code        = '4G'
* IMPORTING
*   sap_code        = lv_uom
**   UNIQUE          =
** EXCEPTIONS
**   NOT_FOUND       = 1
**   OTHERS          = 2
*          .
*IF sy-subrc <> 0.
** Implement suitable error handling here
*ENDIF.
*
*CALL FUNCTION 'CONVERSION_EXIT_CUNIT_OUTPUT'
*  EXPORTING
*    input                = lv_uom
**   LANGUAGE             = SY-LANGU
* IMPORTING
**   LONG_TEXT            =
*   output               = lv_uom1
**   SHORT_TEXT           =
** EXCEPTIONS
**   UNIT_NOT_FOUND       = 1
**   OTHERS               = 2
*          .
*IF sy-subrc <> 0.
** Implement suitable error handling here
*ENDIF.
*
*
*SELECT
*  *
*  FROM /sapapo/marm
*  INTO TABLE @DATA(lt_marm).
*  IF sy-subrc IS INITIAL.
*    DELETE lt_marm WHERE laeng IS INITIAL AND
*                         breit IS INITIAL AND
*                         hoehe IS INITIAL.
*
*    DELETE lt_marm WHERE ( laeng IS INITIAL AND
*                           breit IS INITIAL AND
*                           hoehe IS INITIAL ).
*
*  ENDIF.
*
*DATA: lv_carrier    TYPE bu_partner,
*      lv_tsp_key    TYPE /bobf/conf_key. "005056B837D41ED6B8CBF67BEFFB80C7
*
*  CALL METHOD /scmtms/cl_pln_tsps_helper=>get_tsp_ui_data
*    EXPORTING
*      iv_tsp_key   = lv_tsp_key
*    IMPORTING
*      ev_tsp_id    = lv_carrier
**      ev_tsp_descr =
**      ev_scac      =
*      .
*
*
*
*DATA: lv_ext_amount TYPE /scmtms/amount,
*      lv_int_amount TYPE /scmtms/amount,
*      lv_digits     TYPE i,
*      ls_return     TYPE bapireturn,
*      lv_chg_amt    TYPE bapicurr-bapicurr,
*      lv_string     TYPE string,
*
*      lt_carrank    TYPE STANDARD TABLE OF /scmtms/d_torrl,
*      ls_carrank    TYPE /scmtms/d_torrl,
*      lv_pin        TYPE p DECIMALS 6,
*      lv_pout       TYPE p DECIMALS 6.
*
*SELECT
*  *
*  FROM
*  /scmtms/d_torrl
*  INTO TABLE lt_carrank
*  WHERE parent_key = '005056B837D41ED78AD048084A4F20C7'.
*
*IF sy-subrc IS INITIAL.
*  LOOP AT lt_carrank INTO ls_carrank.
*    CLEAR: lv_pin, lv_pout.
*
*    TRY.
*    lv_pin = ls_carrank-amount.
*    CALL METHOD cl_gdt_conversion=>amount_inbound
*      EXPORTING
*        im_value         = lv_pin
*        im_currency_code = 'USD'
*        im_use_rounding  = abap_true
*      IMPORTING
*        ex_value         = ls_carrank-amount
**        ex_currency_code =
*       .
*
*
*
*     CATCH cx_gdt_conversion .
*    ENDTRY.
**    ls_carrank-amount = lv_pout.
*    WRITE ls_carrank-amount CURRENCY ls_carrank-currcode016.
*  ENDLOOP.
*ENDIF.
*
*
**
**
**lv_chg_amt = lv_ext_amount.
**
**CALL FUNCTION 'BAPI_CURRENCY_CONV_TO_INTERNAL'
**  EXPORTING
**    currency                   = 'USD'
**    amount_external            = lv_chg_amt
**    max_number_of_digits       = lv_digits
**  IMPORTING
**    AMOUNT_INTERNAL            = lv_string
**    RETURN                     = ls_RETURN
**          .
**
**lv_int_amount = lv_string.
**
**
**
**SELECT single name,
**              low
**         FROM tvarvc
**         INTO @DATA(ls_carrier)
**        WHERE name eq 'ZI0118_OSCO'
**          AND low  eq '500002'.
**
**
**
**
**
**DATA: lv_bpartner_proxy TYPE /SCMTMS/CPX_NOSC_PTY_INTRNL_ID,
**      lv_bpartner_abap  type bu_partner.
**
**"Table declarations
**  DATA:            lt_locid             TYPE STANDARD TABLE OF /sapapo/locid.                 "Table of location ids
**  DATA:            lv_fltp_value        TYPE fltp_value,
**                   lv_dist              TYPE /SAPAPO/TR_DIST.
**
**
**  lv_fltp_value = 13456.
**
**  CALL FUNCTION 'UNIT_CONVERSION_SIMPLE'
**    EXPORTING
**      input                      = lv_fltp_value
***     NO_TYPE_CHECK              = 'X'
***     ROUND_SIGN                 = ' '
**      UNIT_IN                    = 'MI'
**      UNIT_OUT                   = 'KM'
**    IMPORTING
***     ADD_CONST                  =
***     DECIMALS                   =
***     DENOMINATOR                =
***     NUMERATOR                  =
**      OUTPUT                     = lv_dist
**    EXCEPTIONS
**     CONVERSION_NOT_FOUND       = 1
**     DIVISION_BY_ZERO           = 2
**     INPUT_INVALID              = 3
**     OUTPUT_INVALID             = 4
**     OVERFLOW                   = 5
**     TYPE_INVALID               = 6
**     UNITS_MISSING              = 7
**     UNIT_IN_NOT_FOUND          = 8
**     UNIT_OUT_NOT_FOUND         = 9
**     OTHERS                     = 10
**            .
**  IF sy-subrc <> 0.
*** Implement suitable error handling here
**  ELSE.
**
**  ENDIF.
**
**
**
**CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
**  EXPORTING
**    input         = lv_bpartner_proxy
**  IMPORTING
**    OUTPUT        = lv_bpartner_abap.
**
**IF lv_bpartner_proxy NE lv_bpartner_abap.
**
**ENDIF.
**&---------------------------------------------------------------------*
**&      Form  GIVE_LENGTH
**&---------------------------------------------------------------------*
**       text
**----------------------------------------------------------------------*
**      -->P_LV_CHAR100  text
**----------------------------------------------------------------------*
*FORM give_length  USING    pr_lv_any  TYPE any.
*  DATA: lv_int TYPE i,
*        lv_str TYPE string.
*
*  DESCRIBE FIELD pr_lv_any LENGTH lv_int IN CHARACTER MODE.
*  DESCRIBE FIELD pr_lv_any TYPE lv_str.
*
*  WRITE:/'Inside sub Length:', lv_int, lv_str.
*
*  REPLACE ALL OCCURRENCES OF '&' in pr_lv_any WITH 'AND' REPLACEMENT LENGTH lv_int.
*
*  WRITE:/ 'After replacement:' && pr_lv_any && lv_int.
*
*ENDFORM.