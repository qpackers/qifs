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
use Fcntl qw(F_SETFD);
use File::Temp qw(tempfile);
use Getopt::Long;

my ($diff_mode, $strip_comments, $http);

GetOptions(
    "diff"           => \$diff_mode,
    "strip-comments" => \$strip_comments,
    "http"           => \$http,
    "help"           => sub {
        print << "EOT";
Usage $0 [options] [files]

Options:
  --diff            diff mode; takes two files as arguments and runs `diff -u`
  --strip-comments  strips comments
  --http            moves pseudo headers and content-length to the top of each
                    header block

EOT
        exit 0;
    },
) or die "error in command line arguments\n";

if ($diff_mode) {
    die "diff mode excepts two arguments (filenames)\n"
        if @ARGV != 2;
    my @tmpfds = map {
        my $qif = filter($_);
        my $fh = tempfile();
        print $fh $qif;
        seek $fh, 0, 0;
        fcntl $fh, F_SETFD, 0
            or die "failed to clear O_CLOEXEC of temporary file:$!";
        $fh;
    } @ARGV;
    exec 'diff', '-u', map { '/dev/fd/' . fileno $_ } @tmpfds;
    die "failed to execute diff:$!";
} else {
    print filter($_)
        for @ARGV;
}

# reads given qif file and returns the filtered output as a string
sub filter {
    my $fn = shift;
    my @chunks = do {
        open my $fh, "<", $fn
            or die "failed to open file:$fn:$!";
        local $/ = "\n\n";
        map { $$_[1] }
            sort { $$a[0] <=> $$b[0] }
            map { /^#\s*stream\s+(\d+)/; [ $1 || 0, $_ ] }
            <$fh>;
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

    join "", @chunks;
}
