#!/usr/bin/perl 

# a short script that will read all XML files in this 
# directory, (as SEMEVAL 2013 task7 files), and outputs 
# one T-H pair with gold annotation, in the format of 
# EXCITEMENT open platform rawfile format. (extended RTE5
# format) 

use warnings; 
use strict; 

#
# Global variables 

# XML Header as Here-doc 
my $XML_HEADER = <<END; 
<?xml version="1.0" encoding="UTF-8"?>
<entailment-corpus lang="EN">
END

# XML Footer as Here-doc 
my $XML_FOOTER = <<END;
</entailment-corpus>
END


# start of the code 
my @files = glob ("*.xml"); 

# print header 
print $XML_HEADER, "\n"; 

foreach (@files) 
{
    my $filename = $_; 
    open FILE, "<$filename"; 
    my $ref_answer; 

    # get reference answer 
    while(<FILE>)
    {
	my $line = $_; 

	if ($line =~ /<referenceAnswer id=/)
	{
	    $line =~ /<referenceAnswer id.+?>(.+?)<\/referenceAnswer>/; 
	    $ref_answer = $1; 
	    last; 
	}
    }
    close FILE; 
    #dcode # print STDERR $filename, "\t", $ref_answer, "\n"; 

    # now, get student answers with label. 
    # print out on the fly, as RTE5+ format. 
    open FILE, "<$filename"; 
    my $student_answer; 
    my $label; 
    
    while(<FILE>)
    {
	my $line = $_;
	if ($line =~ /<studentAnswer id=/)
	{
	    $line =~ /<studentAnswer id=\"(.+?)\" accuracy=\"(.+?)\">(.+)<\/studentAnswer>/; 
	    my $id = $1; 
	    my $label = $2; 
	    my $student_answer = $3; 
	    #dcode # print STDERR "$id\t$label\t$student_answer\n"; 
	    
	    my $entailment_label; 
	    if ($label eq "correct") {
		$entailment_label = "ENTAILMENT"; 
	    }
	    else {
		$entailment_label = "NONENTAILMENT"; 
	    }
	    print "\t<pair id=\"" . $id . "\" entailment=\"" . $entailment_label . "\" task=\"QA\">\n"; 
	    print "\t\t<t>" . $student_answer . "<\/t>\n"; 
	    print "\t\t<h>" . $ref_answer . "<\/h>\n"; 
	    print "\t<\/pair>\n"; 
	}	
    }
    close FILE; 
}

print $XML_FOOTER, "\n"; 

