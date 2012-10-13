# this small perl script will convert german RTE3 (translated) 
# data into EXCITEMENT (RTE5-based) XML format. 
# It doesn't really parse XML... so only works on DFKI data file. 

use strict; 
use warnings; 
#use Getopt::Std; # no options for now 

#
# Global variables 

# XML Header as Here-doc 
my $XML_HEADER = <<END; 
<?xml version="1.0" encoding="UTF-8"?>
<entailment-corpus lang="DE">
END

# XML Footer as Here-doc 
my $XML_FOOTER = <<END;
</entailment-corpus>
END


#
# Start of the code 
unless ($ARGV[0])
{
    print "Usage: perl rte3_to_eopformat.pl [rte3 XML file]\nConverted output will be printed on STDOUT. \n(e.g. perl rte3_to_eopformat.pl testin.xml > testout.xml)\n "; 
    die; 
}

open FILE, "<$ARGV[0]" or die "unable to open $ARGV[0]"; 

print STDERR "Processing $ARGV[0]...\n"; 
my @line;
while(<FILE>)
{
    s/\r\n$/\n/; # change dos \r\n to simple \n
    push @line, $_;
}
close FILE; 

#
# Start of the processing 
# Now the file is in @line
print $XML_HEADER;
for(my $i=0; $i < @line; $i++)
{
    next unless $line[$i] =~ /<pair id="/; # we only process pairs! pass until seeing pair
    my $pairline = $line[$i]; 
    my $tline = $line[++$i]; 
    my $hline = $line[++$i]; 
    my $pairend = $line[++$i]; 
    
    # remove length, some prediction
    $pairline =~ s/ BoW_Prediction="\S+"//; 
    $pairline =~ s/ length="\S+"//; 
    $pairline =~ s/ Triple_Prediction="\S+"//; 

    # Vico data
    if ($pairline =~ /judgement/ and $pairline =~ /hLangFeatures/) 
    {   
        # add missing task, and remove unneeded attributes 
	$pairline =~ s/ judgement="\S+"//; 
	$pairline =~ s/ hLangFeatures="\S+"//; 
	$pairline =~ s/>/ task="SUM">/
    }          


    # Convert output 
    $pairline =~ s/entailment="YES"/entailment="ENTAILMENT"/; 
    $pairline =~ s/entailment="NO"/entailment="NONENTAILMENT"/; 

    print $pairline; 
    print $tline;
    print $hline; 
    print $pairend; 
}
print $XML_FOOTER; 
