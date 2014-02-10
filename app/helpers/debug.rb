helpers do
  
  def pre(var)
    haml("%pre #{var.class}<br />#{var.inspect.split(',').join('<br />')}")
  end
  
  def ob?
    o=['peter@obdev.co.uk','team@obdev.co.uk','marek@osbornebrook.co.uk','emily@obdev.co.uk','james@obdev.co.uk','simon@obdev.co.uk','bruno@obdev.co.uk'].include?(@current_owner.email) rescue false
    u=['peter@obdev.co.uk','team@obdev.co.uk','marek@osbornebrook.co.uk','emily@obdev.co.uk','james@obdev.co.uk','simon@obdev.co.uk','bruno@obdev.co.uk'].include?(@current_user.email) rescue false
    if o || u
      return true
    else
      return false
    end
  end
  
end