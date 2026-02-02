*&---------------------------------------------------------------------*
*& Include zial_report_generator_tmpl_cls
*&---------------------------------------------------------------------*
CLASS lcl_exits IMPLEMENTATION.

  METHOD on_initialization.

    gv_alv_display_mode = lcl_report_control=>mc_alv_display_mode-sel_output.

  ENDMETHOD.


  METHOD on_set_ucomm_execute.
  ENDMETHOD.


  METHOD on_set_selopt_restrict.
  ENDMETHOD.


  METHOD on_selscreen_pbo.

    CONSTANTS mc_aunit_clas_name TYPE seoclname  VALUE 'ZIAL_CL_AUNIT'.
    CONSTANTS mc_aunit_meth_name TYPE seomtdname VALUE 'IS_ACTIVE'.

    DATA(lt_object_name) = VALUE rinfoobj( ( object = mc_aunit_meth_name encl_obj = mc_aunit_clas_name ) ).
    DATA(lt_object_type) = VALUE zial_tt_dev_obj_type( ( zial_cl_dev_obj=>mc_eu_obj_type-clas ) ).
    DATA(lt_where_used) = zial_cl_dev_obj=>det_where_used( iv_object_class = zial_cl_dev_obj=>mc_eu_obj_type-meth
                                                           it_object_name  = lt_object_name
                                                           it_object_type  = lt_object_type ).
    SELECT
      FROM @lt_where_used AS devobj ##ITAB_KEY_IN_SELECT
           JOIN tadir     AS tadir  ON tadir~obj_name = devobj~encl_objec
      FIELDS devclass,
             devobj~encl_objec    AS obj_name,
             @icon_configuration  AS btn_tests,
             @icon_execute_object AS btn_exec
      ORDER BY devclass
      INTO CORRESPONDING FIELDS OF TABLE @gt_output.

    ##TODO. " Read method def. and impl. for each dev. obj.
    " check if controllable
    " add existing / remove non-existing

    LOOP AT lt_where_used ASSIGNING FIELD-SYMBOL(<s_where_used>)
         GROUP BY ( encl_obj = <s_where_used>-encl_objec ) ASSIGNING FIELD-SYMBOL(<lg_where_used>).

      ASSIGN gt_output[ obj_name = <lg_where_used>-encl_obj ] TO FIELD-SYMBOL(<ls_output>) ELSE UNASSIGN.
      CHECK <ls_output> IS ASSIGNED.

      DATA(lo_clas) = NEW zial_cl_clas( <ls_output>-obj_name ).
      lo_clas->read_source_code( IMPORTING et_tests = DATA(lt_source_code_tests) ).

      LOOP AT GROUP <lg_where_used> ASSIGNING FIELD-SYMBOL(<ls_where_used>).

        TRY.
            DATA(lo_compiler) = NEW cl_abap_compiler( p_name             = CONV #( <ls_where_used>-object )
                                                      p_no_package_check = 'X' ).
            lo_compiler->get_single_ref( EXPORTING  p_full_name = |\\TY:{ mc_aunit_clas_name }\\ME:{ mc_aunit_meth_name }|
                                                    p_grade     = 1
                                         IMPORTING  p_result    = DATA(lt_result) ##NEEDED
                                         EXCEPTIONS OTHERS      = 0 ).

          CATCH zcx_error.
            MESSAGE e016(zial_dev_basis) WITH <ls_where_used>-full_name INTO DATA(lv_msgtx) ##NEEDED.
            INSERT zial_cl_log=>to_bapiret( iv_msgid = sy-msgid
                                            iv_msgty = sy-msgty
                                            iv_msgno = sy-msgno
                                            iv_msgv1 = sy-msgv1
                                            iv_msgv2 = sy-msgv2
                                            iv_msgv3 = sy-msgv3
                                            iv_msgv4 = sy-msgv4 ) INTO TABLE gt_log.

        ENDTRY.

        LOOP AT lt_result ASSIGNING FIELD-SYMBOL(<ls_result>).

          INSERT VALUE #( incl = <ls_where_used>-object
                          line = <ls_result>-line ) INTO TABLE <ls_output>-tests ASSIGNING FIELD-SYMBOL(<ls_test>).

          DO <ls_result>-line TIMES.

            DATA(lv_index) = sy-index.
            ASSIGN lt_source_code_tests[ <ls_result>-line - lv_index ] TO FIELD-SYMBOL(<lv_source_code_line>) ELSE UNASSIGN.
            IF <lv_source_code_line> IS NOT ASSIGNED.
              EXIT.
            ENDIF.

            zial_cl_regex_search=>search( EXPORTING iv_pattern    = zial_cl_clas=>mc_regex-imp_method_name
                                                    iv_line       = <lv_source_code_line>
                                          IMPORTING et_submatches = DATA(lt_submatches) ).
            ASSIGN lt_submatches[ 1 ]-value TO FIELD-SYMBOL(<lv_method_name>) ELSE UNASSIGN.
            IF <lv_method_name> IS NOT ASSIGNED.
              CONTINUE.
            ENDIF.

            <ls_test>-name = <lv_method_name>.
            EXIT.

          ENDDO.

        ENDLOOP.

      ENDLOOP.

    ENDLOOP.

  ENDMETHOD.


  METHOD on_selscreen_pai.
  ENDMETHOD.


  METHOD on_start_of_sel.

    IF simulate EQ abap_false.
      COMMIT WORK.
    ENDIF.

  ENDMETHOD.


  METHOD on_salv_hotspot.

    CASE iv_column.
      WHEN gc_alv_fname-btn_exec.
        ##TODO. " Run all AUNIT tests of class

      WHEN gc_alv_fname-btn_tests.
        ##TODO. " Popup to display, switch tests on/off or execute them

    ENDCASE.

  ENDMETHOD.


  METHOD on_salv_ucomm.

    CASE iv_ucomm.
      WHEN lcl_report_control=>mc_fcode-log.
        zial_cl_log=>display_as_popup( it_bapiret = gt_log ).

      WHEN OTHERS.
    ENDCASE.

  ENDMETHOD.


  METHOD on_salv_double_click.
  ENDMETHOD.


  METHOD on_prepare_output.

    DATA lo_column TYPE REF TO cl_salv_column_table.

    TRY.
        DATA(lo_display_settings) = go_alv->get_display_settings( ).
        lo_display_settings->set_striped_pattern( if_salv_c_bool_sap=>false  ).

        DATA(ls_key) = go_report_control->get_salv_layout_key( ).
        DATA(lo_layout) = go_alv->get_layout( ).
        lo_layout->set_key( ls_key ).
        lo_layout->set_save_restriction( if_salv_c_layout=>restrict_none ).
        lo_layout->set_default( if_salv_c_bool_sap=>true ).

        DATA(lo_columns) = go_alv->get_columns( ).

        lo_column ?= lo_columns->get_column( gc_alv_fname-btn_exec ).
        lo_column->set_cell_type( if_salv_c_cell_type=>button ).
        lo_column->set_alignment( if_salv_c_alignment=>centered ).
        lo_column->set_short_text( TEXT-c02 ).
        lo_column->set_medium_text( TEXT-c02 ).
        lo_column->set_long_text( TEXT-c02 ).
        lo_column->set_tooltip( TEXT-t02 ).
        lo_column->set_output_length( 4 ).

        lo_column ?= lo_columns->get_column( gc_alv_fname-btn_tests ).
        lo_column->set_cell_type( if_salv_c_cell_type=>button ).
        lo_column->set_alignment( if_salv_c_alignment=>centered ).
        lo_column->set_short_text( TEXT-c03 ).
        lo_column->set_medium_text( TEXT-c03 ).
        lo_column->set_long_text( TEXT-c03 ).
        lo_column->set_tooltip( TEXT-t03 ).
        lo_column->set_output_length( 4 ).

        DATA(lo_selections) = go_alv->get_selections( ).
        lo_selections->set_selection_mode( if_salv_c_selection_mode=>cell ).

        IF gt_log IS INITIAL.
          DATA(lo_functions) = go_alv->get_functions( ).
          lo_functions->set_all( if_salv_c_bool_sap=>true ).
        ELSE.
          go_alv->set_screen_status( report        = sy-repid
                                     pfstatus      = 'SALV_STANDARD'
                                     set_functions = go_alv->c_functions_all ).
        ENDIF.

      CATCH cx_salv_not_found INTO DATA(lx_error).
        RAISE EXCEPTION NEW zcx_error( previous = lx_error ).

    ENDTRY.

  ENDMETHOD.

ENDCLASS.
