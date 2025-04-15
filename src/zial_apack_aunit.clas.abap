"! <p class="shorttext synchronized">Metadata: ABAP Unit Test</p>
CLASS zial_apack_aunit DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES if_apack_manifest.

    METHODS constructor.

ENDCLASS.


CLASS zial_apack_aunit IMPLEMENTATION.

  METHOD constructor.

    if_apack_manifest~descriptor-group_id     = 'c-a-s.de'.
    if_apack_manifest~descriptor-artifact_id  = 'aunit'.
    if_apack_manifest~descriptor-version      = '12.12.2024.001-rc'.
    if_apack_manifest~descriptor-git_url      = 'https://github.com/mraht-ewm-standard/AUNIT.git' ##NO_TEXT.

    if_apack_manifest~descriptor-dependencies = VALUE #( ) ##NO_TEXT.

  ENDMETHOD.

ENDCLASS.
