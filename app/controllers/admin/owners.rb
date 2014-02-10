module MyScrum
  class AdminApp
  
    # ====================
    # = Owner management =
    # ====================
  
    get '/owners' do # render all owners (list)
      make_breadcrumbs
      
      @owners = Owner.all
      haml :'owners/list'
    end
  
    get '/owners/:id/view' do |id|
      @owner = Owner[id]
      make_breadcrumbs
      
      haml :"owners/show"
    end
  
    get '/owners/:id' do # edit page
      @owner = Owner.find(:id => params[:id])
      
      make_breadcrumbs
      
      haml :'owners/form'
    end

    get '/owners/:id/become' do |id|
      Owner[id] || halt(404)
      session[:owner] = id
      @current_owner = id

      # clear all session variable that should be deleted

      redirect '/owner'
    end
  
    get '/owner' do # render new owner page
      make_breadcrumbs
      
      @owner = Owner.new
      haml :'owners/form'
    end
  
    put '/owners/:id' do # update owner
      @owner = Owner.find(:id => params[:id])
      @owner.update(params[:owner])
      flash[:notice] = "Owner updated"
      redirect '/admin/owners'
    end

    delete '/owners/:id' do |id| # delete owner
      Owner[id].destroy
      flash[:notice] = "Owner deleted"
      "OK"
    end
  
    post '/owners' do # create new owner
      delivery_as_billing = params[:owner].delete("delivery_as_billing") # retrieve flag from params
    
      @owner = Owner.new(params[:owner])
    
      if delivery_as_billing == "1" # if flag set, use delivery address as billing address
        @owner.set({
          :address_1  => params[:owner][:billing_address_1],
          :address_2  => params[:owner][:billing_address_2],
          :address_3  => params[:owner][:billing_address_3],
          :city       => params[:owner][:billing_city],
          :county     => params[:owner][:billing_county],
          :postcode   => params[:owner][:billing_postcode]
        })
      end

      begin
        @owner.save
        flash[:notice] = "Owner created"
        redirect '/admin/owners'
      rescue
        haml :'owners/form'
      end
    end
    
    # create owner from new appointment page
    post '/owners/shortcut' do
      @owner = Owner.new(params[:owner])
      @owner.standard_terms = true
      @owner.klinic_terms_accepted = true
      @owner.save :validate => false
      @owner.to_json
    end
    
    get '/owners/:id/account' do |id|
      make_breadcrumbs
      @owner = Owner[id]
      
      if( params[:aid] && @appointment = Appointment[params[:aid]] ) 
        @payments = @appointment.payments      
      else 
        @payments = @owner.payments
      end
    
      haml :"owners/account"
    end
    
    post '/owners/:id/charge/:aid' do |id, aid|
      
      @owner = Owner[id]
      
      @appointment = Appointment[aid]
      
      net = VAT.total_to_net(params[:amount].to_i)
      vat = params[:amount].to_i - net
      
      
      return haml :"/owners/account" if net == 0.0 && vat == 0.0
      
      payment_method = params[:payment_method]
      
      if payment_method == "credit_card"
        
        # get existing cards 
        @card = @appointment.owner.cards_dataset.filter(:id => params[:credit_card_id]).first if params[:new_card] == "0"
      
        unless @card
          @card = Card.new(params[:card])

          if !@card.valid?
            return haml :"/owners/account"

          end
        end
        
        realex = Realex.new(@appointment.owner, @card, net, vat)

        # charge owner !!!
        payment = realex.charge
        
      elsif payment_method == "cash"
        
        payment = Payment.new(:owner_id => @appointment.owner_id, :net => net, :vat => vat, :cash => true)

        
      elsif payment_method == "cheque"
        payment = Payment.new(:owner_id => @appointment.owner_id, :net => net, :vat => vat, :cheque => true)
      
      # already paid, or free
      elsif (@appointment.balance == 0.0 rescue false)
                
        payment = @appointment.payments.first
        payment = Payment.new(:owner_id => @appointment.owner_id, :net => net, :vat => vat) unless payment
      end
      

      

      
      if payment
        payment.appointment_id = @appointment.id
        payment.save
        flash[:notice] = "Payment has been addded"
        redirect "/admin/owners/#{@owner.id}/account?aid=#{@appointment.id}"
      else
      
        flash[:error] = "Payment has not been added"
        haml :"/owners/account"
      end
    end
  end
end