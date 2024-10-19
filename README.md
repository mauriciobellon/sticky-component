# Sticky Component Plugin for SketchUp

## Description

The Sticky Component plugin for SketchUp allows users to attach a selected component to the camera view, creating a "sticky" effect where the component follows the camera as it moves around the 3D space. This can be particularly useful for creating heads-up displays, logos, or other elements that need to remain visible regardless of the camera position.

## Features

- Select any component to make it "sticky"
- Adjust the component's position relative to the camera view
- Real-time configuration updates for fine-tuning
- Toggle the sticky effect on and off with a single button
- Customizable distance from the camera and screen position

## Installation

1. Download the files from this repository.
2. Place these files in your SketchUp Plugins directory:
   - Windows: `C:\Users\[YOUR USERNAME]\AppData\Roaming\SketchUp\SketchUp [VERSION]\SketchUp\Plugins`
   - Mac: `~/Library/Application Support/SketchUp [VERSION]/SketchUp/Plugins`
3. Restart SketchUp.

## Usage

1. Select the component you want to make sticky.
2. Click the "Select Component" button in the Sticky Component toolbar.
3. Adjust the configurations using the "Adjust Configurations" button.
4. Click the "Toggle Sticky Component" button to start/stop the sticky effect.

### Toolbar Buttons

- Select Component: Choose the component to make sticky.
- Adjust Configurations: Fine-tune the component's position and behavior.
- Toggle Sticky Component: Start or stop the sticky effect. 

### Configuration Options

- **Distance Factor**: Controls how far the component is from the camera (0.0 to 1.0).
- **Screen X**: Horizontal position on the screen (0.0 to 1.0, left to right).
- **Screen Y**: Vertical position on the screen (0.0 to 1.0, bottom to top).  

## Tips

- You can adjust configurations in real-time while the sticky effect is active.
- Experiment with different distance factors and screen positions to achieve the desired effect.
- The sticky component will automatically update its position as you orbit, pan, or zoom in the SketchUp viewport.

## ToDo
- Add "Toggle Face Camera" button to make the component always face the camera for components that need to maintain a specific orientation relative to the viewer.

## Troubleshooting

If you encounter any issues:

1. Check the Ruby Console for error messages.
2. Ensure all files are in the correct directory.
3. Verify that the icons are present in the `icons` folder.

## Support

For support, please open an issue on the GitHub repository or contact the plugin author.

## License

GPL (http://www.gnu.org/licenses/gpl.html)

## Author

Mauricio Bellon - [@mauriciobellon](https://github.com/mauriciobellon)

## Version History

- 1.0: Initial release
