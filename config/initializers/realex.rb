class Realex
  require 'digest/sha1'
  require 'net/https'
  require 'rexml/document'

  HOST = 'epage.payandshop.com'
  URL = '/epage-remote-plugins.cgi'
  MERCHANT = 'petskitchen'
  SECRET = '649e8wRuCD'
  REFUND_SECRET = 'v3tskl1n1c'
  
  
  if  ENV['RACK_ENV'] == "production"
    ACCOUNT = 'internet'
  else
    ACCOUNT = 'internettest'
  end



  attr_accessor :payer, :card, :net, :vat, :amount, :timestamp, :order_id_prefix, :order_id, :prefix, :request, :raw_response, :response, :result, :message, :transaction, :payment

  def initialize(payer, card, net, vat)

    self.payer = payer
    self.card = card
    self.net = net
    self.vat = vat
    self.amount = ((net.round(2) + vat.round(2)) * 100).to_i # check that again
    self.timestamp = Time.now.strftime('%Y%m%d%H%M%S')
    self.order_id_prefix = "#{payer.pk}-#{timestamp}"

    if ENV['RACK_ENV'] == "production"
      self.prefix = ''
    else
      self.prefix = Socket.gethostname.gsub('.', '_')
    end
  end

  # =============================
  # = make realex http request  =
  # =============================
  def realex_request(xml)
    self.request = xml
    puts "REQUEST"
    puts xml
    puts "\n"
    
    http_request = Net::HTTP.new(HOST, 443)
    http_request.use_ssl = true

    log

    http_request.request_post(URL, xml).body
  end

  # =====================================
  # = generate hash for realex requests =
  # =====================================
  def generate_hash(*vals)
    h = Digest::SHA1.hexdigest(vals.join('.'))
    Digest::SHA1.hexdigest("#{h}.#{SECRET}")
  end

  # =========================
  # = Parse realex response =
  # =========================
  def parse(xml)

    response = {}
    xml = REXML::Document.new(xml)
    xml.elements.each('//response/*') do |node|

      response[node.name.downcase.to_sym] = node.text

    end unless xml.root.nil?

    self.response = response
    self.message = response[:message]
    self.result = response[:result]

    log(transaction.pk)
  end

  # =====================================================
  # = create transaction log, or update response in log =
  # =====================================================
  def log(tid = nil)
    unless tid
      self.transaction = RealexTransaction.new({
        :realex_order_id => order_id, 
        :realex_request => request
      })
      
      transaction.save
    else
      self.transaction = RealexTransaction[tid]
      transaction.set({:realex_message => message, :realex_status => result, :realex_response => raw_response})
      transaction.save
    end
  end


  # ================================================
  # = Methods to create realex payer if not exists =
  # ================================================
  def create_payer

    self.raw_response = realex_request( create_payer_xml_request )
    parse(raw_response)

    if result == "00"
      payer.payer_ref = "#{prefix}owner_#{payer.pk}"
      payer.save :validate => false
    else
      # TODO Think what we shoould do, probbably raise exception
      
    end

    puts raw_response
    puts "\n"
    puts response
  end

  # =============================================
  # = Methods to store card ref on realex vault =
  # =============================================
  def create_card
    self.raw_response = realex_request( create_card_xml_request )
    parse(raw_response)


    if result == "00"
      card.owner_id = payer.pk
      card.card_number = "XXXX-XXXX-XXXX-#{card.real_card_number[-4, 4]}"
      card.card_ref = "#{prefix}#{card.card_type}_#{card.exp_y}_#{card.exp_m}_#{card.card_number[-4, 4]}"
      card.save :validate => false
    else
      # TODO Think what we shoould do, probbably raise exception
    end
    puts raw_response
    puts "\n"
    puts response
  end
  
  
  def receipt_in
    if amount == 0
      self.payment = Payment.new(:net => net, :vat => vat, :owner_id => payer.id)
      return payment
    end
    
    self.raw_response = realex_request( create_receipt_in_xml_request )
    parse(raw_response)
    
    if result == "00"
      self.payment = Payment.new(:net => net, :vat => vat, :realex_transaction_id => transaction.pk, :owner_id => payer.id)

      # we gonna save paiments after save appointment
      # payment.save
      
      return payment
    else
      # TODO what's happen if payments failed
      return nil
    end
    puts raw_response
    puts "\n"
    puts response
  end
  
  # ================================
  # = main method to make payments =
  # ================================
  def charge

    unless payer.payer_ref
      create_payer
    end

    if card.real_card_number && !card.card_ref
      create_card
    end

    if payer.payer_ref && card.card_ref
      receipt_in
    end
  end
  
  # ==============================
  # = main method to make refund =
  # ==============================
  def refund
    if payer.payer_ref && card.card_ref
      puts create_refund_xml_request.inspect
      self.raw_response = realex_request( create_refund_xml_request )
      parse(raw_response)
      if result == "00"
        self.payment = Payment.new(:net => -net, :vat => -vat, :realex_transaction_id => transaction.pk)
        return payment
      else
        puts "tu nil"
        return nil
      end
    else
      puts "1 nil"
      return nil  
    end    
  end

  # =============================================
  # = METHODS to create xml for realex requests =
  # =============================================

  # <request type="payer-new" timestamp="20030516175919">
   #       <merchantid>yourmerchantid</merchantid>
   #       <orderid>uniqueid</orderid>
   #       <payer type="Business" ref="smithj01">
   #         <title>Mr</title>
     #       <firstname>John</firstname>
     #       <surname>Smith</surname>
     #       <company>Acme Inc</company>
     #       <address>
     #         <line1>123 Fake St.</line1>
       #       <line2 />
       #       <line3 />
       #       <city>Hytown</city>
       #       <county>Dunham</county>
       #       <postcode>3</postcode>
       #       <country code="IE"> Ireland </country>
     #       </address>
     #       <phonenumbers>
     #       <home />
     #       <work>+35317433923</work>
     #       <fax>+35317893248</fax>
     #       <mobile>+353873748392</mobile>
     #       </phonenumbers>
     #       <email>jsmith@acme.com</email>
     #       <comments>
     #       <comment id="1" />
     #       <comment id="2" />
     #       </comments>
   #       </payer>
   #       <sha1hash>7daf026b193eb18344f5ab6822cd05959718c567</sha1hash>
   #       <comments>
   #       <comment id="1" />
   #       <comment id="2" />
   #       </comments>
   #       </request>
  def create_payer_xml_request()
    trans_type = "new"

    payer_ref = "#{prefix}owner_#{payer.pk}"
    
    self.order_id = "#{order_id_prefix}-Payer-#{trans_type}"
    
    xml = ''
    xml = :request.wrap({:timestamp => timestamp, :type => "Payer-#{trans_type}"}) do
        xml += :merchantid.wrap( MERCHANT )
        xml += :orderid.wrap( order_id )
        str = ''
        str = :payer.wrap({:type => "Business", :ref => payer_ref}) do
          str += :firstname.wrap(payer.realex_first_name)
          str += :surname.wrap(payer.realex_last_name)
        end
        xml += str
        xml += :sha1hash.wrap(payer_hash(trans_type))

    end

    xml

  end

  def payer_hash(trans_type)
    # timestamp.merchantid.orderid.amount.currency.payerref
    generate_hash(timestamp, MERCHANT, order_id, '', '', "#{prefix}owner_#{payer.pk}");
  end

  # <request type="card-new" timestamp="20030516181127">
  #       <merchantid>yourmerchantid</merchantid>
  #       <orderid>uniqueid</orderid>
  #       <card>
  #         <ref>visa01</ref>
  #         <payerref>smithj01</payerref>
  #         <number>498843******9991</number>
  #         <expdate>0104</expdate>
  #         <chname>John Smith</chname>
  #         <type>visa</type>
  #         <issueno />
  #       </card>
  #       <sha1hash>4d708b24e3494bf80916ba3c8afd8347060fdd65</sha1hash>
  # </request>
  def create_card_xml_request()
    trans_type = 'new'
    self.order_id = "#{order_id_prefix}-Card-#{trans_type}"
    xml = ''
    xml += :request.wrap({:timestamp => timestamp, :type => "card-#{trans_type}"}) do
      xml += :merchantid.wrap( MERCHANT )
      xml += :orderid.wrap( order_id )
      str = ''
      str = :card.wrap do
        str += :ref.wrap( "#{prefix}#{card.generate_card_ref}" )
        str += :payerref.wrap( payer.payer_ref )
        str += :number.wrap( card.real_card_number )
        str += :expdate.wrap( card.realex_expiry_date )
        str += :chname.wrap( card.card_holder_name )
        str += :type.wrap( card.card_type )

      end
      xml += str
      xml += :sha1hash.wrap( card_hash(trans_type) )
    end

    xml
  end

  def card_hash(trans_type)
    # timestamp.merchantid.orderid.amount.currency.payerref.chname.(card)number
    generate_hash(timestamp, MERCHANT, order_id, '', '', payer.payer_ref, card.card_holder_name, card.real_card_number)    
  end


  # <request type="receipt-in" timestamp="20030520151742">
  #   <merchantid>yourmerchantid</merchantid>
  #     <account>internet</account>
  #   <orderid>transaction01</orderid>
  #   <paymentdata>
  #     <cvn>
  #        <number>123</number>
  #     </cvn>
  #   </paymentdata>
  #   <amount currency="EUR">9999</amount>
  #   <payerref>smith01</payerref>
  #   <paymentmethod>visa01</paymentmethod>
  #   <autosettle flag="1" />
  #   <md5hash />
  #   <sha1hash>c81377ac77b6c0a8ca4152e00cc173d01c3d98eb</sha1hash>
  #   <comments>
  #   <comment id="1" />
  #   <comment id="2" />
  #   </comments>
  #   <tssinfo>
  #   <address type="billing">
  #   <code />
  #   <country />
  #   </address>
  #   <address type="shipping">
  #   <code />
  #   <country />
  #   </address>
  #   <custnum></custnum>
  #   <varref></varref>
  #   <prodid></prodid>
  #   </tssinfo>
  #   </request>
  def create_receipt_in_xml_request()
    self.order_id = "#{order_id_prefix}-Receipt-in"
    
    xml = ''
    xml += :request.wrap({ :type => "receipt-in", :timestamp => @timestamp }) do
      xml += :merchantid.wrap( MERCHANT )
      xml += :account.wrap( ACCOUNT )
      xml += :orderid.wrap( order_id )
      xml += :amount.wrap({:currency => "GBP"}) { amount }
      xml += :payerref.wrap( payer.payer_ref )
      xml += :paymentmethod.wrap( card.card_ref )
      xml += :autosettle.wrap({:flag => 1})
      xml += :sha1hash.wrap( receipt_in_hash )
      # TODO add payer details (address etc)
    end

    xml
  end
  
  def receipt_in_hash
    # timestamp.merchantid.orderid.amount.currency.payerref
    generate_hash(timestamp, MERCHANT, order_id, amount, 'GBP', payer.payer_ref)    
  end
  
  def cancel_card
    self.raw_response = realex_request( create_card_cancel_card_xml_request )
    parse(raw_response)
  end
  
  # =================================================================
  # = <request timestamp="20091002153434" type="card-cancel-card"> 
  # =   <merchantid>yourclientid</merchantid> 
  # =   <card> 
  # =     <ref>visa01</ref> 
  # =     <payerref>smithj01</payerref> 
  # =  </card> 
  # =  <sha1hash>4d708b24e…8afd8347060fdd65 </sha1hash> 
  # = </request> =
  # =================================================================
  def create_card_cancel_card_xml_request
    xml = ''
    xml += :request.wrap({ :type => "card-cancel-card", :timestamp => @timestamp }) do
      xml += :merchantid.wrap( MERCHANT )
      str = ''
      str = :card.wrap do 
         str += :ref.wrap( card.card_ref )
         str += :payerref.wrap( payer.payer_ref )
      end
      xml += str
      xml += :sha1hash.wrap( cancel_card_hash )
    end
    
    xml
  end
  
  def cancel_card_hash
    # Timestamp.merchantID.payerref.pmtref
    generate_hash(timestamp, MERCHANT, payer.payer_ref, card.card_ref)
  end
  

  
  # <request type="payment-out" timestamp="20090320151742"> M
  #     <merchantid>yourclientid</merchantid> M
  #     <account>internet</account> M
  #     <orderid>transaction01</orderid> 
  #     <amount currency="EUR">9999</amount> M 
  #     <payerref>bloggsj01</payerref> M
  #     <paymentmethod>mandate01</paymentmethod> M
  #     <md5hash /> 
  #     <sha1hash>c81377ac77b6c0a8ca4152e00cc173d01c3d98eb</sha1hash> M
  #     <refundhash>489167b182152dd81afc199e056890f7383674e5</refundhash> M` 
  #     <comments> 
  #       <comment id="1" /> 
  #       <comment id="2" /> 
  #     </comments> 
  #     <tssinfo> 
  #       <address type="billing"> 
  #         <code>zip/postal code</code> 
  #         <country>country</country> 
  #       </address> 
  #       <address type="shipping"> 
  #         <code>zip/postal code</code>
  #         <country>country</country> 
  #       </address> 
  #       <custnum></custnum> 
  #       <varref></varref> 
  #       <prodid></prodid> 
  #     </tssinfo> 
  #     <supplementarydata> 
  #       <item type="pnr"> 
  #         <field01>238002</field01> 
  #       </item> 
  #     </supplementarydata> 
  #   </request>
  def create_refund_xml_request
    xml = ''
    self.order_id = "#{order_id_prefix}-Refund"
    xml += :request.wrap({ :type => "payment-out", :timestamp => @timestamp }) do
      xml += :merchantid.wrap( MERCHANT )
      xml += :account.wrap( ACCOUNT )
      xml += :orderid.wrap( order_id )
      xml += :amount.wrap({:currency => "GBP"}) { amount }
      xml += :payerref.wrap( payer.payer_ref )
      xml += :paymentmethod.wrap( card.card_ref )      
      
      xml += :sha1hash.wrap( refund_sha1_hash )
      xml += :refundhash.wrap( refund_hash )
    end 
    
    xml   
  end
  
  # Format:  timestamp.merchant_id.order_id.amount.currency.payerref 
  # Example:   20090320151742.yourmerchantid.transaction01.9999.EUR.bloggsj01
  def refund_sha1_hash
    generate_hash(timestamp, MERCHANT, order_id, amount, "GBP", payer.payer_ref)
  end
  
  # i hope its ok
  def refund_hash
    # vals = [ timestamp, MERCHANT, order_id, amount, currency ]
    #     h = Digest::SHA1.hexdigest(vals.join('.'))
    Digest::SHA1.hexdigest( REFUND_SECRET )
  end
  
  
  
end