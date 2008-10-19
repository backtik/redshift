# Spec
#   self.describe
#   specs
#   examples
#   has_exception?
#   total_failures
#   total_errors
#   filter_entries_by_embedded_expressions
#   extract_special_entries
#   make_examples_from_entries
#   example_by_id
#   executor
#   
# Spec::Executor
#   merge_exceptions
#   run
# 
# Spec::Runner
#   total_examples
#   specs
#   specs_map
#   add_all_specs(specs)
#   add_spec
#   get_spec_by_id
#   get_spec_by_context
#   has_exception
#   total_failures
#   total_errors
#   run
#   rerun
# 
# Spec::Logger
#   on_runner_start
#   on_runner_end
#   blink_title
#   on_spec_start
#   on_spec_end
#   on_example_start
#   on_example_end
#   
# Spec::Matchers
#   include
#   length
#   equality
#   nil
#   date
#   object
#   array
#   number
#   string
#   pattern
#   
# Spec::DSL (module)
#   should_fail
#   should_be
#   should_not_be
#   should_be_empty
#   should_not_be_empty
#   should_be_true
#   should_not_be_true
#   should_be_false
#   should_not_be_false
#   should_be_nil
#   should_not_be_nil
#   should_have
#   should_not_have
#   should_have_exactly
#   should_have_at_least
#   should_have_at_most
#   should_include
#   should_not_include
#   should_match
#   should_not_match
#

# RedSpec is a BDD library designed for Red (url)
# RedSpec draws inspiration from both Ruby RSpec and Javascript JSSpec
# Using:
# RedSpec is intended for use with Red Herring, the framework-independant Red runner (url)


class String
  # returns the underlying javascript value of a string as a native javascript object
  def js
    `#{self}._value`
  end
end


module DSL
  def should (expression)
    expression
  end
  
  def equal(other)
    true
  end
end

# Just stores the @@spec_list class variables. @@spec_list is an array of
# all the specs created with Spec.describe. This might go away with everthing nested inside
# of class Spec
class RedSpec
  @@specs_list = []
  def self.specs
    @@specs_list
  end
  
  def self.escape_tags(string)
    return string
  end
end

class Spec  
  attr_accessor :name, :block, :examples, :runner
  
  def self.describe(name, &block)
    s = Spec.new(name, &block)
    RedSpec.specs << s
    block.call(s)
  end
  
  def initialize(name, &block)
    @name  =  name.to_s
    @block = block
    @examples = []
  end
  
  # the meat of the verb calls on 'it' ('can', 'has', 'does', 'wants', etc).
  # allows us to add new verbs and stay DRY.
  def verb(display_verb, description, &block)
    self.examples << ::Specs::Example.new((display_verb + " " + description), self, &block)
  end
  
  def can(description, &block)
    self.verb("can", description, &block)
  end
  
  def returns(description, &block)
     self.verb("returns", description, &block)
  end
  
  def to_heading_html
    "<li id=\"spec_#{self.object_id.to_s}_list\"><h3><a href=\"#spec_#{self.object_id.to_s}\"> #{RedSpec.escapeTags(self.name)}</a> [<a href=\"?rerun=#{self.name}\">rerun</a>]</h3></li>"
  end
  
  def examples_to_html
    examples_as_text = []
    self.examples.each do |example|
      examples_as_text << example.to_html
    end
    examples_as_text.join('')
  end
  
  def to_html_with_examples
    "<li id=\"spec_#{self.object_id.to_s}\">
       <h3>#{RedSpec.escape_tags(self.name)} [<a href=\"?rerun=#{self.name}\">rerun</a>]</h3>
       <ul id=\"spec_#{self.object_id.to_s}_examples\" class=\"examples\">
         #{self.examples_to_html}
       </ul>
     </li>
    "
  end

  def executor
    ::Specs::Executor.new(self)
  end
end

module Specs
  # # each block within a spec is an example.  typicall referenced with 'it' and one
  # # of the action verb methods ('should', 'can', 'has', etc)
  class Example
    attr_accessor :block, :name, :result, :spec
    def initialize(name, spec, &block)
      @name  = name
      @spec  = spec
      @block = block
    end
    
    def to_html
      "<li id=\"example_#{self.object_id.to_s}\">
        <h4>#{RedSpec.escape_tags(self.name)}</h4>
       </li>
      "
    end
    
    def executor
      ::Specs::Executor.new(self)
    end
    
  end
  
  # responsible for gathering all specs from RedSpec.specs (or a subset if you're rerunning
  # a particual spec) into one place and running them.
  class Runner
    attr_accessor :specs, :specs_map, :total_examples, :logger, :ordered_executor, :total_failures, :total_errors
    def initialize(arg_specs, logger)
      logger.runner = self
      @logger = logger
      
      @specs = []
      @specs_map = {}
      @total_examples = 0
      self.total_failures = 0
      self.add_all_specs(arg_specs)
    end
    
    def add_all_specs(specs)
      specs.each {|spec| self.add_spec(spec)}
    end
    
    def add_spec(spec)
      spec.runner = self
      self.specs << spec
      # self.specs_map[spec.object_id] = spec
      self.total_examples += spec.examples.size
    end
    
    def run
      self.logger.on_runner_start
      self.ordered_executor = Specs::OrderedExecutor.new
      self.specs.each do |spec|
        spec.examples.each do |example|
          self.ordered_executor.add_executor(example.executor)
        end
      end
      
      self.ordered_executor.run
      self.logger.on_runner_end
    end

    #     def get_spec_by_id          ; end
    #     def get_spec_by_context     ; end
    #     def has_exception           ; end
    #     def total_failures          ; end
    #     def total_errors            ; end
    #     def rerun                   ; end
     
  end
  
  # executes the code of the examples in each spec
  # and stores their state (success/failure) and any
  # failure messages, normalized for browser differences
  class Executor
    attr_accessor :example, :type, :containing_ordered_executor, :on_start, :on_end
    
    def initialize(example)
      self.example  = example
    end
    
    def run
      if self.example.class.to_s.downcase.split('::')[1] == 'example'
        ::Specs::Logger.on_example_start(self.example)
      else
        ::Specs::Logger.on_spec_start(self.example)
      end
      
      result = self.example.block.call
      
      if result
        self.type = 'success'
        self.example.result = 'success'
      else
        self.type = 'failure'
        self.example.result = 'exception'
        self.example.spec.runner.total_failures += 1
      end
            
      if self.example.class.to_s.downcase.split('::')[1] == 'example'
        ::Specs::Logger.on_example_end(self.example)
      else
        ::Specs::Logger.on_spec_end(self.example)
      end
      
      self.containing_ordered_executor.next
    end
  end
  
  
  class OrderedExecutor
    attr_accessor :queue, :at
    
    def initialize
      @queue = []
      self.at = 0
    end
    
    def add_executor(executor)
      # some other stuff with callbacks? no idea
      executor.containing_ordered_executor = self
      self.queue << executor
    end
    
    # Runs the next Executor in the queue.
    def next
      self.at += 1
      self.queue[self.at].run unless self.at >= self.queue.size
    end
    
    def run
      if self.queue.size > 0
        self.queue[0].run
      end
    end
  end
  
  # Logger write the pretty to the screen
  class Logger
    attr_accessor :runner, :started_at, :ended_at
    
    # on_runner_start is called just before the specs are run and writes the general logging
    # structure to the page for later manipulation
    def on_runner_start
      title = `document.title`
      self.started_at = Time.now
      # self.runnetotal_failures = 0
      container = `document.getElementById('redspec_container')`
      if container
        `container.innerHTML = ""`
      else
        `container = document.createElement("DIV")`
        `container.id = "redspec_container"`
        `document.body.appendChild(container)`
      end
    
      `title = document.createElement("DIV")`
      `title.id = "dashboard"`
      `title.innerHTML = [
        '<h1>RedSpec</h1>',
        '<ul>',
        // JSSpec.options.rerun ? '<li>[<a href="?" title="rerun all specs">X</a>] ' + JSSpec.util.escapeTags(decodeURIComponent(JSSpec.options.rerun)) + '</li>' : '',
        ' <li><span id="total_examples">' + #{self.runner.total_examples} + '</span> examples</li>',
        ' <li><span id="total_failures">0</span> failures</li>',
        ' <li><span id="total_errors">0</span> errors</li>',
        ' <li><span id="progress">0</span>% done</li>',
        ' <li><span id="total_elapsed">0</span> secs</li>',
        '</ul>',
        '<p><a href="">RedSpec homepage</a></p>',
        ].join("");`
        
      `container.appendChild(title);`
      
       # convert all of the specs for this runner into native js strings for writing
       all_runner_specs = []
       self.runner.specs.each do |spec|
         all_runner_specs << spec.to_heading_html
       end
       `all_runner_specs_as_list_items = #{all_runner_specs.join("")}._value`
       
      `list = document.createElement("DIV")`
      `list.id = "list"`
      `list.innerHTML = [
         '<h2>List</h2>',
         '<ul class="specs">',
         all_runner_specs_as_list_items,
        '</ul>'
         ].join("")`
      `container.appendChild(list)`
      
      `log = document.createElement("DIV")`
      `log.id = "log"`
      
      all_runner_specs_with_examples = []
      self.runner.specs.each do |spec|
        all_runner_specs_with_examples << spec.to_html_with_examples
      end
      `all_runner_specs_as_list_items_with_examples = #{all_runner_specs_with_examples.join("")}._value`
      
      `log.innerHTML = [
        '<h2>Log</h2>',
        '<ul class="specs">',
        all_runner_specs_as_list_items_with_examples,
         '</ul>'
        ].join("")`
        
         `container.appendChild(log)`
    
      # add event click handler to each spec for toggling
      self.runner.specs.each do |spec|
        # `spec_div  = document.getElementById('spec_' + #{spec.object_id})`
        # `title = spec_div.getElementsByTagName("H3")[0]`
        # `title.onclick = function(e){
        #   var target = document.getElementById(this.parentNode.id + "_examples")
        #   target.style.display = target.style.display == 'none' ? 'block' : 'none'
        #   return true
        # }`
      end
    end
    
    def on_runner_end
      `document.getElementById("total_elapsed").innerHTML = (#{Time.now - self.started_at })`
      `document.getElementById("total_failures").innerHTML = #{self.runner.total_failures}`
    end
        
    def self.on_spec_start(spec)
      `spec_list = document.getElementById("spec_" + spec.id + "_list")`
    	`spec_log = document.getElementById("spec_" + spec.id)`

    	`spec_list.className = "ongoing"`
    	`spec_log.className = "ongoing"`
    end
    
    def self.on_spec_end(spec)
      
    end
    
    def self.on_example_start(example)
      `li = document.getElementById("example_" + #{example.object_id.to_s})`
      `li.className = "ongoing"`
    end
    
    def self.on_example_end(example)
      `li = document.getElementById("example_" + #{example.object_id.to_s})`
      `li.className = #{example.result}._value`
    end
    
  end
end

main = lambda {
  if RedSpec.specs.size > 0
    r = Specs::Runner.new(RedSpec.specs, Specs::Logger.new)
    r.run
  end
}

# Wait for the window to load and then determing run the specs
`window.onload = #{main}._block`
