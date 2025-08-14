-- Trivia

local TRIVIA_VERSION = "0.22"
local SecondsCounter=0;
local Regen;local HealthPoint={};local ManaPoint={};local TimePoint=0;
local Kill_Counter = {};
local Coins_Temp = 0;
local Strike_Counter = {};

--Вспомогательная переменная для скрипта Arcane Surg + Fire Blast
-- /script local ix,sw;for ix=1,99 do if GetSpellName(ix,1)=="Arcane Surge"then if GetSpellCooldown(ix,1)>0 or ArcaneSurg==0 then CastSpellByName("Fire Blast");else CastSpellByName("Arcane Surge");ArcaneSurg=0;end;break;end;end;
ArcaneSurg=0;


local function COLOR_HUNTER(text) if text then return "|cffabd473"..text.."|r";end;end;
local function COLOR_GREEN2(text) if text then return "|cff00ff00"..text.."|r";end;end;

local function Info_Print(msg,r,g,b,frame,id)
	if (not r) then r = 0.8; end; if (not g) then g = 0.4; end; if (not b) then b = 0.8; end;
	if ( DEFAULT_CHAT_FRAME ) then 	DEFAULT_CHAT_FRAME:AddMessage(msg, r, g, b, id);end;
end;

local function GotBuff(name,target) 
	if not target then target="player";end;
	local tex,cnt,ix;
	for ix = 1,32 do 
		tex,cnt = UnitBuff(target,ix);
		if not tex then return; end;
		if strfind(tex,name) then return cnt; end;
	end;
end;
function Trivia_OnLoad()
	
	if not TRIVIA_CONF then TRIVIA_CONF = {}; end;
	if not TRIVIA_CONF["language"] then TRIVIA_CONF["language"] = "EN"; end;
	if not TRIVIA_CONF["Kill_Counter"] then TRIVIA_CONF["Kill_Counter"] = 0; end;
	Kill_Counter[3]=0;
	Strike_Counter[1]=true;Strike_Counter[2]=0;Strike_Counter[3]=0;Strike_Counter[4]=0;Strike_Counter[5]=0;Strike_Counter[6]=0;Strike_Counter[6]=0;Strike_Counter[7]=0;
	
	if not TRIVIA_CONF["Coins_Counter"] then TRIVIA_CONF["Coins_Counter"] = 0; end;
	Coins_Temp=GetMoney();
	
	SlashCmdList["TRIVIA"] = TRIVIA_CommandHandler;
	SLASH_TRIVIA1 = "/trivia";
	
	--Regen 
	if not Regen then Regen = 0; end;
	SlashCmdList["REGEN"] = REGEN_CommandHandler;
	SLASH_REGEN1 = "/regen";
	
	--counter
	this:RegisterEvent("CHAT_MSG_COMBAT_HOSTILE_DEATH");
	this:RegisterEvent("CHAT_MSG_COMBAT_XP_GAIN");
	this:RegisterEvent("CHAT_MSG_COMBAT_HONOR_GAIN");
	this:RegisterEvent("COMBAT_TEXT_UPDATE");
	-- this:RegisterEvent("CHAT_MSG_CHANNEL");
	SlashCmdList["KILL"] = KILL_CommandHandler;
	SLASH_KILL1 = "/kill";
	
	--counter
	SlashCmdList["COINS"] = COINS_CommandHandler;
	SLASH_COINS1 = "/coins";
	
	--Calculator 
	this:RegisterEvent("UNIT_COMBAT");
	SlashCmdList["STRIKE"] = STRIKE_CommandHandler;
	SLASH_STRIKE1 = "/strike";
	
	--Calculator 
	SlashCmdList["CALCULATOR"] = CALCULATOR_CommandHandler;
	SLASH_CALCULATOR1 = "/calculator"; SLASH_CALCULATOR2 = "/calc";
	
	--Rest 
	SlashCmdList["REST"] = function() local RX,RP=GetXPExhaustion();RP=format("%.0f",RX/UnitXPMax("player")*100);DEFAULT_CHAT_FRAME:AddMessage(COLOR_HUNTER("Rest = ")..COLOR_GREEN2(RP.."% / "..RX.."xp")); end;
	SLASH_REST1 = "/rest";
	
	--Link 
	SlashCmdList["LINK"] = LINK_CommandHandler;
	SLASH_LINK1 = "/link";
	
	--Spam 
	SlashCmdList["SPAM"] = SPAM_CommandHandler;
	SLASH_SPAM1 = "/spam";
	
	Trivia_Emo();
	
	Info_Print("Trivia ".. COLOR_GREEN2(TRIVIA_VERSION) .." loaded. /trivia");
end;

function TRIVIA_CommandHandler(cmd)
	
	if string.sub(cmd, 1, 2) == "" then 
		if TRIVIA_CONF["language"] == "RU" then Info_Print("Предоставляет команды: trivia RU/EN - переключает язык интерфейса, regen - отображает регенирацию здаровья и маны, kill - счётчик убийст (глобальный, сессионный, временный), calculator (5+5) - калькулятор. link - линк предмета из базы. /rest - Показать количество отдыха."); end;
		if TRIVIA_CONF["language"] == "EN" then Info_Print("Provides commands: trivia RU/EN - switches the interface language, regen - displays the regeneration of health and mana, kill - kill counter (global, session, temporary), calculator (5+5) - calculator. link - link of the item from the database. /rest - Show the amount of rest."); end;
	end;
	if string.sub(cmd, 1, 2) == "ru" or string.sub(cmd, 8, 9) == "RU" then TRIVIA_CONF["language"] = "RU";Info_Print("Язык: "..COLOR_GREEN2(TRIVIA_CONF["language"]).."."); end;
	if string.sub(cmd, 1, 2) == "en" or string.sub(cmd, 8, 9) == "EN" then TRIVIA_CONF["language"] = "EN";Info_Print("Language: "..COLOR_GREEN2(TRIVIA_CONF["language"]).."."); end;
end;

function LINK_CommandHandler(cmd)
	local COLOR_1 			= "cFFaa55cc"
	local COLOR_2			= "cFFffff00"
	local COLOR_3			= "cFFcc0000"
	local COLOR_4			= "cFF00cc00"
	local COLOR_Junk		= "cFF9d9d9d"
	local COLOR_Common		= "cFFffffff"
	local COLOR_Uncommon	= "cFF1eff00"
	local COLOR_Rare		= "cFF0070dd"
	local COLOR_Epic		= "cFFa335ee"
	local COLOR_Lengendary	= "cFFff8000"
	local COLOR_Disable		= "cFF555555"
	local COLOR_Enable		= "cFF00ff00"
	if string.sub(cmd, 1, 2) == "" then 
		if TRIVIA_CONF["language"] == "RU" then Info_Print("/link номер предмета из датобазы/показываемое имя/цвет(0-11 или cFF00ff00)"); end;
		if TRIVIA_CONF["language"] == "EN" then Info_Print("/link item number from the database/ display name/ color(0-11 or cFF00ff00)"); end;
	else 
		local a1,a2,a3; a1,a2,a3=strmatch(cmd,"(%d+)[%/]+([%a%s%d]+)[%/]+([%d%a]+)");
		if not a1 then a1,a2=strmatch(cmd,"(%d+)[%/]+([%a%s%d]+)");end;
		if not a1 then a1=strmatch(cmd,"(%d+)");end;
		if a1 then 
			if not a2 then a2="link"; else if not strmatch(a2,"([%a%d]+)") then a2="link";end; end;
			if a3=="0" or not a3 then a3=COLOR_Disable;end; if a3=="11" then a3=COLOR_Enable;end; if a3=="7" then a3=COLOR_1;end; if a3=="8" then a3=COLOR_2;end; if a3=="9" then a3=COLOR_3;end; if a3=="10" then a3=COLOR_4;end;
			if a3=="1" then a3=COLOR_Junk;end; if a3=="2" then a3=COLOR_Common;end; if a3=="3" then a3=COLOR_Uncommon;end; if a3=="4" then a3=COLOR_Rare;end; if a3=="5" then a3=COLOR_Epic;end; if a3=="6" then a3=COLOR_Lengendary;end;
			DEFAULT_CHAT_FRAME:AddMessage("\124"..a3.."\124Hitem:"..a1.."::::::::40:::::\124h["..a2.."]\124h\124r");
		end;
	end;
end;

function CALCULATOR_CommandHandler(cmd)	
	if string.sub(cmd, 1, 2) == "" then 
		Info_Print("calc (5+5)*2")
	else 
		if not string.find(cmd, "[%a%s%=]") then 
			local stemp=string.gsub(cmd,"[^1^2^3^4^5^6^7^8^9^0^%-^%+^%*^%/^%.^%(^%)^%^^%%]","") ;
			if string.find(stemp, "(%d[%-%+%*%/%^%^^%%]%d)") then 
				local func = assert(loadstring("return " .. stemp));
				if tonumber(func()) then 
					Info_Print(COLOR_HUNTER(stemp.."="..COLOR_GREEN2(func())));
				end;
			end;
		end;
	end;
end;

function REGEN_CommandHandler(cmd)
	if string.sub(cmd, 1, 4) == "" then 
		if Regen == 0 then Regen = 2; else Regen = 0; end;
	else
		Regen = tonumber(string.sub(cmd, 1, 4));
	end;
	if TRIVIA_CONF["language"] == "RU" then Info_Print("Временная петля регенерации: "..COLOR_GREEN2(Regen).." seconds."); end;
	if TRIVIA_CONF["language"] == "EN" then Info_Print("Regen time loop: "..COLOR_GREEN2(Regen).." секунд."); end;
end;

function SPAM_CommandHandler(cmd)
	if string.len(cmd)==0 then 
		if TRIVIA_CONF["language"] == "RU" then Info_Print("/spam сообщение."); end;
		if TRIVIA_CONF["language"] == "EN" then Info_Print("/spam message."); end;
	else
		local id,name,ix
		for ix=1,10 do 
			id,name = GetChannelName(ix);
			if name then 
				if string.find(name,"General") or string.find(name,"Trade") or string.find(name,"LookingForGroup") or string.find(name,"world") then 
					SendChatMessage(cmd,"CHANNEL",nil,id);
					-- print(id.."|"..name.."|"..cmd);
				end;
			end;
		end;
	end;
end;

function KILL_CommandHandler(cmd)
	if strfind(cmd,"show") then 
		if TRIVIA_CONF["language"] == "RU" then Info_Print(COLOR_HUNTER("Всего убито: "..COLOR_GREEN2(TRIVIA_CONF["Kill_Counter"]))); end;
		if TRIVIA_CONF["language"] == "EN" then Info_Print(COLOR_HUNTER("Total kills: "..COLOR_GREEN2(TRIVIA_CONF["Kill_Counter"]))); end;
		if TRIVIA_CONF["language"] == "RU" then Info_Print(COLOR_HUNTER("Убито за сессию: "..COLOR_GREEN2(Kill_Counter[3]))); end;
		if TRIVIA_CONF["language"] == "EN" then Info_Print(COLOR_HUNTER("Kills per session: "..COLOR_GREEN2(Kill_Counter[3]))); end;
		if Kill_Counter[1] then 
			if TRIVIA_CONF["language"] == "RU" then Info_Print(COLOR_HUNTER(Kill_Counter[1].." убито: ")..COLOR_GREEN2(Kill_Counter[2]));end;
			if TRIVIA_CONF["language"] == "EN" then Info_Print(COLOR_HUNTER(Kill_Counter[1].." killed: ")..COLOR_GREEN2(Kill_Counter[2]));end;
			if TRIVIA_CONF["language"] == "RU" then Info_Print(COLOR_HUNTER("Убито группой: "..COLOR_GREEN2(Kill_Counter[4]))); end;
			if TRIVIA_CONF["language"] == "EN" then Info_Print(COLOR_HUNTER("Killed by the group: "..COLOR_GREEN2(Kill_Counter[4]))); end;
		else 
			if TRIVIA_CONF["language"] == "RU" then Info_Print(COLOR_HUNTER("Временный счётчик не запущен.")); end;
			if TRIVIA_CONF["language"] == "EN" then Info_Print(COLOR_HUNTER("The temporary counter is not running.")); end;
		end;
	end;
	if strfind(cmd,"start") then 
		if UnitExists("target") then 
			Kill_Counter[1]=GetUnitName("target");
			if TRIVIA_CONF["language"] == "RU" then Info_Print("Счётчик для "..COLOR_HUNTER(Kill_Counter[1]).." запущен."); end;
			if TRIVIA_CONF["language"] == "EN" then Info_Print("Counter for "..COLOR_HUNTER(Kill_Counter[1]).." is running."); end;
		else 
			Kill_Counter[1]="any";
			if TRIVIA_CONF["language"] == "RU" then Info_Print("Счётчик для "..COLOR_HUNTER("Кто либо").." запущен."); end;
			if TRIVIA_CONF["language"] == "EN" then Info_Print("Counter for "..COLOR_HUNTER("Anyone").." is running."); end;
		end;
		Kill_Counter[2]=0; Kill_Counter[4]=0; Kill_Counter[5]=0;
	end; 
	if strfind(cmd,"reset") then 
		-- Kill_Counter[1]="any";
		Kill_Counter[2]=0; Kill_Counter[4]=0; Kill_Counter[5]=0;
		if strfind(cmd,"total") then TRIVIA_CONF["Kill_Counter"]=0;end;
		if TRIVIA_CONF["language"] == "RU" then Info_Print("Счётчик сброшен."); end;
		if TRIVIA_CONF["language"] == "EN" then Info_Print("The counter has been reset."); end;
	end;
	if strfind(cmd,"stop") then 
		Kill_Counter[1]=nil;
		-- Kill_Counter[2]=nil; Kill_Counter[4]=nil; Kill_Counter[5]=nil; Kill_Counter[6]=nil;
		if TRIVIA_CONF["language"] == "RU" then Info_Print("Счётчик остановлен."); end;
		if TRIVIA_CONF["language"] == "EN" then Info_Print("The counter is stopped."); end;
	end;
	if tonumber(cmd) then 
		if tonumber(cmd)>0 then 
			Kill_Counter[6]=tonumber(cmd);
			if TRIVIA_CONF["language"] == "RU" then Info_Print("Счётчик будет отображаться каждые: "..COLOR_HUNTER(Kill_Counter[6]));end;
			if TRIVIA_CONF["language"] == "EN" then Info_Print("The counter will be displayed every : "..COLOR_HUNTER(Kill_Counter[6]));end;
		else 
			if TRIVIA_CONF["language"] == "RU" then Info_Print("Счётчик не будет отображаться.");end;
			if TRIVIA_CONF["language"] == "EN" then Info_Print("The counter will not be displayed.");end;
			Kill_Counter[6]=nil;
		end;
	end;
	if string.sub(cmd, 1, 2) == "" then 
		if TRIVIA_CONF["language"] == "RU" then Info_Print("Возможные команды: start, stop, reset, reset total, show, <число> - количество показа.");end;
		if TRIVIA_CONF["language"] == "EN" then Info_Print("Possible commands: start, stop, reset, reset total, show, <number> - the number of impressions.");end;
	end;
end;

function COINS_CommandHandler(cmd)
	if strfind(cmd,"reset") then 
		TRIVIA_CONF["Coins_Counter"]=0;
		if TRIVIA_CONF["language"] == "RU" then Info_Print("Счётчик монет сброшен."); end;
		if TRIVIA_CONF["language"] == "EN" then Info_Print("The coin counter has been reset."); end;
	end;
	if string.sub(cmd, 1, 2) == "" then 
		if TRIVIA_CONF["language"] == "RU" then Info_Print(COLOR_HUNTER("Всего монет заработано: "..COLOR_GREEN2(TRIVIA_CONF["Coins_Counter"]))); end;
		if TRIVIA_CONF["language"] == "EN" then Info_Print(COLOR_HUNTER("Total coins earned: "..COLOR_GREEN2(TRIVIA_CONF["Coins_Counter"]))); end;
	end;
end;
function STRIKE_CommandHandler(cmd)
	if strfind(cmd,"show") then 
		if TRIVIA_CONF["language"] == "RU" then Info_Print(COLOR_HUNTER("Всего атак: "..COLOR_GREEN2(Strike_Counter[2]))); end;
		if TRIVIA_CONF["language"] == "EN" then Info_Print(COLOR_HUNTER("Total Attacks: "..COLOR_GREEN2(Strike_Counter[2]))); end;
		if TRIVIA_CONF["language"] == "RU" then Info_Print(COLOR_HUNTER("Целевые попадания: "..COLOR_GREEN2(Strike_Counter[3]))); end;
		if TRIVIA_CONF["language"] == "EN" then Info_Print(COLOR_HUNTER("Target hits: "..COLOR_GREEN2(Strike_Counter[3]))); end;
		if TRIVIA_CONF["language"] == "RU" then Info_Print(COLOR_HUNTER("Целевые промахи: "..COLOR_GREEN2(Strike_Counter[4]))); end;
		if TRIVIA_CONF["language"] == "EN" then Info_Print(COLOR_HUNTER("Target мisses: "..COLOR_GREEN2(Strike_Counter[4]))); end;
		if TRIVIA_CONF["language"] == "RU" then Info_Print(COLOR_HUNTER("Цель уклонилась: "..COLOR_GREEN2(Strike_Counter[5]))); end;
		if TRIVIA_CONF["language"] == "EN" then Info_Print(COLOR_HUNTER("Target evaded: "..COLOR_GREEN2(Strike_Counter[5]))); end;
		if TRIVIA_CONF["language"] == "RU" then Info_Print(COLOR_HUNTER("Цель парировала: "..COLOR_GREEN2(Strike_Counter[6]))); end;
		if TRIVIA_CONF["language"] == "EN" then Info_Print(COLOR_HUNTER("Target parried: "..COLOR_GREEN2(Strike_Counter[6]))); end;
		if TRIVIA_CONF["language"] == "RU" then Info_Print(COLOR_HUNTER("Цель блокировала: "..COLOR_GREEN2(Strike_Counter[7]))); end;
		if TRIVIA_CONF["language"] == "EN" then Info_Print(COLOR_HUNTER("Target blocked: "..COLOR_GREEN2(Strike_Counter[7]))); end;
		if TRIVIA_CONF["language"] == "RU" then Info_Print(COLOR_HUNTER("Процентное попаданий: "..COLOR_GREEN2((Strike_Counter[3]/Strike_Counter[2]*100).."%"))); end;
		if TRIVIA_CONF["language"] == "EN" then Info_Print(COLOR_HUNTER("Hit percentage: "..COLOR_GREEN2((Strike_Counter[3]/Strike_Counter[2]*100).."%"))); end;
	end;
	if strfind(cmd,"start") then 
		Strike_Counter[1]=true;
		if TRIVIA_CONF["language"] == "RU" then Info_Print("Счётчик для атак запущен."); end;
		if TRIVIA_CONF["language"] == "EN" then Info_Print("Counter for strike is running."); end;
	end;
	if strfind(cmd,"reset") then 
		Strike_Counter[1]=true;
		Strike_Counter[2]=0;
		Strike_Counter[3]=0;
		Strike_Counter[4]=0;
		Strike_Counter[5]=0;
		Strike_Counter[6]=0;
		Strike_Counter[7]=0;
		if TRIVIA_CONF["language"] == "RU" then Info_Print("Счётчик сброшен."); end;
		if TRIVIA_CONF["language"] == "EN" then Info_Print("The counter has been reset."); end;
	end;
	if strfind(cmd,"stop") then 
		Strike_Counter[1]=false;
		if TRIVIA_CONF["language"] == "RU" then Info_Print("Счётчик остановлен."); end;
		if TRIVIA_CONF["language"] == "EN" then Info_Print("The counter is stopped."); end;
	end;
	if string.sub(cmd, 1, 2) == "" then 
		if TRIVIA_CONF["language"] == "RU" then Info_Print("Возможные команды: start, stop, reset.");end;
		if TRIVIA_CONF["language"] == "EN" then Info_Print("Possible commands: start, stop, reset.");end;
	end;
end;


function Trivia_OnUpdate() 
	
	if not TRIVIA_CONF then TRIVIA_CONF = {}; end;
	if not TRIVIA_CONF["language"] then TRIVIA_CONF["language"] = "EN"; end;
	if not TRIVIA_CONF["Kill_Counter"] then TRIVIA_CONF["Kill_Counter"] = 0; end;
	if not TRIVIA_CONF["Coins_Counter"] then TRIVIA_CONF["Coins_Counter"] = 0; end;
	
	if Regen>0 then 
		if HealthPoint[2]==nil then HealthPoint[2]=0;end;
		if ManaPoint[2]==nil then ManaPoint[2]=0;end;
		----HealthPoint[2] regen
		if HealthPoint[1]==nil then HealthPoint[1]=UnitHealth("player");end;
		if HealthPoint[1]<UnitHealth("player") then HealthPoint[2]=HealthPoint[2]+(UnitHealth("player")-HealthPoint[1]); HealthPoint[1]=UnitHealth("player") end;
		if HealthPoint[1]>UnitHealth("player") then HealthPoint[1]=UnitHealth("player"); end;
		----ManaPoint[2] regen
		if ManaPoint[1]==nil then ManaPoint[1]=UnitMana("player");end;
		if ManaPoint[1]<UnitMana("player") then ManaPoint[2]=ManaPoint[2]+(UnitMana("player")-ManaPoint[1]); ManaPoint[1]=UnitMana("player"); end;
		if ManaPoint[1]>UnitMana("player") then ManaPoint[1]=UnitMana("player"); end;
	end;
	
	if GetTime() >= SecondsCounter then SecondsCounter=GetTime()+1;
		
		if Regen>0 then 
			if TimePoint >= Regen then 
				
				-- if HealthPoint[2]>0 or ManaPoint[2]>0 then DEFAULT_CHAT_FRAME:AddMessage(COLOR_GREEN2("Health restored:"..HealthPoint[2].." | Mana restored:"..ManaPoint[2].." | TimePoint:"..TimePoint.."s")); end;
				DEFAULT_CHAT_FRAME:AddMessage(COLOR_GREEN2("Health restored:"..HealthPoint[2].." | Mana restored:"..ManaPoint[2].." | TimePoint:"..TimePoint.."s"));
				HealthPoint[2]=0;HealthPoint[1]=UnitHealth("player");
				ManaPoint[2]=0;ManaPoint[1]=UnitMana("player");
				TimePoint=0;
			end;
			TimePoint=TimePoint+1;
		else 
			if HealthPoint[1] then HealthPoint[1]=nil;end;
			if HealthPoint[2] then HealthPoint[2]=0;end;
			if ManaPoint[1] then ManaPoint[1]=nil;end;
			if ManaPoint[2] then ManaPoint[2]=0;end;
		end;
		
		-- Kill_Counter[1] Имя моба для счётчика./ переключатеть.
		-- Kill_Counter[2] Счётчик.
		-- Kill_Counter[3] Счётчик сессии.
		-- Kill_Counter[4] Групповой счётчик.
		-- Kill_Counter[5] Проверочный для Kill_Counter[6] счётчик.
		-- Kill_Counter[6] Показывать счётчик каждые № убийств.
		if Kill_Counter[1] then 
			if Kill_Counter[6] then 
				if Kill_Counter[5]+1 <= Kill_Counter[2]/Kill_Counter[6] then 
					Kill_Counter[5]=Kill_Counter[2]/Kill_Counter[6];
					if TRIVIA_CONF["language"] == "RU" then Info_Print(COLOR_HUNTER(Kill_Counter[1]).." убито: "..COLOR_GREEN2(Kill_Counter[2]));end;
					if TRIVIA_CONF["language"] == "EN" then Info_Print(COLOR_HUNTER(Kill_Counter[1]).." killed: "..COLOR_GREEN2(Kill_Counter[2]));end;
				end;
			end;
		end;
		
		if Coins_Temp < GetMoney() then 
			TRIVIA_CONF["Coins_Counter"]=TRIVIA_CONF["Coins_Counter"]+(GetMoney()-Coins_Temp);
			Coins_Temp=GetMoney();
		end;
		
		if ArcaneSurg>0 then ArcaneSurg=ArcaneSurg-1; end;
		
		-- if GotBuff("Ability_Druid_CatForm") and not GotBuff("INV_Misc_Orb") then 
			-- print("1")
			-- RunMacro("!OrbOfDeception")
			-- RunSuperMacro("!OrbOfDeception")
			-- RunBody("/cast Orb of Deception")
			-- RunLine("/script CastSpellByName('Orb of Deception')")
			-- Macro("orb")
		-- end;
	end;
end;

function Trivia_OnEvent(event, arg1)
	
	--CHAT_MSG_COMBAT_HOSTILE_DEATH-- You have slain NAME!
	--CHAT_MSG_COMBAT_XP_GAIN-- Maraudine Priest dies, you gain 144 experience. (+72 exp Rested bonus)
	
	if event == "CHAT_MSG_COMBAT_HOSTILE_DEATH" and strfind(arg1,"You have slain") and Kill_Counter[1] then 
		if strfind(arg1,Kill_Counter[1]) or strfind("any",Kill_Counter[1]) then 
			Kill_Counter[2]=Kill_Counter[2]+1;
		end;
	end; 
	if event == "CHAT_MSG_COMBAT_XP_GAIN" and strfind(arg1," dies, you gain ") and Kill_Counter[1] then 
		if strfind(arg1,Kill_Counter[1]) or strfind("any",Kill_Counter[1]) then 
			Kill_Counter[4]=Kill_Counter[4]+1;
		end;
	end; 
	if event == "CHAT_MSG_COMBAT_HONOR_GAIN" and strfind(arg1," dies, honorable kill ") and Kill_Counter[1] then 
		if strfind(arg1,Kill_Counter[1]) or strfind("any",Kill_Counter[1]) then 
			Kill_Counter[4]=Kill_Counter[4]+1;
		end;
	end;
	-- if event == "CHAT_MSG_COMBAT_HOSTILE_DEATH" or event == "CHAT_MSG_COMBAT_XP_GAIN" or event == "CHAT_MSG_COMBAT_HONOR_GAIN" then 
		-- if strfind(arg1,"You have slain") or strfind(arg1," dies, you gain ") or strfind(arg1," dies, honorable kill ") then 
			-- -- TRIVIA_CONF["Kill_Counter"]=TRIVIA_CONF["Kill_Counter"]+1;
			-- if strfind(arg1,Kill_Counter[1]) or strfind("any",Kill_Counter[1]) then Kill_Counter[2]=Kill_Counter[2]+1; end;print("+")
		-- end;
	-- end;
	if event == "CHAT_MSG_COMBAT_HOSTILE_DEATH" then 
		if strfind(arg1,"You have slain") then 
			Kill_Counter[3]=Kill_Counter[3]+1;
			TRIVIA_CONF["Kill_Counter"]=TRIVIA_CONF["Kill_Counter"]+1;
		end;
	end;
	
	if event == "UNIT_COMBAT" and Strike_Counter[1] then 
		if arg1=="target" and (arg2=="WOUND" or arg3=="ABSORB" or arg3=="SPELL_ABSORBED") then 
			Strike_Counter[3]=Strike_Counter[3]+1;Strike_Counter[2]=Strike_Counter[2]+1;
		end;
		if arg1=="target" and (arg2=="MISS" or arg2=="SPELL_MISS") then Strike_Counter[4]=Strike_Counter[4]+1;Strike_Counter[2]=Strike_Counter[2]+1;end;
		if arg1=="target" and arg2=="DODGE" then Strike_Counter[5]=Strike_Counter[5]+1;Strike_Counter[2]=Strike_Counter[2]+1;end;
		if arg1=="target" and arg2=="PARRY" then Strike_Counter[6]=Strike_Counter[6]+1;Strike_Counter[2]=Strike_Counter[2]+1;end;
		if arg1=="target" and arg2=="BLOCK" then Strike_Counter[7]=Strike_Counter[7]+1;Strike_Counter[2]=Strike_Counter[2]+1;end;
	end;
	
	-- if event == "COMBAT_TEXT_UPDATE" and arg1=="SPELL_ACTIVE" and arg2=="Arcane Surge" then ArcaneSurg=5; end;
	if (event == "COMBAT_TEXT_UPDATE" and arg1=="SPELL_ACTIVE" and arg2=="Arcane Surge") 
	or (event == "UNIT_COMBAT" and arg1=="target" and arg2=="RESIST") 
	then ArcaneSurg=5; end;
	
end;

-- local print = function (msg)
  -- DEFAULT_CHAT_FRAME:AddMessage(msg)
-- end

-- is_casting = false
-- SampleTrackerFunctions = { }

-- SampleTracker = CreateFrame("Frame", nil, UIParent)
-- SampleTracker:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
-- SampleTracker:RegisterEvent("UNIT_SPELLCAST_INTERRUPTED")
-- SampleTracker:RegisterEvent("UNIT_SPELLCAST_FAILED")
-- SampleTracker:RegisterEvent("UNIT_SPELLCAST_START")
-- SampleTracker:SetScript("OnEvent", function (_,e) SampleTrackerFunctions[e]() end)

--
-- function SampleTrackerFunctions.UNIT_SPELLCAST_SUCCEEDED()
  -- if not is_casting then
    -- print("An instant spell, oh my!")
  -- end
  -- is_casting = false
-- end
--
-- function SampleTrackerFunctions.UNIT_SPELLCAST_START()
  -- is_casting = true print("is_casting")
-- end
--
-- function SampleTrackerFunctions.UNIT_SPELLCAST_FAILED()
  -- is_casting = false
-- end