# This small script uses
# Mgraph.rb (WP2 graph data), and EOPFormatOut.rb (XML outputter).
# to generate EOP data in its XML format (training & testing purpose) 

require_relative "Mgraph.rb"
require_relative "EOPFormatOut.rb"

if not ARGV[0]
  puts "needs one or more filename[s] of WP2 merged graph XML"
  exit
end

# main data holder 
$entailment_edge_data = [] 
$nonentailment_edge_data = []

# get filenames from args
# (pending)
ARGV.each do |filename| 

#filename = ARGV[0] # update this (pending) 

# for each file, loads the file, make new Mgraph
# fetch edges and non-edges
rawxml = File.open(filename).read
x = Mgraph.new(rawxml) 
edges = x.inter_fragment_edges() 
nodes = x.node_hash() 

# edge Hash 
# id: "source_node_id >>> target_node_id" 
# * @inter_fragment_edges[id] == true: existing (Entailment) edge 
# * @inter_fragment_edges[id] == false: non-existing (nonentailment) edge 
# * @inter_fragment_edges[id] == nil: not-defined. (intra fragment, etc) 

edges.keys.each do |key|
  (source, target) = key.split(" >>> ")
  source_text = nodes[source]
  target_text = nodes[target]

  if (source_text == nil or target_text == nil)# sanity check, 
    $stderr.puts("something wrong, internal integrity failure, edge-node id - text")
    exit
  end
  # we have the data. edges[key] holds entailment edges, 
  # source_text and target_text holds t & h. 
  # put the data into 
  # something that can be passed into EOPFormatter. 
  # e.g.  [ [text, hypothesis, id, relation, task(can be nil)], ...] 

  t = []
  t[0] = source_text
  t[1] = target_text
  t[2] = source + "-" + target 
  if (edges[key] == true) # entailment edge 
    #puts("#{source_text} >>> #{target_text}") #dcode
    t[3] = "ENTAILMENT" 
    $entailment_edge_data.push(t)
  else (edges[key] == false)
    t[3] = "NONENTAILMENT"
    $nonentailment_edge_data.push(t)
  end
  # no need to check nil case, since we started with keys 

end

end

#puts($edge_data) #dcode 

# Okay? now print via print_entailment_corpus
edge_data = $entailment_edge_data + $nonentailment_edge_data 
formatter = EOPFormatOut.new("EN", "usecase1") # language code, task 
formatter.print_entailment_corpus(edge_data)

# done. Hey. Don't forget to run a XML validator to check it is
# Okay. Use "rawinput.rnc" (or rawinput.dtd) scheme file for this. 

