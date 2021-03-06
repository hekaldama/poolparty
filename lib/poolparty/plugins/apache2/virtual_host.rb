module PoolParty
  module Resources
    class VirtualHost < Apache
      
      default_options(
        :port     => 80,
        :www_dir  => "/var/www",
        :www_user => "www-data"
      )
      
      def listen(port="80")
        has_variable(:name => "port", :value => port)
        self.port = port
      end

      def virtual_host_entry(file)
        @virtual_host_entry = true
        if File.file?(file)
          has_file( :name => "/etc/apache2/sites-available/#{name}", 
                    :template => file, 
                    :requires => get_package("apache2"))
        else          
          has_file( :name => "/etc/apache2/sites-available/#{name}", 
                    :content => file, 
                    :requires => get_package("apache2"))
        end
      end


      def after_loaded(opts={}, parent=self)
        has_directory(:name => "#{www_dir}/#{name}", :owner => www_user, :mode=>'0744')
        has_directory(:name => "#{www_dir}/#{name}/logs", :owner => www_user, :mode=>'0744')

        has_variable(:name => "sitename", :value => "#{name}")

        unless @virtual_host_entry
          vf = <<-eof
  <VirtualHost *:#{port}> 
  ServerName     #{name}
  DocumentRoot   /var/www/#{name}
  </VirtualHost>
  eof
        virtual_host_entry vf
        end

        has_exec(:name => "insert-site-#{name}", 
                 :command => "/usr/sbin/a2ensite #{name}", 
                 :requires => get_file("/etc/apache2/sites-available/#{name}")) do
          requires get_package("apache2")
          notifies get_exec("reload-apache2"), :run
          not_if "/bin/sh -c '[ -L /etc/apache2/sites-enabled/#{parent.name} ] && [ /etc/apache2/sites-enabled/#{parent.name} -ef /etc/apache2/sites-available/#{parent.name} ]'"
        end
      end
      
    end
    
  end
  
end