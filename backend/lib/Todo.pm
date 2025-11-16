package Todo;

use strict;
use warnings;

use DBI;
use DBD::SQLite;

sub get_all {
    my $db_file = $_[1];

    my $dbh = DBI->connect("dbi:SQLite:dbname=$db_file","","");
    my $sth = $dbh->prepare("SELECT * FROM todo");

    $sth->execute() or die $DBI::errstr;

    my @result_data;
    while (my $row = $sth->fetchrow_hashref) {
        my %current_row = (
            id => $row->{id},
            label => $row->{label},
            done => $row->{done}
        );
        push(@result_data, \%current_row);
    }

    $dbh->disconnect();

    return @result_data;
}

1;