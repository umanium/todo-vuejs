#!/usr/bin/env perl
use lib qw(lib);

use AppConfig;

use DBI;
use DBD::SQLite;

use strict;
use warnings;

print "Starting init db...\n";

my $db_path = "${ \(AppConfig->db_path) }";

my $create_sql_file = 'sql/create.sql';
open ( my $csf_glob, '<', $create_sql_file ) || die "Can't open $create_sql_file: $!";
my $create_sql = join('', <$csf_glob>);

my $insert_sql = <<EOF;
INSERT INTO todo(label) VALUES 
('Learn Vue'), ('Create a Vue project with the CLI'),
('Have fun'), ('Create a to-do list'), ('Write about this')
EOF

my $dbh = DBI->connect("dbi:SQLite:dbname=$db_path","","");
$dbh->do($create_sql);
$dbh->do($insert_sql);

$dbh->disconnect();

print "Finished init db.\n";
