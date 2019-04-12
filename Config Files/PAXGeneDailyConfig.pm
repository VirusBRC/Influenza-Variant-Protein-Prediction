package flu::daily::PAXGeneDailyConfig;
use strict;
use Exporter;
use vars qw (@ISA @EXPORT_OK %configParams);
@ISA       = qw ( Exporter );
@EXPORT_OK = qw ( %configParams );

%configParams = (
  ###
  ### Basic Tool Properties (always present)
  ###
  debugSwitch        => 0,
  executionDirectory => '/home/idaily/influenza_daily',
  logInfix           => 'pax.gene.daily',
  workspaceRoot      => '/home/idaily/influenza_daily',
  ###
  ### Database Specifics (always present?)
  ###
  serverType   => 'OracleDB',
  databaseName => '',           ### like BRCSTAGE1
  userName     => 'dots',
  password     => 'dots#2',
  schemaOwner  => 'dots',
  ###
  ### PAX Gene Parameters
  ###
  className    => 'Genes::PAX',
  datasetName  => 'pax',
  discardFile  => 'workspaceRoot/pax_discard.dat',
  generate     => 1,
  load         => 1,
  useDelta     => 0,
  todayDayDate => '',                                ### YYYYMMDD ###
  clustalWPath =>
    '/home/idaily/loader/ext/clustalw-2.1-linux-x86_64-libcppstatic/clustalw2',
  deltaFile => '',

  segments      => [ '3', ],
  gb_accession  => 'CY034137',
  geneSpecifics => {
    symbol           => 'PA-X',
    native           => 'PA-Native',
    variants         => [ 'A', 'T', 'C', 'G', ],
    short_len        => 41,
    long_len         => 61,
    motif            => 'TTT',
    ref_motif_prefix => 'TCCTTT',
    ref_frameshift   => 'C',
    ref_motif_suffix => 'GTC',
    bad_frameshift   => { 'A' => 'A', 'G' => 'G', },
  },

  selectQuery => {
    maxElements     => 500,
    queryParamSubs  => { segments => 'varchar', },
    queryParams     => [],
    queryPredicates => {},
    queryResultsOrd =>
      [ 'na_sequence_id', 'gb_accession', 'gb_version', 'seq', 'org_genus', 'gb_gi', ],
    query => "
select /*+ parallel(4) */ n.na_sequence_id,
       n.string1,
       n.sequence_version,
       i.auto_aligned_sequence,
       i.org_genus,
       regexp_replace(n.string3, '.*Bio::PrimarySeq=HASH.*', '') string3
from   nasequenceimp       n,
       sequence_other_info i
where  n.obsolete_date  is null
and    n.string1 not like 'IRD%'
and    n.na_sequence_id  = i.na_sequence_id
and    i.org_family      = 'Orthomyxoviridae'
and    i.org_genus       = 'Influenzavirus A'
and    length(i.auto_aligned_sequence) > 1
and    (i.autocuration_segment  in (segments)
          or
        returnsegment(n.na_sequence_id) in (segments))
and    not exists
         (select /*+ parallel(4) */ 'x'
          from   stg_ird_flu_feature_annotation a
          where  a.na_sequence_id = n.na_sequence_id
          and    gene_symbol = 'PA-X')
",
  },

  referenceQuery => {
    maxElements     => 500,
    queryParamSubs  => { segments => 'varchar', },
    queryParams     => [ 'gb_accession', ],
    queryPredicates => {},
    queryResultsOrd =>
      [ 'na_sequence_id', 'gb_accession', 'gb_version', 'seq', 'org_genus', 'gb_gi', ],
    query => "
select n.na_sequence_id,
       n.string1,
       n.sequence_version,
       i.auto_aligned_sequence,
       i.org_genus,
       regexp_replace(n.string3, '.*Bio::PrimarySeq=HASH.*', '') string3
from   nasequenceimp       n,
       sequence_other_info i
where  n.obsolete_date  is null
and    n.na_sequence_id  = i.na_sequence_id
and    i.org_family      = 'Orthomyxoviridae'
and    i.org_genus       = 'Influenzavirus A'
and    n.string1         = ?
and    length(i.auto_aligned_sequence) > 1
and    (i.autocuration_segment  in (segments)
          or
        returnsegment(n.na_sequence_id) in (segments))
",
  },

  seqIdComp => 'annot_feat_seq_id',

  annotFeatSeqIdQuery => {
    name        => 'seq_id',
    queryParams => [],
    query       => "
select dots.stg_ird_flu_feat_annotation_sq.nextval
from   dual
",
  },

  annotationQuery => {
    name        => 'annotation_insert',
    queryParams => [ 'na_sequence_id', 'gb_accession', ],
    query       => "
DECLARE
  ANNOT_ERROR    EXCEPTION;
  na_sequence_id number       := ?;
  acc_num        varchar2(50) := ?;
  err_str        varchar2(4000);
BEGIN
  LOAD_FLU_FEATURE_ANNOT.LOAD_FLU_FEAT_ANNOT_MAIN(na_sequence_id, err_str);
  if length(err_str) > 0 then
    dbms_output.put_line('ORA-00000: ' || acc_num || ', ' || na_sequence_id || ', ' || err_str);
    raise ANNOT_ERROR;
  else
    dbms_output.put_line(acc_num || ', ' || na_sequence_id);
  end if;
EXCEPTION
  WHEN ANNOT_ERROR THEN
    raise_application_error(-20001, err_str);
  WHEN OTHERS THEN
    raise_application_error(-20001, sqlerrm);
END;
",
  },

  stgInsertQuery => {
    name        => 'stg_insert',
    queryParams => [
      'annot_feat_seq_id', 'na_sequence_id',
      'gb_accession',      'flu_type',
      'protein_id',        'protein_gi',
      'seq_len',           'gene_product_name',
      'cds_interval',      'cds_start',
      'cds_end',           'protein',
      'seq',               'motif_variant',
      'is_reversed',
    ],
    query => "
insert into stg_ird_flu_feature_annotation
  (
   ANNOT_FEAT_SEQ_ID,
   NA_SEQUENCE_ID,
   NCBI_GENOME_ACCESSION,
   FLU_TYPE,
   ANNOT_TYPE,
   ANNOT_ID,
   ANNOT_GI_NUMBER,
   SEQUENCE_LENGTH,
   GENE_SYMBOL,
   GENE_PRODUCT_NAME,
   NA_LOCATION,
   NA_START_POSITION,
   NA_END_POSITION,
   ANNOT_AA_SEQUENCE,
   ANNOT_NA_SEQUENCE,
   ANNOT_MOTIF_VARIANT,
   IS_REVERSED
  )
values (?,?,?,?,'CDS',?,?,?,'PA-X',?,?,?,?,?,?,?,?)
",
  },
  ###
  ### Specific properties
  ###
  propertySet => [
    'annotFeatSeqIdQuery', 'annotationQuery',
    'className',           'databaseName',
    'discardFile',         'generate',
    'load',                'password',
    'referenceQuery',      'schemaOwner',
    'selectQuery',         'serverType',
    'stgInsertQuery',      'todayDayDate',
    'userName',            'workspaceRoot',
    'datasetName',         'seqIdComp',
    'clustalWPath',        'useDelta',
    'deltaFile',           'geneSpecifics',
    'segments',            'gb_accession',
  ]
);

1;
