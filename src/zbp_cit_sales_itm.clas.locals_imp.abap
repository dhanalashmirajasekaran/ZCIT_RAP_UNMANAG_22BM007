CLASS lhc_SalesOrderItm DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    METHODS update FOR MODIFY IMPORTING entities FOR UPDATE SalesOrderItm.
    METHODS delete FOR MODIFY IMPORTING keys FOR DELETE SalesOrderItm.
    METHODS read FOR READ IMPORTING keys FOR READ SalesOrderItm RESULT result.
ENDCLASS.

CLASS lhc_SalesOrderItm IMPLEMENTATION.
  METHOD update.
    DATA: ls_sales_itm TYPE zmk_item_tb. " Using your updated table name
    LOOP AT entities INTO DATA(ls_entities).
      ls_sales_itm = CORRESPONDING #( ls_entities MAPPING FROM ENTITY ).

      " Using your utility class: zcl_cit_util_umgi
      DATA(lo_util) = zcl_cit_util_umgi=>get_instance( ).
      lo_util->set_itm_value( EXPORTING im_sales_itm = ls_sales_itm
                              IMPORTING ex_created = DATA(lv_created) ).

      IF lv_created EQ abap_true.
        APPEND VALUE #( salesdocument = ls_sales_itm-salesdocument
                        salesitemnumber = ls_sales_itm-salesitemnumber ) TO mapped-salesorderitm.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD delete.
    DATA(lo_util) = zcl_cit_util_umgi=>get_instance( ).
    LOOP AT keys INTO DATA(ls_key).
      " Using your specific utility method for items to store deletion info in buffer
      lo_util->set_itm_t_deletion( EXPORTING im_sales_itm_info = VALUE #( salesdocument = ls_key-salesdocument
                                                                         salesitemnumber = ls_key-salesitemnumber ) ).
    ENDLOOP.
  ENDMETHOD.

  METHOD read.
    LOOP AT keys INTO DATA(ls_key).
      SELECT SINGLE FROM zmk_item_tb FIELDS *
        WHERE salesdocument = @ls_key-salesdocument
          AND salesitemnumber = @ls_key-salesitemnumber
        INTO @DATA(ls_itm).

      IF sy-subrc = 0.
        APPEND CORRESPONDING #( ls_itm ) TO result.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
