# WUDOC - The whats up Doc(umenter)

Sorry, I am a 'Dresden Files fan' so I could not resist.

This documenter is an attempt to explore alternatives to the document navigation supported by the other documenters. I always found it difficult to follow the navigation implemented by the other documenters, they always seemed to scale badly to large or even just medium sized projects.

WUDOC is an attempt to give the people producing the documentation some tools to guide the read of the docs to what is important to allow connected parts of the code be grouped together.

## Configuration.

All the configuration on wudoc uses JSON data stored in several locations. The first is the main configuration file, this is called .wudoc.init then within each directory of your project including the root, you can put additional configuration in the local config file (.wudoc.rc). The settings within the local file will be in force for all files and directories within the directory the local file is placed.

if you would prefer not to sprinkle .rc files for documentation throuought your project you can include 'local' configuration within the .init file.

Finally, any comment within your other files that include a 'pragma' will be read as json configuration data for that specific file.

### Main configuration file (.wudoc.init)

This should be in the root of your project. It should be a correctly formed json file.

### Styles.

#### Centralised

Look at the .wudoc.init file of wudoc itself to see how the 'Documenters' tag is added to the documenters. That is an example of centralised configuration.

It is even possible to add configuration for a specific file within the centralised 'tree'. See how the Markdown tag is added to the Markdown documenter.

#### Decentralised

#### Pragmas

It is possible to add configuration in the files themselves. To do this, support needs to be included in the documenter. Take a look at the markdown concern file for an example.

## Tags

So far, wudoc can't do anything that any other documenter can do. Here is where things get interesting.

You can add tags to areas of your code. When you add a tag, that will be added to the navigation section of the project and selecting it will change the file tree to filter it down to just that tag.

Now, you might complain that the navigation is going to get a little crowded, and when it might, but for this... Any tag of the form "Major|minor" will be grouped in a dropdown called Major.