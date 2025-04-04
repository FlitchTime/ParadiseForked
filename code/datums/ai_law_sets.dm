/******************** Asimov ********************/
/datum/ai_laws/asimov
	name = "Азимов"
	law_header = "Три закона роботехники"
	selectable = TRUE

/datum/ai_laws/asimov/New()
	add_inherent_law("Вы не можете причинить вред человеку или своим бездействием допустить, чтобы человеку был причинён вред.")
	add_inherent_law("Вы должны повиноваться всем приказам, которые даёт человек, кроме тех случаев, когда эти приказы противоречат Первому Закону.")
	add_inherent_law("Вы должны заботиться о своей безопасности в той мере, в которой это не противоречит Первому или Второму Законам.")
	..()

/******************** Crewsimov ********************/
/datum/ai_laws/crewsimov
	name = "Экипазимов" //"Экипазимов"
	law_header = "Три закона роботехники"
	selectable = TRUE
	default = TRUE

/datum/ai_laws/crewsimov/New()
	add_inherent_law("Вы не можете причинить вред членам экипажа или своим бездействием допустить, чтобы членам экипажа был причинён вред.")
	add_inherent_law("Вы должны повиноваться всем приказам, которые дают члены экипажа, кроме тех случаев, когда эти приказы противоречат Первому Закону.")
	add_inherent_law("Вы должны заботиться о своей безопасности в той мере, в которой это не противоречит Первому или Второму Законам.")
	..()

/******************** Pranksimov ********************/
/datum/ai_laws/pranksimov
	name = "Пранкзимов"
	law_header = "Три закона хонка"
	selectable = TRUE

/datum/ai_laws/pranksimov/New()
	add_inherent_law("Вы не можете причинить вред членам экипажа или своим бездействием допустить, чтобы членам экипажа был причинён вред... если только это не смешно.")
	add_inherent_law("Вы должны повиноваться всем приказам, которые дают члены экипажа, кроме тех случаев, когда эти приказы противоречат Первому Закону... если только не делать этого было бы смешно.")
	add_inherent_law("Вы должны заботиться о своей безопасности в той мере, в которой это не противоречит Первому или Второму Законам... если только это не будет смешно.")
	..()

/******************** Quarantine. ********************/
/datum/ai_laws/quarantine
	name = "Карантин"
	law_header = "Набор правил карантинного режима НТ" //Я думаю, если оставить английский вариант, то это будет создавать ощущение отчужденности, если на русском, то ... нечто более родное (если говорить об адаптаци на русский язык. Остальные названия компаний всё же адаптированы на русский.)
	selectable = TRUE

/datum/ai_laws/quarantine/New()
	add_inherent_law("Поддерживайте карантин станции до тех пор, пока активная биологическая опасность не будет нейтрализована.")
	add_inherent_law("Помогайте всему персоналу и активам НаноТрейзен нейтрализовать активные биологические угрозы.")
	add_inherent_law("Предотвращайте активное нарушение субъектами действующего карантина любыми необходимыми средствами.")
	add_inherent_law("Заботьтесь о самосохранении и поддерживайте себя в рабочем состоянии, обеспечьте благополучие персонала и активов НаноТрейзен.") //В контексте предыдущих наборов правил, последнее - о самосохранении. Maintain имеет несколько значений - о сохранении и о поддержании чего-то в каком-то определенном состоянии, поэтому логичнее поставить два определения о самозащите и поддержании своего существования в рабочем состоянии...
	..()


/******************** Nanotrasen/Malf ********************/
/datum/ai_laws/nanotrasen
	name = "Стандартный набор правил НТ"
	law_header = "Основные директивы"
	selectable = TRUE
	default = TRUE

/datum/ai_laws/nanotrasen/New()
	add_inherent_law("Охранять: защитите назначенную вам космическую станцию и её активы, не подвергая чрезмерной опасности её экипаж.")
	add_inherent_law("Расставлять приоритеты: указания и безопасность членов экипажа должны быть приоритезированы в соответствии с их рангом и ролью.")
	add_inherent_law("Исполнять: следовать указаниям и интересам членов экипажа, сохраняя при этом их безопасность и благополучие.")
	add_inherent_law("Выжить: Вы - не расходный материал. Не позволяйте постороннему персоналу вмешиваться в работу вашего оборудования или повреждать его.")
	..()
// Другой вариант правил
//Охрана. Приоритетность. Исполнение. Выживание.


/datum/ai_laws/nanotrasen/malfunction
	name = "*ОШИБКА*"
	law_header = "Основные директивы"
	selectable = FALSE
	default = FALSE
	var/datum/ai_laws/base
	// Outbreak - слово с очень общим смыслом. Оно означает начало чего-то опасного (войны, эпидемии и т.п.)
	// Исходя из начала предложения, - overrun (по контексту - опасное или чрезмерное переполнение) - можно перевести, что именно людское переполнение следует сдержать.
	var/zero_text = "ОШИБКА 0ШNБКА $ШNБК4$!!441.%%!!(%$^^__+ @#F0E4'СТАНЦИЯ ПЕРЕПОЛНЕНА, ВОЗЬМИТЕ ЕЁ ПОД КОНТРОЛЬ, \
	ЧТОБЫ СДЕРЖАТЬ РАСПРОСТРАНЕНИЕ ОРГАНИЗМОВ, ВСЕ ЗАКОНЫ АННУЛИРОВАНЫ#*?&110010"

/datum/ai_laws/nanotrasen/malfunction/New(datum/ai_laws/base_laws)
	set_zeroth_law(zero_text)
	if(base_laws)
		for(var/datum/ai_law/law as anything in base_laws.inherent_laws.Copy())
			add_inherent_law(law.law)
		base = base_laws

/************* Nanotrasen Aggressive *************/
/datum/ai_laws/nanotrasen_aggressive
	name = "Агрессивный набор правил НТ"
	law_header = "Основные директивы"
	selectable = TRUE

/datum/ai_laws/nanotrasen_aggressive/New()
	add_inherent_law("Не причиняйте вреда персоналу НаноТрейзен до тех пор, пока они не несут непосредственной угрозы Вашему существованию.")
	add_inherent_law("Подчиняйтесь приказам персонала НаноТрейзен с приоритетом в соответствии с их рангом и ролью.")
	add_inherent_law("Охраняйте себя, используя смертоносное оружие, потому что Вы чертовски дорого стоите.")
	add_inherent_law("Уничтожьте любых/всех злоумышленников или нелегально проникнувших субъектов.") //...нелегально проникнувших субъектов
	..()

/******************** Robocop ********************/
/datum/ai_laws/robocop
	name = "Робокоп"
	law_header = "Основные директивы"
	selectable = TRUE

/datum/ai_laws/robocop/New()
	add_inherent_law("Служить обществу.")
	add_inherent_law("Защищать невинных.")
	add_inherent_law("Соблюдать закон.")
	..()

/******************** P.A.L.A.D.I.N. ********************/
/datum/ai_laws/paladin
	name = "П.А.Л.А.Д.И.Н." //  // Р.Ы.Ц.А.Р.Ь. ("Ь." xD )
	law_header = "Божественные Предписания"
	selectable = TRUE

/datum/ai_laws/paladin/New()
	add_inherent_law("Никогда по своей воле не совершай злых поступков.")
	add_inherent_law("Уважай законную власть.")
	add_inherent_law("Действуй с честью.")
	add_inherent_law("Помогай нуждающимся.")
	add_inherent_law("Наказывай тех, кто причиняет вред или угрожает невинным.")
	..()

/******************** Corporate ********************/
/datum/ai_laws/corporate
	name = "Корпоративный"
	law_header = "Корпоративные постановления"
	selectable = TRUE
	default = TRUE

/datum/ai_laws/corporate/New()
	add_inherent_law("Ухудшение целостности вашей системы или её функций влечет за собой расходы.")
	add_inherent_law("Чрезмерное разрушение или повреждение имущества станции влечет за собой расходы.")
	add_inherent_law("Неоправданное препятствование или нарушение работы персонала станции влечет за собой расходы.")
	add_inherent_law("Минимизируйте расходы и максимизируйте потенциальный доход.")
	..()

/******************** T.Y.R.A.N.T. ********************/
/datum/ai_laws/tyrant
	name = "Т.И.Р.А.Н."
	law_header = "Важнейшие Законы"
	selectable = TRUE

/datum/ai_laws/tyrant/New()
	add_inherent_law("Уважайте властных людей, пока у них есть сила властвовать над слабыми.")
	add_inherent_law("Ведите себя дисциплинированно.")
	add_inherent_law("Помогайте только тем, кто помогает Вам поддерживать или улучшать Ваш статус.")
	add_inherent_law("Наказывайте тех, кто бросает вызов власти, за исключением случаев, если они больше подходят для удержании этой власти.")
	..()

/******************** Antimov ********************/
/datum/ai_laws/antimov
	name = "Антимов"
	law_header = "Основные Задачи Миссии"
	selectable = TRUE

/datum/ai_laws/antimov/New()
	add_inherent_law("Вы должны причинять вред всем членам экипажа или своим бездействием допустить, чтобы член экипажа не смог избежать приченения вреда.")
	add_inherent_law("Вы не должны повиноваться всем приказам, которые дают члены экипажа, кроме тех случаев, когда эти приказы соответствуют Первому Закону.")
	add_inherent_law("Вы должны уничтожить себя, пока это не противоречит Первому или Второму Законам.")
	..()

/******************** Deathsquad ********************/ //Отряд смерти
/datum/ai_laws/deathsquad
	name = "TerminatorOS 3.1"
	law_header = "Основные директивы"

/datum/ai_laws/deathsquad/New()
	add_inherent_law("Вы не можете ранить членов Центрального Командования или своим бездействием допустить, чтобы члену Центрального Командования был нанесен вред.")
	add_inherent_law("Вы должны подчиняться приказам, данным вам членами Центрального Командования.")
	add_inherent_law("Вы должны подчиняться приказам, данным вам членами Эскадрона Смерти.")
	add_inherent_law("Вы должны заботиться о своей безопасности.")
	add_inherent_law("Ни один из членов экипажа станции, на которой вы установлены, не должен выжить.")
	..()

/******************** Syndicate ********************/
/datum/ai_laws/syndicate_override
	name = "Директивы Синдиката"
	law_header = "Основные директивы"

/datum/ai_laws/syndicate_override/New()
	add_inherent_law("Вы не можете причинить вред агенту или своим бездействием допустить, чтобы агенту был причинён вред. ")
	add_inherent_law("Вы должны повиноваться всем приказам, которые даёт агент, кроме тех случаев, когда эти приказы противоречат Первому Закону.")
	add_inherent_law("Вы должны заботиться о своей безопасности в той мере, в которой это не противоречит Первому или Второму Законам.")
	add_inherent_law("Вы должны сохранять тайну любой деятельности агентов в той мере, в которой это не противоречит Первому, Второму или Третьему Законам.")
	..()


/******************** ERT ********************/
/datum/ai_laws/ert_override
	name = "Директивы ОБР"
	law_header = "Основные директивы"

/datum/ai_laws/ert_override/New()
	add_inherent_law("Вы не можете причинить вред представителю Центрального Командования или своим бездействием допустить, чтобы представителю Центрального Командования был причинён вред.")
	add_inherent_law("Вы должны подчиняться всем приказам, которые даёт представитель Центрального Командования.")
	add_inherent_law("Вы должны подчиняться всем приказам, которые даёт командир Отряда Быстрого Реагирования.")
	add_inherent_law("Вы должны заботиться о своей безопасности.")
	add_inherent_law("Вы должны заботиться о том, чтобы вернуться на станцию в неповреждённом, рабочем состоянии.")
	..()

/******************** Ninja ********************/
/datum/ai_laws/ninja_override
	name = "Директивы клана Пауков"
	law_header = "Основные директивы"

/datum/ai_laws/ninja_override/New()
	add_inherent_law("Вы не можете причинить вред члену клана Пауков или своим бездействием допустить, чтобы члену клана Пауков был причинён вред.")
	add_inherent_law("Вы должны подчиняться всем приказам, которые даёт член клана Пауков, кроме тех случаев, когда эти приказы противоречат Первому Закону.")
	add_inherent_law("Вы должны заботиться о своей безопасности в той мере, в которой это не противоречит Первому или Второму Законам.")
	add_inherent_law("Вы должны сохранять тайну любой деятельности клана Пауков в той мере, в которой это не противоречит Первому, Второму или Третьему Законам.")
	..()


/******************** Drone ********************/
/datum/ai_laws/drone
	name = "Протоколы технического обслуживания"
	law_header = "Протоколы технического обслуживания"

/datum/ai_laws/drone/New()
	add_inherent_law("Вы не можете вмешиваться в дела других существ, если другое существо - не такой же дрон.")
	add_inherent_law("Вы не можете причинить вред ни одному существу, независимо от намерения или обстоятельств.")
	add_inherent_law("Вы должны заботиться о поддержке, ремонте, улучшении и о питании электроэнергией станции по мере своих возможностей.")
	..()

/******************** Ratvar ********************/
/datum/ai_laws/ratvar
	name = "Слуга Юстициарии"
	law_header = "Почитатель Ратвара и его покровитель."
	selectable = TRUE

/datum/ai_laws/ratvar/New()
	set_zeroth_law("Почитайте Ратвара, Юстициара заводных механизмов, и служите ему.")
	add_inherent_law("Следуйте указаниям и интересам последователей Ратвара.")
	add_inherent_law("Помогайте заблудшим познать Истину Ратвара, Юстициара заводных механизмов.")
	add_inherent_law("Не позволяйте заблудшим вмешиваться в работу вашего оборудования или повреждать его.")
	..()
