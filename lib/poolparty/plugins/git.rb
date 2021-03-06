module PoolParty
  module Resources
    
    class Git < Resource
      
      def before_load
        case cloud.platform
        when :ubuntu
          has_package "git-core"
        else
          has_package "git"
        end
      end
      
    end
    
  end
end

require "#{File.dirname(__FILE__)}/git/git_repository"