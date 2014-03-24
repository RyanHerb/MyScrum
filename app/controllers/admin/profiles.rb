module MyScrum
  class AdminApp

    get '/profiles' do
      @profiles = Admin.all
      haml :"profiles/list"
    end

    post '/profiles' do
      @admin = Admin.new
      @admin.set(params[:admin])
      if @admin.valid?
        @admin.save
        redirect '/admin/profiles'
      else
        haml :"profiles/form"
      end
    end

    get '/profiles/new' do
      @admin = Admin.new
      haml :"profiles/form"
    end

    put '/profiles/:id' do |id|
      @admin = Admin.find(:id => id) || halt(404)
      @admin.set(params[:admin])
      if @admin.valid?
        @admin.save
        redirect '/admin/profiles'
      else
        haml :"profiles/form"
      end
    end

    get '/profiles/:id/show' do |id|
      @admin = Admin.find(:id => id) || halt(404)
      haml :"profiles/show"
    end

    get '/profiles/:id/edit' do |id|
      @admin = Admin.find(:id => id) || halt(404)
      haml :"profiles/form"
    end

  end
end