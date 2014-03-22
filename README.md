MyScrum
=======

Setting up your environment
-------

Either install rvm with Ruby 2.1.0

  https://rvm.io/rvm/install
  
    \curl -sSL https://get.rvm.io | bash -s stable --ruby

Or simply install Ruby 2.1.0

    sudo apt-get install ruby

Install Bundler

    gem install bundler

Add the following line to your .bashrc file:

    source /home/largaroth/.rvm/scripts/rvm
    PATH=$PATH:$HOME/.rvm/bin # Add RVM to PATH for scripting

cd into the website's root and accept the use of the .rvmrc file

Install the myscrum gemset:
  
    bundle install

Once the bundle has intalled, you are ready to start using running our website.

Running the server:

    thin -e local -R config.ru start

Additionnaly you may install rerun:

    gem install rerun

And run the server like this:

    rerun -p "{./,app/*/,app/*/*/,config/*/}*.rb" "thin -e local -R config.ru start"

This way, if may set a listener on critical files, in order to automatically restart the server when necessary.

Create a database and fill in the data in config/database.yaml to correspond to this database, then run:
    
    rake db:schema:load


