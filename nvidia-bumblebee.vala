using GLib;
using Gtk;

namespace NVIDIABumblebee {
  class AppStatusIcon : GLib.Object {
    private StatusIcon trayicon;
    private Gtk.Menu menuSystem;
    private bool active = false;
    int active_applications = 0;
    private int old_size;
    public AppStatusIcon() {
      /* Create tray icon */
      this.old_size=0;
      trayicon = new StatusIcon();
      trayicon.set_from_icon_name("nvidia-bumblebee");
      trayicon.set_tooltip_text ("NVIDIA Bumblebee");
      trayicon.set_visible(true);
                
      // This event is called when the user clicks on the icon.
      trayicon.activate.connect(open_nvidia_settings);

      create_menuSystem();
      trayicon.popup_menu.connect(menuSystem_popup);
    }

    /* Create menu for right button */
    public void create_menuSystem() {
      menuSystem = new Gtk.Menu();
      var menuAbout = new Gtk.MenuItem();
      menuAbout.set_label("NVIDIA Settings");
      menuAbout.activate.connect(open_nvidia_settings);
      menuSystem.append(menuAbout);
      var menuQuit = new Gtk.MenuItem();
      menuQuit.set_label("Quit");
      menuQuit.activate.connect(Gtk.main_quit);
      menuSystem.append(menuQuit);
      menuSystem.show_all();
    }

    /* Show popup menu on right button */
    private void menuSystem_popup(uint button, uint time) {
      menuSystem.popup(null, null, null, button, time);
    }

    private void open_nvidia_settings() {

      Process.spawn_command_line_sync ("optirun -b none nvidia-settings -c :8",
                      null,
                      null,
                      null);
    }
    public bool display_icon(){
      string status;
      string ls_stderr;
      int ls_status;
      try {
        Process.spawn_command_line_sync ("optirun --status | grep -c off",
                      out status,
                      out ls_stderr,
                      out ls_status);

        if(status.contains("off") || status.contains("on") && status.contains("Ready")){
          string text;
          Process.spawn_command_line_sync("optirun --status | grep -c off",
                      out text,
                      out ls_stderr,
                      out ls_status);
            var count = int.parse(text.substring(0, 2).replace(" ",""));
          if(!active || active_applications != count){
            active = true;
            active_applications = count;
            trayicon.set_from_icon_name("nvidia-bumblebee-active");
            trayicon.set_tooltip_text (text);
          }
        } else {
          string text;
          Process.spawn_command_line_sync("optirun --status | grep -c off",
                      out text,
                      out ls_stderr,
                      out ls_status);
          if(active){
            active = false;
            trayicon.set_from_icon_name("dialog-error");
            trayicon.set_tooltip_text("Active graphic card is unknown.");
          }
        }
      } catch (SpawnError e) {
        stdout.printf ("Error: %s\n", e.message);
        return false;
      }
      return true;
    }
  }
  private static bool is_support_nvidia_bumblebee(){
    var optirun = File.new_for_path ("/usr/bin/optirun");
    var settings = File.new_for_path ("/usr/bin/nvidia-settings");
    return optirun.query_exists() && settings.query_exists();
  }
  public static int main (string[] args) {
    if(!NVIDIABumblebee.is_support_nvidia_bumblebee()){
      Process.exit(0);
    }
    Gtk.init(ref args);
    var App = new AppStatusIcon();
    Gtk.main();
    return 0;
  }
}
