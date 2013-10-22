
# A class that holds WP2 merged graph data, 
# An instance of this class extracts inter-fragment edges (@inter_fragment_edges) and node texts(@node_hash). Useful to make entailment test data. 

class Mgraph

  # Full XML data of the merged graph 
  #attr_reader :xml_raw_data 

  # Hash that represents inter-fragment edges (and non-edges) 
  # id: "source_node_id >>> target_node_id" 
  # * @inter_fragment_edges[id] == true: existing (Entailment) edge 
  # * @inter_fragment_edges[id] == false: non-existing (nonentailment) edge 
  # * @inter_fragment_edges[id] == nil: not-defined. (intra fragment, etc) 
  attr_reader :inter_fragment_edges 

  # Number of nodes and edges 
  attr_reader :count_nodes, :count_edges, :count_non_edges

  # The node text as a hash (node_id as keys, node text as value)
  attr_reader :node_hash 

  # initialize one Mgraph object with XML as one string 
  def initialize(xml_raw)
    @xml_lines_arr = xml_raw.split(/\n/) 
    extract_nodes
    extract_edges
    extract_non_edges
  end

  # extract nodes and store it in @node_hash, where node_hash[id] = text string
  def extract_nodes
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
  def extract_edges
    @count_edges = 0 
    @inter_fragment_edges = Hash.new 
    
    @xml_lines_arr.each_index do |i|
      if @xml_lines_arr[i].match(/<edge /) # edge start line 
        @count_edges = @count_edges +1
        source, target = match_edge_source_target(@xml_lines_arr[i])
        #puts("#{source} -> #{target}") #dcode 
        #puts(@node_hash[source], " => ", @node_hash[target]) #dcode 
        if not same_fragment?(source, target) 
          #@inter_fragment_edges.push([source, target]) 
          key = source + " >>> " + target
          @inter_fragment_edges[key] = true 
        end
      end
    end
    puts "In total #{count_edges} edges, and #{@inter_fragment_edges.size()} inter-fragment edges." 
  end

  # this method extract non-existing (could have been, but not there) 
  # edges among inter-fragment nodes. ... 
  # such non-edges will be the base for non-entailment relations. 
  # (is this really non entailment? hmm. let's check. ) 
  def extract_non_edges
    @count_non_edges=0 

    # sanity check 
    if (@inter_fragment_edges == nil)
      raise RuntimeError, "intergrity failure: extract_non_edges must be called after extract_edges, but we have no edge hash yet." 
    end

    if (@node_hash == nil)
      raise RuntimeError, "intergrity failure: extract_non_edges must be called after extract_nodes, but we have no node hash yet." 
    end

    # run over all nodes, 
    # check all node-pairs that are not in the same fragments,
    # if not in edge list, 
    @node_hash.keys.each do |node_l|
      @node_hash.keys.each do |node_r|
        next if (node_l.eql? node_r) # no need to check self 
        next if same_fragment?(node_l, node_r) # no need to check in-fragment

        id = node_l + " >>> " + node_r 

        if not @inter_fragment_edges[id] 
          # we don't have this edge. So add it as interfragment non-edge 
          @inter_fragment_edges[id] = false 
          @count_non_edges = @count_non_edges + 1
        end
      end
    end
    puts("And non-edge counts are #{@count_non_edges}") 
  end
  #############################################
  # and here goes some internal utility methods 
  #############################################

  private 
  def match_node_id(string)
    id = string.match(/ id ?="(.+?)">/)[1]
  end

  private 
  def match_node_text(string)
    text = string.match(/<original_text>(.+?)<\/original_text>/)[1] 
  end

  private
  def match_edge_source_target(string)
    source = string.match(/ source="(.+?)"/)[1]
    target = string.match(/ target="(.+?)"/)[1] 
    return [source, target] 
  end

  private 
  def same_fragment?(id1, id2) 
    # if all is same but only the last _[ ] part is different.. 
    id1_postfix_removed = id1.match(/(.+)_.+?$/)[1]
    id2_postfix_removed = id2.match(/(.+)_.+?$/)[1]
    id1_postfix_removed.eql? id2_postfix_removed 
  end
  
end
