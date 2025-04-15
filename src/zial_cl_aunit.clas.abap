"! <p class="shorttext synchronized">ABAP Unit Test: {@link CL_ABAP_UNIT_ASSERT}</p>
CLASS zial_cl_aunit DEFINITION
  PUBLIC FINAL
  CREATE PROTECTED
  FOR TESTING.

  PUBLIC SECTION.
    CLASS-METHODS on_class_setup
      IMPORTING iv_ign_errors      TYPE abap_bool                   DEFAULT abap_false
                iv_tdc_cnt         TYPE etobj_name
                ir_tdc_data        TYPE REF TO data
                it_sql_data        TYPE zial_tt_aunit_sql_test_data OPTIONAL
      RETURNING VALUE(ro_instance) TYPE REF TO zial_cl_aunit
      RAISING   cx_ecatt_tdc_access.

    METHODS on_setup.
    METHODS on_teardown.
    METHODS on_class_teardown.

    METHODS active
      IMPORTING iv_active        TYPE abap_bool
      RETURNING VALUE(rv_result) TYPE abap_bool.

  PROTECTED SECTION.
    CLASS-DATA mo_instance TYPE REF TO zial_cl_aunit.

    CONSTANTS mc_tdc_dflt_var_name TYPE etvar_id VALUE 'ECATTDEFAULT'.

    DATA mv_tdc_cnt      TYPE etobj_name.
    DATA mr_tdc_data     TYPE REF TO data.
    DATA mo_tdc          TYPE REF TO cl_apl_ecatt_tdc_api.
    DATA mv_tdc_var_name TYPE etvar_id.

    DATA mo_sql          TYPE REF TO if_osql_test_environment.
    DATA mt_sql_data     TYPE zial_tt_aunit_sql_test_data.

    METHODS constructor
      IMPORTING iv_ign_errors TYPE abap_bool
                iv_tdc_cnt    TYPE etobj_name
                ir_tdc_data   TYPE REF TO data
                it_sql_data   TYPE zial_tt_aunit_sql_test_data
      RAISING   cx_ecatt_tdc_access.

ENDCLASS.


CLASS zial_cl_aunit IMPLEMENTATION.

  METHOD constructor.

    mv_tdc_cnt  = iv_tdc_cnt.
    mr_tdc_data = ir_tdc_data.
    mt_sql_data = it_sql_data.

    ASSIGN mr_tdc_data->* TO FIELD-SYMBOL(<ls_tdc_data>).
    CHECK <ls_tdc_data> IS ASSIGNED.

    TRY.
        mo_tdc = cl_apl_ecatt_tdc_api=>get_instance( mv_tdc_cnt ).

        mv_tdc_var_name = |{ sy-sysid }{ sy-mandt }|.
        DATA(lt_tdc_var) = mo_tdc->get_variant_list( ).
        IF NOT line_exists( lt_tdc_var[ table_line = mv_tdc_var_name ] ).
          mv_tdc_var_name = mc_tdc_dflt_var_name.
        ENDIF.

        LOOP AT mo_tdc->get_variant_content( mv_tdc_var_name ) ASSIGNING FIELD-SYMBOL(<ls_tdc_var_content>).
          ASSIGN COMPONENT <ls_tdc_var_content>-parname OF STRUCTURE <ls_tdc_data> TO FIELD-SYMBOL(<lv_tdc_value>).
          CHECK <lv_tdc_value> IS ASSIGNED.
          ASSIGN <ls_tdc_var_content>-value_ref->* TO FIELD-SYMBOL(<lv_tdc_var_value>).
          CHECK <lv_tdc_var_value> IS ASSIGNED.
          <lv_tdc_value> = <lv_tdc_var_value>.
          UNASSIGN: <lv_tdc_value>, <lv_tdc_var_value>.
        ENDLOOP.

        IF mt_sql_data IS NOT INITIAL.
          DATA(lt_sql_tables) = VALUE if_osql_test_environment=>ty_t_sobjnames( FOR <s_sql_test_data> IN mt_sql_data
                                                                                ( <s_sql_test_data>-tbl_name ) ).
          mo_sql = cl_osql_test_environment=>create( lt_sql_tables ).
        ENDIF.

      CATCH cx_ecatt_tdc_access INTO DATA(lx_error).
        CHECK iv_ign_errors EQ abap_false.
        RAISE EXCEPTION lx_error.

    ENDTRY.

  ENDMETHOD.


  METHOD on_class_setup.

    IF mo_instance IS NOT BOUND.
      mo_instance = NEW #( iv_ign_errors = iv_ign_errors
                           iv_tdc_cnt    = iv_tdc_cnt
                           ir_tdc_data   = ir_tdc_data
                           it_sql_data   = it_sql_data ).
    ENDIF.
    ro_instance = mo_instance.

  ENDMETHOD.


  METHOD on_setup.

    FIELD-SYMBOLS <lt_tbl_data> TYPE ANY TABLE.

    IF mo_sql IS BOUND.
      LOOP AT mt_sql_data ASSIGNING FIELD-SYMBOL(<ls_sql_test_data>).
        ASSIGN <ls_sql_test_data>-tbl_data->* TO <lt_tbl_data>.
        CHECK <lt_tbl_data> IS ASSIGNED.
        mo_sql->insert_test_data( <lt_tbl_data> ).
        UNASSIGN <lt_tbl_data>.
      ENDLOOP.
    ENDIF.

  ENDMETHOD.


  METHOD on_teardown.

    IF mo_sql IS BOUND.
      mo_sql->clear_doubles( ).
    ENDIF.

  ENDMETHOD.


  METHOD on_class_teardown.

    IF mo_sql IS BOUND.
      mo_sql->destroy( ).
    ENDIF.

  ENDMETHOD.


  METHOD active.

    rv_result = iv_active.

  ENDMETHOD.

ENDCLASS.
