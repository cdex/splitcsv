#!/usr/local/bin/perl -w

use strict;
require 'common.pl';

my @depthheaders;

&getdepthheaders();

sub getdepthheaders {
    @depthheaders = getheaders( &cg_depth() );
}

sub getheaders {
    my ( $file ) = @_;

    return split( /[\n\r]+/, $file );
}

sub getfilter {
    my ( $targetmaterialcolumnsarray, $datacolumnsarray, @values ) = @_;

    my @nondatacolboolean;
    my @colboolean;

    my $value;
    VALUE: foreach $value ( @values ) {
	$value =~ s/^\"?//;
	$value =~ s/\"?$//;
	my $header;
	foreach $header ( @$datacolumnsarray ) {
	    if ( ( $header =~ /^\/(.*)\/$/ && $value =~ /^$1$/ )
		 || ( $value eq $header ) ) {
		push( @colboolean, 1 );
		next VALUE;
	    }
	}
	push( @colboolean, 0 );
    }

    VALUE: foreach $value ( @values ) {
	$value =~ s/^\"?//;
	$value =~ s/\"?$//;
	my $nondatahead;
	foreach $nondatahead ( @depthheaders, @$targetmaterialcolumnsarray ) {
	    if ( ( $nondatahead =~ /^\/(.*)\/$/ && $value =~ /^$1$/ )
		 || ( $value eq $nondatahead ) ) {
		push( @nondatacolboolean, 1 );
		next VALUE;
	    }
	}
	push( @nondatacolboolean, 0 );
    }

    return ( \@nondatacolboolean, \@colboolean );
}

# pick values from @values.
# @$datafilterarray contains boolean values whether or not to pick values from the columns.
#     This array does not include boolean values for depth columns
# @$nondatafilterarray contains boolean values whether or not the columns are depth ones.
sub filter {
    my ( $nondatafilterarray, $datafilterarray, @values ) = @_;

    my @filteredvalues;
    my $hasvaluenotatdepthcols = 0;

    for ( my $i = 0; $i <= $#values; $i++ ) {
	( $$datafilterarray[$i] || $$nondatafilterarray[$i] ) or next;
	push ( @filteredvalues, $values[$i] );
	( $$datafilterarray[$i] && $values[$i] !~ /^\s*$/ && $values[$i] !~ /^\s*\"\"\s*$/ )
	    and $hasvaluenotatdepthcols = 1;
    }

    return ($hasvaluenotatdepthcols, @filteredvalues);
}

sub out_extra_scalar_from_column_list {
    my $category = shift;
    my $file = &getscriptdir()."/extra-scalar-column/${category}";
    ( -f $file ) or return '';
    open( FILE, "< $file" ) or die "Can not open $file";
    my $list = '';
    while ( my $line = <FILE> ) {
	( $line =~ /^([^\t\r\n]*)(\t[^\r\n]*)?([\r\n]*)$/ )
	    or die( "Corrupted line in $file: $line" );
	$list .= $1.$3;
	$list .= $1.' registerer'.$3;
	$list .= $1.' registration time-stamp'.$3;
    }
    close( FILE ) or die "Can not close FILE";
    return $list;
}

sub out_udp_from_set_list {
    my $category = shift;
    my $file = &getscriptdir()."/udp-set/${category}";
    ( -f $file ) or return '';
    open( FILE, "< $file" ) or die "Can not open $file";
    my $list = '';
    while ( my $line = <FILE> ) {
	( $line =~ /^([^\t\r\n]*)([\r\n]*)$/ )
	    or die( "Corrupted line in $file: $line" );
	$list .= '/'.quotemeta( $1 ).'::\S.*\S(?: \[.*\])?::(?:number|text|file)/'.$2;
	$list .= $1.'::registerer'.$2;
	$list .= $1.'::registration time-stamp'.$2;
    }
    close( FILE ) or die "Can not close FILE";
    return $list;
}

sub out_udp_halves {
    return << 'EOF';
Section half
Miscellaneous material half
EOF
}

sub cg_depth {
    return << 'EOF';
Top Core Depth []
Top Drilling depth below sea floor [m DSF]
Top Mud depth below sea floor [m MSF]
Top Wireline log depth below sea floor [m WSF]
Top Seismic TWT [sec.]
Top Depth DSF, MSF, WSF and CSF-A [m]
Top Depth DSF, MSF, WSF and CSF-C [m, SV]
Top Depth DSF, MSF, WSF and CSF-C [m, SE]
Top Depth DSF, MSF, WSF and CSF-C [m, SVE]
Top Depth DSF, MSF, WSF and CSF-B [m, CMP]
Top Depth DSF, MSF, WSF and CSF-C [m, SV-CMP]
Top Depth DSF, MSF, WSF and CSF-C [m, SE-CMP]
Top Depth DSF, MSF, WSF and CSF-C [m, SVE-CMP]
Top Core depth (below sea floor) [m CSF-A]
Top Core depth (below sea floor) [m CSF-B]
/Top .* \[.*\]/
Bottom Core Depth []
Bottom Drilling depth below sea floor [m DSF]
Bottom Mud depth below sea floor [m MSF]
Bottom Wireline log depth below sea floor [m WSF]
Bottom Seismic TWT [sec.]
Bottom Depth DSF, MSF, WSF and CSF-A [m]
Bottom Depth DSF, MSF, WSF and CSF-C [m, SV]
Bottom Depth DSF, MSF, WSF and CSF-C [m, SE]
Bottom Depth DSF, MSF, WSF and CSF-C [m, SVE]
Bottom Depth DSF, MSF, WSF and CSF-B [m, CMP]
Bottom Depth DSF, MSF, WSF and CSF-C [m, SV-CMP]
Bottom Depth DSF, MSF, WSF and CSF-C [m, SE-CMP]
Bottom Depth DSF, MSF, WSF and CSF-C [m, SVE-CMP]
Bottom Core depth (below sea floor) [m CSF-A]
Bottom Core depth (below sea floor) [m CSF-B]
/Bottom .* \[.*\]/
EOF
}

# On 2012-03-07 it has been confirmed that
# CSF-C depth columns were removed correctly
# from bulk-*.csv by removing the following lines
# from the function cg_depth above.
#
# Top Depth DSF, MSF, WSF and CSF-C [m, SV]
# Top Depth DSF, MSF, WSF and CSF-C [m, SE]
# Top Depth DSF, MSF, WSF and CSF-C [m, SVE]
# Top Depth DSF, MSF, WSF and CSF-C [m, SV-CMP]
# Top Depth DSF, MSF, WSF and CSF-C [m, SE-CMP]
# Top Depth DSF, MSF, WSF and CSF-C [m, SVE-CMP]
# /Top .* \[.*\]/
# Bottom Depth DSF, MSF, WSF and CSF-C [m, SV]
# Bottom Depth DSF, MSF, WSF and CSF-C [m, SE]
# Bottom Depth DSF, MSF, WSF and CSF-C [m, SVE]
# Bottom Depth DSF, MSF, WSF and CSF-C [m, SV-CMP]
# Bottom Depth DSF, MSF, WSF and CSF-C [m, SE-CMP]
# Bottom Depth DSF, MSF, WSF and CSF-C [m, SVE-CMP]
# /Bottom .* \[.*\]/

sub cg_exp {
    return << 'EOF';
Expedition
Expedition name
Expedition purpose
Expedition location
EOF
}

sub cg_site {
    return << 'EOF';
Site
Site ship
EOF
}

sub cg_hole {
    return << 'EOF';
Hole
Hole method
Hole type
Hole prospectus latitude (degree N)
Hole prospectus longitude (degree E)
Hole prospectus water depth (m)
Hole final latitude (degree N)
Hole final longitude (degree E)
Hole final water depth (m)
Hole comment
/Hole survey (mud logging|LWD|others)/
EOF
}

sub cg_core_drill {
    return << 'EOF';
Core drilling
Core time on deck
Core recovered length (m)
Core recovery (%)
Core initial length (m)
Core initial recovery (%)
Core total length of extraneous material intervals (m)
Core corrected length (m)
Core corrected recovery (%)
Core orientation tool
Core liner type
Core drilling comment
EOF
}

sub cg_core_cur {
    return << 'EOF';
Core curated
Core curatorial comment
Core curatorial comment
Core curatorial comment
Core number of sections
EOF
}

sub cg_section {
    return << 'EOF';
Section
J-CORES section ID
Section curated length (m)
Section stored with section
Section archive half repository
Section working half repository
Section comment
Logical subsection of section
Logical subsection
Section piece
Section piece comment
Section piece orientation
EOF
}

sub cg_misc_m {
    return << 'EOF';
Miscellaneous material
Miscellaneous material method description
Miscellaneous material volume (cm3)
Miscellaneous material repository
Miscellaneous material comment
Miscellaneous material comment
Miscellaneous material comment
EOF
}

sub cg_sample {
    return << 'EOF';
Sample source
J-CORES sample ID
Sample code
Sample request
Sample volume (cm3)
Sample entered by
Sample comment
Sample repository
Sample time-stamp
EOF
}

#sub out_smcs_ci {
#    return &cg_exp() . &cg_site() . &cg_hole() . &cg_core_drill()
#	. &cg_core_cur() . &cg_section()
#	. &cg_misc_m()
#	. &cg_sample();
#}

sub out_vcd_lithology {
    return << 'EOF';
VCD lithology name
VCD lithology rough classification
VCD lithology comment
VCD lithology describer
VCD lithology time-stamp
/VCD lithology hard\-rock .*/
VCD lithology sediment sorting
VCD lithology sediment roundness
VCD lithology sediment fabric
VCD lithology sediment consolidation
/VCD lithology sediment component .* abundance \(\%\)/
/VCD lithology sediment textural component .* abundance \(\%\)/
VCD microscopy
VCD lithology-distribution object
VCD lithology-distribution describer
VCD lithology-distribution time-stamp
VCD lithology-distribution lithology assigner
EOF
}

sub out_vcd_lithology_distribution {
    return << 'EOF';
VCD lithology-distribution object
VCD lithology-distribution describer
VCD lithology-distribution time-stamp
VCD lithology-distribution lithology assigner
VCD lithology name
VCD lithology rough classification
VCD lithology comment
VCD lithology describer
VCD lithology time-stamp
VCD lithology-distribution boundary object
VCD lithology-distribution boundary
VCD lithology-distribution boundary comment
VCD lithology-distribution boundary describer
VCD lithology-distribution boundary time-stamp
EOF
}

sub out_vcd_structure {
    return << 'EOF';
VCD lithology-distribution boundary object
VCD lithology-distribution boundary
VCD lithology-distribution boundary comment
VCD lithology-distribution boundary describer
VCD lithology-distribution boundary time-stamp
/VCD (deformation structure|drilling disturbance|sedimentary structure|hard\-rock structure) structure .*/
VCD structure comment
VCD structure describer
VCD structure time-stamp
VCD direction apparent azimuth 1 (degree)
VCD direction apparent plunge 1 (degree)
VCD direction apparent azimuth 2 (degree)
VCD direction apparent plunge 2 (degree)
VCD direction true azimuth (degree)
VCD direction true plunge (degree)
VCD direction geographic azimuth (degree)
VCD direction geographic plunge (degree)
EOF
}

sub cg_vcd_comment {
    return << 'EOF';
/VCD general (sedimentological|structure geological|petrological) comment on (Core|Section|Hole)/
/VCD general comment (sedimentological|structure geological|petrological) describer/
/VCD general comment (sedimentological|structure geological|petrological) time\-stamp/
EOF
}

sub cg_vcd_graphic_representation {
    return << 'EOF';
/VCD (sedimentological|structure geological|petrological) graphic representation image file/
/VCD (sedimentological|structure geological|petrological) graphic representation describer/
/VCD (sedimentological|structure geological|petrological) graphic representation time\-stamp/
EOF
}

sub out_vcd_comment {
    return &cg_vcd_comment() . &cg_vcd_graphic_representation();
}

sub cg_vcd_sum_lithounit {
    return << 'EOF';
VCD summarized-lithounit hole
VCD summarized-lithounit name
VCD summarized-lithounit definition
VCD summarized-lithounit pattern image file
VCD summarized-lithounit definition describer
VCD summarized-lithounit definition time-stamp
VCD summarized-lithounit distribution describer
VCD summarized-lithounit distribution time-stamp
EOF
}

sub out_fossil_occurrence_file {
    return << "EOF";
/Stratigraphy fossil occurrence .* file/
/Stratigraphy fossil occurrence .* observer/
/Stratigraphy fossil occurrence .* time\-stamp/
EOF
}

sub col_fossil_occurrence_marker {
    return << "EOF";
Stratigraphy fossil occurrence
EOF
}

sub out_fossil_occurrence {
    my ( $fossilgroup ) = @_;
    $fossilgroup = quotemeta( $fossilgroup );
    return << "EOF";
/Stratigraphy fossil occurrence $fossilgroup .*/
/Stratigraphy fossil occurrence [0-9]{3};$fossilgroup;[0-9]+ .*/
/Stratigraphy fossil occurrence $fossilgroup comment/
EOF
}

sub out_stratigraphy {
    return << 'EOF';
Stratigraphy horizon recognition file holes
Stratigraphy horizon recognition file
Stratigraphy horizon recognition
Stratigraphy horizon recognition direction
Stratigraphy horizon recognition age (Ma)
Stratigraphy horizon recognition ID
/Stratigraphy horizon recognition employed by age model .*/
Stratigraphy age model
Stratigraphy age model depth
Stratigraphy age model file
Stratigraphy age model builder
Stratigraphy age model time-stamp
Stratigraphy horizon age-model break horizon
Stratigraphy horizon age-model sedimentation rate
Stratigraphy horizon age-model top age (Ma)
Stratigraphy horizon age-model bottom age (Ma)
/Stratigraphy horizon age\-model sedimentation rate \(mm\/kyr\.\) .* \[.*\]/
EOF
}

sub cg_microbio {
    warn;
    return << 'EOF';
/Microbiology .*/
EOF
}

sub cg_microphoto {
    return << 'EOF';
Microphoto attached to
Microphoto subject
Microphoto image file
Microphoto image file MIME type
Microphoto microscope
Microphoto magnification
Microphoto observation method
Microphoto cross polarization
Microphoto comment
Microphoto photographer
EOF
}

sub cg_xct {
    return << 'EOF';
/X\-ray CT scanner [\+\-][0-9]+[\+\-][0-9]+ registerer/
/X\-ray CT scanner [\+\-][0-9]+[\+\-][0-9]+ registration time\-stamp/
/X\-ray CT scanner [\+\-][0-9]+[\+\-][0-9]+ dicom file/
/X\-ray CT scanner [\+\-][0-9]+[\+\-][0-9]+ dicom pixel width \(mm\)/
/X\-ray CT scanner [\+\-][0-9]+[\+\-][0-9]+ dicom pixel height \(mm\)/
/X\-ray CT scanner [\+\-][0-9]+[\+\-][0-9]+ dicom top space \(pixel\)/
/X\-ray CT scanner [\+\-][0-9]+[\+\-][0-9]+ dicom bottom space \(pixel\)/
/X\-ray CT scanner [\+\-][0-9]+[\+\-][0-9]+ dicom top space \(mm\)/
/X\-ray CT scanner [\+\-][0-9]+[\+\-][0-9]+ dicom bottom space \(mm\)/
/X\-ray CT scanner [\+\-][0-9]+[\+\-][0-9]+ converted image black CT value/
/X\-ray CT scanner [\+\-][0-9]+[\+\-][0-9]+ converted image white CT value/
/X\-ray CT scanner [\+\-][0-9]+[\+\-][0-9]+ converted image file/
EOF
}

sub cg_mscl {
    return << 'EOF';
/MSCL\-(W|C|S) registerer/
/MSCL\-(W|C|S) registration time\-stamp/
/MSCL\-(W|C|S) run date\-time/
/MSCL\-(W|C|S) run comment/
/MSCL\-(W|C|S) reference core thickness \(cm\)/
/MSCL\-(W|C|S) core liner thickness \(cm\)/
/MSCL\-(W|C|S) temperature \(degree C\)/
/MSCL\-(W|C|S) thickness deviation \(mm\)/
/MSCL\-(W|S) P\-wave velocity \(m\/s\)/
/MSCL\-(W|S) P\-wave amplitude/
/MSCL\-(W|S) P\-wave travel time \(microsec\.\)/
/MSCL\-(W|S) P\-wave single amplitude/
/MSCL\-(W|S) P\-wave travel time offset \(microsec\.\)/
/MSCL\-(W|S) P\-wave temperature correction \(degree C\)/
/MSCL\-(W|S) P\-wave salinity correction \(ppt\)/
/MSCL\-(W|S) P\-wave depth correction \(m\)/
/MSCL\-(W|S) P\-wave acoustic impedance/
/MSCL\-(W|S) gamma ray attenuation density \(g\/cm3\)/
/MSCL\-(W|S) fractional porosity/
/MSCL\-(W|S) gamma density constant A/
/MSCL\-(W|S) gamma density constant B/
/MSCL\-(W|S) gamma density constant C/
/MSCL\-(W|S) pore field density \(g\/cm3\)/
/MSCL\-(W|S) pore fluid density \(g\/cm3\)/
/MSCL\-(W|S) mineral grain density \(g\/cm3\)/
/MSCL\-(W|S) gamma count rate \(sec\.\)/
/MSCL\-(W|C|S) magnetic susceptibility \(x0\.0*1 SI\)/
/MSCL\-(W|C|S) magnetic susceptibility \(x0\.0*1 m3\/kg CGI\)/
/MSCL\-(W|C|S) magnetic susceptibility density correction/
/MSCL\-(W|C|S) magnetic susceptibility data acquisition period \(sec\.\)/
/MSCL\-(W|C|S) magnetic susceptibility loop sensor diameter \(cm\)/
/MSCL\-(W|C|S) raw magnetic susceptibility \(SI\)/
/MSCL\-(W|C|S) magnetic susceptibility sensor/
/MSCL\-(W|S) electrical resistivity \(Ohm\-m\)/
/MSCL\-(W|S) electrical resistivity calibration constant A/
/MSCL\-(W|S) electrical resistivity calibration constant B/
/MSCL\-(W|S) NCR response \(mV\)/
/MSCL\-C (SCI|SCE|SCI cut|SCE cut) spectrum file/
/MSCL\-C (SCI|SCE|SCI cut|SCE cut) Munsell/
/MSCL\-C (SCI|SCE|SCI cut|SCE cut) CIE X/
/MSCL\-C (SCI|SCE|SCI cut|SCE cut) CIE Y/
/MSCL\-C (SCI|SCE|SCI cut|SCE cut) CIE Z/
/MSCL\-C (SCI|SCE|SCI cut|SCE cut) CIE L\*/
/MSCL\-C (SCI|SCE|SCI cut|SCE cut) CIE a\*/
/MSCL\-C (SCI|SCE|SCI cut|SCE cut) CIE b\*/
/MSCL\-(W|C|S) (SCI|SCE|SCI cut|SCE cut) calibration date\-time/
/MSCL\-(W|S) calibration date\-time/
/MSCL\-(W|C|S) (SCI|SCE|SCI cut|SCE cut) calibration file/
/MSCL\-(W|S) calibration file/
EOF
### TODO: throw dummy values away
}

sub cg_mscl_s {
    return << 'EOF';
/MSCL\-S registerer/
/MSCL\-S registration time\-stamp/
/MSCL\-S run date\-time/
/MSCL\-S run comment/
/MSCL\-S reference core thickness \(cm\)/
/MSCL\-S core liner thickness \(cm\)/
/MSCL\-S temperature \(degree C\)/
/MSCL\-S thickness deviation \(mm\)/
/MSCL\-S P\-wave velocity \(m\/s\)/
/MSCL\-S P\-wave amplitude/
/MSCL\-S P\-wave travel time \(microsec\.\)/
/MSCL\-S P\-wave single amplitude/
/MSCL\-S P\-wave travel time offset \(microsec\.\)/
/MSCL\-S P\-wave temperature correction \(degree C\)/
/MSCL\-S P\-wave salinity correction \(ppt\)/
/MSCL\-S P\-wave depth correction \(m\)/
/MSCL\-S P\-wave acoustic impedance/
/MSCL\-S gamma ray attenuation density \(g\/cm3\)/
/MSCL\-S fractional porosity/
/MSCL\-S gamma density constant A/
/MSCL\-S gamma density constant B/
/MSCL\-S gamma density constant C/
/MSCL\-S pore field density \(g\/cm3\)/
/MSCL\-S pore fluid density \(g\/cm3\)/
/MSCL\-S mineral grain density \(g\/cm3\)/
/MSCL\-S gamma count rate \(sec\.\)/
/MSCL\-S magnetic susceptibility \(x0\.0*1 SI\)/
/MSCL\-S magnetic susceptibility \(x0\.0*1 m3\/kg CGI\)/
/MSCL\-S magnetic susceptibility density correction/
/MSCL\-S magnetic susceptibility data acquisition period \(sec\.\)/
/MSCL\-S magnetic susceptibility loop sensor diameter \(cm\)/
/MSCL\-S raw magnetic susceptibility \(SI\)/
/MSCL\-S magnetic susceptibility sensor/
/MSCL\-S electrical resistivity \(Ohm\-m\)/
/MSCL\-S electrical resistivity calibration constant A/
/MSCL\-S electrical resistivity calibration constant B/
/MSCL\-S NCR response \(mV\)/
/MSCL\-S calibration date\-time/
/MSCL\-S calibration file/
EOF
### TODO: throw dummy values away
}

sub cg_mscl_c {
    return << 'EOF';
/MSCL\-C registerer/
/MSCL\-C registration time\-stamp/
/MSCL\-C run date\-time/
/MSCL\-C run comment/
/MSCL\-C reference core thickness \(cm\)/
/MSCL\-C core liner thickness \(cm\)/
/MSCL\-C temperature \(degree C\)/
/MSCL\-C thickness deviation \(mm\)/
/MSCL\-C magnetic susceptibility \(x0\.0*1 SI\)/
/MSCL\-C magnetic susceptibility \(x0\.0*1 m3\/kg CGI\)/
/MSCL\-C magnetic susceptibility density correction/
/MSCL\-C magnetic susceptibility data acquisition period \(sec\.\)/
/MSCL\-C magnetic susceptibility loop sensor diameter \(cm\)/
/MSCL\-C raw magnetic susceptibility \(SI\)/
/MSCL\-C magnetic susceptibility sensor/
/MSCL\-C (SCI|SCE|SCI cut|SCE cut) spectrum file/
/MSCL\-C (SCI|SCE|SCI cut|SCE cut) Munsell/
/MSCL\-C (SCI|SCE|SCI cut|SCE cut) CIE X/
/MSCL\-C (SCI|SCE|SCI cut|SCE cut) CIE Y/
/MSCL\-C (SCI|SCE|SCI cut|SCE cut) CIE Z/
/MSCL\-C (SCI|SCE|SCI cut|SCE cut) CIE L\*/
/MSCL\-C (SCI|SCE|SCI cut|SCE cut) CIE a\*/
/MSCL\-C (SCI|SCE|SCI cut|SCE cut) CIE b\*/
/MSCL\-C (SCI|SCE|SCI cut|SCE cut) calibration date\-time/
/MSCL\-C (SCI|SCE|SCI cut|SCE cut) calibration file/
EOF
### TODO: throw dummy values away
}

sub cg_split_image {
    return << 'EOF';
/Split (working|archive) half section image registerer/
/Split (working|archive) half section image time\-stamp/
/Split (working|archive) half section image top \(pixel\)/
/Split (working|archive) half section image bottom \(pixel\)/
/Split (working|archive) half section image MIME type/
/Split (working|archive) half section image file/
/Split (working|archive) half section image pixel width \(mm\)/
/Split (working|archive) half section image pixel height \(mm\)/
/Split (working|archive) half section image aperture/
EOF
}

sub cg_mad {
    return << 'EOF';
MAD registerer
MAD registration time-stamp
MAD comment
MAD constant density of water (g/cm3)
MAD constant density of pore water (g/cm3)
MAD constant density of salt (g/cm3)
MAD constant salinity of pore water
MAD constant water ratio
MAD wet sample beaker ID
MAD wet sample beaker type
MAD wet sample beaker mass (g)
MAD wet sample beaker volume (cm3)
MAD wet sample beaker+sample mass (g)
MAD wet sample beaker+sample volume (cm3)
MAD wet sample mass (g)
/MAD .* wet sample volume \(cm3\)/
MAD dry sample beaker ID
MAD dry sample beaker type
MAD dry sample beaker mass (g)
MAD dry sample beaker volume (cm3)
MAD dry sample beaker+sample mass (g)
MAD dry sample beaker+sample volume (cm3)
MAD dry sample mass (g)
/MAD .* dry sample volume \(cm3\)/
MAD mass of pore water (g)
MAD mass of salt (g)
MAD mass of solids (g)
MAD water content wet
MAD water content dry
MAD volume of pore water (cm3)
MAD volume of salt (cm3)
/MAD .* volume of solids \(cm3\)/
/MAD .* porosity/
/MAD .* void ratio/
/MAD .* bulk density \(g\/cm3\)/
/MAD .* dry density \(g\/cm3\)/
/MAD .* grain density \(g\/cm3\)/
MAD attachment file
EOF
}

sub cg_tcon {
    return << 'EOF';
Thermal conductivity registerer
Thermal conductivity registration time-stamp
Thermal conductivity probe type
Thermal conductivity probe name
Thermal conductivity probe comment
Thermal conductivity average (W/m-K)
Thermal conductivity measurement horizon comment
Thermal conductivity number of runs
/Thermal conductivity run [0-9]+ thermal conductivity \(W\/m\-K\)/
/Thermal conductivity run [0-9]+ natural logarithm of the extreme time/
/Thermal conductivity run [0-9]+ number of solutions found for complete the heating curve/
/Thermal conductivity run [0-9]+ time start \(sec\.\)/
/Thermal conductivity run [0-9]+ time length \(sec\.\)/
/Thermal conductivity run [0-9]+ time end \(sec\.\)/
/Thermal conductivity run [0-9]+ contact value of the heating curve/
/Thermal conductivity run [0-9]+ method/
/Thermal conductivity run [0-9]+ comment/
/Thermal conductivity run [0-9]+ probe number/
Thermal conductivity internal standard file
EOF
}

sub cg_magnetometer {
    return << 'EOF';
/Magnetometer (Cryogenic|Spinner) (NRM|AFD [0-9]+\.?[0-9]* mT|THD [0-9]+\.?[0-9]* deg\.\(C\)) registerer/
/Magnetometer (Cryogenic|Spinner) (NRM|AFD [0-9]+\.?[0-9]* mT|THD [0-9]+\.?[0-9]* deg\.\(C\)) registration time\-stamp/
/Magnetometer (Cryogenic|Spinner) (NRM|AFD [0-9]+\.?[0-9]* mT|THD [0-9]+\.?[0-9]* deg\.\(C\)) run number/
/Magnetometer (Cryogenic|Spinner) (NRM|AFD [0-9]+\.?[0-9]* mT|THD [0-9]+\.?[0-9]* deg\.\(C\)) run date\-time/
/Magnetometer (Cryogenic|Spinner) (NRM|AFD [0-9]+\.?[0-9]* mT|THD [0-9]+\.?[0-9]* deg\.\(C\)) tray correction date\-time/
/Magnetometer (Cryogenic|Spinner) (NRM|AFD [0-9]+\.?[0-9]* mT|THD [0-9]+\.?[0-9]* deg\.\(C\)) area \(cm2\)/
/Magnetometer (Cryogenic|Spinner) (NRM|AFD [0-9]+\.?[0-9]* mT|THD [0-9]+\.?[0-9]* deg\.\(C\)) volume \(cm3\)/
/Magnetometer (Cryogenic|Spinner) (NRM|AFD [0-9]+\.?[0-9]* mT|THD [0-9]+\.?[0-9]* deg\.\(C\)) inclination \(degree\)/
/Magnetometer (Cryogenic|Spinner) (NRM|AFD [0-9]+\.?[0-9]* mT|THD [0-9]+\.?[0-9]* deg\.\(C\)) declination \(degree\)/
/Magnetometer (Cryogenic|Spinner) (NRM|AFD [0-9]+\.?[0-9]* mT|THD [0-9]+\.?[0-9]* deg\.\(C\)) intensity \(A\/m\)/
/Magnetometer (Cryogenic|Spinner) (NRM|AFD [0-9]+\.?[0-9]* mT|THD [0-9]+\.?[0-9]* deg\.\(C\)) X intensity, uncorrected \(A\/m\)/
/Magnetometer (Cryogenic|Spinner) (NRM|AFD [0-9]+\.?[0-9]* mT|THD [0-9]+\.?[0-9]* deg\.\(C\)) X moment, uncorrected \(Am2\)/
/Magnetometer (Cryogenic|Spinner) (NRM|AFD [0-9]+\.?[0-9]* mT|THD [0-9]+\.?[0-9]* deg\.\(C\)) X moment, drift and tray corrected \(Am2\)/
/Magnetometer (Cryogenic|Spinner) (NRM|AFD [0-9]+\.?[0-9]* mT|THD [0-9]+\.?[0-9]* deg\.\(C\)) standard deviation of X moment, uncorrected \(Am2\)/
/Magnetometer (Cryogenic|Spinner) (NRM|AFD [0-9]+\.?[0-9]* mT|THD [0-9]+\.?[0-9]* deg\.\(C\)) Y intensity, uncorrected \(A\/m\)/
/Magnetometer (Cryogenic|Spinner) (NRM|AFD [0-9]+\.?[0-9]* mT|THD [0-9]+\.?[0-9]* deg\.\(C\)) Y moment, uncorrected \(Am2\)/
/Magnetometer (Cryogenic|Spinner) (NRM|AFD [0-9]+\.?[0-9]* mT|THD [0-9]+\.?[0-9]* deg\.\(C\)) Y moment, drift and tray corrected \(Am2\)/
/Magnetometer (Cryogenic|Spinner) (NRM|AFD [0-9]+\.?[0-9]* mT|THD [0-9]+\.?[0-9]* deg\.\(C\)) standard deviation of Y moment, uncorrected \(Am2\)/
/Magnetometer (Cryogenic|Spinner) (NRM|AFD [0-9]+\.?[0-9]* mT|THD [0-9]+\.?[0-9]* deg\.\(C\)) Z intensity, uncorrected \(A\/m\)/
/Magnetometer (Cryogenic|Spinner) (NRM|AFD [0-9]+\.?[0-9]* mT|THD [0-9]+\.?[0-9]* deg\.\(C\)) Z moment, uncorrected \(Am2\)/
/Magnetometer (Cryogenic|Spinner) (NRM|AFD [0-9]+\.?[0-9]* mT|THD [0-9]+\.?[0-9]* deg\.\(C\)) Z moment, drift and tray corrected \(Am2\)/
/Magnetometer (Cryogenic|Spinner) (NRM|AFD [0-9]+\.?[0-9]* mT|THD [0-9]+\.?[0-9]* deg\.\(C\)) standard deviation of Z moment, uncorrected \(Am2\)/
/Magnetometer (Cryogenic|Spinner) (NRM|AFD [0-9]+\.?[0-9]* mT|THD [0-9]+\.?[0-9]* deg\.\(C\)) number of magnetic moment readings averaged/
/Magnetometer (Cryogenic|Spinner) (NRM|AFD [0-9]+\.?[0-9]* mT|THD [0-9]+\.?[0-9]* deg\.\(C\)) magnetic moment sample DAQ timer value \(millisec\.\)/
/Magnetometer (Cryogenic|Spinner) (NRM|AFD [0-9]+\.?[0-9]* mT|THD [0-9]+\.?[0-9]* deg\.\(C\)) X moment background 1 \(Am2\)/
/Magnetometer (Cryogenic|Spinner) (NRM|AFD [0-9]+\.?[0-9]* mT|THD [0-9]+\.?[0-9]* deg\.\(C\)) X moment background 2 \(Am2\)/
/Magnetometer (Cryogenic|Spinner) (NRM|AFD [0-9]+\.?[0-9]* mT|THD [0-9]+\.?[0-9]* deg\.\(C\)) Y moment background 1 \(Am2\)/
/Magnetometer (Cryogenic|Spinner) (NRM|AFD [0-9]+\.?[0-9]* mT|THD [0-9]+\.?[0-9]* deg\.\(C\)) Y moment background 2 \(Am2\)/
/Magnetometer (Cryogenic|Spinner) (NRM|AFD [0-9]+\.?[0-9]* mT|THD [0-9]+\.?[0-9]* deg\.\(C\)) Z moment background 1 \(Am2\)/
/Magnetometer (Cryogenic|Spinner) (NRM|AFD [0-9]+\.?[0-9]* mT|THD [0-9]+\.?[0-9]* deg\.\(C\)) Z moment background 2 \(Am2\)/
/Magnetometer (Cryogenic|Spinner) (NRM|AFD [0-9]+\.?[0-9]* mT|THD [0-9]+\.?[0-9]* deg\.\(C\)) background 1 DAQ timer value \(millisec\.\)/
/Magnetometer (Cryogenic|Spinner) (NRM|AFD [0-9]+\.?[0-9]* mT|THD [0-9]+\.?[0-9]* deg\.\(C\)) background 2 DAQ timer value \(millisec\.\)/
/Magnetometer (Cryogenic|Spinner) (NRM|AFD [0-9]+\.?[0-9]* mT|THD [0-9]+\.?[0-9]* deg\.\(C\)) measurement type/
/Magnetometer (Cryogenic|Spinner) (NRM|AFD [0-9]+\.?[0-9]* mT|THD [0-9]+\.?[0-9]* deg\.\(C\)) data type/
/Magnetometer (Cryogenic|Spinner) (NRM|AFD [0-9]+\.?[0-9]* mT|THD [0-9]+\.?[0-9]* deg\.\(C\)) whether drift corrected/
/Magnetometer (Cryogenic|Spinner) (NRM|AFD [0-9]+\.?[0-9]* mT|THD [0-9]+\.?[0-9]* deg\.\(C\)) whether tray corrected/
/Magnetometer (Cryogenic|Spinner) (NRM|AFD [0-9]+\.?[0-9]* mT|THD [0-9]+\.?[0-9]* deg\.\(C\)) X calibration \(emu\/Phi\)/
/Magnetometer (Cryogenic|Spinner) (NRM|AFD [0-9]+\.?[0-9]* mT|THD [0-9]+\.?[0-9]* deg\.\(C\)) Y calibration \(emu\/Phi\)/
/Magnetometer (Cryogenic|Spinner) (NRM|AFD [0-9]+\.?[0-9]* mT|THD [0-9]+\.?[0-9]* deg\.\(C\)) Z calibration \(emu\/Phi\)/
/Magnetometer (Cryogenic|Spinner) (NRM|AFD [0-9]+\.?[0-9]* mT|THD [0-9]+\.?[0-9]* deg\.\(C\)) X response \(cm\)/
/Magnetometer (Cryogenic|Spinner) (NRM|AFD [0-9]+\.?[0-9]* mT|THD [0-9]+\.?[0-9]* deg\.\(C\)) Y response \(cm\)/
/Magnetometer (Cryogenic|Spinner) (NRM|AFD [0-9]+\.?[0-9]* mT|THD [0-9]+\.?[0-9]* deg\.\(C\)) Z response \(cm\)/
EOF
}

sub cg_ams {
    return << 'EOF';
AMS mean magnetic susceptibility
AMS shape parameter T
AMS anisotropy factor L
AMS anisotropy factor F
AMS anisotropy factor P
AMS Kmax declination, geographic system (degree)
AMS Kmax inclination, geographic system (degree)
AMS Kmax normed susceptibility
AMS Kint declination, geographic system (degree)
AMS Kint inclination, geographic system (degree)
AMS Kint normed susceptibility
AMS Kmin declination, geographic system (degree)
AMS Kmin inclination, geographic system (degree)
AMS Kmin normed susceptibility
AMS run date-time
AMS registerer
AMS registration time-stamp
EOF
}

sub cg_xrf_core_logger {
    return << 'EOF';
XRF core logger registerer
XRF core logger registration time-stamp
XRF core logger measurement date-time
XRF core logger comment
XRF core logger X (mm)
XRF core logger Y (mm)
XRF core logger Z (mm)
XRF core logger tube voltage (kV)
XRF core logger tube current (mA)
XRF core logger path
XRF core logger collimator size (mm)
XRF core logger live time (sec.)
XRF core logger real time (sec.)
XRF core logger spectrum per channel (keV)
XRF core logger spectrum start channel (keV)
XRF core logger spectrum p per channel (keV)
XRF core logger spectrum p start channel (keV)
XRF core logger spectrum unit
XRF core logger spectrum n
XRF core logger quantization mode
XRF core logger quantization reference
XRF core logger quantization target
XRF core logger quantization BG dilution g str
XRF core logger quantization BG dilution g value
XRF core logger quantization BG remove g str
XRF core logger quantization BG remove g value
XRF core logger quantization BG sample g
XRF core logger spectrum file
/XRF core logger .* .*/
EOF
}

sub cg_xrd {
    return << 'EOF';
XRD registerer
XRD registration time-stamp
XRD attachment
EOF
}

sub out_headgas {
    return << 'EOF';
GC FID compound Ethane 
GC FID compound Ethylene 
GC FID compound Methane 
GC FID compound Propane 
GC FID compound Propylene 
GC FID compound comment
GC FID compound iso-Butane 
GC FID compound method directory
GC FID compound n-Butane 
GC FID compound registerer
GC FID compound registration time-stamp
EOF
}

sub out_cns_analysis {
    return &cg_chnso_ea() . &cg_ca() . &cg_carb();
}

sub cg_chnso_ea {
    return << 'EOF';
/Element Analyzer (bulk|acidified)\-[CHNSO]+ carbon \(wt \%\)/
/Element Analyzer (bulk|acidified)\-[CHNSO]+ hydrogen \(wt \%\)/
/Element Analyzer (bulk|acidified)\-[CHNSO]+ nitrogen \(wt \%\)/
/Element Analyzer (bulk|acidified)\-[CHNSO]+ sulfur \(wt \%\)/
/Element Analyzer (bulk|acidified)\-[CHNSO]+ carbon area/
/Element Analyzer (bulk|acidified)\-[CHNSO]+ hydrogen area/
/Element Analyzer (bulk|acidified)\-[CHNSO]+ nitrogen area/
/Element Analyzer (bulk|acidified)\-[CHNSO]+ sulfur area/
/Element Analyzer (bulk|acidified)\-[CHNSO]+ measurement date\-time/
/Element Analyzer (bulk|acidified)\-[CHNSO]+ registration time\-stamp/
/Element Analyzer (bulk|acidified)\-[CHNSO]+ registerer/
/Element Analyzer (bulk|acidified)\-[CHNSO]+ chromatogram file/
EOF
}

sub cg_ca {
    return << 'EOF';
/Carbonate Analyzer .*/
EOF
}

sub cg_carb {
    return << 'EOF';
Carbonate EAbulk-CA total non-carbonate carbon (wt%)
EOF
}

sub cg_chromatography {
    warn;
    return << 'EOF';
/(HPLC|ICP\-MS|GC ECD|GC FID|GC NGA \(FID\)|GC NGA \(TCD\)|GC NGA|GC TCD\&FID|GC-MSD) compound .*/
/(HPLC|ICP\-MS|GC ECD|GC FID|GC NGA \(FID\)|GC NGA \(TCD\)|GC NGA|GC TCD\&FID|GC-MSD) compound registration time\-stamp/
/(HPLC|ICP\-MS|GC ECD|GC FID|GC NGA \(FID\)|GC NGA \(TCD\)|GC NGA|GC TCD\&FID|GC-MSD) compound registerer/
/(HPLC|ICP\-MS|GC ECD|GC FID|GC NGA \(FID\)|GC NGA \(TCD\)|GC NGA|GC TCD\&FID|GC-MSD) compound comment/
/(HPLC|ICP\-MS|GC ECD|GC FID|GC NGA \(FID\)|GC NGA \(TCD\)|GC NGA|GC TCD\&FID|GC-MSD) compound method directory/
/(HPLC|ICP\-MS|GC ECD|GC FID|GC NGA \(FID\)|GC NGA \(TCD\)|GC NGA|GC TCD\&FID|GC-MSD) compound attachment file/
EOF
}

sub cg_iw {
    return << 'EOF';
Interstitial water Alkalinity Titrator System Alkalinity mM
Interstitial water Alkalinity Titrator System Alkalinity mM comment
Interstitial water Alkalinity Titrator System Alkalinity mM file
Interstitial water Alkalinity Titrator System Alkalinity mM registerer
Interstitial water Alkalinity Titrator System Alkalinity mM registration time-stamp
Interstitial water Alkalinity Titrator System pH pmH
Interstitial water Alkalinity Titrator System pH pmH comment
Interstitial water Alkalinity Titrator System pH pmH file
Interstitial water Alkalinity Titrator System pH pmH registerer
Interstitial water Alkalinity Titrator System pH pmH registration time-stamp
EOF
}

sub cg_extra_scalar_iw {
    return << 'EOF';
EOF

# will be deleted these data from DB
return << 'EOF';
Extra scalar alkalinity [mM]: pore water::alkalinity [mM]: titrator (potentiometric titration)
Extra scalar alkalinity [mM]: pore water::alkalinity [mM]: titrator (potentiometric titration) registerer
Extra scalar alkalinity [mM]: pore water::alkalinity [mM]: titrator (potentiometric titration) registration time-stamp
Extra scalar pH: pore water::pH: pH electrode (attached to titrator)
Extra scalar pH: pore water::pH: pH electrode (attached to titrator) registerer
Extra scalar pH: pore water::pH: pH electrode (attached to titrator) registration time-stamp
Extra scalar pmH: pore water::pmH: pH electrode (attached to titrator)
Extra scalar pmH: pore water::pmH: pH electrode (attached to titrator) registerer
Extra scalar pmH: pore water::pmH: pH electrode (attached to titrator) registration time-stamp
EOF
}

sub out_trash {
    return << 'EOF';
EOF
}

1;
