require 'optparse' 
require 'ostruct'
require 'date'
require 'rubygems'
require 'appscript';include Appscript
require 'amatch';include Amatch
require 'chronic'
require 'rdoc'

class OmniTask
  attr_reader :options

  def initialize(arguments, stdin)
    @arguments = arguments
    @stdin = stdin
    
    # Set defaults
    @options = OpenStruct.new
    @options.verbose = false
    @options.quiet = false

    # TO DO - add additional defaults
  end

  # Parse options, check arguments, then process the command
  def run
    if parsed_options? && !arguments_valid?
      usage_and_exit
    end

    if parsed_options? && arguments_valid?
      if @options.verbose
        puts "Start at #{DateTime.now}\n\n"
        puts "--Options--------------------"
        output_options if @options.verbose # [Optional]
        puts "--Task-Properties------------" 
      end
      process_arguments
      process_command
      
      puts "\nFinished at #{DateTime.now}" if @options.verbose
    end
  end
  
  protected
  
    def parsed_options?
      
      # Specify options
      opts = OptionParser.new
      opts.on( '-h', '--help', 'Display this screen' ) do
        puts opts
        puts "\nNotes are entered in parenthesis: This is my title (This is the note)"
        puts "Tags are added with hashmarks #like #this. They can appear anywhere in the title string, but will be removed from the output."
        puts "Note: natural-language date parsing will work better if you install the Chronic Ruby gem (`sudo gem install chronic`)." unless TodoUtils.new.use_chronic
        exit(0)
      end
      opts.on('-V', '--verbose', 'Verbose logging')    { @options.verbose = true }
      opts.on('-q', '--quiet', 'Run silently')      { @options.quiet = true }
      opts.on('-g', '--growl', 'Use Growl notifications')  { @options.growl = true }
      # TO DO - add additional options
            
      opts.parse!(@arguments) rescue return false
      
      process_options
      true      
    end

    # Performs post-parse processing on options
    def process_options
      @options.verbose = false if @options.quiet
      if @options.growl
        procs = app("System Events").processes.bundle_identifier.get(:result_type => :list)

        if procs.include? "com.Growl.GrowlHelperApp"
          app("Growl").register(:as_application => "OTask", :all_notifications => ['Alert'], :default_notifications => ['Alert'], :icon_of_application => "OmniFocus")
        else
          @options.growl = false
        end
      end
    end
    
    def output_options
      @options.marshal_dump.each do |name, val|        
        puts "  #{name}: #{val}"
      end
    end

    # True if required arguments were provided
    def arguments_valid?
      # TO DO - implement your real logic here
      @arguments.length == 1 ? true : false
    end
    
    # Setup the arguments
    def process_arguments
      input = @stdin.stat.size > 0 ? @stdin.read : nil
      titlestring = @arguments.join(' ')
      
      # check for trailing ! (flagged task)
      @options.flagged = titlestring.match(/ !\Z/).nil? ? false : true
      titlestring.sub!(/ !\Z/,'') if @options.flagged

      # check for #project in the string
      projmatch = titlestring.match(/ ?#([a-z0-9]+)/i)
      @options.project = projmatch.nil? ? nil : projmatch[1]
      titlestring.sub!(/ ?##{projmatch[1]}/,'') unless projmatch.nil?

      # check for @contexts
      contextmatch = titlestring.match(/ @([^ ]+)/)
      @options.context = contextmatch.nil? ? false : contextmatch[1]
      titlestring.sub!(/ @[^ ]+/,'') unless contextmatch.nil?

      # start/due date
      startmatch = titlestring.match(/ s(?:tart)?\(([^\)]+)\)/)
      @options.start = startmatch.nil? ? false : startmatch[1]
      titlestring.sub!(/ s(tart)?\(([^\)]+)\)/,'') unless startmatch.nil?
      duematch = titlestring.match(/ d(?:ue)?\(([^\)]+)\)/)
      @options.due = duematch.nil? ? false : duematch[1]
      titlestring.sub!(/ d(ue)?\(([^\)]+)\)/,'') unless duematch.nil?

      # creation date
      creationmatch = titlestring.match(/ c(?:reate)?\(([^\)]+)\)/)
      @options.creation = creationmatch.nil? ? false : creationmatch[1]
      titlestring.sub!(/ c(reate)?\(([^\)]+)\)/,'') unless creationmatch.nil?



      @options.notes = ''
      if titlestring =~ /\(([^\)]+)\)/
        @options.notes = $1
        titlestring.gsub!(/\(([^\)]+)\)/,'')
      end
      if @options.notes == '' && !input.nil? # check for piped input on STDIN
        @options.notes = input
      elsif @options.notes && input
        @options.notes = @options.notes + "\n\n" + input
      end
      @options.name = titlestring
    end

    def usage_and_exit
      puts 'Usage: otask [options] "Task string"'
      puts
      puts "For help use: otask -h"

      exit(0)
    end
    
    def output_version
      puts "#{File.basename(__FILE__)} version #{VERSION}"
    end

    def add_task(dd, props)

      if props['project']
        proj_name = props["project"]
        proj = dd.flattened_tasks[proj_name]
      end
      if props['context']
        ctx_name = props["context"]
        ctx = dd.flattened_contexts[ctx_name]
      end

      tprops = props.inject({}) do |h, (k, v)|
        h[:"#{k}"] = v
        h
      end

      tprops.delete(:project)
      tprops[:context] = ctx if props['context']

      t = dd.make(:new => :inbox_task, :with_properties => tprops)
      t.assigned_container.set(proj) if props['project']

      return true
    end

    def best_match(items,fragment)

      highscore = {'score'=>0,'name'=>nil}
      items.each {|item|
        if fragment && !item.nil?
          score = (Jaro.new(item).match(fragment) * 10).to_i
          highscore = score > highscore['score'] ? {'score'=>score,'name'=>item} : highscore
        end
      }
      return highscore['name']

    end
    
    def parse_date(datestring)
      days = 0
      if datestring =~ /^\+(\d+)$/
        days = (60 * 60 * 24 * $1.to_i)
        newdate = Time.now + days
      else
        newdate = Chronic.parse(datestring, {:context => :future, :ambiguous_time_range => 8})
      end
      # parsed = newdate.strftime('%D %l:%M%p').gsub(/\s+/,' ');
      # return parsed =~ /1969/ ? false : parsed
      return newdate
    end
    
    def growl(title, message)
      app("Growl").notify(:title => title, :description => message, :application_name => "OTask", :with_name => "Alert") if @options.growl
    end

    def process_command
      of = app('OmniFocus')
      dd = of.default_document

      @props = {}
      @props['name'] = @options.name
      if @options.project
        projs = dd.flattened_projects.name.get
        @props['project'] = best_match(projs,@options.project)
      end
      if @options.context
        ctxs = dd.flattened_contexts.name.get
        @props['context'] = best_match(ctxs,@options.context)
      end
      @props['start_date'] = parse_date(@options.start) if @options.start
      @props['due_date'] = parse_date(@options.due) if @options.due
      @props['creation_date'] = parse_date(@options.creation) if @options.creation
      @props['note'] = @options.notes unless @options.notes == ''
      @props['flagged'] = @options.flagged
      add_task(dd, @props)
      unless @options.quiet
        o = "Task added to "
        o += @props['project'].nil? ? "Inbox" : @props['project']
        o += ", context "+@props['context']+"." unless @props['context'].nil?
        if @options.growl
          growl("Task created",o)
        else
          puts o
        end
      end
      @props.each do |name, val|        
        puts "  #{name}: #{val}"
      end if @options.verbose
    end
end
