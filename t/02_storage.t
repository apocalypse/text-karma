use 5.010;
use strict;
use warnings;
use DBI;
use File::Temp 'tempfile';
use Text::Karma;
use Test::More tests => 4;

my (undef, $filename) = tempfile(UNLINK => 1);
my $dbh = DBI->connect("dbi:SQLite:dbname=$filename",'','');
my $karma = Text::Karma->new(dbh => $dbh);

$karma->process_karma(
    where => '#dsfdsf',
    who   => 'dfdsf',
    str   => "foo++ bar++ bar++ bar++ bar--",
    nick  => 'dfdsf',
);

my $foo_karma = $karma->get_karma(subject => 'foo');
my $bar_karma = $karma->get_karma(subject => 'bar');
my $FOO_karma = $karma->get_karma(subject => 'FOO');
my $BAR_karma = $karma->get_karma(subject => 'BAR', case_sens => 1);

is_deeply(
    $foo_karma,
    {
        score => 1,
        up    => 1,
        down  => 0,
    },
    'Got karma for foo',
);

is_deeply(
    $bar_karma,
    {
        score => 2,
        up    => 3,
        down  => 1,
    },
    'Got karma for bar',
);

is_deeply(
    $FOO_karma,
    {
        score => 1,
        up    => 1,
        down  => 0,
    },
    'FOO matches foo case insensitively',
);

is($BAR_karma, undef, 'BAR is not bar');
