CLASS zcl_ai_connector DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_message,
             role    TYPE string,
             content TYPE string,
           END OF ty_message,
           tt_messages TYPE STANDARD TABLE OF ty_message WITH DEFAULT KEY.

    METHODS constructor
      IMPORTING
        iv_api_key  TYPE string
        iv_endpoint TYPE string.

    METHODS ask_llm
      IMPORTING
        iv_prompt        TYPE string
      RETURNING
        VALUE(rv_answer) TYPE string
      RAISING
        cx_static_check.

  PROTECTED SECTION.
  PRIVATE SECTION.
    DATA: mv_api_key  TYPE string,
          mv_endpoint TYPE string.

    METHODS create_payload
      IMPORTING
        iv_prompt         TYPE string
      RETURNING
        VALUE(rv_payload) TYPE string.
ENDCLASS.

CLASS zcl_ai_connector IMPLEMENTATION.

  METHOD constructor.
    me->mv_api_key  = iv_api_key.
    me->mv_endpoint = iv_endpoint.
  ENDMETHOD.

  METHOD ask_llm.
    DATA: lo_http_client TYPE REF TO if_http_client,
          lv_json_body   TYPE string,
          lv_response    TYPE string.

    " 1. Create HTTP Client
    cl_http_client=>create_by_url(
      EXPORTING
        url    = me->mv_endpoint
      IMPORTING
        client = lo_http_client
      EXCEPTIONS
        OTHERS = 1 ).

    IF sy-subrc <> 0.
      RAISE EXCEPTION TYPE cx_sy_create_object_error.
    ENDIF.

    " 2. Set Request Headers
    lo_http_client->request->set_method( if_http_request=>co_request_method_post ).
    lo_http_client->request->set_header_field( name  = 'Content-Type'
                                               value = 'application/json' ).
    lo_http_client->request->set_header_field( name  = 'Authorization'
                                               value = |Bearer { me->mv_api_key }| ).

    " 3. Prepare Payload
    lv_json_body = me->create_payload( iv_prompt ).

    lo_http_client->request->set_cdata( lv_json_body ).

    " 4. Send and Receive
    lo_http_client->send( EXCEPTIONS OTHERS = 1 ).
    lo_http_client->receive( EXCEPTIONS OTHERS = 1 ).

    " 5. Get Response Data
    lv_response = lo_http_client->response->get_cdata( ).
    lo_http_client->close( ).

    " Simple return of response (In real life, parse with /ui2/cl_json)
    rv_answer = lv_response.
  ENDMETHOD.

  METHOD create_payload.
    " Dynamic JSON generation for standard OpenAI / HuggingFace chat format
    rv_payload = |\{ "model": "mistralai/Mistral-7B-Instruct-v0.2", | &&
                 |  "messages": [\{ "role": "user", "content": "{ iv_prompt }" \}], | &&
                 |  "max_tokens": 500 \}|.
  ENDMETHOD.

ENDCLASS.
