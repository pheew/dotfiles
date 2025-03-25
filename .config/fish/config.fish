if status is-interactive
    # Commands to run in interactive sessions can go here
   
    # Enable vi mode
    fish_vi_key_bindings


    # force commands to output colored output
    set -gx CLICOLOR_FORCE 1
  
    # pipe shortcuts
    abbr --add --position anywhere G '| grep'
    abbr --add --position anywhere H '| head'
    abbr --add --position anywhere T '| tail'

    abbr --add reload fish

    abbr --add l ls -lFh

end
