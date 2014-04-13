# For LaunchBar

on handle_string(actionString)
	if (length of actionString is not 0) then
		my runRubyScript(actionString)
	end if
	open location "x-launchbar:hide"
end handle_string

on runRubyScript(action)
	do shell script "/usr/bin/otask -g \"" & action & "\""
end runRubyScript
