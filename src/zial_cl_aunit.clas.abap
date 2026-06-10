"! <p class="shorttext synchronized">ABAP Unit Test: {@link CL_ABAP_UNIT_ASSERT}</p>
CLASS zial_cl_aunit DEFINITION
  PUBLIC FINAL
  CREATE PROTECTED
  FOR TESTING.

  PUBLIC SECTION.
    INTERFACES zial_if_class_descr.

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

    METHODS is_active
      IMPORTING iv_is_active     TYPE abap_bool
      RETURNING VALUE(rv_result) TYPE abap_bool.

    METHODS set_sql_data
      IMPORTING it_sql_data TYPE zial_tt_aunit_sql_test_data.

  PROTECTED SECTION.
    CLASS-DATA mo_instance TYPE REF TO zial_cl_aunit.

    CONSTANTS mc_tdc_dflt_var_name TYPE etvar_id VALUE 'ECATTDEFAULT'.

    DATA mv_tdc_cnt      TYPE etobj_name.
    DATA mr_tdc_data     TYPE REF TO data.
    DATA mo_tdc          TYPE REF TO cl_apl_ecatt_tdc_api.
    DATA mv_tdc_var_name TYPE etvar_id.

    DATA mo_sql          TYPE REF TO if_osql_test_environment.
    DATA mt_sql_data     TYPE zial_tt_aunit_sql_test_data.

    CLASS-METHODS create
      IMPORTING iv_ign_errors      TYPE abap_bool
                iv_tdc_cnt         TYPE etobj_name
                ir_tdc_data        TYPE REF TO data
                it_sql_data        TYPE zial_tt_aunit_sql_test_data
      RETURNING VALUE(ro_instance) TYPE REF TO zial_cl_aunit
      RAISING   cx_ecatt_tdc_access.

    METHODS register_sql_data
      IMPORTING it_sql_data TYPE zial_tt_aunit_sql_test_data.

ENDCLASS.


CLASS zial_cl_aunit IMPLEMENTATION.

  METHOD create.

    ro_instance = NEW zial_cl_aunit( ).

    ro_instance->mv_tdc_cnt  = iv_tdc_cnt.
    ro_instance->mr_tdc_data = ir_tdc_data.

    ASSIGN ro_instance->mr_tdc_data->* TO FIELD-SYMBOL(<ls_tdc_data>).
    IF <ls_tdc_data> IS NOT ASSIGNED.
      RETURN.
    ENDIF.

    TRY.
        ro_instance->mo_tdc          = cl_apl_ecatt_tdc_api=>get_instance( ro_instance->mv_tdc_cnt ).
        ro_instance->mv_tdc_var_name = |{ sy-sysid }{ sy-mandt }|.
        DATA(lt_tdc_var) = ro_instance->mo_tdc->get_variant_list( ).
        IF NOT line_exists( lt_tdc_var[ table_line = ro_instance->mv_tdc_var_name ] ).
          ro_instance->mv_tdc_var_name = mc_tdc_dflt_var_name.
        ENDIF.

        LOOP AT ro_instance->mo_tdc->get_variant_content( ro_instance->mv_tdc_var_name ) ASSIGNING FIELD-SYMBOL(<ls_tdc_var_content>).
          ASSIGN COMPONENT <ls_tdc_var_content>-parname OF STRUCTURE <ls_tdc_data> TO FIELD-SYMBOL(<lv_tdc_value>).
          IF <lv_tdc_value> IS NOT ASSIGNED.
            CONTINUE.
          ENDIF.
          ASSIGN <ls_tdc_var_content>-value_ref->* TO FIELD-SYMBOL(<lv_tdc_var_value>).
          IF <lv_tdc_var_value> IS NOT ASSIGNED.
            CONTINUE.
          ENDIF.
          <lv_tdc_value> = <lv_tdc_var_value>.
          UNASSIGN: <lv_tdc_value>, <lv_tdc_var_value>.
        ENDLOOP.

        ro_instance->register_sql_data( it_sql_data ).

      CATCH cx_ecatt_tdc_access INTO DATA(lx_error).
        IF iv_ign_errors NE abap_false.
          RETURN.
        ENDIF.
        RAISE EXCEPTION lx_error.

    ENDTRY.

  ENDMETHOD.


  METHOD set_sql_data.

    FIELD-SYMBOLS <lt_tbl_data> TYPE ANY TABLE.

    register_sql_data( it_sql_data ).
    IF mo_sql IS NOT BOUND.
      RETURN.
    ENDIF.

    mo_sql->clear_doubles( ).

    LOOP AT mt_sql_data ASSIGNING FIELD-SYMBOL(<ls_sql_test_data>).
      ASSIGN <ls_sql_test_data>-tbl_data->* TO <lt_tbl_data>.
      IF <lt_tbl_data> IS NOT ASSIGNED.
        CONTINUE.
      ENDIF.
      mo_sql->insert_test_data( <lt_tbl_data> ).
      UNASSIGN <lt_tbl_data>.
    ENDLOOP.

  ENDMETHOD.


  METHOD register_sql_data.

    mt_sql_data = it_sql_data.

    IF mo_sql IS BOUND.
      RETURN.
    ENDIF.

    IF mt_sql_data IS NOT INITIAL.
      DATA(lt_sql_tables) = VALUE if_osql_test_environment=>ty_t_sobjnames( FOR <s_sql_test_data> IN mt_sql_data
                                                                            ( <s_sql_test_data>-tbl_name ) ).
      mo_sql = cl_osql_test_environment=>create( lt_sql_tables ).
    ENDIF.

  ENDMETHOD.


  METHOD on_class_setup.

    IF mo_instance IS NOT BOUND.
      mo_instance = create( iv_ign_errors = iv_ign_errors
                            iv_tdc_cnt    = iv_tdc_cnt
                            ir_tdc_data   = ir_tdc_data
                            it_sql_data   = it_sql_data ).
    ENDIF.
    ro_instance = mo_instance.

  ENDMETHOD.


  METHOD on_setup.

    set_sql_data( mt_sql_data ).

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


  METHOD is_active.

    rv_result = iv_is_active.

  ENDMETHOD.


  METHOD zial_if_class_descr~get_own_class_name.

    rv_class_name = zial_cl_clas=>get_name_by_object( NEW zial_cl_aunit( ) ).

  ENDMETHOD.


  METHOD zial_if_class_descr~implements_method.

    rv_result = zial_cl_clas=>implements_method_by_object( io_object      = NEW zial_cl_aunit( )
                                                           iv_method_name = iv_method_name ).

  ENDMETHOD.

ENDCLASS.
