#bon fichier
module MyScrum
  class ApiApp < Sinatra::Application

    Dir[ROOT_DIR + '/app/controllers/api/*.rb'].sort.each {|file| require file }

    error 401 do
      "401"
    end
    
    not_found do
      "404"
    end

    before do
      show_me params.inspect
      unless params[:api_key].nil?
        if o = Owner.auth_with_key(params)
          @current_owner = o
        else
          halt(401)
        end
      else
        halt(401)
      end
    end
    
    get '/' do
      "You successfully queried our api, this means authentication was successful"
    end

    # ===========
    # = Profile =
    # ===========

    get '/owner/profile' do
      response = @owner.to_json
    end

    post '/owner/profile' do
      params[:owner] = JSON.parse(params[:owner])
      @current_owner.set(params[:owner])
      if @current_owner.valid?
        @current_owner.save
      else
        "An error occured while updating account"
      end
    end
    
  end
end
