#!/usr/bin/env perl
#
# sort-qif.pl -- sort QIF file
#
# Sort QIF file.  This assumes that the header lists in the QIF file have a
# leading comment that looks like '# stream $number'.
#
# Usage: sort-qif.pl [--strip-comments] [files]

use strict;
use warnings;
use Getopt::Long;

my ($strip_comments, $http);

GetOptions(
    "strip-comments" => \$strip_comments,
    "http"           => \$http,
    "help"           => sub {
        print << "EOT";
Usage $0 [options] [files]

Options:
  --strip-comments  strips comments
  --http            moves pseudo headers and content-length to the top of each
                    header block

EOT
        exit 0;
    },
) or die "error in command line arguments\n";


my @chunks = do {
    local $/ = "\n\n";
    map { $$_[1] }
        sort { $$a[0] <=> $$b[0] }
        map { /^#\s*stream\s+(\d+)/; [ $1 || 0, $_ ] }
        <>;
};

if ($strip_comments) {
    for (@chunks) {
        s/^#.*\n//mg;
    }
}

if ($http) {
    @chunks = map {
        my @in = split /\n/, $_;
        my @out = (
            (grep { /^#/ } @in),
            (sort grep { /^:/ } @in),
            (sort grep { /^content-length\s/ } @in),
            (grep { !/^(?:#|:|content-length\s|$)/ } @in),
        );
        (join "\n", @out) . "\n\n";
    } @chunks;
}

print @chunks;
