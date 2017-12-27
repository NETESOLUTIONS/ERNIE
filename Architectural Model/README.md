# Architectural Model #

The ERNIE architecture is modeled using [C4 modeling approach and notation](https://c4model.com) and the free 
[Structurizr Express](https://structurizr.com/express?type=LocalStorage) tool.

To update a diagram (one at a time):
1. Open [Structurizr Express](https://structurizr.com/express?type=LocalStorage)
1. Copy and paste a corresponding diagram in YAML into the YAML tab.
1. Press Tab to refresh the diagram.
1. Elements: use the Elements tab to add elements and update their tags or descriptions. Elements tagged as "Internal"
are automatically located within the context boundary. All other elements are located outside the boundary. Use global 
replace in diagram's YAML to rename or remove elements.
1. Relationships: use the Relationships tab to add, remove or update relationships.
1. Styles: use the Styles tab to add, remove or update styles. Styles are applied cumulatively based on elements or 
relationships tags. This allows, for example, to color elements tagged with a styled tag while keeping their shapes.  
1. Diagram: use the Diagram tab to update Diagrams's description.
1. After you're done with editing, export a diagram as PNG. To export as an SVG:
    * Open browser Developer Tools and copy HTML of an SVG element. Paste it into an SVG file.
    * Replace `&nbsp;` with `&#160;` 
    * Optionally, add DTD:
        * `<!DOCTYPE svg PUBLIC "-//W3C//DTD SVG 1.1//EN" "http://www.w3.org/Graphics/SVG/1.1/DTD/svg11.dtd">`
1. Save updated YAML (via copy-and-paste). 
1. Commit updated files.

C4 Deployment Diagrams are not currently supported by Structurizr Express. The Deployment Diagram is modeled in
a free [draw.io](http://draw.io) online tool with 
the [C4 Modelling plugin for draw.io](https://github.com/tobiashochguertel/c4-draw.io).

To update the diagram:
1. Open [draw.io](http://draw.io) online. [Plugins are not supported](https://github.com/jgraph/drawio-desktop/issues/7) 
in draw.io Desktop.
1. (one-time setup) Select GitHub as a storage option.   
1. (one-time setup) Install 
[C4 Modelling plugin for draw.io](https://github.com/tobiashochguertel/c4-draw.io).
1. Open ERNIE C4 Deployment Diagram.xml
1. Edit. Be aware that default draw.io C4 plug-in styling 
[doesn't match](https://github.com/tobiashochguertel/c4-draw.io/issues/3) the default C4 styling. It's recommended to 
duplicate shapes or copy existing diagram styles, which were matched to the default C4 styling as close as possible.
1. Save. The diagram will be committed directly to GitHub.    
1. After you're done with editing, export a diagram as PNG and SVG.
1. Commit updated files.