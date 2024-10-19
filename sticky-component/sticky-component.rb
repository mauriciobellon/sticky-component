# Begin module encapsulation
module MyComponentFollower
  extend self

  # Define variables to store the observer and component instance
  @observer = nil
  @component_instance = nil
  @distance_factor = 0.1
  @screen_x = 0.4
  @screen_y = 0.6
   @follower_active = false

  # Get the directory path of the script file
  @plugin_dir = File.dirname(__FILE__)

  # Path to the icons
  @icon_path = File.join(@plugin_dir, "icons")

  # Debugging: Print the full path to check if it's correct
  puts "Icon path: #{@icon_path}"
  puts "Icon directory exists: #{File.directory?(@icon_path)}"

  # Helper method to load icon and handle errors
  def load_icon(icon_name)
    full_path = File.join(@icon_path, icon_name)
    if File.exist?(full_path)
      puts "Icon found: #{full_path}"
      return full_path
    else
      puts "Warning: Icon file not found: #{full_path}"
      return nil
    end
  end

  # Define the CameraObserver class
  class CameraObserver < Sketchup::ViewObserver
    def initialize(component_instance, distance_factor, screen_x, screen_y)
      @component_instance = component_instance
      @distance_factor = distance_factor
      @screen_x = screen_x
      @screen_y = screen_y
    end

    def update_config(distance_factor, screen_x, screen_y)
      @distance_factor = distance_factor
      @screen_x = screen_x
      @screen_y = screen_y
      # Trigger an update immediately
      onViewChanged(Sketchup.active_model.active_view)
    end

    def onViewChanged(view)
      perform_calculation(view)
    end

    def perform_calculation(view)
      begin
        # Get the current camera properties
        camera = view.camera
        eye = camera.eye
        target = camera.target
        up = camera.up

        # Ensure all necessary vectors are present and valid
        unless valid_vector?(eye) && valid_vector?(target) && valid_vector?(up)
          puts "Error: Invalid camera properties."
          return
        end

        # Determine if the camera is in perspective or parallel projection
        perspective = camera.perspective?

        # Calculate the camera direction vector (normalized)
        direction = eye.vector_to(target)
        direction.normalize!

        # Calculate the right vector (normalized)
        right = direction.cross(up)
        right.normalize!

        # Recalculate the up vector to ensure orthogonality (normalized)
        up = right.cross(direction)
        up.normalize!

        # Clamp the distance factor between 0.0 and 1.0
        distance_factor = [[@distance_factor, 0.0].max, 1.0].min

        # Calculate distance based on camera properties
        if perspective
          # In perspective mode, use the distance from eye to target
          total_distance = eye.distance(target)
          distance = distance_factor * total_distance
        else
          # In parallel projection, use a fixed distance
          distance = distance_factor * 1000.0 # Adjust this value as needed
        end

        # Get the view size in pixels to determine aspect ratio
        width_px = view.vpwidth
        height_px = view.vpheight

        if width_px.nil? || height_px.nil? || height_px.to_f == 0.0
          # Fallback to a default aspect ratio
          aspect_ratio = 16.0 / 9.0
          puts "Warning: Unable to determine viewport size, using default aspect ratio of 16:9."
        else
          aspect_ratio = width_px.to_f / height_px.to_f
        end

        # Calculate the height and width at the given distance
        if perspective
          # For perspective projection, calculate height based on FOV
          fov = camera.fov
          fov_rad = fov * Math::PI / 180.0
          height = 2.0 * distance * Math.tan(fov_rad / 2.0)
        else
          # For parallel projection, use camera height
          height = camera.height
        end

        # Calculate the width based on the aspect ratio
        width = height * aspect_ratio

        # Calculate the offset based on normalized screen coordinates
        offset_x = (@screen_x - 0.5) * width
        offset_y = (0.5 - @screen_y) * height

        # Calculate the new position for the component
        new_position = eye.offset(direction, distance)
        new_position = new_position.offset(right, offset_x)
        new_position = new_position.offset(up, offset_y)

        # Create a transformation to move the component to the new position
        transformation = Geom::Transformation.new(new_position)

        # Optionally, make the component face the camera
        # Uncomment the following lines if you want the component to always face the camera
        # rotation = Geom::Transformation.new(new_position, direction)
        # transformation *= rotation

        # Apply the transformation to the component instance if it's still valid
        if @component_instance.valid?
          @component_instance.transformation = transformation
        else
          puts "Component no longer exists. Removing observer."
          view.remove_observer(self)
        end

      rescue StandardError => e
        puts "Error in perform_calculation: #{e.class} - #{e.message}"
        puts e.backtrace.join("\n")
      end
    end

    private

    def valid_vector?(vector)
      (vector.is_a?(Geom::Point3d) || vector.is_a?(Geom::Vector3d)) &&
        vector.to_a.all? { |coord| coord.is_a?(Numeric) }
    end
  end

  # Method to select the component
  def select_component
    model = Sketchup.active_model
    selection = model.selection
    if selection.count != 1
      UI.messagebox("Please select a single component instance.")
      return
    end

    selected = selection.first
    if selected.is_a?(Sketchup::ComponentInstance)
      @component_instance = selected
      UI.messagebox("Component '#{selected.definition.name}' selected.")
    else
      UI.messagebox("Selected entity is not a component instance.")
    end
  end

  # Method to adjust configurations with hot updates
  def adjust_configs
    prompts = ["Distance Factor (0.0 to 1.0):", "Screen X (0.0 to 1.0):", "Screen Y (0.0 to 1.0):"]
    defaults = [@distance_factor.to_s, @screen_x.to_s, @screen_y.to_s]
    input = UI.inputbox(prompts, defaults, "Adjust Component Follower Configurations")
    return unless input

    distance_factor = input[0].to_f
    screen_x = input[1].to_f
    screen_y = input[2].to_f

    # Validate inputs
    if distance_factor < 0.0 || distance_factor > 1.0
      UI.messagebox("Distance Factor must be between 0.0 and 1.0.")
      return
    end
    if screen_x < 0.0 || screen_x > 1.0
      UI.messagebox("Screen X must be between 0.0 and 1.0.")
      return
    end
    if screen_y < 0.0 || screen_y > 1.0
      UI.messagebox("Screen Y must be between 0.0 and 1.0.")
      return
    end

    @distance_factor = distance_factor
    @screen_x = screen_x
    @screen_y = screen_y

    # Update the observer if it's active
    if @observer && @observer.is_a?(CameraObserver)
      @observer.update_config(@distance_factor, @screen_x, @screen_y)
    end

    UI.messagebox("Configurations updated.")
  end

  # Method to start the component following the camera
  def start_component_follower
    # Check if already running
    if @observer
      UI.messagebox("Sticky Component is already running.")
      return
    end

    unless @component_instance && @component_instance.valid?
      UI.messagebox("No valid component selected. Please select a component first.")
      return
    end

    # Get the active model
    model = Sketchup.active_model
    return unless model

    # Get the active view
    view = model.active_view

    # Create and add the observer
    @observer = CameraObserver.new(@component_instance, @distance_factor, @screen_x, @screen_y)
    view.add_observer(@observer)

    @follower_active = true
    update_toggle_button
  end

  # Method to stop the component following the camera
  def stop_component_follower
    if @observer
      # Get the active model
      model = Sketchup.active_model
      return unless model

      # Get the active view
      view = model.active_view

      # Remove the observer
      view.remove_observer(@observer)
      @observer = nil
      # @component_instance = nil # We may want to keep the selected component

      @follower_active = false
      update_toggle_button
    else
      # UI.messagebox("Sticky Component is not running.")
    end
  end

  # Method to toggle the Sticky Component
  def toggle_component_follower
    if @follower_active
      stop_component_follower
    else
      start_component_follower
    end
    @follower_active = !@follower_active
    update_toggle_button
  end

  # Method to update the toggle button's appearance
  def update_toggle_button
    if @toggle_cmd
      if @follower_active
        @toggle_cmd.small_icon = load_icon("stop.png")
        @toggle_cmd.large_icon = load_icon("stop.png")
        @toggle_cmd.tooltip = "Stop Sticky Component"
        @toggle_cmd.status_bar_text = "Stop the Sticky Component script"
      else
        @toggle_cmd.small_icon = load_icon("start.png")
        @toggle_cmd.large_icon = load_icon("start.png")
        @toggle_cmd.tooltip = "Start Sticky Component"
        @toggle_cmd.status_bar_text = "Start the Sticky Component script"
      end
    end
  end

  # Create the toolbar and menu items
  unless file_loaded?(__FILE__)
    toolbar = UI::Toolbar.new("Sticky Component")

    # Select Component command
    cmd_select = UI::Command.new("Select Component") {
      select_component
    }
    icon_path = load_icon("select.png")
    if icon_path
      cmd_select.small_icon = icon_path
      cmd_select.large_icon = icon_path
    else
      puts "Using default icon for Select Component command"
    end
    cmd_select.tooltip = "Select Component"
    cmd_select.status_bar_text = "Select the component to follow"
    toolbar.add_item(cmd_select)

    # Adjust Configurations command
    cmd_adjust = UI::Command.new("Adjust Configurations") {
      adjust_configs
    }
    icon_path = load_icon("config.png")
    if icon_path
      cmd_adjust.small_icon = icon_path
      cmd_adjust.large_icon = icon_path
    else
      puts "Using default icon for Adjust Configurations command"
    end
    cmd_adjust.tooltip = "Adjust Configurations"
    cmd_adjust.status_bar_text = "Adjust the configurations for the Sticky Component"
    toolbar.add_item(cmd_adjust)

    # Toggle command
    @toggle_cmd = UI::Command.new("Toggle Sticky Component") {
      toggle_component_follower
    }
    icon_path = load_icon("start.png")
    if icon_path
      @toggle_cmd.small_icon = icon_path
      @toggle_cmd.large_icon = icon_path
    else
      puts "Using default icon for Toggle Sticky Component command"
    end
    @toggle_cmd.tooltip = "Start Sticky Component"
    @toggle_cmd.status_bar_text = "Start the Sticky Component script"
    toolbar.add_item(@toggle_cmd)

    toolbar.restore

    # Add menu items
    plugins_menu = UI.menu("Plugins")
    submenu = plugins_menu.add_submenu("Sticky Component")
    submenu.add_item("Select Component") { select_component }
    submenu.add_item("Adjust Configurations") { adjust_configs }
    submenu.add_separator
    submenu.add_item("Toggle Follower") { toggle_component_follower }

    file_loaded(__FILE__)
  end

end
# End module encapsulation
