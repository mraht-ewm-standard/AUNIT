*&---------------------------------------------------------------------*
*& Include zial_report_generator_tmpl_top
*&---------------------------------------------------------------------*

##TODO. " Define custom screen elements
TYPES: BEGIN OF s_sel_screen,
         devclass TYPE devclass,
       END OF s_sel_screen.

TYPES: BEGIN OF s_tests,
         name      TYPE seomtdname,
         incl      TYPE string,
         line      TYPE i,
         is_active TYPE abap_bool,
       END OF s_tests,
       t_tests TYPE STANDARD TABLE OF s_tests WITH EMPTY KEY.

##TODO. " Define custom output elements
TYPES: BEGIN OF s_alv_output,
         devclass  TYPE devclass,
         obj_name  TYPE seoclname,
         tests     TYPE t_tests,
         btn_tests TYPE icon_d,
         btn_exec  TYPE icon_d,
       END OF s_alv_output.

CONSTANTS: BEGIN OF gc_alv_fname,
             btn_tests TYPE lvc_fname VALUE 'BTN_TESTS',
             btn_exec  TYPE lvc_fname VALUE 'BTN_EXEC',
           END OF gc_alv_fname.

##TODO. " Define custom function codes
CONSTANTS: BEGIN OF gc_fcodes,
             exec TYPE syucomm VALUE 'EXEC',
           END OF gc_fcodes.
