# ⚡ ABAP-AI-Connector

A modern, object-oriented ABAP library designed to bridge **SAP NetWeaver / S/4HANA** systems with modern Large Language Models (LLMs) like **Hugging Face, OpenAI, and DeepSeek** via REST APIs.

## 🚀 Features
- **Pure OO-ABAP:** Built with Clean ABAP principles.
- **Generic Architecture:** Works with any OpenAI-compatible or Hugging Face Inference API.
- **Zero Third-Party Dependency:** Uses native SAP `CL_HTTP_CLIENT` and `/UI2/CL_JSON`.

## 📦 How to Use

```abap
DATA: lo_ai     TYPE REF TO zcl_ai_connector,
      lv_answer TYPE string.

" Initialize the connector with API Endpoint and Bearer Token
lo_ai = NEW zcl_ai_connector(
  iv_api_key  = 'YOUR_API_KEY'
  iv_endpoint = 'https://api.together.xyz/v1/chat/completions'
).

TRY.
    " Send prompt and get LLM response directly into ABAP
    lv_answer = lo_ai->ask_llm( 'Summarize the financial risk of high aging debts.' ).
    WRITE: / lv_answer.
  CATCH cx_root INTO DATA(lx_err).
    WRITE: / lx_err->get_text( ).
ENDTRY.
