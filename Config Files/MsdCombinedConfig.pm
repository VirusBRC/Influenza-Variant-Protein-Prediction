package flu::daily::MsdCombinedConfig;
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
  logInfix           => 'msd.combined',
  workspaceRoot      => '/home/idaily/influenza_daily',
  ###
  ### Database Specifics (always present?)
  ###
  serverType   => 'OracleDB',
  databaseName => '',
  userName     => 'dots',
  password     => 'dots#2',
  schemaOwner  => 'dots',
  ###
  ### Job Specifics
  ###
  className     => 'MsdCombined',
  datasetName   => 'msd_combined',
  sourceFile    => 'seq.sid',
  naSidFile     => 'na_sid',
  fileSeparator => ' ',
  rawFile       => 1,
  runTypes      => {
    'm42'     => [ 'gb_accession', 'na_sequence_id', 'other_accession', ],
    'ns3'     => [ 'gb_accession', 'na_sequence_id', 'other_accession', ],
    'pa-n155' => [ 'gb_accession', 'na_sequence_id', 'other_accession', ],
    'pa-n182' => [ 'gb_accession', 'na_sequence_id', 'other_accession', ],
    'pax'     => [ 'gb_accession', 'na_sequence_id', 'other_accession', ],
    'pb1-n40' => [ 'gb_accession', 'na_sequence_id', 'other_accession', ],
  },
  statusFile   => '.status.msd.combined',
  todayDayDate => '',                       ### YYYYMMDD ###
  ###
  ### Specific properties
  ###
  propertySet => [
    'className',  'databaseName',  'datasetName', 'naSidFile',
    'password',   'schemaOwner',   'runTypes',    'serverType',
    'statusFile', 'todayDayDate',  'userName',    'workspaceRoot',
    'sourceFile', 'fileSeparator', 'rawFile',
  ]
);

1;
