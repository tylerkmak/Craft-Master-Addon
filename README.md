# CraftMaster.TOC
## Interface
This is a number that is a 1:1 with the current build of wow. You can find this by running the following command: `/dump select(4, GetBuildInfo())`

## Version
We are using SemVer styling for the version. Ensure you update apropriately as you make changes. 

# Core.lua
Add the files you want to import/run in this area. Currently we are only using main.lua. I'm uncertain as to how you can reference other files, but it's done here somehow.

# Notes
At the time of writing the only way to get the trade skills is when the player has the trade skill window open. They will need to open all skills they want to have saved and run the command for each string output. 

### Recommended VSCode Addons
- https://marketplace.visualstudio.com/items?itemName=sumneko.lua
- https://marketplace.visualstudio.com/items?itemName=ketho.wow-api

### Helpful Links
- https://warcraft.wiki.gg/wiki/Global_functions/Classic


# Future Endeavors
1. Get approval to upload extension to curseforge or something like that
2. Automate uploading process to hosting site for addons.