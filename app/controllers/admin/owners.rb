module MyScrum
  class AdminApp

  	get '/owners' do
  		@owners = Owner.all
  		haml :"owners/list"
  	end

  end
end