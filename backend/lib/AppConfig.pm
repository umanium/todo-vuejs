package AppConfig;

use strict;
use warnings;
use File::Basename;

sub db_file { 
    my $db_file = $ENV{DB_FILE} || 'todo.db';
    return $db_file; 
}

sub db_path {
    my ($name, $path, $suffix) = File::Basename::fileparse($0);
    my $file = db_file;

    if ($path =~ /db\/\z/) {
        return "$path$file";
    } else {
        return "${ \($path) }db/$file";
    }
}

1;