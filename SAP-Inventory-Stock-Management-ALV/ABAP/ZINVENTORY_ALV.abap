REPORT zinventory_alv.

*---------------------------------------------------------------------*
* Type Declaration
*---------------------------------------------------------------------*
TYPES: BEGIN OF ty_stock,

         mat_id       TYPE zinv_material-mat_id,
         mat_name     TYPE zinv_material-mat_name,
         mat_type     TYPE zinv_material-mat_type,
         unit         TYPE zinv_material-unit,
         price        TYPE zinv_material-price,

         plant        TYPE zinv_stock-plant,
         storage_loc  TYPE zinv_stock-storage_loc,
         stock_qty    TYPE zinv_stock-stock_qty,
         min_stock    TYPE zinv_stock-min_stock,
         stock_date   TYPE zinv_stock-stock_date,

         stock_value  TYPE p LENGTH 13 DECIMALS 2,
         status       TYPE char20,

       END OF ty_stock.

*---------------------------------------------------------------------*
* Internal Table and Work Area
*---------------------------------------------------------------------*
DATA: it_stock TYPE TABLE OF ty_stock,
      wa_stock TYPE ty_stock.

*---------------------------------------------------------------------*
* ALV Field Catalog
*---------------------------------------------------------------------*
DATA: it_fieldcat TYPE slis_t_fieldcat_alv,
      wa_fieldcat TYPE slis_fieldcat_alv.

*---------------------------------------------------------------------*
* ALV Layout
*---------------------------------------------------------------------*
DATA: wa_layout TYPE slis_layout_alv.

*---------------------------------------------------------------------*
* Selection Screen
*---------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE text-001.

SELECT-OPTIONS:
  s_matid FOR wa_stock-mat_id,
  s_plant FOR wa_stock-plant,
  s_sloc  FOR wa_stock-storage_loc.

SELECTION-SCREEN END OF BLOCK b1.

*---------------------------------------------------------------------*
* Start of Selection
*---------------------------------------------------------------------*
START-OF-SELECTION.

  PERFORM get_data.

  IF it_stock IS INITIAL.

    MESSAGE 'No inventory data found' TYPE 'I'.

  ELSE.

    PERFORM calculate_data.
    PERFORM build_fieldcatalog.
    PERFORM display_alv.

  ENDIF.

*---------------------------------------------------------------------*
* Get Data
*---------------------------------------------------------------------*
FORM get_data.

  SELECT
    m~mat_id,
    m~mat_name,
    m~mat_type,
    m~unit,
    m~price,
    s~plant,
    s~storage_loc,
    s~stock_qty,
    s~min_stock,
    s~stock_date

    FROM zinv_material AS m
    INNER JOIN zinv_stock AS s
      ON m~mat_id = s~mat_id

    WHERE m~mat_id      IN @s_matid
      AND s~plant       IN @s_plant
      AND s~storage_loc IN @s_sloc

    INTO CORRESPONDING FIELDS OF TABLE @it_stock.

ENDFORM.

*---------------------------------------------------------------------*
* Calculate Stock Value and Stock Status
*---------------------------------------------------------------------*
FORM calculate_data.

  LOOP AT it_stock INTO wa_stock.

    "Calculate stock value
    wa_stock-stock_value =
      wa_stock-stock_qty * wa_stock-price.

    "Determine stock status
    IF wa_stock-stock_qty = 0.

      wa_stock-status = 'Out of Stock'.

    ELSEIF wa_stock-stock_qty < wa_stock-min_stock.

      wa_stock-status = 'Low Stock'.

    ELSE.

      wa_stock-status = 'Available'.

    ENDIF.

    MODIFY it_stock FROM wa_stock.

  ENDLOOP.

ENDFORM.

*---------------------------------------------------------------------*
* Build ALV Field Catalog
*---------------------------------------------------------------------*
FORM build_fieldcatalog.

  CLEAR wa_fieldcat.
  wa_fieldcat-fieldname = 'MAT_ID'.
  wa_fieldcat-seltext_m = 'Material ID'.
  wa_fieldcat-col_pos   = 1.
  APPEND wa_fieldcat TO it_fieldcat.

  CLEAR wa_fieldcat.
  wa_fieldcat-fieldname = 'MAT_NAME'.
  wa_fieldcat-seltext_m = 'Material Name'.
  wa_fieldcat-col_pos   = 2.
  APPEND wa_fieldcat TO it_fieldcat.

  CLEAR wa_fieldcat.
  wa_fieldcat-fieldname = 'MAT_TYPE'.
  wa_fieldcat-seltext_m = 'Material Type'.
  wa_fieldcat-col_pos   = 3.
  APPEND wa_fieldcat TO it_fieldcat.

  CLEAR wa_fieldcat.
  wa_fieldcat-fieldname = 'UNIT'.
  wa_fieldcat-seltext_m = 'Unit'.
  wa_fieldcat-col_pos   = 4.
  APPEND wa_fieldcat TO it_fieldcat.

  CLEAR wa_fieldcat.
  wa_fieldcat-fieldname = 'PRICE'.
  wa_fieldcat-seltext_m = 'Price'.
  wa_fieldcat-col_pos   = 5.
  APPEND wa_fieldcat TO it_fieldcat.

  CLEAR wa_fieldcat.
  wa_fieldcat-fieldname = 'PLANT'.
  wa_fieldcat-seltext_m = 'Plant'.
  wa_fieldcat-col_pos   = 6.
  APPEND wa_fieldcat TO it_fieldcat.

  CLEAR wa_fieldcat.
  wa_fieldcat-fieldname = 'STORAGE_LOC'.
  wa_fieldcat-seltext_m = 'Storage Location'.
  wa_fieldcat-col_pos   = 7.
  APPEND wa_fieldcat TO it_fieldcat.

  CLEAR wa_fieldcat.
  wa_fieldcat-fieldname = 'STOCK_QTY'.
  wa_fieldcat-seltext_m = 'Stock Quantity'.
  wa_fieldcat-col_pos   = 8.
  wa_fieldcat-do_sum    = 'X'.
  APPEND wa_fieldcat TO it_fieldcat.

  CLEAR wa_fieldcat.
  wa_fieldcat-fieldname = 'MIN_STOCK'.
  wa_fieldcat-seltext_m = 'Minimum Stock'.
  wa_fieldcat-col_pos   = 9.
  APPEND wa_fieldcat TO it_fieldcat.

  CLEAR wa_fieldcat.
  wa_fieldcat-fieldname = 'STOCK_DATE'.
  wa_fieldcat-seltext_m = 'Stock Date'.
  wa_fieldcat-col_pos   = 10.
  APPEND wa_fieldcat TO it_fieldcat.

  CLEAR wa_fieldcat.
  wa_fieldcat-fieldname = 'STOCK_VALUE'.
  wa_fieldcat-seltext_m = 'Stock Value'.
  wa_fieldcat-col_pos   = 11.
  wa_fieldcat-do_sum    = 'X'.
  APPEND wa_fieldcat TO it_fieldcat.

  CLEAR wa_fieldcat.
  wa_fieldcat-fieldname = 'STATUS'.
  wa_fieldcat-seltext_m = 'Stock Status'.
  wa_fieldcat-col_pos   = 12.
  APPEND wa_fieldcat TO it_fieldcat.

ENDFORM.

*---------------------------------------------------------------------*
* Display ALV
*---------------------------------------------------------------------*
FORM display_alv.

  wa_layout-zebra             = 'X'.
  wa_layout-colwidth_optimize = 'X'.

  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      i_callback_program      = sy-repid
      i_callback_user_command = 'USER_COMMAND'
      is_layout               = wa_layout
      it_fieldcat             = it_fieldcat
      i_save                  = 'A'
    TABLES
      t_outtab                = it_stock
    EXCEPTIONS
      program_error           = 1
      OTHERS                  = 2.

  IF sy-subrc <> 0.

    MESSAGE 'Error while displaying ALV' TYPE 'I'.

  ENDIF.

ENDFORM.

*---------------------------------------------------------------------*
* Double Click Functionality
*---------------------------------------------------------------------*
FORM user_command USING
      r_ucomm     LIKE sy-ucomm
      rs_selfield TYPE slis_selfield.

  DATA: wa_selected TYPE ty_stock.

  IF r_ucomm = '&IC1'.

    IF rs_selfield-fieldname = 'MAT_ID'.

      READ TABLE it_stock INTO wa_selected
        INDEX rs_selfield-tabindex.

      IF sy-subrc = 0.

        MESSAGE |Material: { wa_selected-mat_id } - { wa_selected-mat_name }|
          TYPE 'I'.

      ENDIF.

    ENDIF.

  ENDIF.

ENDFORM.