#!/usr/local/bin/perl -w
use Tk;
use lib './blib/lib'; use Tk::Thumbnail;
use strict;

my $mw = MainWindow->new;

my $thumb = $mw->Thumbnail( -images => [ <images/*> ], -ilabels => 1 );

$thumb->pack( qw/ -fill both -expand 1 / );
$thumb->update;
$thumb->after(2000);

my $kat = $mw->Photo( -file => 'images/Icon.gif' );
my $pot = $mw->Photo( -file => Tk->findINC( 'demos/images/teapot.ppm' ) );
$thumb->configure(-images => [ $kat, $pot ]);
$thumb->update;
$thumb->after(2000);

$thumb->configure(-images => [ <images/*> ], -command => sub {print "args=@_!\n"});
$thumb->update;

MainLoop;
