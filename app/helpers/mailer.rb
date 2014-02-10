class String
  
  def strip_html
    text = self.split(/<body[^>]*>/i)[1] rescue self.dup
    text = text.split(/<\/body>/i)[0] rescue self.dup
    text.gsub(/^\s+</, '<').
         gsub(/<p.*?>/i, "\n\n").
         gsub(/<br.*?>/i, "\n").
         gsub(/<b>(.*?)<\/b>/mi, "*\1*").
         gsub(/<strong>(.*?)<\/strong>/mi) { |s| "*#{$1}*" }.
         gsub(/<li[^>]*>/i, "\n  * ").
         gsub(/<h[123][^>]*>(.*?)<\/h[123]>/mi, ($1.upcase rescue '')).
         gsub(/(<table[^>]*>|<\/table>)/i, "\n\n").
         gsub(/(<tr[^>]*>|<\/tr>)/i, "\n").
         gsub(/<a[^>]*?href=['\"]([^'\"]*)['\"].*?\>(.*?)<\/a>/mi) { |s| "#{$2} [#{$1}]" }.
         gsub(/<\/?[^>]*>/m, "").
         gsub(/\n\s+\n/m, "\n\n").
         gsub(/\n{3,}/m, "\n\n").
         strip
  end
  
end

# Use like this:

# mail :name => @name,
#      :email => @email,
#      :from_name => @from_name,
#      :from_email => @from_email,
#      :subject => "This is an Email from Us",
#      :body => haml(:"mail/notification", :layout => false),
#      :attachments => [{:filename => "tandc.pdf", :content => pdf_content }]



module Sinatra
  module Mailer
    
    require 'mail'

    def mail(opts = {})
      
      unless ENV['RACK_ENV'] == 'production'
        user, domain = opts[:email].split '@'
        test_domains = settings.mailer_test_domains || []
        opts[:email] = 'test@obdev.co.uk' unless test_domains.include? domain
      end
      
      from_name  = opts[:from_name]  || settings.mailer_from_name  || 'Website Mailer'
      from_email = opts[:from_email] || settings.mailer_from_email 
      # TODO raise specific error here if missing ?

      email = Mail.new do
        
        to opts[:email]
        # cc opts[:cc] if opts[:cc] && ENV['RACK_ENV'] == 'production'
        cc opts[:cc] if opts[:cc]
        
        from "#{from_name} <#{from_email}>"
        subject opts[:subject]

        # headers :To => "#{opts[:name]} <#{opts[:email]}>"

      end
      
      html_part = Mail::Part.new do
        content_type 'text/html; charset=UTF-8'
        body opts[:body]
      end

      text_part = Mail::Part.new do
        body opts[:body].strip_html
      end
      
      if opts[:attachments].is_a? Array
        
        inner_mail = Mail.new
        inner_mail.html_part = html_part
        inner_mail.text_part = text_part          
      
        opts[:attachments].each do |attachment|
          next unless attachment.is_a?(Hash) && attachment[:filename] && attachment[:content]
          email.add_file :filename => attachment[:filename], :content => attachment[:content]
        end
        
        email.add_part inner_mail
        
      else
              
        email.html_part = html_part        
        email.text_part = text_part
      
      end
      
      # puts email.encoded
      
      email.deliver!
      owner = Owner.find(:email => opts[:email])
      SentEmail.create({
        :owner_id => owner.nil? ? nil : owner.id,
        :owner_email => opts[:email],
        :appointment_id => opts[:appointment_id].nil? ? nil : opts[:appointment_id],
        :template => opts[:template].nil? ? nil : opts[:template]
      })
      
    end
    
    helpers Mailer

  end
end



