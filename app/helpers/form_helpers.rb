helpers do

  # ==========================================
  # = helper to generate html form for model
  # =
  # ==========================================
  def form_for(object, options={}, &block)

    raise ArgumentError, "Missing block to fieldset()" unless block_given?

    object, parent_object = [*object]
    if parent_object
      prefix = "/#{parent_object.class.to_s.underscore.pluralize}/#{parent_object.pk}"
    else
      prefix = ""
    end

    opts = { :method => :post }
    mfield = ""
    if object.new?
      opts[:action] = request.script_name.gsub(/\/$/, '') + prefix + "/#{object.class.to_s.underscore.pluralize}"
    else
      opts[:action] = request.script_name.gsub(/\/$/, '') + prefix + "/#{object.class.to_s.underscore}s/#{object.pk}"
      mfield = :input.tag(:type => 'hidden', :name => '_method', :value => 'put')
    end

    :form.wrap(options.reverse_merge(opts)) { mfield + capture_haml( FormModel.new(self, object), &block ) }

  end


  # ===============
  # = input field =
  # ===============
  def input( object, name, options = {}) #name, options = {}
    puts options.inspect
    input_id = "#{object.class.to_s}_#{name}".underscore
    input_name = "#{object.class.to_s.underscore}[#{name}]"

    # get object value
    val = object.send(name) rescue nil
    if val.is_a? BigDecimal
      # if the field appears to be for currency, format it to 2 decimal places.
      if options[:type] == :currency
        val = sprintf("%0.2f", val)
      else
        val = val.to_f
      end
    end

    if options[:type].to_s == 'hidden'
      options[:label] = false
      options[:no_wrap] = true
    end

    if name == :password || name == :password_confirmation
      options[:type] = 'password'
    end

    input_options = {
      :id => input_id,
      :type => options.delete(:type) || 'text',
      :name => input_name,
      :placeholder => options.delete(:placeholder),
      :value => options.delete(:value) || val
    }.merge(options.delete(:input_options) || {})
    
    if options.delete(:no_wrap)
      :input.tag(input_options)
    else
      field_for object, name, :input.tag(input_options), options.merge({:input_id => input_id})
    end

  end
  
  # ==========
  # = hidden =
  # ==========
  
  def hidden(object, name, options = {})
    input object, name, options.merge({:type => 'hidden'})
  end
  # ================
  # = select field =
  # ================
  def select(object, name, options = {})

    select_id = "#{object.class.to_s}_#{name}".underscore
    select_name = "#{object.class.to_s.underscore}[#{name}]"

    options_html = ""
    if prompt = options.delete(:prompt)
      options_html = :option.wrap(:value => '') { prompt }
    elsif prompt.nil?
      options_html = :option.wrap(:value => '') {'Choose'}
    end

    select_options = {
      :id => select_id,
      :name => select_name
    }.merge(options.delete(:input_options) || {})
    
    selected = object.send(name) rescue nil
    selected = options.delete(:selected) || selected

    options[:options] = options_for_select(options[:options]) unless options[:options].is_a? Array

    select_html = :select.wrap(select_options) do
      options_html += options.delete(:options).inject("") do |s, op|
        val, text = op.is_a?(Array) ? [ op[0], op[1] ] : [op, op]
        s += :option.wrap({ :value => val, :selected => ('selected' if selected == val && val) }) { text }
      end
    end
    
    if options.delete(:no_wrap)
      select_html
    else
      field_for object, name, select_html, options.merge({:input_id => select_id})
    end
    

  end

  # =====================
  # = radio group field =
  # =====================
  def radio_group(object, name, options = {})

    radio_id = "#{object.class.to_s}_#{name}".underscore
    radio_name = "#{object.class.to_s.underscore}[#{name}]"

    radio_options = {


    }.merge(options.delete(:input_options) || {})

    radio_group_html = :div.wrap(:class => "field_options") do
      radios_html = options.delete(:options).inject("") do |s, op|
        s += :div.wrap(:class => 'option') do
          selected_attr = {}
          selected = options.delete(:selected)
          if object.send(name) == op[0]
            selected_attr = {:checked => "checked"}
          elsif object.send(name).nil? && selected == op[0]
            selected_attr = {:checked => "checked"}
          end
          :input.wrap({:type => "radio", :name => radio_name, :id => "#{radio_id}_#{op[0]}", :value => op[0] }.merge(selected_attr)) { op[1] }
        end
      end
    end
    
    if options.delete(:no_wrap)
      radio_group_html
    else
      field_for object, name, radio_group_html, options.merge({:radio_id => radio_id})
    end

  end

  def checkbox(object, name, options = {})
    checkbox_id = "#{object.class.to_s}_#{name}".underscore
    checkbox_name = "#{object.class.to_s.underscore}[#{name}]"
    val = object.send(name)
    
    #checkbox_html = :label.wrap({:for => "#{checkbox_id}_true"}) { options.delete(:label) || name.to_s.humanize.titleize }

    h = {:type => "hidden", :name => checkbox_name, :id => "#{checkbox_id}_false", :value => 0}
    checkbox_html = :input.wrap(h) # hidden field input, so we always post a value for the checkbox. 1 if checked, 0 if not.
    
    o = {:type => "checkbox", :name => checkbox_name, :id => "#{checkbox_id}_true", :value => 1}
    o.update({:checked => "checked"}) if val || options[:checked] == "checked"    
    checkbox_html += :input.wrap(o)    
    checkbox_html += :label.wrap({:for => "#{checkbox_id}_true"}) { options.delete(:label) || name.to_s.humanize.titleize }

    if options[:class]
      c = options[:class]
      options[:class] = "checkbox #{c}"
    else
      options[:class] = "checkbox"
    end
    
    field_for object, name, checkbox_html, options.merge({:label => false})
  end
  
  def textarea(object, name, options = {})
    textarea_id = "#{object.class.to_s}_#{name}".underscore
    textarea_name = "#{object.class.to_s.underscore}[#{name}]"
    val = object.send(name)

    textarea_options = {
      :id => textarea_id,
      :name => textarea_name,
      :rows => options.delete(:rows),
      :cols => options.delete(:cols)      
    }.merge(options.delete(:input_options) || {})
    
    textarea_html = :textarea.wrap(textarea_options) { val }
      
    field_for object, name, textarea_html, options.merge({:input_id => textarea_id})
  end

  # ==================
  # = Submit button  =
  # ==================
  def submit(object, value = nil, options = {})
    
    value = object.new? ? 'submit' : 'update' unless value
    
    :div.wrap(:class => "field submit") do
      :input.wrap(options.merge(:value => value, :type => 'submit'))
    end

  end

  # Generic field wrapper (called from other methods)

  def field_for( object, name, input_html, options = {})
    o = object.class.new
    o.valid?
    required_fields = o.errors.keys
    
    options[:class] ||= 'field'

    if options[:label].nil? || options[:label]

      label_options = { :for => options.delete(:input_id) }.merge(options.delete(:label_options) || {})
      label_options[:class] += " required" rescue (label_options[:class] = "required") if required_fields.include?(name)


      if caption = options.delete(:label) || name.to_s.humanize.titleize
        label = :label.wrap(label_options) { caption }
      end

    end

    if hint = options.delete(:hint)
      hint = :div.wrap(:class => 'hint') { hint }
    else
      hint = ""
    end

    err = (object.errors[name] || nil) rescue nil
    if err && ![*err].empty?
      err = :div.wrap(:class => 'error') { err.join(", ") }
    else
      err  = ""
    end

    field_input = :div.wrap(:class => 'field_input') { input_html + hint.to_s + err.to_s }

    :div.wrap(options) { label.to_s + field_input }

  end

  def options_for_select(model, opts = {})
    opts[:value_field] ||= 'id'
    opts[:text_field] ||= 'name'
    model.select(opts[:value_field].to_sym, opts[:text_field].to_sym).order(opts[:text_field]).all.inject([]) { |i,p| i << [ p.send(opts[:value_field]), p.send(opts[:text_field])] } rescue []
  end

  class FormModel
    def initialize(context, model_obj)
      @context = context
      @model   = model_obj
    end

    def method_missing(meth, *args)
      @context.send(meth, @model, *args)
    end

  end

  # ==========================
  # = helpers for helpers :) =
  # ==========================


end