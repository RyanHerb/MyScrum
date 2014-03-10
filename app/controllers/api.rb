module MyScrum
  class ApiApp < Sinatra::Application

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
        end
      else
        halt(401)
      end
    end
    
    get '/' do
      "Hello"
    end

    get '/owner/profile' do
      @owner = Owner.find(:api_key => params['api_key'])
      unless (@owner.nil?)
        response = @owner.to_json
      else
        halt 401
      end
      response
    end

    get '/owner/projects' do
      @owner = Owner.find(:api_key => params['key'])
    end
    
  end
end
