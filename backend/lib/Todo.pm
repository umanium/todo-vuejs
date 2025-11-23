package Todo;

use strict;
use warnings;

use DBI;
use DBD::SQLite;

sub get_all {
    my ($self, $db_file) = @_;

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

sub get_not_deleted {
    my ($self, $db_file) = @_;

    my $dbh = DBI->connect("dbi:SQLite:dbname=$db_file","","");
    my $sth = $dbh->prepare("SELECT * FROM todo WHERE deleted_at IS NULL");

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

sub insert {
    my ($self, $db_file, $inserted_label) = @_;
    if(!$inserted_label) { die 'no label supplied for insert' }
    my $dbh = DBI->connect("dbi:SQLite:dbname=$db_file","","");

    # create a statement, then insert to db
    my $sth = $dbh->prepare('INSERT INTO todo (label) VALUES (?)');
    $sth->execute($inserted_label);

    $dbh->disconnect();
}

sub delete {
    my ($self, $db_file, $id) = @_;
    if(!$id) { die 'no id supplied for delete' }
    my $dbh = DBI->connect("dbi:SQLite:dbname=$db_file","","");

    # create a statement, then insert to db
    my $sth = $dbh->prepare('UPDATE todo SET deleted_at=CURRENT_TIMESTAMP WHERE id=?');
    $sth->execute($id);

    $dbh->disconnect();
}

1;