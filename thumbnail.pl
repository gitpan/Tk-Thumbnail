#!/usr/local/bin/perl -w
use Tk;
use lib './blib/lib'; use Tk::Thumbnail;
use Tk::widgets qw//;
use strict;

my $mw = MainWindow->new;

my $thumb = $mw->Thumbnail(-images => [<images/*>], -labels => 1);
$thumb->pack;

MainLoop;
