=begin

Copyright 2024, Mauricio Bellon
All rights reserved

THIS SOFTWARE IS PROVIDED "AS IS" AND WITHOUT ANY EXPRESS OR IMPLIED WARRANTIES,
INCLUDING, WITHOUT LIMITATION, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND
FITNESS FOR A PARTICULAR PURPOSE.

License:            GPL (http://www.gnu.org/licenses/gpl.html)

Author :            Mauricio Bellon, mauriciobellon@gmail.com

Website:            http://github.com/mauriciobellon/sticky-component

Name :              StickyComponent

Version:            1.0

Date :              2024-10-19

Description :   StickyComponent is a SketchUp plugin that allows you to lock a component in place when you move the camera around.

Usage :             Select a component and click the StickyComponent Start button in the toolbar menu.

History:           1.0 (2024-10-19) - Initial release
                

=end


require 'sketchup'
require 'extensions'


module AS_Extensions

  module StickyComponent
  
    @extversion           = "1.0"
    @exttitle             = "StickyComponent"
    @extname              = "sticky-component"
    
    @extdir = File.dirname(__FILE__)
    @extdir.force_encoding('UTF-8') if @extdir.respond_to?(:force_encoding)
    
    loader = File.join( @extdir , @extname , "sticky-component.rb" )
   
    extension             = SketchupExtension.new( @exttitle , loader )
    extension.copyright   = "Copyright 2024, Mauricio Bellon"
    extension.creator     = "Mauricio Bellon, mauriciobellon@gmail.com"
    extension.version     = @extversion
    extension.description = "StickyComponent is a SketchUp plugin that allows you to lock a component in place when you move the camera around."
    
    Sketchup.register_extension( extension , true )
         
  end 
  
end 