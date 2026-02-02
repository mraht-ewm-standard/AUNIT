*&---------------------------------------------------------------------*
*& Include zial_report_generator_tmpl_def
*&---------------------------------------------------------------------*
CLASS lcl_exits DEFINITION FINAL.

  PUBLIC SECTION.
    INTERFACES zial_if_report_generator_exit.

    ALIASES on_initialization      FOR zial_if_report_generator_exit~on_initialization.
    ALIASES on_set_ucomm_execute   FOR zial_if_report_generator_exit~on_set_ucomm_execute.
    ALIASES on_set_selopt_restrict FOR zial_if_report_generator_exit~on_set_selopt_restrict.
    ALIASES on_selscreen_pbo       FOR zial_if_report_generator_exit~on_selscreen_pbo.
    ALIASES on_selscreen_pai       FOR zial_if_report_generator_exit~on_selscreen_pai.
    ALIASES on_start_of_sel        FOR zial_if_report_generator_exit~on_start_of_sel.
    ALIASES on_salv_hotspot        FOR zial_if_report_generator_exit~on_salv_hotspot.
    ALIASES on_salv_ucomm          FOR zial_if_report_generator_exit~on_salv_ucomm.
    ALIASES on_salv_double_click   FOR zial_if_report_generator_exit~on_salv_double_click.
    ALIASES on_prepare_output      FOR zial_if_report_generator_exit~on_prepare_output.

ENDCLASS.
