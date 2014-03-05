module MyScrum
  class ApiApp < Sinatra::Application
    
    get '/' do 
    end

    get '/owner/:id/profile' do |id|
      @owner = Owner.find(:id => id)
      unless (@owner.nil?)
        response = @owner.to_json
      else
        response = "404"
      end
      response
    end
    
  end
end
