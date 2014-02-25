module MyScrum
  class AdminApp

    get '/owners' do
      @owners = Owner.all
      haml :"owners/list"
    end

    post '/owners' do
      @owner = Owner.new
      @owner.set(params[:owner])
      if @owner.valid?
        @owner.save
        redirect '/admin/owners'
      else
        haml :"owners/form"
      end
    end

    get '/owners/new' do
      @owner = Owner.new
      haml :"owners/form"
    end

    put '/owners/:id' do |id|
      @owner = Owner.find(:id => id) || halt(404)
      @owner.set(params[:owner])
      if @owner.valid?
        @owner.save
        redirect '/admin/owners'
      else
        haml :"owners/form"
      end
    end

    get '/owners/:id/show' do |id|
      @owner = Owner.find(:id => id) || halt(404)
      @projects = @owner.projects
      haml :"owners/show"
    end

    get '/owners/:id/edit' do |id|
      @owner = Owner.find(:id => id) || halt(404)
      haml :"owners/form"
    end
  end
end