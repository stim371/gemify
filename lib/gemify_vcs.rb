
require 'open3'

class Gemify

class VCS
  def self.determine_vcs
    vcs = :unknown
    if File.exist?(".git")
      vcs = :git
    elsif File.exist?("_darcs")
      vcs = :darcs
    elsif File.exist?(".hg")
      vcs = :hg
    elsif File.exist?(".bzr")
      vcs = :bzr
    elsif File.exist?(".svn")
      vcs = :svn
    elsif File.exist?("CVSROOT")
      vcs = :cvs
    end
    
    vcs
  end
  
  def self.get_files_from_command(command)
    files = []
    
    Open3.popen3(command) do |stdin, stdout, stderr|
      stdout.each { |line|
        file = line.strip
        files << file if File.exist?(file)
      }
    end
    files
  end
  
  def self.files
    list = []
    case determine_vcs
      when :git
        list = get_files_from_command("git-ls-files").delete_if { |w| w == ".gitignore" or w == ".gitattributes" }
      when :darcs
        list = get_files_from_command("darcs query manifest")
      when :bzr
        list = get_files_from_command("bzr ls").delete_if { |w| w == ".bzrignore" }
      when :hg
        list = get_files_from_command("hg manifest")
      when :svn
        list = get_files_from_command("svn ls")
      when :cvs
        list = get_files_from_command("cvs ls")
      when :unknown
        ['bin/*', 'lib/**/**'].each do |glob| 
          Dir.glob(File.join(Dir.getwd, glob)).each { |file|
            list << file
          }
        end
    end
    
    list
  end
end

end
