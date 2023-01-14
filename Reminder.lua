script_name('reminder-by-ronald-bennet')
script_version('0.0.1')
script_author('Ronald_Bennet')
script_description('Hello, i hack your PC hehehe')
local inicfg = require 'inicfg'
local encoding = require 'encoding'
encoding.default = 'CP1251'
u8 = encoding.UTF8

local cfg = inicfg.load({ --Конфиг
	Remind={
		hours = 0,
		minuts = 0,
		countR = 2
	},
	RemindOn={
		remindActivate = false
	},
	RemindR={
		rr = 'Напоминалке'
	}
}, "Reminder")

local tag = '{0087FF}Reminder: {FFFFFF}' --Тэг
local scriptname = 'reminder-by-ronald-bennet' --название скрипта
local scriptversion = 'v0.0.1' --версия скрита
local json_url = 'https://raw.githubusercontent.com/DEBIJI/Reminder-by-Ronald_Bennet/main/update.json'
local prefix = tag
local url = 'https://raw.githubusercontent.com/DEBIJI/Reminder-by-Ronald_Bennet/main/update.json'

mcx = 0x0087FF -- основной цвет
mc = '{0087FF}' -- основной цвет
ff = '{FFFFFF}' -- белый цвет

function main()
    if not isSampLoaded() or not isSampfuncsLoaded() then return end
    while not isSampAvailable() do wait(0) end -- проверяем запущена игра или нет

	autoupdate('https://raw.githubusercontent.com/DEBIJI/Reminder-by-Ronald_Bennet/main/update.json', '['..string.upper(thisScript().name)..']: ')
	
	if not doesFileExist('moonloader/config/Reminder.ini') then
        if inicfg.save(cfg, 'Reminder.ini') then sampfuncsLog(tag..'Создан файл конфигурации: Reminder.ini') end
    end -- проверяем наличие конфига, если нет то создаем

	sampRegisterChatCommand('remind', cmd_remind) -- регистрируем команды
    sampRegisterChatCommand('remindt', cmd_remindt) -- регистрируем команды
    sampRegisterChatCommand('remindc', cmd_remindc) -- регистрируем команды

	sampAddChatMessage(tag..'Скрипт '..mc..scriptname..' {FFFFFF}| '..mc..scriptversion..ff..' Загружен!', mcx) --сообщение при загрузки скрипты
	sampAddChatMessage(tag..'Команды: '..mc..'/remind'..ff..' | '..mc..'/remindt'..ff..' | '..mc..'/remindc', mcx) --сообщение при загрузки скрипты

	while true do
        nowHours = tonumber(os.date("%H", os.time())) --час в эту секунду
        nowMinuts = tonumber(os.date("%M", os.time())) --минута в эту секунду

        if cfg.RemindOn.remindActivate then --если будильник включен
            if (nowHours == cfg.Remind.hours) and (nowMinuts == cfg.Remind.minuts) then --проверяет время будильника с настоящим
                alarm() --выполняется функция будильника
            end
        end
		wait(0)
    end
end

function cmd_remind(arg) --функция регистрации будильника
	local hour, minute = string.match(arg, "(%d+)%s(%d+)") --отделяем 2 аргумента на 2 переменные
	result = (hour ~= nil) and (minute ~= nil) -- проверяем, если переменная не число, то будет равно nil
	if result then --проверяем переменные на принадлежение к числам
		hour_s = tonumber(hour) --конвертируем переменную
		minute_s = tonumber(minute)--конвертируем переменную
		if ((hour_s>-1) and (hour_s <24)) and ((minute_s>-1) and (minute_s<60)) then --проверяем действительное ли время
			hour_ss = hour_s -- присваиваем другой переменной
			minute_ss = minute_s-- присваиваем другой переменной
			if hour_s<10 then hour_ss = ('0'..hour_s) end --если число в диапозоне от 0 до 9, то число меняется на '01,02...'
			if minute_s<10 then minute_ss = ('0'..minute_s) end--если число в диапозоне от 0 до 9, то число меняется на '01,02...'
			sampAddChatMessage(tag..'Напоминалка уставновленна на '..hour_ss..':'..minute_ss, mcx)set_remind() -- сообщение об уставновленном будильнике
		else
			sampAddChatMessage(tag.."Вы ввели не корректное время", mcx) --если время введено не правильное
		end
	else
		sampAddChatMessage(tag..'Использование '..mc..'/remind'..ff..' [час] [минуты]', mcx) -- если нет аргументов или вместо цифр другие символы
	end
end

function cmd_remindt(arg) --замена текста будильника
	if #arg == 0 then sampAddChatMessage(tag..'Вы не ввели текст напоминания.', mcx) --если аргументы пустые
	else 
        cfg.RemindR.rr = arg -- заносим в конфиг
		inicfg.save(cfg, "Reminder.ini") --сохраняем конфиг
		sampAddChatMessage(tag..'Вы успешно изменили текст напоминания на '..mc..arg,mcx) --сообщение о замене текста
	end
end

function cmd_remindc(arg) --замена кол-ва строк напоминалки
	if #arg==0 then sampAddChatMessage(tag..'Используйте '..mc..'/remindc [кол-во]',mcx) --если число не введено
    else
        local argCount = string.match(arg, "(%d+)") -- присваиваем значение аргумента переменной
        if argCount ~= nil then --проверяем аргумент на принадлежность к цифрам
            sampAddChatMessage(tag..'Вы успешно изменили кол-во строк напоминания на '..mc..argCount..ff..', было '..mc..cfg.Remind.countR..'',mcx)--сообщение об успешной замене текста
            cfg.Remind.countR = argCount --заносим в Конфиг
            inicfg.save(cfg, "Reminder.ini") --сохраняем конфиг
        else 
            sampAddChatMessage(tag..'Введите число ',mcx) --если введено не число
        end
    end
end

function alarm() --функция будильника 
    for i = 1, cfg.Remind.countR, 1 do --выводим в чат то кол-во строк, которое мы указали
         sampAddChatMessage(tag..'Мы напоминаем вам о '..mc..cfg.RemindR.rr, mcx) -- текст будильника
    end
    cfg.RemindOn.remindActivate = false --выключаем будильник
    inicfg.save(cfg, "Reminder.ini") -- сохраняем конфинг
end

function set_remind() --установка будильник
    cfg.RemindOn.remindActivate = true --включение будильник
    cfg.Remind.hours = hour_ss --занесение в конфинг
    cfg.Remind.minuts = minute_ss--занесение в конфинг
    inicfg.save(cfg, "Reminder.ini")--сохраняем конфинг
end



--
--     _   _   _ _____ ___  _   _ ____  ____    _  _____ _____   ______   __   ___  ____  _     _  __
--    / \ | | | |_   _/ _ \| | | |  _ \|  _ \  / \|_   _| ____| | __ ) \ / /  / _ \|  _ \| |   | |/ /
--   / _ \| | | | | || | | | | | | |_) | | | |/ _ \ | | |  _|   |  _ \\ V /  | | | | |_) | |   | ' /
--  / ___ \ |_| | | || |_| | |_| |  __/| |_| / ___ \| | | |___  | |_) || |   | |_| |  _ <| |___| . \
-- /_/   \_\___/  |_| \___/ \___/|_|   |____/_/   \_\_| |_____| |____/ |_|    \__\_\_| \_\_____|_|\_\                                                                                                                                                                                                                
--
-- Author: http://qrlk.me/samp
--
function autoupdate(json_url, prefix, url)
  local dlstatus = require('moonloader').download_status
  local json = getWorkingDirectory() .. '\\'..thisScript().name..'-version.json'
  if doesFileExist(json) then os.remove(json) end
  downloadUrlToFile(json_url, json,
    function(id, status, p1, p2)
      if status == dlstatus.STATUSEX_ENDDOWNLOAD then
        if doesFileExist(json) then
          local f = io.open(json, 'r')
          if f then
            local info = decodeJson(f:read('*a'))
            updatelink = info.updateurl
            updateversion = info.latest
            f:close()
            os.remove(json)
            if updateversion ~= thisScript().version then
              lua_thread.create(function(prefix)
                local dlstatus = require('moonloader').download_status
                local color = -1
                sampAddChatMessage((prefix..'Обнаружено обновление. Пытаюсь обновиться c '..thisScript().version..' на '..updateversion), color)
                wait(250)
                downloadUrlToFile(updatelink, thisScript().path,
                  function(id3, status1, p13, p23)
                    if status1 == dlstatus.STATUS_DOWNLOADINGDATA then
                      print(string.format('Загружено %d из %d.', p13, p23))
                    elseif status1 == dlstatus.STATUS_ENDDOWNLOADDATA then
                      print('Загрузка обновления завершена.')
                      sampAddChatMessage((prefix..'Обновление завершено!'), color)
                      goupdatestatus = true
                      lua_thread.create(function() wait(500) thisScript():reload() end)
                    end
                    if status1 == dlstatus.STATUSEX_ENDDOWNLOAD then
                      if goupdatestatus == nil then
                        sampAddChatMessage((prefix..'Обновление прошло неудачно. Запускаю устаревшую версию..'), color)
                        update = false
                      end
                    end
                  end
                )
                end, prefix
              )
            else
              update = false
              print('v'..thisScript().version..': Обновление не требуется.')
            end
          end
        else
          print('v'..thisScript().version..': Не могу проверить обновление. Смиритесь или проверьте самостоятельно на '..url)
          update = false
        end
      end
    end
  )
  while update ~= false do wait(100) end
end
