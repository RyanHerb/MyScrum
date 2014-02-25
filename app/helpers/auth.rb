# authentication helpers

helpers do

  def protected!(scope = nil, redirect_to = nil)
    
    act_on_fail = Proc.new do
      session[:return_to] = request.path_info
      redirect_to.is_a?(String) ? redirect(redirect_to) : halt(401) 
    end

    #TODO make this more DRY on obvious pattern for basic stuff
    case scope
    when :admin
      act_on_fail.call unless current_admin
    when :owner
      act_on_fail.call unless current_owner
    else
      raise "No authentication scope provided"
    end
  end
  
  def check_access_rights(scope = nil, redir_url = nil)
    case scope
    when :admin
      halt(403) unless current_admin
    else
      raise "No scope provided"
    end
  end

  def authenticate!(scope = nil)
    case scope
    when :admin
      if a = Admin.auth_with_password(params)
        session[:admin] = a.id
        @current_admin = a
      end
    when :owner
      if o = Owner.auth_with_password(params)
        session[:owner] = o.id
        @current_owner = o
      end
    else
      false
    end
  end
  
  # Check that a session is valid - use for when current_owner is not called
  def is_logged_in(scope)
    case scope
    when :owner
      !session[:owner].blank?
    else
      false
    end
  end
  
  def logout(*scopes)
    if scopes.empty?
      session.clear
    else      
      session[scopes.shift] = nil
      session.clear # Is it safe ?
      response.set_cookie("owner", :value => nil)
      logout(scopes) unless scopes.empty?
    end
  end

  #TODO fix these boring defs with some meta-magic
  def current_owner
    @current_owner ||= Owner[session[:owner]]
  end

  def current_admin
    @current_admin ||= Admin[session[:admin]]
  end
  
end
