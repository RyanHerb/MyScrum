# encoding: utf-8

helpers do

  def haml(path, options = {})

    if settings.environment.to_s == 'local'
      file, line, rest = caller.first.split(':')
      puts "#{`tput sgr0`}Rendering #{`tput setaf 2`}#{settings.views.gsub(settings.root, '')}/#{path}.haml #{`tput sgr0`}for controller #{`tput setaf 6`}#{file.gsub(settings.root, '')} line #{line}#{`tput sgr0`}"
    end

    super

  end

  def show_me(text)
    if settings.environment.to_s == 'local'
      puts "------------------------------"
      puts "#{`tput setaf 2`}#{text}#{`tput sgr0`}"
      puts "------------------------------"
    end
  end

  def ssl_required!
    unless request.secure? || !production?
      redirect "https://#{request.host}#{request.fullpath}"
    end
  end

  def no_ssl!
    redirect "http://#{request.host}#{request.fullpath}" if request.secure?
  end

  def production?
    (ENV['RACK_ENV'] == 'production')
  end

# ============
# = Partials =
# ============

  def partial(view, options={})
    haml :"_partials/#{view.to_s}", options.merge!(:layout => false)
  end

  def global_partial(view, options ={})
    haml(view, options.merge({:views => ROOT_DIR + '/app/views/_global_partials', :layout => false}))
  end

  def cached_partial(view, options={})
    cached(:"_partials'}/#{view.to_s}", options.merge(:layout => false))
  end

  def cached_global_partial(view,options={})
    cached(view, options.merge({:views => ROOT_DIR + '/app/views/_global_partials', :layout => false}))
  end
  
# =================
# = Communication =
# =================

  def send_sms(number, message, options = {})
    
    setup_sms(CONFIG['sms']) unless settings.sms_user
    
    result = send_text(number, message)
    
    status, msgid = (result.split(' - ') rescue [nil, nil])
    
    if status == '00'
      mid = msgid
    else
      STDERR.puts "SMS to #{options[:number]} failed with code #{status}"      
    end

    SmsMessage.create(:mobile => number, :message => message, :result => status, :message_id => mid, :recipient_type => options[:recipient_type], :recipient_id => options[:recipient_id])

    mid

  end
  
# =========================
# = Generic route helpers =
# =========================

  def model(str)
      constantize(str.classify) rescue nil
  end

  def constantize(camel_cased_word)
    names = camel_cased_word.split('::')
    names.shift if names.empty? || names.first.empty?

    constant = Object
    names.each do |name|
      constant = constant.const_defined?(name) ? constant.const_get(name) : constant.const_missing(name)
    end
    constant
  end

# ==================
# = String helpers =
# ==================

  def if_blank(str, alternative)
    str.to_s.strip.blank? ? alternative : str
  end

  def if_not_blank(str, prefix, postfix = '')
    str.to_s.strip.blank? ? "" : "#{prefix}#{str}#{postfix}"
  end

  # Used regularly, this will generate "1 review" or "2 reviews" when passed
  #
  #   pluralise(1, 'review') pluralise(2, 'review')
  #
  # but you can override the plural with options, or opt not to have the count
  #
  #   pluralise(6, 'sheep', :plural => 'sheep') = "6 sheep"
  #   pluralise(2, 'cow', :show_count => false) = "cows"
  #
  def pluralise(count, singular, options={})
    options[:show_count] = true if options[:show_count].nil?
    inflection = singular.to_s.pluralize
    (options[:show_count] ? "#{count || 0} " : "") + ((count == 1 || count == '1') ? singular : (options[:plural] || inflection))
  end

  def show_errors(obj, options = {})
    heading = options[:heading] || "<h2>Please correct the following errors</h2>"
    custom_errors = options[:custom_errors] || []
    unless obj.errors.empty? && custom_errors.empty?
      :div.wrap(:class => "errors") do
        heading + :ul.wrap(:style => "width: auto") do
          obj.errors.merge(:custom_errors => custom_errors).map do |label, message|
            message.is_a?(Array) ?
              message.map{ |message_n| :li.wrap(message_n) }.join("\n") :
              :li.wrap(message)
          end.join("\n")
        end
      end
    end
  end

  def money(amt, currency="£",decimal = nil)
    amt.nil? ? nil : ts(format("#{currency}%.0#{decimal || 2}f", amt.to_f), ',')
  end

  def ts(st, sep = ',')
    st.to_s.gsub(/(\d)(?=(\d\d\d)+(?!\d))/, "\\1#{sep}")
  end

  def time_picker_hours
    24.times.inject([]){ |a, n| h = n < 10 ? "0#{n}" : n; a << [ n, "#{h}" ];  a }
  end

  def time_picker_minutes
    12.times.inject([]){|a, n| m = n * 5 < 10 ? "0#{n * 5}" : n * 5; a << [ n*5, "#{m}" ]; a  }
  end

  def age_in_years(age_in_months)
    begin
      y = (age_in_months/12).floor
      m = age_in_months % 12
      "#{(pluralise(y,"year")) if y > 0} #{(pluralise(m,"month")) if m > 0 || y == 0}".strip
    rescue
      'unknown'
    end
  end

# ======================
# = Breadcrumb helpers =
# ======================

  def breadcrumbs(delim = ' &raquo; ')
    begin
      d = ""
      output = ""
      @breadcrumbs.each do |b|
        output += d + b.output
        d = b.delim || delim
      end
      "<p>#{output}</p>" if output.length > 0
    rescue
      "-"
    end
  end
  
  def show_breadcrumbs
    if (@breadcrumbs.length > 0 rescue false)
      :div.wrap(:id => 'breadcrumb') do
        breadcrumbs
      end
    end
  end
  
  def get_name_from_object(obj, names = [:title, :name, :fullname, :first_name])
    n = ""
    while n == "" && m = names.shift
      n = obj.send(m) rescue ""
    end
    n
  end
  
  def make_breadcrumbs(url = nil)
    url = request.path unless url
    # TODO - make this work for other paths..
    parts = url.split('/')
    show_me parts.inspect
    parts.shift
    root = "/#{parts.shift}"
    @breadcrumbs << Breadcrumb.new('Home', root)

    last = nil
    while part = parts.shift
      
      if last
        case part
        when "new"
          @breadcrumbs << Breadcrumb.new("New #{last.humanize}")
          last = nil
        when "edit"
          @breadcrumbs << Breadcrumb.new("Edit")
          last = nil
        else
          if (model = last.classify.constantize rescue nil) && (obj = model[part] rescue false)
            @breadcrumbs << Breadcrumb.new(get_name_from_object(obj), ("#{root}/#{last}/#{part}" if parts.length > 0))
            last = part
          else
            # uh oh!
          end
        end 
      else
        show_me "Parsing #{url}"
        
        @breadcrumbs << Breadcrumb.new(part.humanize, ("#{root}/#{part}" if parts.length > 0))
        last = part
      end
    end
      
    
    # /products
    # /products/new
    # /products/:id
    # /products/:id/edit
    
  end

  # ========
  # = Misc =
  # ========

  # get the icon for the type of staff member (e.g. female vet)
  def poster_icon(poster)

    if poster.is_a? Owner
      poster.photo.url(:thumb) rescue ''
    else
      if poster.admin?
        ''
      elsif poster.vet?
        poster.sex == 'male' ? '/img/icons/vet-male-bw.png' : '/img/icons/vet-female-bw.png'
      elsif poster.assistant?
        ''
      elsif poster.media?
        ''
      else
        ''
      end
    end

  end
  
  # =======
  # = SSL =
  # =======
  def ssl_required!
    unless request.secure? || !production?
      redirect "https://#{request.host}#{request.fullpath}"
    end
  end
  
  def no_ssl!
    redirect "http://#{request.host}#{request.fullpath}" if request.secure?
  end

  def production?
    (ENV['RACK_ENV'] == 'production')
  end

end
