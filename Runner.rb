# This small script uses
# Mgraph.rb (WP2 graph data), and EOPFormatOut.rb (XML outputter).
# to generate EOP data in its XML format (training & testing purpose) 

require "Mgraph.rb"
require "EOPFormatOut.rb"

if not ARGV[0]
  puts "needs one or more filename[s] of WP2 merged graph XML"
  exit
end

# get filenames from args

# for each file, loads the file, make new Mgraph
# fetch edges and non-edges


# once collected all edges and non-edges, process the data into
# something that can be passed into EOPFormatter. 
# e.g.  [ [text, hypothesis, id, relation, task(can be nil)], ...] 

# Okay? now print via print_entailment_corpus

# done. Hey. Don't forget to run a XML validator to check it is
# Okay. Use "rawinput.rnc" (or rawinput.dtd) scheme file for this. 

