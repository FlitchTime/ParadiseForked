/datum/event/pda_spam
	endWhen = 36000
	var/last_spam_time = 0
	var/obj/machinery/message_server/useMS

/datum/event/pda_spam/setup()
	last_spam_time = world.time
	find_pda_server()

/datum/event/pda_spam/tick()
	if(world.time > last_spam_time + 3000)
		//if there's no spam managed to get to receiver for five minutes, give up
		kill()
		return

	if(!useMS || !useMS.active)
		useMS = find_pda_server()

	if(useMS)
		if(prob(5))
			// /obj/machinery/message_server/proc/send_pda_message(var/recipient = "",var/sender = "",var/message = "")
			var/list/viables = list()
			for(var/obj/item/pda/check_pda in GLOB.PDAs)
				var/datum/data/pda/app/messenger/check_m = check_pda.find_program(/datum/data/pda/app/messenger)

				if(!check_m || !check_m.can_receive())
					continue
				viables.Add(check_pda)

			if(!viables.len)
				return
			var/obj/item/pda/P = pick(viables)
			var/datum/data/pda/app/messenger/PM = P.find_program(/datum/data/pda/app/messenger)

			var/sender
			var/message
			switch(pick(1,2,3,4,5,6,7,8,9,10,11,12,13))
				if(1)
					sender = pick("МегаСтавка — ставь или проиграешь!","Онлайн казино МегаСтавка — 256 лет на рынке полулегальных азартных игр","Сэкси дилеры в лучшем онлайн казино","Все остальные онлайн казино — кидалы. Мы не такие.")
					message = pick("Думаете жать одну кнопку на автомате это занятие для умственно неполноценных? Докажите что это не так сыграв у нас!",\
					"В нашем казино нет никаких «подкруток» или прочих нечестных приёмов. Вам просто не везёт!",\
					"Проиграли всю зарплату в друго казино? Проиграйте ещё одну у нас! В этот раз точно повезёт!",\
					"Зачем работать на корпорации, когда можно спустить свою жизнь чуть более приятным способом?",\
					"Игровая зависимость этом миф! Они просто не могут оторваться от 450 увлекательных игр в нашем казино!",\
					"Отделения МегаСтавки есть везде — от Элизиума до Аурума! Да, может даже на вашей станции!",\
					"В Онлайн Казино МегаСтавка мы не чешем колоду, гарантируем честную раздачу и наши колоды заряжены не в киосках как у конкурентов!")
				if(2)
					sender = pick("СладкаяЦыпа","Одинокая русская невеста","ТаярскаяКрасотка57","СкРеЛлОчКа))0","Унаточка_чмаффки","Фанатка_ЕРП_82","Босс_Качалки93")
					message = pick("Классные фотки на БыстрыхСвиданиях! Я бы пообщалась побольше, но у меня кончаются кредиты… если ты мне не скинешь немного XD (БыстрыеСвидания).",\
					"Подпишись на мой профиль — мой аккаунт [pick(GLOB.first_names_female)]@[pick(GLOB.last_names_female)].[pick("ru","ck","tj","ur","nt")], и получишь доступ к моим фото~",\
					"Слушай, у меня мало времени. Ты хочешь большой и чистой любви? Если хочешь, то ответь. Ещё никто не ответил…",\
					"У вас (1) новое сообщение от Куколки с 4 размером!",\
					"Я просто ОБОЖАЮ людей! Такие властные, сильные и умные… ммф… встретимся?",\
					"Я просто БЕЗ УМА от вульпакин! Хочу пошевелить с тобой хвостиками! Скинь аудио как ты воешь!",\
					"Я, как это говорится у меня на родине, «перфоманс артист».",\
					"Мой отец учил меня не стесняться, поэтому… не хочешь вступить в наш клуб? Всего 250 кредитов…",\
					"Я просто ВЛЮБЛЕНА в таких скреллов как ты! Такие большие, упругие и сочные щупальца на голове!",\
					"Я просто СХОЖУ С УМА от греев! Скинешь фотку своих больших глаз?",\
					"Плазмамен? А там внизу так же горячо?~",\
					"Все таяры такие милые? Обещаю почесать за ушком когда мы встретимся <3",\
					"Говорят что КПБ не устают в постели… это правда? Если так, то это свидание!",\
					"У Кидан такие большие глаза… скажем так, им есть на что посмотреть…",\
					"Легендарная гибкость и влажность слаймоменов… Хочу опробовать на себе!",\
					"Всегда хотелось пригреть драска… кстати, ты сегодня мальчик или девочка?",\
					"Надеюсь что диона переживёт отсутствие света под одеялом?~",\
					"Все остальные такие неженки… а вот воксы — самое то. Особенно пираты, ух… Встретимся?",\
					"У вас (2) новых просмотров профиля: Секси Скреллка и Сосед-по-Качалке")
				if(3)
					sender = pick("Ассоциация Галактических Платежей","Бюро Отличного Бизнеса","Надёжные Электронные Платежи","Финансовый Отдел NanoTrasen","Главное Казначейство")
					message = pick("Роскошные часы по бросовым ценам! Есть экземпляры с древнего Альтама!",\
					"Часы, Ювелирные Изделия и Аксессуары из костей %УДАЛЕНО%, Сумки и Кошельки из кожи %УДАЛЕНО%",\
					"Внесите на счёт $100 и мгновенно получите назад $300! «Реально работает!» — Бобби",\
					"Кредиты для граждан ТСФ! Всего лишь от 99% годовых! Для остальных — 100%!",\
					"К нам поступила жалоба от одного из Ваших коллег по поводу его отношениий с Вами. После разбирательств вы были объявлены в розыск за домогательства. Я могу убедить его отозвать заявление за символические 5000 кредитов.",\
					"Мы убедительно просим Вас открыть ОТЧЕТ О ЖАЛОБЕ (прилагается), чтобы ответить на поступившую на вас жалобу, иначе вам будет начислен штраф.")
				if(4)
					sender = pick("На часах полшестого?","Имеете проблемы с дисфункцией?","Слишком часто «болит голова»?")
					message = pick("Доктор Максман: РЕАЛЬНЫЕ доктора, РЕАЛЬНАЯ наука, РЕАЛЬНЫЕ результаты! Уникальная мазь на основе дегидроза фуфломицина!",\
					"Доктор Максман был создан Джорджем Окуляром, сертифицированным ЦК урологом который лишь в этом секторе помог больше 70 000 пациентов с «мужскими проблемами». Может даже вашему начальнику!",\
					"После семи лет исследований доктор Окуляр и его команда разработали эту простую и революционную формулу улучшения для мужчин. Редкий фуфломицин удалось синтезировать патентованым способом с помощью дегидроза монооксида дигидрогена!",\
					"Мужчины всех видов сообщают об УДИВИТЕЛЬНОМ увеличении длины, ширины и выносливости.")
				if(5)
					sender = pick("Др.","Наследный принц","Король-регент","Профессор","Капитан")
					sender += " " + pick("Роберт","Альфред","Джозефат","Кингсли","Сехи","Жуан")
					sender += " " + pick("Мугавэ","Нкем","Гвембеш","Абимбола","Ндим","Эну")
					message = pick("ВАШИ СРЕДСТВА БЫЛИ ПЕРЕВЕДЕНЫ В БАНК РАЗВИТИЯ [pick("Салусы","Сегунды","Цефея","Андромеды","Пи Журавля","Короны","Аквиллы","АРЕСА","Аселлия")]. ДЛЯ ДАЛЬНЕЙШЕГО ПЕРЕВОДА ДЕНЕЖНЫХ СРЕДСТВ СООБЩИТЕ СВОЙ НОМЕР АККАУНТА И ПИН-КОД.",\
					"Мы рады сообщить вам, что в связи с задержкой нам было поручено НЕМЕДЛЕННО перевести все средства на ваш счет. Для подтверждения счёта переведите 1000 кредитов. Не стоит волноваться, мы вернём вам кредиты после проверки.",\
					"Уважаемый получатель средств, сообщаем Вам, что перевод наследства окончательно одобрен и деньги готовы для получения Вами. Всё что Вам нужно сделать — отправить на этот же номер столько кредитов сколько Вы сможете. Это простая банковская формальность. В качестве благодарности мы вышлем Вам в 10 раз больше кредитов.",\
					"Из-за отсутствия у меня доверенных лиц мне требуется финансовый счет за пределами моего мира чтобы немедленно внести сумму в размере ПЯТИ МИЛЛИОНОВ кредитов.",\
					"Приветствую вас, сэр или мэм.Я с огромным сожалением сообщаю вам, что я умираю, и, из-за отсутствия наследников я выбрал вас, чтобы вы получили все мои сбережения за всю мою жизнь в размере 1,5 миллиарда кредитов. Но у меня нет вашего номера аккаунта и пин-кода, пожалуйста, сообщите их пока не поздно.")
				if(6)
					sender = pick("Подразделение Морального Духа NanoTrasen","Вы одиноки?","Дон Солевая","www.wetskrell.nt")
					message = pick("Подразделение Морального Духа NanoTrasen предоставляет вам качественные развлекательные сайты. www.wetskrell.nt — один из таких сайтов и, специально для вас, ЦК сделало его бесплатным! Осталось только перейти по ссылке!",\
					"WetSkrell.nt является ксенофильским веб-сайтом, одобренным NT для использования членами экипажа мужского пола среди множества станций и аванпостов.",\
					"Wetskrell.nt обеспечивает высочайшее качество мужских развлечений для сотрудников Nanotrasen. Почти все модели старше 18 лет!",\
					"Просто введите номер и пин-код своего банковского аккаунта Nanotrasen. После этого вы получите безлимитный доступ ко ВСЕМУ контенту www.wetskrell.nt!")
				if(7)
					sender = pick("Вы выиграли бесплатные билеты!","Нажмите здесь, чтобы получить свой приз!","Вы 1000-й посетитель!","Вы - счастливый обладатель главного приза!")
					message = pick("Вы выиграли билеты на новейший боевик БИТВА ЗА СТАНЦИЮ",\
					"Вы выиграли билеты на новейшую криминальную драму ПО СЛЕДАМ МАРТЫШЕК",\
					"Вы выиграли билеты на новейшую романтическую комедию БОЛЬШАЯ РАЗБОРКА В МАЛЕНЬКОЙ КРОВАТИ",\
					"Вы выиграли билеты на скандальный блокбастер ПОЛНЫЙ ДОСТУП",\
					"Вы выиграли билеты на скандальную комедию КАПИТАН МЁРТВ!",\
					"Вы выиграли билеты на фильм ужасов УДАР СПЯЩЕГО КАРПА",\
					"Вы выиграли билеты на слэшер ТУННЕЛЬНЫЙ СНЕГОВИК",\
					"Вы выиграли билеты на трагикомедию БУДНИ ОХРАНЫ",\
					"Вы выиграли билеты на %УДАЛЕНО АВТОМАТИЧЕСКИМ ФИЛЬТРОМ. СЛАВА NANOTRASEN%",\
					"Вы выиграли билеты на короткометражный фильм ВСЕ КОНТРАКТЫ РАСТОРГНУТЫ",\
					"Вы выиграли билеты на романтическую комедию ПЕРВЫЙ ХОНК!",\
					"Вы выиграли билеты на приключенческий фильм ВОЛШЕБНИКИ ИЗ ДАЛЁКОГО КОСМОСА",\
					"Вы выиграли билеты на фэнтези ПОСЛЕДНИЙ СЫН ХОНКОМАТЕРИ",\
					"Вы выиграли билеты на боевик МЕСТЬ СИНДИКАТА, ЭПИЗОД III!",\
					"Вы выиграли билеты на документальный фильм СЛАВА НТ",\
					"Вы выиграли билеты на эротический фильм МОХНАТАЯ ПОДРУГА",\
					"Вы выиграли билеты на эротический фильм КЛУБ КОЖЕВЕННОГО МАСТЕРСТВА",\
					"Вы выиграли билеты на боевик РОБАСТБОРГ",\
					"Вы выиграли билеты на драму 28 ОТТЕНКОВ ВУЛЬПАКИН",\
					"Вы выиграли билеты на новейший триллер ЕРЕСЬ В ЦИРКЕ")
				if(8)
					sender = pick("Тамада, баян, услуги","Баянист Тамада Дискотека","Свадьба за 1000 кредитов!","Организуем праздники несмотря на легальность!")
					message = pick("Увлекательные конкусы для ВАШЕЙ свадьбы!",\
					"Невесты РЫДАЮТ от радости! Женихи теряют сознание от счастья!",\
					"7227051245544 — Игорь",\
					"Только лучшие аниматоры со всего сектора! Специализированные конкурсы для сотрудников Nanotrasen! Посвящение в капитаны! Торт для начальника службы безопасности!",\
					"я играть музыка кляссный беру дешево пиши да")
				if(9)
					sender = pick("МАМА ПОМОГИ!","СРОЧНО!","Папа, я вляпался","ПОЖАЛУЙСТА!")
					message = pick("я врезался в корабль и офицер говорит что можно всё замять за 10000 кредитов, переведи пожалуйста",\
					"ОНА САМА УМЕРЛА, Я НЕ ВИНОВАТ! УМОЛЯЮ, МНЕ НУЖНО 5000 НА НОВЫЙ МУЛЬТИПАСПОРТ! СКОРЕЕ, ОНИ СКОРО БУДУТ ЗДЕСЬ",\
					"Меня машина убила! Переведи сколько можешь, иначе они не пришьют мне ноги обратно!",\
					"Это твой сын, памаги! пропорщик говорид что может памочь! Иго номир щёта 133782, банк развития Цыфея")
				if(10)
					sender = pick("Церковь Всех-и-Сразу","Общественная организация «Слава Ран'ис»","Орден «ПРОТИВ ВУЛЬП»","Движение «ЗА ВУЛЬП»","КРОВЬ БОГУ КРОВИ")
					message = pick("Если вам небезразлично наше дело, заходите к нам по адресу: Сектор Ардей, планета Тифон-14, здание №1756B, этаж -76, офис 4",\
					"Наши идею могут показаться немного радикальными, но, уверяю вас, это всего лишь слухи. Напоминаем, что следущая всеобщая молитва в пятницу, и приносите жертвоприношения с собой.",\
					"Привет! Тебе одиноко? Не видишь смысла в жизни? Ну что ж, тогда мы будем рады тебе! Всего за 500 кредитов в месяц ты можешь вступить в наше дружное общество.",\
					"Вам же не всё равно? А?! Или всё равно?! Ты бесхребетная крыса или уверенный в себе гуманоид?! Если у тебя кишка не тонка, то найдёшь нас сам.",\
					"Пожалуйста, спасите меня, я здесь против своей воли.",\
					"Вы уверены что живёте праведной жизнью? Если нет, пошлите нам 100 кредитов и мы помолимся за вас. Если да, то тоже пошлите, нам нужны пожертвования.",\
					"Мы знаем. Мы найдём тебя сами, не нужно ничего делать.")
				if(11)
					sender = pick("Экзотические питомцы","Друзья наши меньшие","Питомцы, домашние и не очень","Торговцы Элизиума")
					message = pick("Торговый корабль «Пупсик» приглашает вас к себе на борт. Большой выбор свиней и кабанов самых разных пород, включая редких взрывных.",\
					"Дикие родственники таяр, вульпакин, воксов, киданов, унатхов, людей в ассортименте. Внимание! Владение нашим товаром может быть запрещено вашим законодательством!",\
					"Если вы не купите у нас хоть что-то, мы пристрелим щенка. Вы думаете я шучу? У вас есть 1 час.",\
					"ГРОМ 74 27 99 14. Геннадий, Роман, Олег, Михаил, 7 4 2 7 9 9 1 4",\
					"Магазин «Мышеловка»! Мыши, крысы, большие и маленькие, плотоядные и не очень! При покупке колесо сыра в подарок! Одобрено Федерацией Мышей!",\
					"Огромный выбор питомцев, вкусные корма, защита от блох и вшей и акссесуары для друзей наших меньших, а так же вульпакин и таяр.")
				if(12)
					sender = pick("Оружие для всей семьи","Стволы по дешёвке","ПУШКИ ПУШКИ ПУШКИ","Большие пушки для больших парней","Мануфактура «У Бобби»")
					message = pick("Самый большой выбор огнестрела в секторе. От дамских пистолетов до снайперской винтовки! Для совершения покупки требуется лицензия на владение оружием.",\
					"Лучшее от Синдиката. Пистолет %УДАЛЕНО%, усыпляющая %УДАЛЕНО%, пробивающая стены %УДАЛЕНО% и даже легендарный %УДАЛЕНО% меч. Агентам скидки, сотрудникам НТ бесплатн…9э%8%?3Р1… ВНИМАНИЕ! Перехвачено враждебное сообщение. Не обращайте внимания. Возвращайтесь к работе. Слава Nanotrasen!",\
					"Нужно что-то особое? Как насчёт магнума что сделает дыру в стене из пластали? Пневматический зонтик-ружьё? Надувной клоун со взрывчаткой внутри? Если вы об этом подумали, у нас это есть.",\
					"Давай к делу. Тебе нужно оружие? Меня зовут Борис и у меня для тебя есть пушки. Не спрашивай откуда, просто покупай.",\
					"Гранаты. Дымовые шашки. Тротил. Бомбы. Снаряды. Мины. С4. Ракеты. Биологическое оружие. Ядерные боеголовки. Распродажа! Успей, пока не урвали! Никаких лицензий, только бабки!")
				if(13)
					sender = pick("ОШ;Б…;кА","25-j*%...o1q","СБОЙ СИСТЕМЫ СООБЩЕНИЙ","ОШИБКА")
					message = pick("…от этого корабля, блядь. Ты кто такой, сука? Не пиши сюда больше блядь, я тебя найд…",\
					"…имание, агент. Дальше будут перечислены ваши цели. Никто не должен уйти живым. Первую цель зов…",\
					"…ася, хватить, блядь! Водки он напился, идиот. У НАС ЗАВТРА НА ТРАНС СОЛНЕЧНУЮ ФЕДЕРАЦИЮ НАЛЁТ, КАКАЯ ВОДКА! Сука, офицер СССП ещё называе…",\
					"…ы меня не любишь? Потому что я скрелл?! …извини, я сорвалась. Я вся на нервах из-за работы… Прилетай ко мне, я соску…",\
					"…еальные стулья! У нас лучшие стулья в секторе! С обивкой и без, с кожей и с инкрустированным ураном! Есть даже передвижные стулья с педалями! Кроме тог…",\
					"…а сковороду тем временем налейте ещё немного масла и выложите тертую свеклу. Обжарьте пару минут и добавьте уксус. Тушите ещё минут 5, а после выложите томатную пасту. Томите на медленном огне ещё 5-7 минут. Зате…")


			if(useMS.send_pda_message("[P.owner]", sender, message))	//Message been filtered by spam filter.
				return

			last_spam_time = world.time

			if(prob(50)) //Give the AI an increased chance to intercept the message
				for(var/mob/living/silicon/ai/ai in GLOB.mob_list)
					// Allows other AIs to intercept the message but the AI won't intercept their own message.
					if(ai.aiPDA != P && ai.aiPDA != src)
						ai.show_message("<i>Перехвачено сообщение от <b>[sender]</b></i> (Вероятно спам) <i>для <b>[P:owner]</b>: [message]</i>")

			PM.notify("<b>Сообщение от [sender], </b>\"[message]\" (Невозможно ответить/спам)", 0)
