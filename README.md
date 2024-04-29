# theme-applier
Applies the active theme in ```$HOME/.config/themes/active``` to config files  
wich do not depend on .css files.  
Which config files get edited is dependant on the configuration in ```$HOME/.config/theme-applier/theme-applier.conf```.

## Usage

    theme-applier.sh [OPTIONS]"
    
    Options:"
      -h  --help      Show this help message"

## Example config file

    # The configuration file for the theme-applier
    update_hyprland=0
    update_dunst=0
    update_bashrc=1