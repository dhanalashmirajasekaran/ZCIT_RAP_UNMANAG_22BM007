CLASS lhc_SalesOrderHdr DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR SalesOrderHdr RESULT result.
    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR SalesOrderHdr RESULT result.
    METHODS create FOR MODIFY IMPORTING entities FOR CREATE SalesOrderHdr.
    METHODS update FOR MODIFY IMPORTING entities FOR UPDATE SalesOrderHdr.
    METHODS delete FOR MODIFY IMPORTING keys FOR DELETE SalesOrderHdr.
    METHODS read FOR READ IMPORTING keys FOR READ SalesOrderHdr RESULT result.
    METHODS lock FOR LOCK IMPORTING keys FOR LOCK SalesOrderHdr.
    METHODS rba_Salesitem FOR READ IMPORTING keys_rba FOR READ SalesOrderHdr\_Salesitem FULL result_requested RESULT result LINK association_links.
    METHODS cba_Salesitem FOR MODIFY IMPORTING entities_cba FOR CREATE SalesOrderHdr\_Salesitem.
ENDCLASS.

CLASS lhc_SalesOrderHdr IMPLEMENTATION.
  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD get_global_authorizations.
  ENDMETHOD.

  METHOD lock.
  ENDMETHOD.

  METHOD create.
    DATA: ls_sales_hdr TYPE zmk_header_tb.
    LOOP AT entities INTO DATA(ls_entities).
      ls_sales_hdr = CORRESPONDING #( ls_entities MAPPING FROM ENTITY ).
      IF ls_sales_hdr-salesdocument IS NOT INITIAL.
        SELECT FROM zmk_header_tb FIELDS *
          WHERE salesdocument = @ls_sales_hdr-salesdocument
          INTO TABLE @DATA(lt_sales_hdr).

        IF sy-subrc NE 0.
          " Using your Utility Class: zcl_cit_util_umgi
          DATA(lo_util) = zcl_cit_util_umgi=>get_instance( ).
          lo_util->set_hdr_value( EXPORTING im_sales_hdr = ls_sales_hdr
                                  IMPORTING ex_created = DATA(lv_created) ).
          IF lv_created EQ abap_true.
            APPEND VALUE #( %cid = ls_entities-%cid salesdocument = ls_sales_hdr-salesdocument ) TO mapped-salesorderhdr.
          ENDIF.
        ELSE.
          APPEND VALUE #( %cid = ls_entities-%cid salesdocument = ls_sales_hdr-salesdocument ) TO failed-salesorderhdr.
        ENDIF.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD update.
    DATA: ls_sales_hdr TYPE zmk_header_tb.
    LOOP AT entities INTO DATA(ls_entities).
      ls_sales_hdr = CORRESPONDING #( ls_entities MAPPING FROM ENTITY ).
      IF ls_sales_hdr-salesdocument IS NOT INITIAL.
        SELECT FROM zmk_header_tb FIELDS *
          WHERE salesdocument = @ls_sales_hdr-salesdocument
          INTO TABLE @DATA(lt_sales_hdr).

        IF sy-subrc EQ 0.
          DATA(lo_util) = zcl_cit_util_umgi=>get_instance( ).
          lo_util->set_hdr_value( EXPORTING im_sales_hdr = ls_sales_hdr
                                  IMPORTING ex_created = DATA(lv_created) ).
          IF lv_created EQ abap_true.
            APPEND VALUE #( salesdocument = ls_sales_hdr-salesdocument ) TO mapped-salesorderhdr.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD delete.
    DATA(lo_util) = zcl_cit_util_umgi=>get_instance( ).
    LOOP AT keys INTO DATA(ls_key).
      lo_util->set_hdr_t_deletion( EXPORTING im_sales_doc = VALUE #( salesdocument = ls_key-salesdocument ) ).
      lo_util->set_hdr_deletion_flag( EXPORTING im_so_delete = abap_true ).
    ENDLOOP.
  ENDMETHOD.

  METHOD read.
    LOOP AT keys INTO DATA(ls_key).
      SELECT SINGLE FROM zmk_header_tb FIELDS *
        WHERE salesdocument = @ls_key-salesdocument
        INTO @DATA(ls_hdr).
      IF sy-subrc = 0.
        APPEND CORRESPONDING #( ls_hdr ) TO result.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD rba_Salesitem.
    LOOP AT keys_rba INTO DATA(ls_key).
      SELECT FROM zmk_item_tb FIELDS *
        WHERE salesdocument = @ls_key-salesdocument
        INTO TABLE @DATA(lt_items).

      LOOP AT lt_items INTO DATA(ls_item).
        APPEND CORRESPONDING #( ls_item ) TO result.
        APPEND VALUE #( source-salesdocument = ls_key-salesdocument
                        target-salesdocument = ls_item-salesdocument
                        target-salesitemnumber = ls_item-salesitemnumber ) TO association_links.
      ENDLOOP.
    ENDLOOP.
  ENDMETHOD.

  METHOD cba_Salesitem.
    DATA ls_sales_itm TYPE zmk_item_tb.
    LOOP AT entities_cba INTO DATA(ls_entities_cba).
      LOOP AT ls_entities_cba-%target INTO DATA(ls_target).
        ls_sales_itm = CORRESPONDING #( ls_target ).
        DATA(lo_util) = zcl_cit_util_umgi=>get_instance( ).
        lo_util->set_itm_value( EXPORTING im_sales_itm = ls_sales_itm
                                IMPORTING ex_created = DATA(lv_created) ).
        IF lv_created EQ abap_true.
           APPEND VALUE #( %cid = ls_target-%cid
                           salesdocument = ls_target-salesdocument
                           salesitemnumber = ls_target-salesitemnumber ) TO mapped-salesorderitm.
        ENDIF.
      ENDLOOP.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
