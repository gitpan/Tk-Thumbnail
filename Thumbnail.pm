$Tk::Thumbnail::VERSION = '1.0';

package Tk::Thumbnail;

use Carp;
use File::Basename;
use Tk::widgets qw/Table/;
#use Tk::widgets qw/JPEG PNG TIFF/;
use base qw/Tk::Derived Tk::Table/;
use subs qw/free_photos/;
use strict;

Construct Tk::Widget 'Thumbnail';

sub Populate {

    # Create a Table of thumbnail images, having a default size of
    # 32x32 pixels.  Once we have a Photo of an image, copy a
    # subsample to a blank Photo and shrink it.  We  maintain a
    # list of our private images so their resources can be released
    # when the Thumbnail is destroyed.

    my($self, $args) = @_;

    my $img = delete $args->{-images}; # reference to array of images
    my $lbl = delete $args->{-labels}; # display file names IFF true
    my $pxx = delete $args->{-width};  # thumbnail pixel width
    my $pxy = delete $args->{-height}; # thumbnail pixel height
    $args->{-scrollbars} = '' unless defined $args->{-scrollbars};
    $pxx ||= 32;
    $pxy ||= 32;
    croak "Tk::Thumbnail: -images argument is required." unless defined $img;
    $self->SUPER::Populate($args);

    my $count = scalar @$img;
    my $rows = int(sqrt $count);
    $rows++ if $rows * $rows != $count;

  THUMB:
    foreach my $r (1 .. $rows) {
	foreach my $c (1 .. $rows) {
	    last THUMB if --$count < 0;

	    my $i = @$img[$#$img - $count];
	    my ($photo, $w, $h);
            $photo = UNIVERSAL::isa($i, 'Tk::Photo') ? $i :
		$self->Photo(-file => $i);

	    ($w, $h) = ($photo->width, $photo->height);

	    my $subsample = $self->Photo;
	    my $sw = $pxx == -1 ? 1 : ($w / $pxx);
	    my $sh = $pxy == -1 ? 1 : ($h / $pxy);

	    if ($sw >= 1 and $sh >= 1) {
		$subsample->copy($photo, -subsample => ($sw, $sh));
	    } else {

		# NOTE: -zoom interpolates and adds pixels.  A fractional
		# -subsample "expands" an image but leaves gaps since it
		# does no interpolation.
		
		$subsample->copy($photo, -zoom => (1 / $sw, 1 / $sh));
	    }
	    push @{$self->{photos}}, $subsample;

	    my $f = $self->Frame;
	    my $l = $f->Label(-image => $subsample)->grid;
	    my $file = $photo->cget(-file);
	    $l->bind('<Button-1>' => [$self => 'Callback', '-command',
				      $l, $file]);
	    $f->Label(-text => basename($file))->grid if $lbl;
	    $self->put($r, $c, $f);
	    
            $photo->delete unless UNIVERSAL::isa($i, 'Tk::Photo');

	} # forend columns
    } #forend rows

    $self->ConfigSpecs(
        -font       => ['DESCENDANTS',          
                        'font',       'Font',      'fixed'],
        -background => [['DESCENDANTS', 'SELF'],
                        'background', 'Background', undef],
        -command    => ['CALLBACK',
                        'command',    'Command',     undef],
                      );
    $self->OnDestroy([$self => 'free_photos']);
             
} # end Populate

sub free_photos {

    # Free all our subsampled Photo images.

    foreach my $photo (@{$_[0]->{photos}}) {
	#print "deleteing $photo!\n";
        $photo->delete;
    }

} # end free_photos

1;
__END__

=head1 NAME

Tk::Thumbnail - Create a Tk::Table of shrunken images.

=for pm Tk/Thumbnail.pm

=for category Images

=head1 SYNOPSIS

 $thumb = $parent->Thumbnail(-option => value, ... );

=head1 DESCRIPTION

Create a B<Table> of thumbnail images, having a default size of
32x32 pixels.  Once we have a B<Photo> of an image, shrink it by copying
a subsample of the original to a blank B<Photo>.

=over 4

=item B<-images>

A list of file names and/or B<Photo> widgets.  B<Thumbnail> creates 
temporarty B<Photo>
images from all the files, and destroys them when the B<Thumbnail> is
destroyed.  Already existing B<Photo>s are left untouched.

=item B<-labels>

A boolean, set to TRUE if you want file names displayed under the
thumbnail image.

=item B<-font>

The default font is B<fixed>.

=item B<-width>

Pixel width of the thumbnails.  Default is 32. The special value -1 means
don't shrink images in the X direction.

=item B<-height>

Pixel height of the thumbnails.  Default is 32. The special value -1 means
don't shrink images in the Y direction.

=item B<-command>

A callback that's executed on a <Button-1> event over a thumbnail image.  It's
passed two arguments, the Label widget reference containing the thumbnail
B<Photo> image, and the file name of the B<Photo>.

=back

=head1 METHODS

=over 4

=item $thumb->free_photos;

Deletes all the temporary B<Photo> images.

=back

=head1 EXAMPLE

 $thumb = $mw->Thumbnail(-images => [<images/*.ppm>], -labels => 1);


=head1 AUTHOR

Stephen.O.Lidie@Lehigh.EDU

Copyright (C) 2001 - 2002, Steve Lidie. All rights reserved.

This program is free software; you can redistribute it
and/or modify it under the same terms as Perl itself.

=head1 KEYWORDS

thumbnail, image

=cut

