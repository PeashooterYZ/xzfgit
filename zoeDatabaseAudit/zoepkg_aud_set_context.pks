CREATE OR REPLACE PACKAGE ZOESECURITY.ZOEPKG_AUD_SET_CONTEXT AS
   PROCEDURE SET_AUD_CONTEXT(iv_name IN VARCHAR2,iv_value IN VARCHAR2);
END ZOEPKG_AUD_SET_CONTEXT;
/
