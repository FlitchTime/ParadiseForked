/*********************MANUALS (BOOKS)***********************/

//Oh god what the fuck I am not good at computer
/obj/item/book/manual
	icon = 'icons/obj/library.dmi'
	due_date = 0
	unique = TRUE
	has_drm = TRUE // No reuploading. Piracy is a crime
	dat = {"

		<html><meta charset="UTF-8"><head>
		</head>

		<body>
		If you see this - hello! Please write a report to NXB Janitor about \"issue #164-e\", they know what to do next.
		</body>

		</html>

		"}
	/// Put name of wiki page to open frame to. If none set - it will not link any wiki.
	var/wiki_title = ""

/obj/item/book/manual/Initialize(mapload)
	. = ..()
	if(!wiki_title || !CONFIG_GET(string/wikiurl)) //it means, manual doesnt rely on wiki, or we dont have wiki
		return
	dat = {"

		<html><meta charset="UTF-8"><head>
		</head>

		<body>
		<iframe width='100%' height='97%' src="[CONFIG_GET(string/wikiurl)]/index.php?action=render&title=[wiki_title]" frameborder="0" id="main_frame"></iframe>
		</body>

		</html>

		"}


/obj/item/book/manual/engineering_construction
	name = "Руководство по Ремонту и Строительству"
	icon_state ="bookEngineering"
	author = "Инженерная Энциклопедия"
	title = "Руководство по Ремонту и Строительству"
	wiki_title = "Руководство_по_строительству"

/obj/item/book/manual/engineering_particle_accelerator
	name = "Тесла Двигатель: Руководство Пользователя"
	icon_state ="bookParticleAccelerator"
	author = "Инженерная Энциклопедия"
	title = "Тесла Двигатель: Руководство Пользователя"
	wiki_title = "Тесла-двигатель"

/obj/item/book/manual/supermatter_engine
	name = "Двигатель на Суперматерии: Руководство Пользователя"
	icon_state = "bookSupermatter"
	author = "Инженерная Энциклопедия"
	title = "Двигатель на Суперматерии: Руководство Пользователя"
	wiki_title = "Двигатель_Суперматерии"

/obj/item/book/manual/engineering_hacking
	name = "Взлом"
	icon_state ="bookHacking"
	author = "Инженерная Энциклопедия"
	title = "Взлом"
	wiki_title = "Руководство_по_взлому"

/obj/item/book/manual/engineering_singularity_safety
	name = "Сингулярный Двигатель: Руководство Пользователя"
	icon_state ="bookEngineeringSingularitySafety"
	author = "Инженерная Энциклопедия"
	title = "Сингулярный Двигатель: Руководство Пользователя"
	wiki_title = "Сингулярный_двигатель"

/obj/item/book/manual/hydroponics_pod_people
	name = "The Human Harvest - From seed to market"
	icon_state ="bookHydroponicsPodPeople"
	author = "Farmer John"
	title = "The Human Harvest - From seed to market"
	dat = {"<html>
				<meta charset="UTF-8">
				<head>
				<style>
				h1 {font-size: 18px; margin: 15px 0px 5px;}
				h2 {font-size: 15px; margin: 15px 0px 5px;}
				li {margin: 2px 0px 2px 15px;}
				ul {list-style: none; margin: 5px; padding: 0px;}
				ol {margin: 5px; padding: 0px 15px;}
				</style>
				</head>
				<body>
				<h3>Growing Humans</h3>

				Why would you want to grow humans? Well I'm expecting most readers to be in the slave trade, but a few might actually
				want to revive fallen comrades. Growing pod people is easy, but prone to disaster.
				<p>
				<ol>
				<li>Find a dead person who is in need of cloning. </li>
				<li>Take a blood sample with a syringe. </li>
				<li>Inject a seed pack with the blood sample. </li>
				<li>Plant the seeds. </li>
				<li>Tend to the plants water and nutrition levels until it is time to harvest the cloned human.</li>
				</ol>
				<p>
				It really is that easy! Good luck!

				</body>
				</html>
				"}

/obj/item/book/manual/medical_cloning
	name = "Cloning techniques of the 26th century"
	icon_state ="bookCloning"
	author = "Medical Journal, volume 3"
	title = "Cloning techniques of the 26th century"
//big pile of shit below.

	dat = {"<html>
				<meta charset="UTF-8">
				<head>
				<style>
				h1 {font-size: 18px; margin: 15px 0px 5px;}
				h2 {font-size: 15px; margin: 15px 0px 5px;}
				li {margin: 2px 0px 2px 15px;}
				ul {list-style: none; margin: 5px; padding: 0px;}
				ol {margin: 5px; padding: 0px 15px;}
				</style>
				</head>
				<body>

				<h3>How to Clone People</h3>
				So theres 50 dead people lying on the floor, chairs are spinning like no tomorrow and you havent the foggiest idea of what to do? Not to worry! This guide is intended to teach you how to clone people and how to do it right, in a simple step-by-step process! If at any point of the guide you have a mental meltdown, genetics probably isnt for you and you should get a job-change as soon as possible before youre sued for malpractice.

				<ol>
					<li><a href='#1'>Acquire body</a></li>
					<li><a href='#2'>Strip body</a></li>
					<li><a href='#3'>Put body in cloning machine</a></li>
					<li><a href='#4'>Scan body</a></li>
					<li><a href='#5'>Clone body</a></li>
					<li><a href='#6'>Get clean Structurel Enzymes for the body</a></li>
					<li><a href='#7'>Put body in morgue</a></li>
					<li><a href='#8'>Await cloned body</a></li>
					<li><a href='#9'>Use the clean SW injector</a></li>
					<li><a href='#10'>Give person clothes back</a></li>
					<li><a href='#11'>Send person on their way</a></li>
				</ol>

				<a name='1'><H4>Step 1: Acquire body</H4>
				This is pretty much vital for the process because without a body, you cannot clone it. Usually, bodies will be brought to you, so you do not need to worry so much about this step. If you already have a body, great! Move on to the next step.

				<a name='2'><H4>Step 2: Strip body</H4>
				The cloning machine does not like abiotic items. What this means is you cant clone anyone if theyre wearing clothes, so take all of it off. If its just one person, its courteous to put their possessions in the closet. If you have about seven people awaiting cloning, just leave the piles where they are, but dont mix them around and for Gods sake dont let people in to steal them.

				<a name='3'><H4>Step 3: Put body in cloning machine</H4>
				Grab the body and then put it inside the DNA modifier. If you cannot do this, then you messed up at Step 2. Go back and check you took EVERYTHING off - a commonly missed item is their headset.

				<a name='4'><H4>Step 4: Scan body</H4>
				Go onto the computer and scan the body by pressing Scan - <Subject Name Here>. If youre successful, they will be added to the records (note that this can be done at any time, even with living people, so that they can be cloned without a body in the event that they are lying dead on port solars and didnt turn on their suit sensors)! If not, and it says Error: Mental interface failure., then they have left their bodily confines and are one with the spirits. If this happens, just shout at them to get back in their body, click Refresh and try scanning them again. If theres no success, threaten them with gibbing. Still no success? Skip over to Step 7 and dont continue after it, as you have an unresponsive body and it cannot be cloned. If you got Error: Unable to locate valid genetic data., you are trying to clone a monkey - start over.

				<a name='5'><H4>Step 5: Clone body</H4>
				Now that the body has a record, click View Records, click the subjects name, and then click Clone to start the cloning process. Congratulations! Youre halfway there. Remember not to Eject the cloning pod as this will kill the developing clone and youll have to start the process again.

				<a name='6'><H4>Step 6: Get clean SEs for body</H4>
				Cloning is a finicky and unreliable process. Whilst it will most certainly bring someone back from the dead, they can have any number of nasty disabilities given to them during the cloning process! For this reason, you need to prepare a clean, defect-free Structural Enzyme (SE) injection for when theyre done. If youre a competent Geneticist, you will already have one ready on your working computer. If, for any reason, you do not, then eject the body from the DNA modifier (NOT THE CLONING POD) and take it next door to the Genetics research room. Put the body in one of those DNA modifiers and then go onto the console. Go into View/Edit/Transfer Buffer, find an open slot and click SE to save it. Then click Injector to get the SEs in syringe form. Put this in your pocket or something for when the body is done.

				<a name='7'><H4>Step 7: Put body in morgue</H4>
				Now that the cloning process has been initiated and you have some clean Structural Enzymes, you no longer need the body! Drag it to the morgue and tell the Chef over the radio that they have some fresh meat waiting for them in there. To put a body in a morgue bed, simply open the tray, grab the body, put it on the open tray, then close the tray again. Use one of the nearby pens to label the bed CHEF MEAT in order to avoid confusion.

				<a name='8'><H4>Step 8: Await cloned body</H4>
				Now go back to the lab and wait for your patient to be cloned. It wont be long now, I promise.

				<a name='9'><H4>Step 9: Use the clean SE injector on person</H4>
				Has your body been cloned yet? Great! As soon as the guy pops out, grab your injector and jab it in them. Once youve injected them, they now have clean Structural Enzymes and their defects, if any, will disappear in a short while.

				<a name='10'><H4>Step 10: Give person clothes back</H4>
				Obviously the person will be naked after they have been cloned. Provided you werent an irresponsible little shit, you should have protected their possessions from thieves and should be able to give them back to the patient. No matter how cruel you are, its simply against protocol to force your patients to walk outside naked.

				<a name='11'><H4>Step 11: Send person on their way</H4>
				Give the patient one last check-over - make sure they dont still have any defects and that they have all their possessions. Ask them how they died, if they know, so that you can report any foul play over the radio. Once youre done, your patient is ready to go back to work! Chances are they do not have Medbay access, so you should let them out of Genetics and the Medbay main entrance.

				<p>If youve gotten this far, congratulations! You have mastered the art of cloning. Now, the real problem is how to resurrect yourself after that traitor had his way with you for cloning his target.



				</body>
				</html>
				"}


/obj/item/book/manual/ripley_build_and_repair
	name = "APLU \"Ripley\" Construction and Operation Manual"
	icon_state ="book"
	author = "Weyland-Yutani Corp"
	title = "APLU \"Ripley\" Construction and Operation Manual"
//big pile of shit below.

	dat = {"<html>
				<meta charset="UTF-8">
				<head>
				<style>
				h1 {font-size: 18px; margin: 15px 0px 5px;}
				h2 {font-size: 15px; margin: 15px 0px 5px;}
				li {margin: 2px 0px 2px 15px;}
				ul {list-style: none; margin: 5px; padding: 0px;}
				ol {margin: 5px; padding: 0px 15px;}
				</style>
				</head>
				<body>
				<center>
				<b style='font-size: 12px;'>Weyland-Yutani - Building Better Worlds</b>
				<h1>Autonomous Power Loader Unit \"Ripley\"</h1>
				</center>
				<h2>Specifications:</h2>
				<ul>
				<li><b>Class:</b> Autonomous Power Loader</li>
				<li><b>Scope:</b> Logistics and Construction</li>
				<li><b>Weight:</b> 820kg (without operator and with empty cargo compartment)</li>
				<li><b>Height:</b> 2.5m</li>
				<li><b>Width:</b> 1.8m</li>
				<li><b>Top speed:</b> 5km/hour</li>
				<li><b>Operation in vacuum/hostile environment:</b> Possible</b>
				<li><b>Airtank Volume:</b> 500liters</li>
				<li><b>Devices:</b>
					<ul>
					<li>Hydraulic Clamp</li>
					<li>High-speed Drill</li>
					</ul>
				</li>
				<li><b>Propulsion Device:</b> Powercell-powered electro-hydraulic system.</li>
				<li><b>Powercell capacity:</b> Varies.</li>
				</ul>

				<h2>Construction:</h2>
				<ol>
				<li>Connect all exosuit parts to the chassis frame</li>
				<li>Connect all hydraulic fittings and tighten them up with a wrench</li>
				<li>Adjust the servohydraulics with a screwdriver</li>
				<li>Wire the chassis. (Cable is not included.)</li>
				<li>Use the wirecutters to remove the excess cable if needed.</li>
				<li>Install the central control module (Not included. Use supplied datadisk to create one).</li>
				<li>Secure the mainboard with a screwdriver.</li>
				<li>Install the peripherals control module (Not included. Use supplied datadisk to create one).</li>
				<li>Secure the peripherals control module with a screwdriver</li>
				<li>Install the internal armor plating (Not included due to Nanotrasen regulations. Can be made using 5 metal sheets.)</li>
				<li>Secure the internal armor plating with a wrench</li>
				<li>Weld the internal armor plating to the chassis</li>
				<li>Install the external reinforced armor plating (Not included due to Nanotrasen regulations. Can be made using 5 reinforced metal sheets.)</li>
				<li>Secure the external reinforced armor plating with a wrench</li>
				<li>Weld the external reinforced armor plating to the chassis</li>
				<li></li>
				<li>Additional Information:</li>
				<li>The firefighting variation is made in a similar fashion.</li>
				<li>A firesuit must be connected to the Firefighter chassis for heat shielding.</li>
				<li>Internal armor is plasteel for additional strength.</li>
				<li>External armor must be installed in 2 parts, totaling 10 sheets.</li>
				<li>Completed mech is more resiliant against fire, and is a bit more durable overall</li>
				<li>Nanotrasen is determined to the safety of its <s>investments</s> employees.</li>
				</ol>
				</body>
				</html>

				<h2>Operation</h2>
				Coming soon...
			"}


/obj/item/book/manual/experimentor
	name = "Mentoring your Experiments"
	icon_state = "rdbook"
	author = "Dr. H.P. Kritz"
	title = "Mentoring your Experiments"
	dat = {"<html>
		<meta charset="UTF-8">
		<head>
		<style>
		h1 {font-size: 18px; margin: 15px 0px 5px;}
		h2 {font-size: 15px; margin: 15px 0px 5px;}
		li {margin: 2px 0px 2px 15px;}
		ul {list-style: none; margin: 5px; padding: 0px;}
		ol {margin: 5px; padding: 0px 15px;}
		</style>
		</head>
		<body>
		<h1>THE E.X.P.E.R.I-MENTOR</h1>
		The Enhanced Xenobiological Period Extraction (and) Restoration Instructor is a machine designed to discover the secrets behind every item in existence.
		With advanced technology, it can process 99.95% of items, and discover their uses and secrets.
		The E.X.P.E.R.I-MENTOR is a Research apparatus that takes items, and through a process of elimination, it allows you to deduce new technological designs from them.
		Due to the volatile nature of the E.X.P.E.R.I-MENTOR, there is a slight chance for malfunction, potentially causing irreparable damage to you or your environment.
		However, upgrading the apparatus has proven to decrease the chances of undesirable, potentially life-threatening outcomes.
		Please note that the E.X.P.E.R.I-MENTOR uses a state-of-the-art random generator, which has a larger entropy than the observable universe,
		therefore it can generate wildly different results each day, therefore it is highly suggested to re-scan objects of interests frequently (e.g. each shift).

		<h2>BASIC PROCESS</h2>
		The usage of the E.X.P.E.R.I-MENTOR is quite simple:
		<ol>
			<li>Find an item with a technological background</li>
			<li>Insert the item into the E.X.P.E.R.I-MENTOR</li>
			<li>Cycle through each processing method of the device.</li>
			<li>Stand back, even in case of a successful experiment, as the machine might produce undesired behaviour.</li>
		</ol>

		<h2>ADVANCED USAGE</h2>
		The E.X.P.E.R.I-MENTOR has a variety of uses, beyond menial research work. The different results can be used to combat localised events, or even to get special items.

		The E.X.P.E.R.I-MENTOR's OBLITERATE function has the added use of transferring the destroyed item's material into a linked lathe.

		The IRRADIATE function can be used to transform items into other items, resulting in potential upgrades (or downgrades).

		Users should remember to always wear appropriate protection when using the machine, because malfunction can occur at any moment!

		<h1>EVENTS</h1>
		<h2>GLOBAL (happens at any time):</h2>
			<ol>
			<li>DETECTION MALFUNCTION - The machine's onboard sensors have malfunctioned, causing it to redefine the item's experiment type.
			Produces the message: The E.X.P.E.R.I-MENTOR's onboard detection system has malfunctioned!</li>

			<li>IANIZATION - The machine's onboard corgi-filter has malfunctioned, causing it to produce a corgi from.. somewhere.
			Produces the message: The E.X.P.E.R.I-MENTOR melts the banana, ian-izing the air around it!</li>

			<li>RUNTIME ERROR - The machine's onboard C4T-P processor has encountered a critical error, causing it to produce a cat from.. somewhere.
			Produces the message: The E.X.P.E.R.I-MENTOR encounters a run-time error!</li>

			<li>B100DG0D.EXE - The machine has encountered an unknown subroutine, which has been injected into it's runtime. It upgrades the held item!
			Produces the message: The E.X.P.E.R.I-MENTOR improves the banana, drawing the life essence of those nearby!</li>

			<li>POWERSINK - The machine's PSU has tripped the charging mechanism! It consumes massive amounts of power!
			Produces the message: The E.X.P.E.R.I-MENTOR begins to smoke and hiss, shaking violently!</li>
			</ol>
		<h2>FAIL:</h2>
			This event is produced when the item mismatches the selected experiment.
			Produces a random message similar to: "the Banana rumbles, and shakes, the experiment was a failure!"

		<h2>POKE:</h2>
			<ol>
			<li>WILD ARMS - The machine's gryoscopic processors malfunction, causing it to lash out at nearby people with it's arms.
			Produces the message: The E.X.P.E.R.I-MENTOR malfunctions and destroys the banana, lashing it's arms out at nearby people!</li>

			<li>MISTYPE - The machine's interface has been garbled, and it switches to OBLITERATE.
			Produces the message: The E.X.P.E.R.I-MENTOR malfunctions!</li>

			<li>THROW - The machine's spatial recognition device has shifted several meters across the room, causing it to try and repostion the item there.
			Produces the message: The E.X.P.E.R.I-MENTOR malfunctions, throwing the banana!</li>
			</ol>
		<h2>IRRADIATE:</h2>
			<ol>
			<li>RADIATION LEAK - The machine's shield has failed, resulting in a toxic radiation leak.
			Produces the message: The E.X.P.E.R.I-MENTOR malfunctions, melting the banana and leaking radiation!</li>

			<li>RADIATION DUMP - The machine's recycling and containment functions have failed, resulting in a dump of toxic waste around it
			Produces the message: The E.X.P.E.R.I-MENTOR malfunctions, spewing toxic waste!</li>

			<li>MUTATION - The machine's radio-isotope level meter has malfunctioned, causing it over-irradiate the item, making it transform.
			Produces the message: The E.X.P.E.R.I-MENTOR malfunctions, transforming the banana!</li>
			</ol>
		<h2>GAS:</h2>
			<ol>
			<li>TOXIN LEAK - The machine's filtering and vent systems have failed, resulting in a cloud of toxic gas being expelled.
			Produces the message: The E.X.P.E.R.I-MENTOR destroys the banana, leaking dangerous gas!</li>

			<li>GAS LEAK - The machine's vent systems have failed, resulting in a cloud of harmless, but obscuring gas.
			Produces the message: The E.X.P.E.R.I-MENTOR malfunctions, spewing harmless gas!</li>

			<li>ELECTROMAGNETIC IONS - The machine's electrolytic scanners have failed, causing a dangerous Electromagnetic reaction.
			Produces the message: The E.X.P.E.R.I-MENTOR melts the banana, ionizing the air around it!</li>
			</ol>
		<h2>HEAT:</h2>
			<ol>
			<li>TOASTER - The machine's heating coils have come into contact with the machine's gas storage, causing a large, sudden blast of flame.
			Produces the message: The E.X.P.E.R.I-MENTOR malfunctions, melting the banana and releasing a burst of flame!</li>

			<li>SAUNA - The machine's vent loop has sprung a leak, resulting in a large amount of superheated air being dumped around it.
			Produces the message: The E.X.P.E.R.I-MENTOR malfunctions, melting the banana and leaking hot air!</li>

			<li>EMERGENCY VENT - The machine's temperature gauge has malfunctioned, resulting in it attempting to cool the area around it, but instead, dumping a cloud of steam.
			Produces the message: The E.X.P.E.R.I-MENTOR malfunctions, activating it's emergency coolant systems!</li>
			</ol>
		<h2>COLD:</h2>
			<ol>
			<li>FREEZER - The machine's cooling loop has sprung a leak, resulting in a cloud of super-cooled liquid being blasted into the air.
			Produces the message: The E.X.P.E.R.I-MENTOR malfunctions, shattering the banana and releasing a dangerous cloud of coolant!</li>

			<li>FRIDGE - The machine's cooling loop has been exposed to the outside air, resulting in a large decrease in temperature.
			Produces the message: The E.X.P.E.R.I-MENTOR malfunctions, shattering the banana and leaking cold air!</li>

			<li>SNOWSTORM - The machine's cooling loop has come into contact with the heating coils, resulting in a sudden blast of cool air.
			Produces the message: The E.X.P.E.R.I-MENTOR malfunctions, releasing a flurry of chilly air as the banana pops out!</li>
			</ol>
		<h2>OBLITERATE:</h2>
			<ol>
			<li>IMPLOSION - The machine's pressure leveller has malfunctioned, causing it to pierce the space-time momentarily, making everything in the area fly towards it.
			Produces the message: The E.X.P.E.R.I-MENTOR's crusher goes way too many levels too high, crushing right through space-time!</li>

			<li>DISTORTION - The machine's pressure leveller has completely disabled, resulting in a momentary space-time distortion, causing everything to fly around.
			Produces the message: The E.X.P.E.R.I-MENTOR's crusher goes one level too high, crushing right into space-time!</li>
			</ol>
		</body>
	</html>
	"}

/obj/item/book/manual/research_and_development
	name = "Research and Development 101"
	icon_state = "rdbook"
	author = "Dr. L. Ight"
	title = "Research and Development 101"
	dat = {"
	<html>
				<meta charset="UTF-8">
				<head>
				<style>
				h1 {font-size: 18px; margin: 15px 0px 5px;}
				h2 {font-size: 15px; margin: 15px 0px 5px;}
				li {margin: 2px 0px 2px 15px;}
				ul {list-style: none; margin: 5px; padding: 0px;}
				ol {margin: 5px; padding: 0px 15px;}
				</style>
				</head>
				<body>

				<h1>Science For Dummies</h1>
				So you want to further SCIENCE? Good man/woman/thing! However, SCIENCE is a complicated process even though it's quite easy. For the most part, it's a three step process:
				<ol>
					<li> 1) Deconstruct items in the Destructive Analyzer to advance technology or improve the design.</li>
					<li> 2) Build unlocked designs in the Protolathe and Circuit Imprinter</li>
					<li> 3) Repeat!</li>
				</ol>

				Those are the basic steps to furthing science. What do you do science with, however? Well, you have four major tools: R&D Console, the Destructive Analyzer, the Protolathe, and the Circuit Imprinter.

				<h2>The R&D Console</h2>
				The R&D console is the cornerstone of any research lab. It is the central system from which the Destructive Analyzer, Protolathe, and Circuit Imprinter (your R&D systems) are controled. More on those systems in their own sections. On its own, the R&D console acts as a database for all your technological gains and new devices you discover. So long as the R&D console remains intact, you'll retain all that SCIENCE you've discovered. Protect it though, because if it gets damaged, you'll lose your data! In addition to this important purpose, the R&D console has a disk menu that lets you transfer data from the database onto disk or from the disk into the database. It also has a settings menu that lets you re-sync with nearby R&D devices (if they've become disconnected), lock the console from the unworthy, upload the data to all other R&D consoles in the network (all R&D consoles are networked by default), connect/disconnect from the network, and purge all data from the database.
				<b>NOTE:</b> The technology list screen, circuit imprinter, and protolathe menus are accessible by non-scientists. This is intended to allow 'public' systems for the plebians to utilize some new devices.

				<h2>Destructive Analyzer</h2>
				This is the source of all technology. Whenever you put a handheld object in it, it analyzes it and determines what sort of technological advancements you can discover from it. If the technology of the object is equal or higher then your current knowledge, you can destroy the object to further those sciences. Some devices (notably, some devices made from the protolathe and circuit imprinter) aren't 100% reliable when you first discover them. If these devices break down, you can put them into the Destructive Analyzer and improve their reliability rather then futher science. If their reliability is high enough ,it'll also advance their related technologies.

				<h2>Circuit Imprinter</h2>
				This machine, along with the Protolathe, is used to actually produce new devices. The Circuit Imprinter takes glass and various chemicals (depends on the design) to produce new circuit boards to build new machines or computers. It can even be used to print AI modules.

				<h2>Protolathe</h2>
				This machine is an advanced form of the Autolathe that produce non-circuit designs. Unlike the Autolathe, it can use processed metal, glass, solid plasma, silver, gold, and diamonds along with a variety of chemicals to produce devices. The downside is that, again, not all devices you make are 100% reliable when you first discover them.

				<h1>Reliability and You</h1>
				As it has been stated, many devices when they're first discovered do not have a 100% reliablity when you first discover them. Instead, the reliablity of the device is dependent upon a base reliability value, whatever improvements to the design you've discovered through the Destructive Analyzer, and any advancements you've made with the device's source technologies. To be able to improve the reliability of a device, you have to use the device until it breaks beyond repair. Once that happens, you can analyze it in a Destructive Analyzer. Once the device reachs a certain minimum reliability, you'll gain tech advancements from it.

				<h1>Building a Better Machine</h1>
				Many machines produces from circuit boards and inserted into a machine frame require a variety of parts to construct. These are parts like capacitors, batteries, matter bins, and so forth. As your knowledge of science improves, more advanced versions are unlocked. If you use these parts when constructing something, its attributes may be improved. For example, if you use an advanced matter bin when constructing an autolathe (rather then a regular one), it'll hold more materials. Experiment around with stock parts of various qualities to see how they affect the end results! Be warned, however: Tier 3 and higher stock parts don't have 100% reliability and their low reliability may affect the reliability of the end machine.
				</body>
				</html>
			"}


/obj/item/book/manual/robotics_cyborgs
	name = "Cyborgs for Dummies"
	icon_state = "borgbook"
	author = "XISC"
	title = "Cyborgs for Dummies"
	dat = {"<html>
				<meta charset="UTF-8">
				<head>
				<style>
				h1 {font-size: 21px; margin: 15px 0px 5px;}
				h2 {font-size: 18px; margin: 15px 0px 5px;}
        h3 {font-size: 15px; margin: 15px 0px 5px;}
				li {margin: 2px 0px 2px 15px;}
				ul {list-style: none; margin: 5px; padding: 0px;}
				ol {margin: 5px; padding: 0px 15px;}
				</style>
				</head>
				<body>

				<h1>Cyborgs for Dummies</h1>

				<h2>Chapters</h2>

				<ol>
					<li><a href="#Equipment">Cyborg Related Equipment</a></li>
					<li><a href="#Modules">Cyborg Modules</a></li>
					<li><a href="#Construction">Cyborg Construction</a></li>
					<li><a href="#Maintenance">Cyborg Maintenance</a></li>
					<li><a href="#Repairs">Cyborg Repairs</a></li>
					<li><a href="#Emergency">In Case of Emergency</a></li>
				</ol>


				<h2><a name="Equipment">Cyborg Related Equipment</h2>

				<h3>Exosuit Fabricator</h3>
				The Exosuit Fabricator is the most important piece of equipment related to cyborgs. It allows the construction of the core cyborg parts. Without these machines, cyborgs can not be built. It seems that they may also benefit from advanced research techniques.

				<h3>Cyborg Recharging Station</h3>
				This useful piece of equipment will suck power out of the power systems to charge a cyborg's power cell back up to full charge.

				<h3>Robotics Control Console</h3>
				This useful piece of equipment can be used to immobolize or destroy a cyborg. A word of warning: Cyborgs are expensive pieces of equipment, do not destroy them without good reason, or Nanotrasen may see to it that it never happens again.


				<h2><a name="Modules">Cyborg Modules</h2>
				When a cyborg is created it picks out of an array of modules to designate its purpose. There are 6 different cyborg modules.

				<h3>Standard Cyborg</h3>
				The standard cyborg module is a multi-purpose cyborg. It is equipped with various modules, allowing it to do basic tasks.<br>A Standard Cyborg comes with:
				<ul>
				  <li>Crowbar</li>
				  <li>Stun Baton</li>
				  <li>Health Analyzer</li>
				  <li>Fire Extinguisher</li>
				</ul>

				<h3>Engineering Cyborg</h3>
				The Engineering cyborg module comes equipped with various engineering-related tools to help with engineering-related tasks.<br>An Engineering Cyborg comes with:
				<ul>
				  <li>A basic set of engineering tools</li>
				  <li>Metal Synthesizer</li>
				  <li>Reinforced Glass Synthesizer</li>
				  <li>An RCD</li>
				  <li>Wire Synthesizer</li>
				  <li>Fire Extinguisher</li>
				  <li>Built-in Optical Meson Scanners</li>
				</ul>

				<h3>Mining Cyborg</h3>
				The Mining Cyborg module comes equipped with the latest in mining equipment. They are efficient at mining due to no need for oxygen, but their power cells limit their time in the mines.<br>A Mining Cyborg comes with:
				<ul>
				  <li>Jackhammer</li>
				  <li>Shovel</li>
				  <li>Mining Satchel</li>
				  <li>Built-in Optical Meson Scanners</li>
				</ul>

				<h3>Security Cyborg</h3>
				The Security Cyborg module is equipped with effective security measures used to apprehend and arrest criminals without harming them a bit.<br>A Security Cyborg comes with:
				<ul>
				  <li>Stun Baton</li>
				  <li>Handcuffs</li>
				  <li>Taser</li>
				</ul>

				<h3>Janitor Cyborg</h3>
				The Janitor Cyborg module is equipped with various cleaning-facilitating devices.<br>A Janitor Cyborg comes with:
				<ul>
				  <li>Mop</li>
				  <li>Hand Bucket</li>
				  <li>Cleaning Spray Synthesizer and Spray Nozzle</li>
				</ul>

				<h3>Service Cyborg</h3>
				The service cyborg module comes ready to serve your human needs. It includes various entertainment and refreshment devices. Occasionally some service cyborgs may have been referred to as "Bros"<br>A Service Cyborg comes with:
				<ul>
				  <li>Shaker</li>
				  <li>Industrail Dropper</li>
				  <li>Platter</li>
				  <li>Beer Synthesizer</li>
				  <li>Zippo Lighter</li>
				  <li>Rapid-Service-Fabricator (Produces various entertainment and refreshment objects)</li>
				  <li>Pen</li>
				</ul>

				<h2><a name="Construction">Cyborg Construction</h2>
				Cyborg construction is a rather easy process, requiring a decent amount of metal and a few other supplies.<br>The required materials to make a cyborg are:
				<ul>
				  <li>Metal</li>
				  <li>Two Flashes</li>
				  <li>One Power Cell (Preferrably rated to 15000w)</li>
				  <li>Some electrical wires</li>
				  <li>One Human Brain</li>
				  <li>One Man-Machine Interface</li>
				</ul>
				Once you have acquired the materials, you can start on construction of your cyborg.<br>To construct a cyborg, follow the steps below:
				<ol>
				  <li>Start the Exosuit Fabricators constructing all of the cyborg parts</li>
				  <li>While the parts are being constructed, take your human brain, and place it inside the Man-Machine Interface</li>
				  <li>Once you have a Robot Head, place your two flashes inside the eye sockets</li>
				  <li>Once you have your Robot Chest, wire the Robot chest, then insert the power cell</li>
				  <li>Attach all of the Robot parts to the Robot frame</li>
				  <li>Insert the Man-Machine Interface (With the Brain inside) Into the Robot Body</li>
				  <li>Congratulations! You have a new cyborg!</li>
				</ol>

				<h2><a name="Maintenance">Cyborg Maintenance</h2>
				Occasionally Cyborgs may require maintenance of a couple types, this could include replacing a power cell with a charged one, or possibly maintaining the cyborg's internal wiring.

				<h3>Replacing a Power Cell</h3>
				Replacing a Power cell is a common type of maintenance for cyborgs. It usually involves replacing the cell with a fully charged one, or upgrading the cell with a larger capacity cell.<br>The steps to replace a cell are follows:
				<ol>
				  <li>Unlock the Cyborg's Interface by swiping your ID on it</li>
				  <li>Open the Cyborg's outer panel using a crowbar</li>
				  <li>Remove the old power cell</li>
				  <li>Insert the new power cell</li>
				  <li>Close the Cyborg's outer panel using a crowbar</li>
				  <li>Lock the Cyborg's Interface by swiping your ID on it, this will prevent non-qualified personnel from attempting to remove the power cell</li>
				</ol>

				<h3>Exposing the Internal Wiring</h3>
				Exposing the internal wiring of a cyborg is fairly easy to do, and is mainly used for cyborg repairs.<br>You can easily expose the internal wiring by following the steps below:
				<ol>
				  <li>Follow Steps 1 - 3 of "Replacing a Cyborg's Power Cell"</li>
				  <li>Open the cyborg's internal wiring panel by using a screwdriver to unsecure the panel</li>
			  </ol>
			  To re-seal the cyborg's internal wiring:
			  <ol>
			    <li>Use a screwdriver to secure the cyborg's internal panel</li>
			    <li>Follow steps 4 - 6 of "Replacing a Cyborg's Power Cell" to close up the cyborg</li>
			  </ol>

			  <h2><a name="Repairs">Cyborg Repairs</h2>
			  Occasionally a Cyborg may become damaged. This could be in the form of impact damage from a heavy or fast-travelling object, or it could be heat damage from high temperatures, or even lasers or Electromagnetic Pulses (EMPs).

			  <h3>Dents</h3>
			  If a cyborg becomes damaged due to impact from heavy or fast-moving objects, it will become dented. Sure, a dent may not seem like much, but it can compromise the structural integrity of the cyborg, possibly causing a critical failure.
			  Dents in a cyborg's frame are rather easy to repair, all you need is to apply a welding tool to the dented area, and the high-tech cyborg frame will repair the dent under the heat of the welder.

        <h3>Excessive Heat Damage</h3>
        If a cyborg becomes damaged due to excessive heat, it is likely that the internal wires will have been damaged. You must replace those wires to ensure that the cyborg remains functioning properly.<br>To replace the internal wiring follow the steps below:
        <ol>
          <li>Unlock the Cyborg's Interface by swiping your ID</li>
          <li>Open the Cyborg's External Panel using a crowbar</li>
          <li>Remove the Cyborg's Power Cell</li>
          <li>Using a screwdriver, expose the internal wiring or the Cyborg</li>
          <li>Replace the damaged wires inside the cyborg</li>
          <li>Secure the internal wiring cover using a screwdriver</li>
          <li>Insert the Cyborg's Power Cell</li>
          <li>Close the Cyborg's External Panel using a crowbar</li>
          <li>Lock the Cyborg's Interface by swiping your ID</li>
        </ol>
        These repair tasks may seem difficult, but are essential to keep your cyborgs running at peak efficiency.

        <h2><a name="Emergency">In Case of Emergency</h2>
        In case of emergency, there are a few steps you can take.

        <h3>"Rogue" Cyborgs</h3>
        If the cyborgs seem to become "rogue", they may have non-standard laws. In this case, use extreme caution.
        To repair the situation, follow these steps:
        <ol>
          <li>Locate the nearest robotics console</li>
          <li>Determine which cyborgs are "Rogue"</li>
          <li>Press the lockdown button to immobolize the cyborg</li>
          <li>Locate the cyborg</li>
          <li>Expose the cyborg's internal wiring</li>
          <li>Check to make sure the LawSync and AI Sync lights are lit</li>
          <li>If they are not lit, pulse the LawSync wire using a multitool to enable the cyborg's Law Sync</li>
          <li>Proceed to a cyborg upload console. Nanotrasen usually places these in the same location as AI uplaod consoles.</li>
          <li>Use a "Reset" upload moduleto reset the cyborg's laws</li>
          <li>Proceed to a Robotics Control console</li>
          <li>Remove the lockdown on the cyborg</li>
        </ol>

        <h3>As a last resort</h3>
        If all else fails in a case of cyborg-related emergency. There may be only one option. Using a Robotics Control console, you may have to remotely detonate the cyborg.
        <h3>WARNING:</h3> Do not detonate a borg without an explicit reason for doing so. Cyborgs are expensive pieces of Nanotrasen equipment, and you may be punished for detonating them without reason.

        </body>
		</html>
		"}

/obj/item/book/manual/security_space_law
	name = "Космический Закон"
	desc = "Свод корпоративных правил Nanotrasen для поддержания закона и порядка на своих космических станциях."
	icon_state = "bookSpaceLaw"
	force = 4 //advanced magistrate tactics
	author = "Nanotrasen"
	title = "Космический Закон"
	wiki_title = "Космический_Закон"

/obj/item/book/manual/security_space_law/black
	name = "Космический Закон - Ограниченное Издание"
	desc = "Кожаный переплет и безукоризненное качество исполнения - превосходня копия ПРАВОСУДИЯ."
	icon_state = "bookSpaceLawblack"
	title = "Космический Закон - Ограниченное Издание"

/obj/item/book/manual/engineering_guide
	name = "Руководство по Инженерии"
	icon_state ="bookEngineering2"
	author = "Инженерная Энциклопедия"
	title = "Руководство по Инженерии"
	wiki_title = "Руководство_по_инженерии"

/obj/item/book/manual/chef_recipes
	name = "Рецепты от шеф-повара: Введение"
	desc = "Одна из частей сборника рецептов шеф-повара."
	icon_state = "cooked_book"
	author = "NanoTrasen"
	title = "Рецепты от шеф-повара: Введение"
	wiki_title = "Руководство_по_еде"

/obj/item/book/manual/chef_recipes/part_one
	name = "Рецепты от шеф-повара: Основные ингредиенты и приправы"
	title = "Рецепты от шеф-повара: Основные ингредиенты и приправы"
	wiki_title = "Руководство_по_еде_и_напиткам/Основные_ингредиенты_и_приправы"

/obj/item/book/manual/chef_recipes/part_two
	name = "Рецепты от шеф-повара: Тесто и хлеб"
	title = "Рецепты от шеф-повара: Тесто и хлеб"
	wiki_title = "Руководство_по_еде_и_напиткам/Тесто_и_базовый_хлеб"

/obj/item/book/manual/chef_recipes/part_three
	name = "Рецепты от шеф-повара: Мясные блюда"
	title = "Рецепты от шеф-повара: Мясные блюда"
	wiki_title = "Руководство_по_еде_и_напиткам/Мясные_блюда"

/obj/item/book/manual/chef_recipes/part_four
	name = "Рецепты от шеф-повара: Рыба, морепродукты, суши"
	title = "Рецепты от шеф-повара: Рыба, морепродукты, суши"
	wiki_title = "Руководство_по_еде_и_напиткам/Рыба,_морепродукты,_суши"

/obj/item/book/manual/chef_recipes/part_five
	name = "Рецепты от шеф-повара: Бутерброды"
	title = "Рецепты от шеф-повара: Бутерброды"
	wiki_title = "Руководство_по_еде_и_напиткам/Бутерброды"

/obj/item/book/manual/chef_recipes/part_six
	name = "Рецепты от шеф-повара: Паста и пицца"
	title = "Рецепты от шеф-повара: Паста и пицца"
	wiki_title = "Руководство_по_еде_и_напиткам/Паста_и_пицца"

/obj/item/book/manual/chef_recipes/part_seven
	name = "Рецепты от шеф-повара: Супы, салаты и гарниры"
	title = "Рецепты от шеф-повара: Супы, салаты и гарниры"
	wiki_title = "Руководство_по_еде_и_напиткам/Супы,_салаты_и_гарниры"

/obj/item/book/manual/chef_recipes/part_eight
	name = "Рецепты от шеф-повара: Хлебобулочные изделия и десерты"
	title = "Рецепты от шеф-повара: Хлебобулочные изделия и десерты"
	wiki_title = "Руководство_по_еде_и_напиткам/Хлебобулочные_изделия_и_десерты"

/obj/item/book/manual/chef_recipes/part_nine
	name = "Рецепты от шеф-повара: Шоколадки и конфеты"
	title = "Рецепты от шеф-повара: Шоколадки и конфеты"
	wiki_title = "Руководство_по_еде_и_напиткам/Шоколадки_и_конфеты"

/obj/item/book/manual/chef_recipes/part_ten
	name = "Рецепты от шеф-повара: Остальные рецепты"
	title = "Рецепты от шеф-повара: Остальные рецепты"
	wiki_title = "Руководство_по_еде_и_напиткам/Остальные_рецепты"

/obj/item/book/manual/barman_recipes
	name = "Рецепты Бармена: Введение"
	desc = "Одна из частей сборника рецептов бармена."
	icon_state = "barbook"
	author = "Сэр Джон Роуз"
	title = "Рецепты Бармена: Введение"
	wiki_title = "Руководство_по_напиткам"

/obj/item/book/manual/barman_recipes/part_one
	name = "Рецепты Бармена: Ассортимент бухломата"
	title = "Рецепты Бармена: Ассортимент бухломата"
	wiki_title = "Руководство_по_еде_и_напиткам/Ассортимент_бухломата"

/obj/item/book/manual/barman_recipes/part_two
	name = "Рецепты Бармена: Раздатчик выпивки"
	title = "Рецепты Бармена: Раздатчик выпивки"
	wiki_title = "Руководство_по_еде_и_напиткам/Раздатчик_выпивки"

/obj/item/book/manual/barman_recipes/part_three
	name = "Рецепты Бармена: Фонтан газировки"
	title = "Рецепты Бармена: Фонтан газировки"
	wiki_title = "Руководство_по_еде_и_напиткам/Фонтан_газировки"

/obj/item/book/manual/barman_recipes/part_four
	name = "Рецепты Бармена: Рецепты бутылочницы"
	title = "Рецепты Бармена: Рецепты бутылочницы"
	wiki_title = "Руководство_по_еде_и_напиткам/Рецепты_Бутылочницы"

/obj/item/book/manual/barman_recipes/part_five
	name = "Рецепты Бармена: Алкогольные напитки и коктейли"
	title = "Рецепты Бармена: Алкогольные напитки и коктейли"
	wiki_title = "Руководство_по_еде_и_напиткам/Алкогольные_напитки_и_коктейли"

/obj/item/book/manual/barman_recipes/part_six
	name = "Рецепты Бармена: Напитки на основе синтанола"
	title = "Рецепты Бармена: Напитки на основе синтанола"
	wiki_title = "Руководство_по_еде_и_напиткам/Напитки_на_основе_синтанола"

/obj/item/book/manual/barman_recipes/part_seven
	name = "Рецепты Бармена: Безалкогольные напитки"
	title = "Рецепты Бармена: Безалкогольные напитки"
	wiki_title = "Руководство_по_еде_и_напиткам/Безалкогольные_напитки"

/obj/item/book/manual/barman_recipes/part_eight
	name = "Рецепты Бармена: Напитки из ингредиентов с кухни"
	title = "Рецепты Бармена: Напитки из ингредиентов с кухни"
	wiki_title = "Руководство_по_еде_и_напиткам/Напитки_из_ингредиентов_с_кухни"

/obj/item/book/manual/detective
	name = "The Film Noir: Proper Procedures for Investigations"
	icon_state ="bookDetective"
	author = "Nanotrasen"
	title = "The Film Noir: Proper Procedures for Investigations"
	dat = {"<html>
			<meta charset="UTF-8">
			<head>
			<style>
			h1 {font-size: 18px; margin: 15px 0px 5px;}
			h2 {font-size: 15px; margin: 15px 0px 5px;}
			li {margin: 2px 0px 2px 15px;}
			ul {list-style: none; margin: 5px; padding: 0px;}
			ol {margin: 5px; padding: 0px 15px;}
			</style>
			</head>
			<body>
			<h3>Detective Work</h3>

			Between your bouts of self-narration, and drinking whiskey on the rocks, you might get a case or two to solve.<br>
			To have the best chance to solve your case, follow these directions:
			<p>
			<ol>
			<li>Go to the crime scene. </li>
			<li>Take your scanner and scan EVERYTHING (Yes, the doors, the tables, even the dog.) </li>
			<li>Once you are reasonably certain you have every scrap of evidence you can use, find all possible entry points and scan them, too. </li>
			<li>Return to your office. </li>
			<li>Using your forensic scanning computer, scan your Scanner to upload all of your evidence into the database.</li>
			<li>Browse through the resulting dossiers, looking for the one that either has the most complete set of prints, or the most suspicious items handled. </li>
			<li>If you have 80% or more of the print (The print is displayed) go to step 10, otherwise continue to step 8.</li>
			<li>Look for clues from the suit fibres you found on your perp, and go about looking for more evidence with this new information, scanning as you go. </li>
			<li>Try to get a fingerprint card of your perp, as if used in the computer, the prints will be completed on their dossier.</li>
			<li>Assuming you have enough of a print to see it, grab the biggest complete piece of the print and search the security records for it. </li>
			<li>Since you now have both your dossier and the name of the person, print both out as evidence, and get security to nab your baddie.</li>
			<li>Give yourself a pat on the back and a bottle of the ships finest vodka, you did it!. </li>
			</ol>
			<p>
			It really is that easy! Good luck!

			</body>
			</html>"}

/obj/item/book/manual/nuclear
	name = "Fission Mailed: Nuclear Sabotage 101"
	icon_state ="bookNuclear"
	author = "Syndicate"
	title = "Fission Mailed: Nuclear Sabotage 101"
	dat = {"<html>
			<meta charset="UTF-8">
			Nuclear Explosives 101:<br>
			Hello and thank you for choosing the Syndicate for your nuclear information needs.<br>
			Today's crash course will deal with the operation of a Fusion Class Nanotrasen made Nuclear Device.<br>
			First and foremost, DO NOT TOUCH ANYTHING UNTIL THE BOMB IS IN PLACE.<br>
			Pressing any button on the compacted bomb will cause it to extend and bolt itself into place.<br>
			If this is done to unbolt it one must completely log in which at this time may not be possible.<br>
			To make the nuclear device functional:<br>
			<li>Place the nuclear device in the designated detonation zone.</li>
			<li>Extend and anchor the nuclear device from its interface.</li>
			<li>Insert the nuclear authorisation disk into slot.</li>
			<li>Type numeric authorisation code into the keypad. This should have been provided. Note: If you make a mistake press R to reset the device.
			<li>Press the E button to log onto the device.</li>
			You now have activated the device. To deactivate the buttons at anytime for example when you've already prepped the bomb for detonation	remove the auth disk OR press the R on the keypad.<br>
			Now the bomb CAN ONLY be detonated using the timer. Manual detonation is not an option.<br>
			Note: Nanotrasen is a pain in the neck.<br>
			Toggle off the SAFETY.<br>
			Note: You wouldn't believe how many Syndicate Operatives with doctorates have forgotten this step.<br>
			So use the - - and + + to set a det time between 5 seconds and 10 minutes.<br>
			Then press the timer toggle button to start the countdown.<br>
			Now remove the auth. disk so that the buttons deactivate.<br>
			Note: THE BOMB IS STILL SET AND WILL DETONATE<br>
			Now before you remove the disk if you need to move the bomb you can:<br>
			Toggle off the anchor, move it, and re-anchor.<br><br>
			Good luck. Remember the order:<br>
			<b>Disk, Code, Safety, Timer, Disk, RUN!</b><br>
			Intelligence Analysts believe that normal Nanotrasen procedure is for the Captain to secure the nuclear authorisation disk.<br>
			Good luck!
			</html>"}

/obj/item/book/manual/atmospipes
	name = "Pipes and You: Getting To Know Your Scary Tools"
	icon_state = "pipingbook"
	author = "Maria Crash, Senior Atmospherics Technician"
	title = "Pipes and You: Getting To Know Your Scary Tools"
	dat = {"<html>
				<meta charset="UTF-8">
				<head>
				<style>
				h1 {font-size: 18px; margin: 15px 0px 5px;}
				h1 {font-size: 15px; margin: 15px 0px 5px;}
				li {margin: 2px 0px 2px 15px;}
				ul {list-style: none; margin: 5px; padding: 0px;}
				ol {margin: 5px; padding: 0px 15px;}
				</style>
				</head>
				<body>
				<font face="Verdana" color=black>

				<h1><a name="Contents">Contents</a></h1>
				<ol>
					<li><a href="#Forward">Author's Forward</a></li>
					<li><a href="#Basic">Basic Piping</a></li>
					<li><a href="#Insulated">Insulated Pipes</a></li>
					<li><a href="#Devices">Atmospherics Devices</a></li>
					<li><a href="#HES">Heat Exchange Systems</a></li>
					<li><a href="#Final">Final Checks</a></li>
				</ol>
				<br><br>

				<h1><a name="Forward"><u><b>HOW TO NOT SUCK QUITE SO HARD AT ATMOSPHERICS</b></u></a></h1><br>
				<i>Or: What the fuck does a "passive gate" do?</i><br><br>

				Alright. It has come to my attention that a variety of people are unsure of what a "pipe" is and what it does.
				Apparently there is an unnatural fear of these arcane devices and their "gases". Spooky, spooky. So,
				this will tell you what every device constructable by an ordinary pipe dispenser within atmospherics actually does.
				You are not going to learn what to do with them to be the super best person ever, or how to play guitar with passive gates,
				or something like that. Just what stuff does.<br><br>


				<h1><a name="Basic"><b>Basic Pipes</b></a></h1><br>
				<i>The boring ones.</i><br>
				TMost ordinary pipes are pretty straightforward. They hold gas. If gas is moving in a direction for some reason, gas will flow in that direction.
				That's about it. Even so, here's all of your wonderful pipe options.<br>

				<li><i>Straight pipes:</i> They're pipes. One-meter sections. Straight line. Pretty simple. Just about every pipe and device is based around this
				standard one-meter size, so most things will take up as much space as one of these.</li>
				<li><i>Bent pipes:</i> Pipes with a 90 degree bend at the half-meter mark. My goodness.</li>
				<li><i>Pipe manifolds:</i> Pipes that are essentially a "T" shape, allowing you to connect three things at one point.</li>
				<li><i>4-way manifold:</i> A four-way junction.</li>
				<li><i>Pipe cap:</i> Caps off the end of a pipe. Open ends don't actually vent air, because of the way the pipes are assembled, so, uh. Use them to decorate your house or something.</li>
				<li><i>Manual Valve:</i> A valve that will block off airflow when turned. Can't be used by the AI or cyborgs, because they don't have hands.</li>
				<li><i>Manual T-Valve:</i> Like a manual valve, but at the center of a manifold instead of a straight pipe.</li><br><br>

				<h1><a name="Insulated"><b>Insulated Pipes</b></a></h1><br>
				<i>Special Public Service Announcement.</i><br>
				Our regular pipes are already insulated. These are completely worthless. Punch anyone who uses them.<br><br>

				<h1><a name="Devices"><b>Devices: </b></a></h1><br>
				<i>They actually do something.</i><br>
				This is usually where people get frightened, </font><font face="Verdana" color=black>afraid, and start calling on their gods and/or cowering in fear. Yes, I can see you doing that right now.
				Stop it. It's unbecoming. Most of these are fairly straightforward.<br>

				<li><i>Gas Pump:</i> Take a wild guess. It moves gas in the direction it's pointing (marked by the red line on one end). It moves it based on pressure, the maximum output being 4500 kPa (kilopascals).
				Ordinary atmospheric pressure, for comparison, is 101.3 kPa, and the minimum pressure of room-temperature pure oxygen needed to not suffocate in a matter of minutes is 16 kPa
				(though 18 is preferred using internals, for various reasons).</li>
				<li><i>Volume pump:</i> This pump goes based on volume, instead of pressure, and the possible maximum pressure it can create in the pipe on the recieving end is double the gas pump because of this,
				clocking in at an incredible 9000 kPa. If a pipe with this is destroyed or damaged, and this pressure of gas escapes, it can be incredibly dangerous depending on the size of the pipe filled.
				Don't hook this to the distribution loop, or you will make babies cry and the Chief Engineer brutally beat you.</li>
				<li><i>Passive gate:</i> This is essentially a cap on the pressure of gas allowed to flow in a specific direction.
				When turned on, instead of actively pumping gas, it measures the pressure flowing through it, and whatever pressure you set is the maximum: it'll cap after that.
				In addition, it only lets gas flow one way. The direction the gas flows is opposite the red handle on it, which is confusing to people used to the red stripe on pumps pointing the way.</li>
				<li><i>Unary vent:</i> The basic vent used in rooms. It pumps gas into the room, but can't suck it back out. Controlled by the room's air alarm system.</li>
				<li><i>Scrubber:</i> The other half of room equipment. Filters air, and can suck it in entirely in what's called a "panic siphon". Actvating a panic siphon without very good reason will kill someone. Don't do it.</li>
				<li><i>Meter:</i> A little box with some gagues and numbers. Fasten it to any pipe or manifold, and it'll read you the pressure in it. Very useful.</li>
				<li><i>Gas mixer:</i> Two sides are input, one side is output. Mixes the gases pumped into it at the ratio defined. The side perpendicular to the other two is "node 2", for reference.
				Can output this gas at pressures from 0-4500 kPa.</li>
				<li><i>Gas filter:</i> Essentially the opposite of a gas mixer. One side is input. The other two sides are output. One gas type will be filtered into the perpendicular output pipe,
				the rest will continue out the other side. Can also output from 0-4500 kPa.</li>

				<h1><a name="HES"><b>Heat Exchange Systems</b></a></h1><br>
				<i>Will not set you on fire.</i><br>
				These systems are used to transfer heat only between two pipes. They will not move gases or any other element, but will equalize the temperature (eventually). Note that because of how gases work (remember: pv=nRt),
				a higher temperature will raise pressure, and a lower one will lower temperature.<br>

				<li><i>Pipe:</i> This is a pipe that will exchange heat with the surrounding atmosphere. Place in fire for superheating. Place in space for supercooling.</li>
				<li><i>Bent Pipe:</i> Take a wild guess.</li>
				<li><i>Junction:</i><i>Junction:</i>The point where you connect your normal pipes to heat exchange pipes. Not necessary for heat exchangers, but necessary for H/E pipes/bent pipes.</li>
				<li><i>Heat Exchanger:</i> These funky-looking bits attach to an open pipe end. Put another heat exchanger directly across from it, and you can transfer heat across two pipes without having to have the gases touch.
				This normally shouldn't exchange with the ambient air, despite being totally exposed. Just don't ask questions...</li><br>


				That's about it for pipes. Go forth, armed with this knowledge, and try not to break, burn down, or kill anything. Please.</font>

				</body>
				</html>
			"}

/obj/item/book/manual/evaguide
	name = "EVA Gear and You: Not Spending All Day Inside"
	icon_state = "evabook"
	author = "Maria Crash, Senior Atmospherics Technician"
	title = "EVA Gear and You: Not Spending All Day Inside"
	dat = {"<html>
				<meta charset="UTF-8">
				<head>
				<style>
				h1 {font-size: 18px; margin: 15px 0px 5px;}
				h1 {font-size: 15px; margin: 15px 0px 5px;}
				li {margin: 2px 0px 2px 15px;}
				ul {list-style: none; margin: 5px; padding: 0px;}
				ol {margin: 5px; padding: 0px 15px;}
				</style>
				</head>
				<body>
				<font face="Verdana" color=black>

				<h1><a name="Contents">Contents</a></h1>
				<ol>
					<li><a href="#Forward">A forward on using EVA gear</a></li>
					<li><a href="#Civilian">Donning a Civilian Suits</a></li>
					<li><a href="#Hardsuit">Putting on a Hardsuit</a></li>
					<li><a href="#Final">Final Checks</a></li>
				</ol>
				<br><br>

				<h1><a name="Forward">EVA Gear and You: Not Spending All Day Inside</a></h1><br>
				<i>Or: How not to suffocate because there's a hole in your shoes</i><br><br>

				EVA gear. Wonderful to use. It's useful for mining, engineering, and occasionally just surviving, if things are that bad. Most people have EVA training,
				but apparently there are some on a space station who don't. This guide should give you a basic idea of how to use this gear, safely. It's split into two sections:
				 Civilian suits and hardsuits.<br><br>

				<h1><a name="Civilian">Civilian Suits</a></h1><br>
				<i>The bulkiest things this side of Alpha Centauri</i><br>
				These suits are the grey ones that are stored in EVA. They're the more simple to get on, but are also a lot bulkier, and provide less protection from environmental hazards such as radiaion or physical impact.
				As Medical, Engineering, Security, and Mining all have hardsuits of their own, these don't see much use, but knowing how to put them on is quite useful anyways.<br><br>

				First, take the suit. It should be in three pieces: A top, a bottom, </font><font face="Verdana" color=black>and a helmet. Put the bottom on first, shoes and the like will fit in it. If you have magnetic boots, however,
				put them on on top of the suit's feet. Next, get the top on, as you would a shirt. It can be somewhat awkward putting these pieces on, due to the makeup of the suit,
				but to an extent they will adjust to you. You can then find the snaps and seals around the waist, where the two pieces meet. Fasten these, and double-check their tightness.
				The red indicators around the waist of the lower half will turn green when this is done correctly. Next, put on whatever breathing apparatus you're using, be it a gas mask or a breath mask. Make sure the oxygen tube is fastened into it.
				Put on the helmet now, straight forward, and make sure the tube goes into the small opening specifically for internals. Again, fasten seals around the neck, a small indicator light in the inside of the helmet should go from red to off when all is fastened.
				There is a small slot on the side of the suit where an emergency oxygen tank or</font><font face="Verdana" color=black> extended emergency oxygen tank will fit,
				but it is reccomended to have a full-sized tank on your back for EVA.<br><br>

				<h1><a name="Hardsuit">Hardsuits</a></h1><br>
				<i>Heavy, uncomfortable, still the best option.</i><br>
				These suits come in Engineering, Mining, and the Armory. There's also a couple Medical Hardsuits in EVA. These provide a lot more protection than the standard suits.<br><br>

				Similarly to the other suits, these are split into three parts. Fastening the pant and top are mostly the same as the other spacesuits, with the exception that these are a bit heavier,
				though not as bulky. The helmet goes on differently, with the air tube feeing into the suit and out a hole near the left shoulder, while the helmet goes on turned ninety degrees counter-clockwise,
				and then is screwed in for one and a quarter full rotations clockwise, leaving the faceplate directly in front of you. There is a small button on the right side of the helmet that activates the helmet light.
				The tanks that fasten onto the side slot are emergency tanks, as</font><font face="Verdana" color=black> well as full-sized oxygen tanks, leaving your back free for a backpack or satchel.<br><br>

				<h1><a name="Final">FINAL CHECKS:</a></h1><br>
				<li>Are all seals fastened correctly?</li>
				<li>Do you either have shoes on under the suit, or magnetic boots on over it?</li>
				<li>Do you have a mask on and internals on the suit or your back?</li>
				<li>Do you have a way to communicate with the station in case something goes wrong?</li>
				<li>Do you have a second person watching if this is a training session?</li><br>

				If you don't have any further issues, go out and do whatever is necessary.</font>

				</body>
				</html>
			"}

/obj/item/book/manual/faxes
	name = "A Guide to Faxes"
	desc = "A Nanotrasen-approved guide to writing faxes"
	icon_state = "book6"
	author = "Nanotrasen"
	title = "A Guide to Faxes"
	dat = {"

		<html>
				<meta charset="UTF-8">
				<head>
				<style>
				h1 {font-size: 15px; margin: 15px 0px 5px;}
				li {margin: 2px 0px 2px 15px;}
				ul {list-style: none; margin: 5px; padding: 0px;}
				ol {margin: 5px; padding: 0px 15px;}
				</style>
				</head>
				<body>
				<font face="Verdana" color=black>

				<h1><a name="Contents">Contents</a></h1>
				<ol>
					<li><a href="#what">What's a Fax?</a></li>
					<li><a href="#when">When to Fax?</a></li>
					<li><a href="#how">How to Fax?</a></li>
				</ol>
				<br><br>

				<h1><a name="what"><u><b>What's a Fax?</b></u></a></h1><br>
				<li>Faxes are your main method of communicating with the Trurl, better known as Central Command.</li>
				<li>Faxes allow personnel on the station to maintain open lines of communication with the Trurl, allowing for vital information to flow both ways.</li>
				<li>Being written communications, proper grammar, syntax and typography is required, in addition to a signature and, if applicable, a stamp. Failure to sign faxes will lead to an automatic rejection.</li>
				<li>We at Nanotrasen provide Fax Machines to every Head of Staff, in addition to the Magistrate, Nanotrasen Representative, and Internal Affairs Agents.</li>
				<li>This means that we trust the recipients of these fax machines to only use them in the proper circumstances (see <b>When to Fax?</b>).</li>

				<h1><a name="when"><b>When to Fax?</b></a></h1><br>
				<li>While it is up to the discretion of each individual person to decide when to fax Central Command, there are some simple guidelines on when to do this.</li>
				<li>Firstly, any situation that can reasonably be solved on-site, <i>should</i> be handled on-site. Knowledge of Standard Operating Procedure is <b>mandatory</b> for everyone with access to a fax machine.</li>
				<li>Resolving issues on-site not only leads to more expedient problem-solving, it also frees up company resources and provides valuable work experience for all parties involved.</li>
				<li>This means that you should work with the Heads of Staff concerning personnel and workplace issues, and attempt to resolve situations with them. If, for whatever reason, the relevent Head of Staff is not available or receptive, consider speaking with the Captain and/or Nanotrasen Representative.</li>
				<li>If, for whatever reason, these issues cannot be solved on-site, either due to incompetence or just plain refusal to cooperate, faxing Central Command becomes a viable option.</li>
				<li>Secondly, station status reports should be sent occasionally, but never at the start of the shift. Remember, we assign personnel to the station. We do not need a repeat of what we just signed off on.</li>
				<li>Thirdly, staff/departmental evaluations are always welcome, especially in cases of noticeable (in)competence. Just as a brilliant coworker can be rewarded, an incompetent one can be punished.</li>
				<li>Fourthly, do not issue faxes asking for sentences. You have an entire Security department and an associated Detective, not to mention on-site Space Law manuals.</li>
				<li>Lastly, please pay attention to context. If the station is facing a massive emergency, such as a Class 7-10 Blob Organism, most, if not all, non-relevant faxes will be duly ignored.</li>

				<h1><a name="how"><b>How to Fax?</b></a></h1><br>
				<li>Sending a fax is simple. Simply insert your ID into the fax machine, then log in.</li>
				<li>Once logged in, insert a piece of paper and select the destination from the provided list. Remember, you can rename your fax from within the fax machine's menu.</li>
				<li>You can send faxes to any other fax machine on the station, which can be a very useful tool when you need to issue broad communications to all of the Heads of Staff.</li>
				<li>To send a fax to Central Command, simply select the correct destination, and send the fax. Keep in mind, the communication arrays need to recharge after sending a fax to Central Command, so make sure you sent everything you need.</li>
				<li>Lastly, paper bundles can also be faxed as a single item, so feel free to bundle up all relevant documentation and send it in at once.</li>

				</ol><br>
				</body>
				</html>

		"}

/obj/item/book/manual/sop_science
	name = "Стандартные Рабочие Процедуры Научного Отдела"
	desc = "Свод правил, направленных на безопасное ведение любой научной деятельности."
	icon_state = "sop_science"
	author = "Nanotrasen"
	title = "Стандартные Рабочие Процедуры Научного Отдела"
	wiki_title = "Стандартные_рабочие_процедуры_(Исследование)"

/obj/item/book/manual/sop_medical
	name = "Стандартные Рабочие Процедуры Медицинского Отдела"
	desc = "Свод правил, направленных на безопасное ведение любой медицинской деятельности."
	icon_state = "sop_medical"
	author = "Nanotrasen"
	title = "Стандартные Рабочие Процедуры Медицинского Отдела"
	wiki_title = "Стандартные_рабочие_процедуры_(Медицина)"

/obj/item/book/manual/sop_engineering
	name = "Стандартные Рабочие Процедуры Инженерного Отдела"
	desc = "Свод правил, направленных на безопасное ведение любой инженерной деятельности."
	icon_state = "sop_engineering"
	author = "Nanotrasen"
	title = "Стандартные Рабочие Процедуры Инженерного Отдела"
	wiki_title = "Стандартные_рабочие_процедуры_(Инженерия)"

/obj/item/book/manual/sop_service
	name = "Стандартные Рабочие Процедуры Отдела Обслуживания"
	desc = "Свод правил, направленных на безопасное ведение любой обслуживающей деятельности."
	icon_state = "sop_service"
	author = "Nanotrasen"
	title = "Стандартные Рабочие Процедуры Отдела Обслуживания"
	wiki_title = "Стандартные_рабочие_процедуры_(Сервис)"

/obj/item/book/manual/sop_supply
	name = "Стандартные Рабочие Процедуры Отдела Снабжения"
	desc = "Свод правил, направленных на безопасное ведение любой снабженческой деятельности."
	icon_state = "sop_cargo"
	author = "Nanotrasen"
	title = "Стандартные Рабочие Процедуры Отдела Снабжения"
	wiki_title = "Стандартные_рабочие_процедуры_(Снабжение)"

/obj/item/book/manual/sop_security
	name = "Стандартные Рабочие Процедуры Службы Безопасности"
	desc = "Свод правил, направленных на безопасное ведение любой охранной деятельности."
	icon_state = "sop_security"
	author = "Nanotrasen"
	title = "Стандартные Рабочие Процедуры Службы Безопасности"
	wiki_title = "Стандартные_рабочие_процедуры_(Охрана)"

/obj/item/book/manual/sop_legal
	name = "Правовые Стандартные Рабочие Процедуры"
	desc = "Свод правил, направленных на безопасное ведение любой правовой деятельности."
	icon_state = "sop_legal"
	author = "Nanotrasen"
	title = "Правовые Стандартные Рабочие Процедуры"
	wiki_title = "Стандартные_рабочие_процедуры_(Закон)"

/obj/item/book/manual/sop_general
	name = "Стандартные Рабочие Процедуры"
	desc = "Свод правил, направленных на безопасное ведение любой станционной деятельности."
	icon_state = "sop"
	author = "Nanotrasen"
	title = "Стандартные Рабочие Процедуры"
	wiki_title = "Стандартные_Рабочие_Процедуры"

/obj/item/book/manual/sop_command
	name = "Стандартные Рабочие Процедуры Коммандования"
	desc = "Свод правил, направленных на безопасное ведение любой Коммандной деятельности."
	icon_state = "sop_command"
	author = "Nanotrasen"
	title = "Стандартные Рабочие Процедуры Коммандования"
	wiki_title = "Стандартные_рабочие_процедуры_(Командование)"
