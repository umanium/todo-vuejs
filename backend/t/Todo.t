use lib qw(lib);

use Test2::V0 -target => 'Todo';
use Test2::Tools::Spec;
use Test2::Tools::Compare;

use DBI;
use DBD::SQLite;

describe "$CLASS" => sub {
    my $db_file = 't/todo.db';

    before_all once => sub {
        my $create_sql_file = 'sql/create.sql';
        open ( my $csf_glob, '<', $create_sql_file ) || die "Can't open $create_sql_file: $!";
        my $create_sql = join('', <$csf_glob>);

        my $dbh = DBI->connect("dbi:SQLite:dbname=$db_file","","");
        $dbh->do($create_sql);

        $dbh->disconnect();
    };

    after_all once => sub {
        unlink($db_file) or die "Can't delete $db_file: $!\n";
    };

    tests 'get_all' => sub {
        # insert data to db
        my $insert_sql = <<EOF;
INSERT INTO todo(label) VALUES ('test1'), ('test2')
EOF
        my $dbh = DBI->connect("dbi:SQLite:dbname=$db_file","","");
        $dbh->do($insert_sql);

        $dbh->disconnect();

        my @expected = (
            { id => 1, label => 'test1', done => 0 },
            { id => 2, label => 'test2', done => 0 }
        );

        my @actual = Todo->get_all($db_file);

        is(scalar @actual, scalar @expected, 'The result count is right');
        is($actual[0], $expected[0], 'The actual is the same as expected (0)');
        is($actual[1], $expected[1], 'The actual is the same as expected (1)');
    };

    after_each many => sub { 
        my $dbh = DBI->connect("dbi:SQLite:dbname=$db_file","","");
        $dbh->do("DELETE FROM todo");
        $dbh->do("UPDATE SQLITE_SEQUENCE SET seq = 0 WHERE name = 'todo'");

        $dbh->disconnect();
    };
};

done_testing;