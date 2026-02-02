*&---------------------------------------------------------------------*
*& Include zial_report_generator_tmpl_sel
*&---------------------------------------------------------------------*
" Data Selection
SELECTION-SCREEN BEGIN OF BLOCK b01 WITH FRAME TITLE TEXT-b01.
  SELECT-OPTIONS: devclass FOR gs_sel-devclass.
SELECTION-SCREEN END OF BLOCK b01.

SELECTION-SCREEN BEGIN OF BLOCK ctrl WITH FRAME TITLE TEXT-bct.
  PARAMETERS simulate TYPE abap_bool AS CHECKBOX DEFAULT abap_true.
SELECTION-SCREEN END OF BLOCK ctrl.
