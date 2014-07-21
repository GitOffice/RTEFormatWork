# meteor table as map of map.
# you can do the followings with the class
# - drop entries with value lower than a given threshold
# - sort entries 


class MeteorTable

  # table as hash of hash
  # table['phrase1']['phrase2'] = prob of phrase1 -> phrase2
  #                   
  attr_reader :table
  attr_reader :count_entries
  attr_accessor :threshold_prob
  
  def initialize(path, threshold=0.01, drop_single_word_rules=false)
    # drop_single_word_rules is not implemented yet 

    # init variables 
    @table = Hash.new
    @count_entries = 0
    @count_original_entries = 0
    @threshold_prob = threshold

    # open file
    file = File.open(path)
    $stderr.puts("Reading phrase table from #{path}... ")
    
    while(line1 = file.gets())
      phrase1 = file.gets().chomp
      phrase2 = file.gets().chomp 
      prob = line1.to_f

      @count_original_entries = @count_original_entries+1
      next if (prob < @threshold_prob) 

      # update table 
      if (not @table.has_key?(phrase1))
        @table[phrase1] = Hash.new()
      end
      @table[phrase1][phrase2] = prob
      @count_entries = @count_entries + 1
      #$stderr.puts ("#{phrase1} -> #{phrase2} :#{@table[phrase1][phrase2]}")
    end
    $stderr.puts("#{@count_entries} of phrase rules have read, among #{@count_original_entries} original entries.")     
  end

  def sort_and_printout

    $stderr.puts("sorting ...") 
    keys = @table.keys.sort

    $stderr.puts("printing out ...")    
    keys.each do |lhs|
      inner_keys = @table[lhs].keys.sort
      
      inner_keys.each do |rhs|
        prob = @table[lhs][rhs]
        puts prob
        puts lhs.downcase
        puts rhs.downcase
      end
    
    end # each 

  end # of def 
  
end

# simple read, sort, drop (below 0.01 default prob), and print out.
#mtable = MeteorTable.new("data1")
mtable = MeteorTable.new("paraphrases.aligned.it.filtered.meteorStyle", 0.00001)
mtable.sort_and_printout

