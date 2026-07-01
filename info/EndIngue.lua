-- From aperturegrillz with info:
-- set in preferences -> environment -> use solo script / script file

Triggers = {}

function Triggers.init()
	if Level.index < 26 then
		Players[0]:teleport_to_level(Level.index+1)
	end
	if Players[0].polygon.index == 91 then
		Players[0]:teleport(88)
	end
end