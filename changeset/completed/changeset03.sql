
-- Create document backup table on the backup database
CREATE TABLE document.document_backup
(
  id character varying(40),
  nr character varying(15),
  extension character varying(5),
  body bytea,
  description character varying(100),
  rowidentifier character varying(40),
  rowversion integer,
  change_action character(1),
  change_user character varying(50),
  change_time timestamp without time zone,
  CONSTRAINT document_backup_pkey PRIMARY KEY (id )
)
WITH (
  OIDS=FALSE
);
ALTER TABLE document.document_backup
  OWNER TO postgres;
COMMENT ON TABLE document.document_backup
  IS 'Used for managing backups of the sola documents table';