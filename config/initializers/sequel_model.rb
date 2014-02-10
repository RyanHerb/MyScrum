class Sequel::Model
  require 'json'
  
  def money(amt, currency="&pound;")
    amt.nil? ? nil : ts(format("#{currency}%.02f", amt.to_f), ',')
  end
  
  def ts(st, sep = ',')
    st.to_s.gsub(/(\d)(?=(\d\d\d)+(?!\d))/, "\\1#{sep}")
  end
  
  def to_json
    self.columns.inject({}) { |h,c| h[c]=self.send(c); h }.to_json
  end

  def self.find_or_new(params)
    find(params) || new(params)
  end
  
end

# ===============================
# = Global Sequel model options =
# ===============================

class Sequel::Model
  
  plugin :validation_helpers
  plugin :timestamps
  # plugin :schema # do we need this?
  plugin :boolean_readers
  plugin :defaults_setter
  
  plugin :tactical_eager_loading
  
  Sequel::Plugins::ValidationHelpers::DEFAULT_OPTIONS.merge!(
   :presence => { :message => 'is required'},
   :format   => { :message => 'is not in the correct format', :allow_nil=>true })
  
end
