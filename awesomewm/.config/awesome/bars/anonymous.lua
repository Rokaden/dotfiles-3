local awful = require("awful")
local gears = require("gears")
local wibox = require("wibox")
local beautiful = require("beautiful")
local helpers = require("helpers")
local dpi = require('beautiful').xresources.apply_dpi
local separators = require('util.separators')
local widget = require('util.widgets')

-- widgets load
local hostname = require("widgets.hostname")
local tor = require("widgets.button_tor")
local scrot = require("widgets.scrot")
local wifi_str = require("widgets.wifi_str")
local pad = separators.pad
local tagslist = require("taglists.anonymous")

-- {{{ Redefine widgets with a background

local mpc_button = require('widgets.button_only_mpc')
local my_mpc_button = widget.bg_rounded( beautiful.xbackground, "#873076", mpc_button )

local mpc = require("widgets.mpc")
local mpc_bg = beautiful.widget_mpc_bg
local my_mpc = widget.bg_rounded( mpc_bg, "#3b6f6f", mpc )

local volume = require("widgets.volume")
local volume_bg = beautiful.widget_volume_bg
local my_vol = widget.bg_rounded( volume_bg, "#5b8f94", volume_widget )

local mail = require("widgets.mail")
local mail_bg = beautiful.widget_battery_bg
local my_mail = widget.bg_rounded( mail_bg, "#567092", mail )

local ram = require("widgets.ram")
local ram_bg = beautiful.widget_ram_bg
local my_ram = widget.bg_rounded( ram_bg, "#524e87", ram_widget )

local battery = require("widgets.battery")
local bat_bg = beautiful.widget_battery_bg
local my_battery = widget.bg_rounded( bat_bg, "#794298", battery_widget )

local date = require("widgets.date")
local date_bg = beautiful.widget_date_bg
local my_date = widget.bg_rounded( date_bg, "#873075", date_widget )

local my_menu = require("menu")
local launcher = awful.widget.launcher(
  { image = beautiful.awesome_icon, menu = my_menu }
)
local my_launcher = widget.bg_rounded( "#4a455e", "#20252c", launcher, "button" )
local my_change_theme = require("widgets.button_change_theme")

-- widget redefined }}}

-- {{{ Helper functions
local function client_menu_toggle_fn()
  local instance = nil

  return function() 
    if instance and instance.wibox.visible then
      instance:hide()
      instance = nil
    else
      instance = awful.menu.clients({ theme = { width = 250 } })
    end
  end
end
-- }}}

-- {{{ Wibar

-- Add the bar on each screen
awful.screen.connect_for_each_screen(function(s)

  -- Create a promptbox for each screen
  s.mypromptbox = awful.widget.prompt()

  -- Create a tasklist widget for each screen
  s.mytasklist = require("widgets.tasklist")(s)

  --s.mytaglist = require("taglists.anonymous")(s, {mode = "icon", want_layout = "grid"}
  s.mytaglist = require("taglists.anonymous")

-- For look like a detached bar, we have to add a fake invisible bar...
s.useless_wibar = awful.wibar({ position = beautiful.wibar_position, screen = s, height = beautiful.screen_margin * 2, opacity = 0 })

-- Create the wibox with default options
s.mywibox = awful.wibar({ height = beautiful.wibar_size, bg = beautiful.wibar_bg, width = beautiful.wibar_width })

-- Add widgets to the wibox
s.mywibox:setup {
  layout = wibox.layout.align.horizontal,
  spacing = dpi(9),
    { -- Left widgets
      layout = wibox.layout.fixed.horizontal,
      spacing = 12,
      my_launcher,
      s.mytaglist,
      --s.mypromptbox,
      --distrib_icon,
      my_mpc_button,
      --wifi_str_widget,
      wibox.widget.systray(),
    },
    { -- middle
      layout = wibox.layout.fixed.horizontal,
      s.mytasklist
    },
    { -- right
      layout = wibox.layout.fixed.horizontal,
      pad(2),
      tor,
      pad(1),
      my_mpc,
      pad(1),
      my_vol,
      pad(1),
      my_mail,
      pad(1),
      my_ram,
      pad(1),
      my_battery,
      pad(1),
      my_date,
      pad(1),
      my_change_theme,
      pad(1),
      scrot
    }
  }
end)
