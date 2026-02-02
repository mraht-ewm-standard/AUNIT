*&---------------------------------------------------------------------*
*& Report zial_r_report_generator_tmpl
*&---------------------------------------------------------------------*
*& Report                : ZIAL_R_AUNIT_CONTROL
*& Author                : DEVELOPER (John Doe)
*& Title                 : ABAP Unit Tests: Control
*& Function              :
*& Creation date         : 28.01.2026
*&---------------------------------------------------------------------*
REPORT zial_r_aunit_control.

INCLUDE zial_r_aunit_control_top. " Data Definition
INCLUDE zial_r_aunit_control_def. " Local Class Definition

INCLUDE zial_report_generator_ctrl_def. " Central control: Local Class Definition
INCLUDE zial_report_generator_ctrl_top. " Central control: Data Definition
INCLUDE zial_report_generator_ctrl_evt. " Central control: Events
INCLUDE zial_report_generator_ctrl_cls. " Central control: Local class

INCLUDE zial_r_aunit_control_sel. " Selection Screen
INCLUDE zial_r_aunit_control_cls. " Local Class

INITIALIZATION.
  go_report_control = NEW lcl_report_control( ).
  go_report_control->on_initialization( ).

AT SELECTION-SCREEN OUTPUT.
  go_report_control->at_selection_screen_output( ).

AT SELECTION-SCREEN.
  go_report_control->at_selection_screen( ).

START-OF-SELECTION.
  go_report_control->at_start_of_selection( ).

END-OF-SELECTION.
  go_report_control->at_end_of_selection( ).
