#!/usr/local/bin/perl -w

use strict;

sub getscriptdir {
    ( $0 !~ /^(.*)\/[^\/]+$/ ) and die "Unexpected $0";
    return $1;
}

1;
