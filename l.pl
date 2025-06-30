#!/usr/bin/env perl

exec("ls", @ARGV) or die "exec failed: $!";