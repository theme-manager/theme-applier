# theme-applier
Applies the active theme in ```$HOME/.config/theme-manager/themes/active``` to config files wich do not depend on .css files.  
Which config files get edited is dependant on the configuration in ```$HOME/.config/theme-manager/theme-applier.conf```.

## Installation
The installation is easy. Just put the shell script in your ```$HOME/.config/theme-manager``` directory and run `theme-applier --init` to create a new configuration file inside the same directory. Alternatively you can just create the `theme-applier.conf` yourself.

## Usage

    theme-applier <OPTION> ...

    Options:
      -h  --help                      Show this help message
          --auto-update               Flag to 'detect' automatic execution of this script.
                                      It checks the auto_update variable in the config and updates if it is set to 1
      -a  --apply <variable> ...      Apply theme <variables>:    
                                          h: Applies Hyprland
                                          p: Applies Hyprpaper
                                          d: Applies dunst
                                          w: Applies waybar
                                          b: Applies bashrc
                                          k: Applies kitty
                                          q: Applies qt theme
      -s  --set   <name> <on/off>     Set the variable <name> to <on/off>
                                          <auto>:         Automatically apply the current theme on system startup
                                          <hyprland>:     Determines if hyprland has to be updated when theme is applied
                                          <hyprpaper>:    Determines if hyprpaper (Wallpaper) has to be updated when the theme is applied
                                          <dunst>:        Determines if dunst has to be updated when theme is applied
                                          <waybar>:       Determines if waybar has to be updated when theme is applied
                                          <bash>:         Determines if bashrc has to be updated when theme is applied
                                          <kitty>:        Determines if kitty has to be updated when theme is applied
                                          <qt>:           Determines if qt theme has to be updated when theme is applied
      -g  --get   <name>              Get the value of the variable <name>
                                          Will print all variables if <name> is 'all'
      -i  --init                      Starts the initial setup and asks for all variables to set them. Creates the config file.

## Example config file

    # The configuration file for the theme-applier
    auto_update = true
    update_hyprland = false
    update_hyprpaper = false
    update_dunst = false
    update_waybar = false
    update_bashrc = true
    update_kitty = true
    update_qt = true

