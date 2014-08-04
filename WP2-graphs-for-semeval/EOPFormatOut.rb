
# A class that knows how to generate EOP XML format (RTE5+) 
# from a list of (id, text, hypothesis, entailment_relation), .. 
# (and also with metadata) 
# * This class does no checking of XML schema. 
# * To check XML validity, you have to use (externally) a XML validator to check output, with provided rawinput.dtd/rnc scheme file.  

class EOPFormatOut

  # metadata for the whole XML file, language (Mandatory) and default task (optional) 
  attr_reader :lang, :default_task 

  # initialize a XML printer with metadata. 
  def initialize(lang, default_task=nil)
    @lang = lang 
    @header = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>"
    @opening = "<entailment-corpus lang=\"#{@lang}\">"
    @closing = "</entailment-corpus>"
    @default_task = default_task if (default_task)
  end

  # print one <pair> element 
  def print_one_pair(text, hypothesis, id, relation, task=nil)     
    # print pair opening line 
    task = @default_task if (@default_task)
    if (task) 
      puts("\t<pair id=\"#{id}\" entailment=\"#{relation}\" task=\"#{task}\" >")
    else 
      puts("\t<pair id=\"#{id}\" entailment=\"#{relation}\" >")
    end
    # print text & hypothesis 
    puts("\t\t<t>#{text}</t>")
    puts("\t\t<h>#{hypothesis}</h>") 
    # print pair closing line 
    puts("\t</pair>") 
  end
  
  # print one <entailment_corpus> that holds all pairs 
  # input is a list of list where
  # [ [text, hypothesis, id, relation, task(can be nil)], ...] 
  def print_entailment_corpus(th_pairs) 
    # print header and opening 
    puts(@header) 
    puts(@opening) 

    th_pairs.each do |pair|
      print_one_pair(pair[0], pair[1], pair[2], pair[3], pair[4]) 
    end
    
    puts(@closing) 
    # print closing 
  end
      

end # of class EOPFormatOut 
