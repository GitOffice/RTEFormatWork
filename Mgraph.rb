
# A class that holds WP2 merged graph data, 
# An instance of this class extracts inter-fragment edges (@inter_fragment_edges) and node texts(@node_hash). Useful to make entailment test data. 
# TODO: non-existing-edges  

class Mgraph

  # Full XML data of the merged graph 
  #attr_reader :xml_raw_data 

  # List of inter-fragment edges, array of [source node id - target node id], [...], ... 
  attr_reader :inter_fragment_edges 

  # Number of nodes and edges 
  attr_reader :count_nodes, :count_edges

  # The node text as a hash (node_id as keys, node text as value)
  attr_reader :node_hash 

  # initialize one Mgraph object with XML as one string 
  def initialize(xml_raw)
    @xml_lines_arr = xml_raw.split(/\n/) 
    extract_nodes(xml_raw) 
    extract_edges(xml_raw)
  end

  # extract nodes and store it in @node_hash, where node_hash[id] = text string
  def extract_nodes(xml_raw)
    @count_nodes = 0 
    @node_hash = Hash.new

    @xml_lines_arr.each_index do |i|
      if @xml_lines_arr[i].match(/<node /) # node line 
        @count_nodes = @count_nodes + 1 
        node_id = match_node_id(@xml_lines_arr[i]) 
        #print("#{node_id} \t") #dcode 
        node_text = match_node_text(@xml_lines_arr[i+1]) # always next line
        #puts("#{node_text} \n") #dcode 
        @node_hash[node_id] = node_text 
      end
    end
    puts("total #{@count_nodes} nodes here.") 
  end 

  # extract edges from raw XML and fills in @inter_fragment_edges
  def extract_edges(xml_raw)
    @count_edges = 0 
    @inter_fragment_edges = [] 
    
    @xml_lines_arr.each_index do |i|
      if @xml_lines_arr[i].match(/<edge /) # edge start line 
        @count_edges = @count_edges +1
        source, target = match_edge_source_target(@xml_lines_arr[i])
        #puts("#{source} -> #{target}") #dcode 
        #puts(@node_hash[source], " => ", @node_hash[target]) #dcode 
        if not same_fragment?(source, target) 
          @inter_fragment_edges.push([source, target]) 
        end
      end
    end
    puts "In total #{count_edges} edges, and #{@inter_fragment_edges.size()} inter-fragment edges." 
  end

  #
  # and here goes some internal utility methods 
  # 

  def match_node_id(string)
    id = string.match(/ id ?="(.+?)">/)[1]
  end

  def match_node_text(string)
    text = string.match(/<original_text>(.+?)<\/original_text>/)[1] 
  end

  def match_edge_source_target(string)
    source = string.match(/ source="(.+?)"/)[1]
    target = string.match(/ target="(.+?)"/)[1] 
    return [source, target] 
  end

  def same_fragment?(id1, id2) 
    # if all is same but only the last _[ ] part is different.. 
    id1_postfix_removed = id1.match(/(.+)_.+?$/)[1]
    id2_postfix_removed = id2.match(/(.+)_.+?$/)[1]
    id1_postfix_removed.eql? id2_postfix_removed 
  end
  
end
