
use Tk::MMutil;

Tk::MMutil::TkExtMakefile(
    NAME          => "Tk::Thumbnail",
    DISTNAME      => "Tk-Thumbnail",
    VERSION_FROM  => "Thumbnail.pm",
    PM            => {"Thumbnail.pm" => "\$(INST_LIBDIR)/Thumbnail.pm"},
    dist          => {COMPRESS => 'gzip', SUFFIX => 'gz'},
    ABSTRACT      => 'Display thumbnail images of Photos',
    AUTHOR        => 'Steve Lidie (sol0@lehigh.edu)',
);
