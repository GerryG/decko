task :push_gems do
  %w(card decko).each do |gem|
    system %(
      cd #{gem}
      rm *.gem
      gem build #{gem}.gemspec
    )
    #gem push #{gem}-#{version}.gem

  end
end

task :version do
  puts version
end

task :release do
  system %(
    git tag -a v#{version} -m "Decko Version #{version}"
    git push --tags decko
  )
end

task :cp_tmpsets do
  system %(
    cd ../decko-tmpsets
    rm -rf set*
    cp -r ../sites/core-dev/tmp/set* .
    git commit -a -m 'updated from core-dev'
    git push; git push wagn
    cd ../gem
    git submodule update --remote
  )
end

def version
  File.open(File.expand_path("../card/VERSION", __FILE__)).read.chomp
end
