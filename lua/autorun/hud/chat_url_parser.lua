local URL_TRIGGER	= "!openurl"

if (CLIENT) then
	local MCLR1	= Color(100, 200, 100)
	local MCLR2	= Color(150, 250, 150)

	local INVALID_URL	= { MCLR1, "Invalid URL." }
	local URL_DETECTED	= { MCLR1, "URL detected. Type ", MCLR2, URL_TRIGGER, MCLR1, " to open it." }
	local URLM = { "https?://%S+", "www%.%S+" }
	
	local LAST_URL = nil
	
	hook.Add("OnPlayerChat", "CHud_Chat", function(Player, Text, TeamChat, Dead)
		if (Player == LocalPlayer() and Text == URL_TRIGGER) then
			if (LAST_URL == nil or #LAST_URL < 1) then
				chat.AddText(unpack(INVALID_URL))
			else
				gui.OpenURL(LAST_URL)
			end
			return true
		end
		
		local URL = nil
		for	i = 1, #URLM do
			if (URL == nil) then URL = Text:match(URLM[i]) end
		end
		
		if (URL) then
			chat.PlaySound()
			timer.Simple(.1, function()
				chat.AddText(unpack(URL_DETECTED))
				if not URL:StartWith("http:") or not URL:StartWith("https:") then
					LAST_URL = "http://" .. URL
				else
					LAST_URL = URL
				end
			end)
		end
		
		return nil
	end)
	
elseif (SERVER) then
	
	hook.Add("OnPlayerChat", "CHud_Chat", function(Player, Text, TeamChat, Dead)
		if (Text == URL_TRIGGER) then return true end
	end)
	
end