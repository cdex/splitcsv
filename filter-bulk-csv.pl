#!/usr/local/bin/perl -w
use strict;
use FileHandle;
use Text::CSV_XS;

require 'csv.columnfilter.pl';
require 'common.pl';

my $encoding = 'UTF-8';

&go( $ARGV[0] );
exit;

sub go {
    my $hole_dir = shift;

    my ( $nondatacolhash, $datacolshash ) = &prepheaderswanted();
#    print keys %$datacolshash; die;
#    print join ( '\n', @{$$nondatacolhash{'pore-water-chemistry'}} ); die;

    $| = 1;

    &processabulkcsv( $hole_dir, $nondatacolhash, $datacolshash );
}

sub prepheaderswanted {
    my %nondatacolhash;
    my %datacolhash;

#    my @holeloc = getheaders( &cg_hole() );
#    $datacolhash{'holeloc'} = \@holeloc;

    my @hole = getheaders( &cg_exp() . &cg_site() . &cg_hole() );
    $datacolhash{'hole'} = \@hole;

    my @core = getheaders( &cg_core_drill() . &cg_core_cur() );
    $datacolhash{'core'} = \@core;

    my @misc_m = getheaders ( &cg_misc_m() );
    $datacolhash{'miscellaneous-material'} = \@misc_m;

    my @section = getheaders( &cg_section() );
    $datacolhash{'section'} = \@section;

    my @sample = getheaders ( &cg_sample() );
    $datacolhash{'sample'} = \@sample;

#    my @material = getheaders( &out_smcs_ci() );
#    $datacolhash{'material'} = \@material;

    my @lithology = getheaders( &out_vcd_lithology() );
    $datacolhash{'lithology-description'} = \@lithology;
#    $nondatacolhash{'lithology-description'} = [ &getheaders( &cg_sample() ) ];

    my @lithodist = getheaders( &out_vcd_lithology_distribution() );
    $datacolhash{'lithology-distribution'} = \@lithodist;

    my @structure = getheaders( &out_vcd_structure() );
    $datacolhash{'structure'} = \@structure;

    my @sumlitho = getheaders( &cg_vcd_sum_lithounit() );
    $datacolhash{'summarized-lithounit'} = \@sumlitho;

#    my @vcdcomment = getheaders( &out_vcd_comment() );
#    $datacolhash{'vcd-comment'} = \@vcdcomment;

    my @vcdcomment = getheaders( &cg_vcd_comment() );
    $datacolhash{'vcd-comment'} = \@vcdcomment;

    my @vcdsketch = getheaders( &cg_vcd_graphic_representation() );
    $datacolhash{'vcd-graphic-representation'} = \@vcdsketch;

    my @fossil = getheaders( &out_fossil_occurrence_file() . &col_fossil_occurrence_marker() );
    $datacolhash{'fossil-occurrence'} = \@fossil;

    my @fossil_calcareous_nannofossils = getheaders( &out_fossil_occurrence('calcareous-nannofossils') );
    $datacolhash{'fossil-occurrence-calcareous-nannofossils'} = \@fossil_calcareous_nannofossils;
    $nondatacolhash{'fossil-occurrence-calcareous-nannofossils'} = [ &getheaders( &cg_sample() ) ];

    my @fossil_planktonic_foraminifers = getheaders( &out_fossil_occurrence('planktonic-foraminifers') );
    $datacolhash{'fossil-occurrence-planktonic-foraminifers'} = \@fossil_planktonic_foraminifers;
    $nondatacolhash{'fossil-occurrence-planktonic-foraminifers'} = [ &getheaders( &cg_sample() ) ];

    my @fossil_benthic_foraminifers = getheaders( &out_fossil_occurrence('benthic-foraminifers') );
    $datacolhash{'fossil-occurrence-benthic-foraminifers'} = \@fossil_benthic_foraminifers;
    $nondatacolhash{'fossil-occurrence-benthic-foraminifers'} = [ &getheaders( &cg_sample() ) ];

    my @fossil_diatoms = getheaders( &out_fossil_occurrence('diatoms') );
    $datacolhash{'fossil-occurrence-diatoms'} = \@fossil_diatoms;
    $nondatacolhash{'fossil-occurrence-diatoms'} = [ &getheaders( &cg_sample() ) ];

    my @fossil_radiolarians = getheaders( &out_fossil_occurrence('radiolarians') );
    $datacolhash{'fossil-occurrence-radiolarians'} = \@fossil_radiolarians;
    $nondatacolhash{'fossil-occurrence-radiolarians'} = [ &getheaders( &cg_sample() ) ];

    my @fossil_dinoflagellates = getheaders( &out_fossil_occurrence('dinoflagellates') );
    $datacolhash{'fossil-occurrence-dinoflagellates'} = \@fossil_dinoflagellates;
    $nondatacolhash{'fossil-occurrence-dinoflagellates'} = [ &getheaders( &cg_sample() ) ];

    my @fossil_acritarchs = getheaders( &out_fossil_occurrence('acritarchs') );
    $datacolhash{'fossil-occurrence-acritarchs'} = \@fossil_acritarchs;
    $nondatacolhash{'fossil-occurrence-acritarchs'} = [ &getheaders( &cg_sample() ) ];

    my @fossil_prasinophytes = getheaders( &out_fossil_occurrence('prasinophytes') );
    $datacolhash{'fossil-occurrence-prasinophytes'} = \@fossil_prasinophytes;
    $nondatacolhash{'fossil-occurrence-prasinophytes'} = [ &getheaders( &cg_sample() ) ];

    my @fossil_pollen = getheaders( &out_fossil_occurrence('pollen') );
    $datacolhash{'fossil-occurrence-pollen'} = \@fossil_pollen;
    $nondatacolhash{'fossil-occurrence-pollen'} = [ &getheaders( &cg_sample() ) ];

    my @fossil_spores = getheaders( &out_fossil_occurrence('spores') );
    $datacolhash{'fossil-occurrence-spores'} = \@fossil_spores;
    $nondatacolhash{'fossil-occurrence-spores'} = [ &getheaders( &cg_sample() ) ];

    my @fossil_silicoflagellates = getheaders( &out_fossil_occurrence('silicoflagellates') );
    $datacolhash{'fossil-occurrence-silicoflagellates'} = \@fossil_silicoflagellates;
    $nondatacolhash{'fossil-occurrence-silicoflagellates'} = [ &getheaders( &cg_sample() ) ];

    my @fossil_ebridians = getheaders( &out_fossil_occurrence('ebridians') );
    $datacolhash{'fossil-occurrence-ebridians'} = \@fossil_ebridians;
    $nondatacolhash{'fossil-occurrence-ebridians'} = [ &getheaders( &cg_sample() ) ];

    my @fossil_actinicidians = getheaders( &out_fossil_occurrence('actinicidians') );
    $datacolhash{'fossil-occurrence-actinicidians'} = \@fossil_actinicidians;
    $nondatacolhash{'fossil-occurrence-actinicidians'} = [ &getheaders( &cg_sample() ) ];

    my @fossil_bolboforma = getheaders( &out_fossil_occurrence('bolboforma') );
    $datacolhash{'fossil-occurrence-bolboforma'} = \@fossil_bolboforma;
    $nondatacolhash{'fossil-occurrence-bolboforma'} = [ &getheaders( &cg_sample() ) ];

    my @fossil_ostracodes = getheaders( &out_fossil_occurrence('ostracodes') );
    $datacolhash{'fossil-occurrence-ostracodes'} = \@fossil_ostracodes;
    $nondatacolhash{'fossil-occurrence-ostracodes'} = [ &getheaders( &cg_sample() ) ];

    my @fossil_bryozoans = getheaders( &out_fossil_occurrence('bryozoans') );
    $datacolhash{'fossil-occurrence-bryozoans'} = \@fossil_bryozoans;
    $nondatacolhash{'fossil-occurrence-bryozoans'} = [ &getheaders( &cg_sample() ) ];

    my @fossil_ammonites = getheaders( &out_fossil_occurrence('ammonites') );
    $datacolhash{'fossil-occurrence-ammonites'} = \@fossil_ammonites;
    $nondatacolhash{'fossil-occurrence-ammonites'} = [ &getheaders( &cg_sample() ) ];

    my @fossil_aptychi = getheaders( &out_fossil_occurrence('aptychi') );
    $datacolhash{'fossil-occurrence-aptychi'} = \@fossil_aptychi;
    $nondatacolhash{'fossil-occurrence-aptychi'} = [ &getheaders( &cg_sample() ) ];

    my @fossil_archaeomonads = getheaders( &out_fossil_occurrence('archaeomonads') );
    $datacolhash{'fossil-occurrence-archaeomonads'} = \@fossil_archaeomonads;
    $nondatacolhash{'fossil-occurrence-archaeomonads'} = [ &getheaders( &cg_sample() ) ];

    my @fossil_calcispherulides = getheaders( &out_fossil_occurrence('calcispherulides') );
    $datacolhash{'fossil-occurrence-calcispherulides'} = \@fossil_calcispherulides;
    $nondatacolhash{'fossil-occurrence-calcispherulides'} = [ &getheaders( &cg_sample() ) ];

    my @fossil_crinoids = getheaders( &out_fossil_occurrence('crinoids') );
    $datacolhash{'fossil-occurrence-crinoids'} = \@fossil_crinoids;
    $nondatacolhash{'fossil-occurrence-crinoids'} = [ &getheaders( &cg_sample() ) ];

    my @fossil_phytolitharia = getheaders( &out_fossil_occurrence('phytolitharia') );
    $datacolhash{'fossil-occurrence-phytolitharia'} = \@fossil_phytolitharia;
    $nondatacolhash{'fossil-occurrence-phytolitharia'} = [ &getheaders( &cg_sample() ) ];

    my @fossil_rhyncollites = getheaders( &out_fossil_occurrence('rhyncollites') );
    $datacolhash{'fossil-occurrence-rhyncollites'} = \@fossil_rhyncollites;
    $nondatacolhash{'fossil-occurrence-rhyncollites'} = [ &getheaders( &cg_sample() ) ];

#    my @stratigraphy = getheaders( &out_stratigraphy() );
    my @stratigraphy = ();
    $datacolhash{'stratigraphy'} = \@stratigraphy;

#    my @microbio = getheaders( &cg_microbio() );
    my @microbio = ();
    $datacolhash{'microbiology'} = \@microbio;
    $nondatacolhash{'microbiology'} = [ &getheaders( &cg_sample() ) ];

    my @microphoto = getheaders( &cg_microphoto() );
    $datacolhash{'microphoto'} = \@microphoto;
#    $nondatacolhash{'microphoto'} = [ &getheaders( &cg_sample() ) ];

    my @otrcorphoto = ();
    $datacolhash{'other-core-photography'} = \@otrcorphoto;

#     my @xct = getheaders( &cg_xct() );
    my @xct = ();
    $datacolhash{'xray-ct-scanner'} = \@xct;

#     my @mscl = getheaders( &cg_mscl() );
#     my @mscl = getheaders( &cg_mscl_s() . &cg_mscl_c() );
    my @mscl = getheaders( &cg_mscl_c() );
    $datacolhash{'mscl'} = \@mscl;
    $nondatacolhash{'mscl'} = [ &getheaders( &out_udp_halves() ) ];

    my @ngr = ();
    $datacolhash{'natural-gamma-radiation'} = \@ngr;
    $nondatacolhash{'natural-gamma-radiation'} = [ &getheaders( &cg_misc_m() ), &getheaders( &out_udp_halves() ) ];

#     my @splitimg = getheaders( &cg_split_image() );
    my @splitimg = ();
    $datacolhash{'split-section-image'} = \@splitimg;
    $nondatacolhash{'split-section-image'} = [ &getheaders( &out_udp_halves() ) ];

    my @cutimg = ();
    $datacolhash{'cuttings-photography'} = \@cutimg;
    $nondatacolhash{'cuttings-photography'} = [ &getheaders( &cg_misc_m() ), &getheaders( &out_udp_halves() ) ];

    my @mad = getheaders( &cg_mad() );
    $datacolhash{'moisture-density'} = \@mad;
    $nondatacolhash{'moisture-density'} = [ &getheaders( &cg_sample() ) ];

    my @tcon = getheaders( &cg_tcon() );
    $datacolhash{'thermal-conductivity'} = \@tcon;

    my @eleccond = ();
    $datacolhash{'electrical-conductivity'} = \@eleccond;

    my @magsusd = ();
    $datacolhash{'magnetic-susceptibility'} = \@magsusd;

    my @pwvd = ();
    $datacolhash{'pwave-swave-velocity'} = \@pwvd;

#    my @otherpp = ();
#    $datacolhash{'other-physical-properties'} = \@otherpp;

#    my @magnetometer = getheaders( &cg_magnetometer() );
    my @magnetometer = ();
    $datacolhash{'magnetometer'} = \@magnetometer;
    $nondatacolhash{'magnetometer'} = [ &getheaders( &cg_sample() ), &getheaders( &out_udp_halves() ) ];

    my @ams = getheaders( &cg_ams() );
    $datacolhash{'anisotropy-magnetic-susceptibility'} = \@ams;
    $nondatacolhash{'anisotropy-magnetic-susceptibility'} = [ &getheaders( &cg_sample() ) ];

    my @xrflog = getheaders( &cg_xrf_core_logger() );
    $datacolhash{'xrf-core-logger'} = \@xrflog;

#     my @xrd = getheaders( &cg_xrd() );
    my @xrd = ();
    $datacolhash{'xrd'} = \@xrd;
    $nondatacolhash{'xrd'} = [ &getheaders( &cg_sample() ) ];

    my @xrf = ();
    $datacolhash{'xrf'} = \@xrf;

#     my @headgas = getheaders( &out_headgas() );
    my @headgas = ();
    $datacolhash{'headspace-gas'} = \@headgas;
    $nondatacolhash{'headspace-gas'} = [ &getheaders( &cg_sample() ) ];

    my @carb = getheaders( &out_cns_analysis() );
    $datacolhash{'bulk-cns-analysis'} = \@carb;
    $nondatacolhash{'bulk-cns-analysis'} = [ &getheaders( &cg_sample() ) ];

#    my @chromatography = getheaders( &cg_chromatography() );
#    $datacolhash{'chromatography'} = \@chromatography;

    my @iw = getheaders( &cg_iw() );
    $datacolhash{'pore-water-chemistry'} = \@iw;
    $nondatacolhash{'pore-water-chemistry'} = [ &getheaders( &cg_sample() ) ];

    my @otherlc = ();
    $datacolhash{'other-liquid-chemistry'} = \@otherlc;

    my @mudlog = ();
    $datacolhash{'mud-logging'} = \@mudlog;

    my @geotech = ();
    $datacolhash{'penetration-shear-strength'} = \@geotech;

    my @drill = ();
    $datacolhash{'drilling'} = \@drill;

    my @welllog = ();
    $datacolhash{'well-logging'} = \@welllog;

    my @dhmeasure = ();
    $datacolhash{'downhole-measurement'} = \@dhmeasure;

    my @psa = ();
    $datacolhash{'particle-size-analysis'} = \@psa;

    my @voidgas = ();
    $datacolhash{'void-gas'} = \@voidgas;

    my @mudchem = ();
    $datacolhash{'mud-water-chemistry'} = \@mudchem;

    my @vitrinite = ();
    $datacolhash{'vitrinite-reflectance'} = \@vitrinite;

    my @semeds = ();
    $datacolhash{'sem-eds'} = \@semeds;

    my @biomarker = ();
    $datacolhash{'biomarker'} = \@biomarker;

    my @wlwaterchem = ();
    $datacolhash{'formation-water-chemistry'} = \@wlwaterchem;

    my @asr = ();
    $datacolhash{'anelastic-strain-recovery'} = \@asr;

    my @observatory = ();
    $datacolhash{'borehole-observatory'} = \@observatory;

    my @othergas = ();
    $datacolhash{'other-gas'} = \@othergas;

    foreach my $category ( keys ( %datacolhash ) ) {
	push( @{$datacolhash{$category}},
	      &getheaders( &out_extra_scalar_from_column_list( $category ) ) );
	push( @{$datacolhash{$category}},
	      &getheaders( &out_udp_from_set_list( $category ) ) );
    }

    return ( \%nondatacolhash, \%datacolhash );
}

sub processabulkcsv {
    my ( $csvdir, $targetmaterialcols, $datacols ) = @_;
#    print keys %$datacols;

    my $csv = Text::CSV_XS->new ({ binary => 1, escape_null => 0 });

    open( BULK, "<:encoding($encoding)", "$csvdir/bulk.csv" ) or die "Can not open $csvdir/bulk.csv";
    my $first = $csv->getline( *BULK );
    my ( $nondatacolfilterhash, $datacolfilterhash ) = &getfilters( $targetmaterialcols, $datacols, @{$first} );
    close( BULK ) or die "Can not close BULK";

#    my %filehandles = &openfiles( $csvdir, keys( %$datacols ) );
    my %filehandles = &openfiles( $csvdir, keys( %{$datacolfilterhash} ) );
#    print %filehandles,"\n";

    open( BULK, "<:encoding($encoding)", "$csvdir/bulk.csv" ) or die "Can not open $csvdir/bulk.csv";

    my %prevlines;

    while ( my $vals_ref = $csv->getline( *BULK ) ) {
	# print join("\n", @{$vals_ref}) . "\n\n"; ##
	foreach my $part ( keys( %$datacolfilterhash ) ) {
	    my ($solid, @filteredvals) = &filter( $$nondatacolfilterhash{$part}, $$datacolfilterhash{$part}, @{$vals_ref} );
	    $solid or next;
	    my $fh = $filehandles{$part};
#	    print "write to $part to $$fh\n"; next;
	    if ( ! defined( $prevlines{$part} ) || ! &are_equal_arraies( $prevlines{$part}, \@filteredvals ) ) {
		# print join("\n", @filteredvals) . "\n\n"; ##
		# $csv->combine(@filteredvals); ##
		# print $csv->string() . "\n\n\n"; ##
		$csv->print( $$fh, \@filteredvals );
		$$fh->print( "\r\n" );
	    }
	    $prevlines{$part} = \@filteredvals;
	}
    }

    &closefiles( values( %filehandles ) );
    close( BULK ) or die "Can not close BULK";
}

sub are_equal_arraies {
    my ( $a, $b ) = @_;
    return 0 unless @{$a} ==@{$b};
    for ( 0 .. $#{$a} ) {
	return 0 unless ${$a}[$_] eq ${$b}[$_];
    }
    return 1;
}

sub getfilters {
    my ( $targetmaterialcols, $datacols, @headers ) = @_;
#    print "getfilters( $datacols, @headers )\n";
#    print keys( %$datacols );

    my %parttofilterarray;
    my %parttonondatacolarray;

    foreach my $part ( keys( %$datacols ) ) {
#	print $part, "\n";
	my $hw = $$datacols{$part};
	my $tm = $$targetmaterialcols{$part};
#	print join("\n",@$hw),"\n\n";
	my ( $nondatacolarray, $filterarray ) = &getfilter( $tm , $hw, @headers );
	if ( &array_contains_true( @{$filterarray} ) ) {
	    ( $parttonondatacolarray{$part}, $parttofilterarray{$part} ) = ( $nondatacolarray, $filterarray );
	}
#	print $deptharray, "\n";
    }
    
    return ( \%parttonondatacolarray, \%parttofilterarray );
}

sub array_contains_true {
    foreach my $i ( @_ ) {
	$i and return 1
    }
    return 0;
}

sub openfiles {
    my ( $csvdir, @parts ) = @_;
    my %return;
    foreach my $part ( @parts ) {
	my $file = 'bulk-'.$part.'.csv';
#	print "opening to write $csvdir/$file...\n"; #####
	open my $fh, ">:encoding($encoding)", "$csvdir/$file" or die "Can not open to write: $file";
	# binmode $fh, ':utf8:';
	$return{$part} = \$fh;
    }
    return %return;
}

sub closefiles {
    my @handles = @_;
    foreach my $handle ( @handles ) {
	# $$handle->close() or die "Can not close: $handle";
	close $$handle or die "Can not close: $handle";
    }   
}
