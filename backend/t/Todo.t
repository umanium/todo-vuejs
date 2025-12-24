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

    tests 'insert then get_all' => sub {
        # insert data to db
        Todo->insert($db_file, 'test1');
        Todo->insert($db_file, 'test2');

        my @expected = (
            { id => 1, label => 'test1', done => 0 },
            { id => 2, label => 'test2', done => 0 }
        );

        my @actual = Todo->get_all($db_file);

        is(scalar @actual, scalar @expected, 'The result count is right');
        is($actual[0], $expected[0], 'The actual is the same as expected (0)');
        is($actual[1], $expected[1], 'The actual is the same as expected (1)');
    };

    tests 'insert failed if there\'s no label' => sub {
        ok(dies { Todo->insert($db_file) }, 'exception thrown for insert if no label supplied');
    };

    tests 'delete failed if there\'s no id' => sub {
        ok(dies { Todo->delete($db_file) }, 'exception thrown for delete if no id supplied');
    };

    tests 'insert, delete, then get_not_deleted' => sub {
        # insert data to db
        Todo->insert($db_file, 'test1');
        Todo->insert($db_file, 'test2');

        # delete from db
        Todo->delete($db_file, 1);

        my @expected = (
            { id => 2, label => 'test2', done => 0 }
        );

        my @all = Todo->get_all($db_file);

        is(scalar @all, 2, 'All data should be still 2');

        my @actual = Todo->get_not_deleted($db_file);

        is(scalar @actual, scalar @expected, 'The result count is right');
        is($actual[0], $expected[0], 'The actual is the same as expected (0)');
    };

    tests 'update data' => sub {
        # insert data to db
        Todo->insert($db_file, 'test1');
        Todo->insert($db_file, 'test2');

        # update data
        Todo->update($db_file, ({ id => 1, label => 'test1edit' }));
        Todo->update($db_file, ({ id => 2, label => 'test2yes', done => 1 }));

        my @expected = (
            { id => 1, label => 'test1edit', done => 0 },
            { id => 2, label => 'test2yes', done => 1 }
        );

        my @actual = Todo->get_all($db_file);

        is(scalar @actual, scalar @expected, 'The result count is right');
        is($actual[0], $expected[0], 'The actual is the same as expected (0)');
        is($actual[1], $expected[1], 'The actual is the same as expected (1)');
    };

    tests 'update failed' => sub {
        ok(dies { Todo->update($db_file, ({ label => 'test1edit', done => 1 })) }, 'exception thrown for update if no id supplied');
        ok(dies { Todo->update($db_file, ({ id => 10 })) }, 'exception thrown for update if only id supplied');
    };

    after_each many => sub { 
        my $dbh = DBI->connect("dbi:SQLite:dbname=$db_file","","");
        $dbh->do("DELETE FROM todo");
        $dbh->do("UPDATE SQLITE_SEQUENCE SET seq = 0 WHERE name = 'todo'");

        $dbh->disconnect();
    };
};

done_testing;