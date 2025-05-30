function SEmo(tex,arg) 
	if not arg then arg="emote";end;
	SendChatMessage(tex,arg,"Common"); 
end;

function TarExNa()
	if UnitExists("target") then if not UnitIsUnit("player","target") then return UnitName("target");end;end;
end;
function Trivia_Emo()
	local sex; if UnitSex("player")==3 then sex="she";end; if UnitSex("player")==2 then sex="he";end;
	-- local TExist,TName=UnitExists("target");if TName then TExist=UnitName("target");end;
	-- if strfind(cmd,"sneeze")then if TExist then SCM("sneezes loudly at "..TName..".","emote"); else SCM("sneezes loudly.","emote");end;end;
	-- local TName;
	-- SlashCmdList["SFE"] = Soulful_CommandHandler;
	SLASH_sneeze1 = "/sneeze"; SLASH_sneeze2 = "/chih";
	SLASH_dehydration1 = "/dehydration"; SLASH_dehydration2 = "/water";
	SLASH_splash1 = "/splash"; SLASH_splash2 = "/shlepok";
	SLASH_sad1 = "/sad"; SLASH_sad2 = "/sadness";
	SLASH_pocket1 = "/pocket"; SLASH_pocket2 = "/steal"; SLASH_pocket3 = "/snitch";
	SLASH_coin1 = "/coin"; SLASH_coin2 = "/money";
	SLASH_woof1 = "/woof "; 
	SLASH_meow1 = "/meow "; 
	
	SlashCmdList["sneeze"] = function(cmd)
		if TarExNa() then SEmo("sneezes loudly at "..TarExNa().."."); else SEmo("sneezes loudly.");end;
	end;
	SlashCmdList["dehydration"] = function(cmd)
		if TarExNa() then SEmo("shows her empty water bottle to"..TarExNa().."."); else SEmo("looks dehydrated.");end;
	end;
	
	SlashCmdList["splash"] = function(cmd)
		if TarExNa() then SEmo("slaps "..TarExNa().."'s buttocks. Nice."); else SEmo("slaps his buttocks. Nice.");end;
	end;
	
	SlashCmdList["sad"] = function(cmd)
		if TarExNa() then SEmo("looks saddened as "..sex.." looks at "..TarExNa().."."); else SEmo("looks saddened.");end;
	end;
	
	SlashCmdList["pocket"] = function(cmd)
		if TarExNa() then SEmo("pulled something shiny out of "..TarExNa().."'s pocket."); else SEmo("rubs his palms, looking at people's pockets.");end;
	end;
	
	SlashCmdList["coin"] = function(cmd)
		if TarExNa() then SEmo("gives the "..TarExNa().." coin."); else if random(0,1)==1 then SEmo("tosses a coin in the air - tails fell out."); else SEmo("tosses a coin in the air - heads have fallen."); end;end;
	end;
	
	SlashCmdList["woof "] = function(cmd)
		if TarExNa() then SEmo("barks at "..TarExNa()..". Woof woof.."); else SEmo("barks loudly. Woof woof..");end;
	end;
	
	SlashCmdList["meow "] = function(cmd)
		if TarExNa() then SEmo("meows looking at "..TarExNa()..". Meow.."); else SEmo("purrs. Meow..");end;
	end;
	
	
	
	
end;