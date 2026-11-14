"""B2 verb gap-fill exercises with a base verb and a short time reference."""

# Each row: time reference | base verb | sentence | reference answer | valid variants (optional).
GROUPS = [
    ('Third conditional', '''
yesterday|catch|I missed the last bus. If I had left earlier, I would ____ it.|have caught
yesterday|avoid|We found the restaurant closed. If we had checked its hours, we would ____ the wasted journey.|have avoided
yesterday|pass|Anna failed the exam. If she had revised, she would ____ it.|have passed
yesterday|have|Our best player was injured. If he had been fit, we would ____ a better chance of winning.|have had
yesterday|save|I lost my files. If I had made a backup, I would ____ them.|have saved
'''),
    ('Second conditional', '''
now|own|I do not own a car. If I ____ one, I would drive you home.|owned
now|live|Lena lives far from work. If she ____ nearer, she would spend less time travelling.|lived
now|earn|We cannot afford a bigger flat. If we ____ twice as much, we would rent one.|earned
now|speak|Sam does not speak Japanese. If he ____ it, he would be able to apply.|spoke
now|be|Our kitchen is tiny. If it ____ larger, we would put a table in it.|were|was
'''),
    ('Mixed conditional', '''
now|be|I stayed up late and feel exhausted. If I had gone to bed earlier, I would ____ less tired now.|be
now|be|Eva missed yesterday's flight and is still at home. If she had caught it, she would ____ on the beach now.|be
now|be|We ignored the map and are lost. If we had followed it, we would ____ on the right path now.|be
now|be|Tom rejected the job and is unemployed. If he had accepted it, he would ____ employed now.|be
now|be|The roof was not fixed and the room is wet. If it had been fixed, the room would ____ dry now.|be
'''),
    ('Future time clauses', '''
tomorrow|arrive|We will sign the form as soon as the courier ____.|arrives|has arrived
tomorrow|arrive|I will be at the station when her train ____.|arrives|has arrived
tomorrow|arrive|We will not restart the server until the technician ____.|arrives|has arrived
tomorrow|arrive|The organiser will introduce the speaker as soon as she ____.|arrives|has arrived
tomorrow|arrive|We will test the equipment after it ____.|arrives|has arrived
'''),
    ('Past perfect simple', '''
before 8:10 yesterday|leave|The train departed at eight. By the time we reached the platform at 8:10, it ____ already.|had left
before 6:30 yesterday|leave|Nora went home at six. When I arrived at 6:30, she ____ already.|had left
before midnight yesterday|leave|The guests went home at ten. When we returned at midnight, they ____ already.|had left
before 9:10 yesterday|leave|The bus departed at nine. I had to walk because it ____ before I reached the stop at 9:10.|had left|left
before 7:30 yesterday|leave|The cleaner went home at seven. When the manager arrived at 7:30, she ____ already.|had left
'''),
    ('Present perfect continuous', '''
until now|work|The report is still unfinished. I ____ on it for three hours so far.|have been working|have worked
until now|work|The bike is still in pieces. We ____ on it for two hours so far.|have been working|have worked
until now|work|The website is still under development. I ____ on it since Monday.|have been working|have worked
until now|work|The research is still in progress. We ____ on it since January.|have been working|have worked
until now|work|The chapter is still unfinished. I ____ on it for two hours so far.|have been working|have worked
'''),
    ('Future perfect', '''
by noon tomorrow|finish|The report is nearly ready. By noon tomorrow, we will have ____ it.|finished
by Friday evening|finish|Only one wall remains. By Friday evening, we will have ____ painting the house.|finished
by Wednesday|finish|Our final lesson is on Tuesday. By our trip on Wednesday, we will have ____ the course.|finished
by next week|finish|We are checking the last entries. By next week's meeting, we will have ____ checking the accounts.|finished
by next month|finish|The builders are doing the final repairs. By next month's opening, they will have ____ the renovations.|finished
'''),
    ('Past continuous', '''
at seven yesterday|cook|Dinner was half prepared when the phone rang. I ____ it at that moment.|was cooking
at noon yesterday|cook|Lunch was half prepared when the power went off. I ____ it at that moment.|was cooking
at noon yesterday|cook|The soup was still on the stove when the doorbell rang. Maya ____ it at that moment.|was cooking
at six yesterday|cook|Ben was halfway through preparing a curry when I arrived. He ____ it at that moment.|was cooking
at eight yesterday|cook|The pasta was still in the pan when the alarm rang. I ____ it at that moment.|was cooking
'''),
    ('Past regret with wish', '''
yesterday|buy|I spent too much on my phone yesterday. I wish I ____ a cheaper one.|had bought
yesterday|book|We booked too late and missed yesterday's concert. We wish we ____ our tickets earlier.|had booked
yesterday|read|Ella signed without reading yesterday and regrets it. She wishes she ____ the contract first.|had read
yesterday|take|I left my umbrella at home yesterday and got soaked. I wish I ____ it with me.|had taken
yesterday|accept|Dan rejected yesterday's invitation and regrets missing the party. He wishes he ____ it.|had accepted
'''),
    ('Present wish', '''
now|know|I wish I ____ the answer.|knew
now|know|We wish we ____ our neighbours better.|knew
now|know|Sara wishes she ____ how to swim.|knew
now|know|I wish I ____ the Wi-Fi password.|knew
now|know|Leo wishes he ____ the way to the hospital.|knew
'''),
    ('Would rather: another person', '''
tomorrow|tell|The party is a secret. I would rather you ____ anyone about it tomorrow.|did not tell
next week|call|I want a holiday without work calls. I would rather you ____ me next week.|did not call
tonight|borrow|I need my car tonight. I would rather you ____ it.|did not borrow
tomorrow|bring|Pets are not allowed in my flat. I would rather you ____ your dog tomorrow.|did not bring
tomorrow|share|The draft must stay confidential. I would rather you ____ it online tomorrow.|did not share
'''),
    ('Used to and past habits', '''
years ago|walk|I take the bus now, but I used ____ three kilometres to school every day.|to walk
years ago|go|We stay in hotels now, but we used ____ camping every summer.|to go
years ago|smoke|My father has quit, but he used ____ every day.|to smoke
years ago|be|This building is a restaurant now, but it used ____ a library.|to be
years ago|be|I love dogs now, but I used ____ afraid of them.|to be
'''),
    ('Be used to and gerunds', '''
now|work|I am used to ____ at night.|working
now|work|Sara is used to ____ from home.|working
now|work|We are used to ____ at weekends.|working
now|work|Ben is used to ____ in a noisy office.|working
now|work|We are used to ____ under pressure.|working
'''),
    ('Perfect modal: unnecessary past action', '''
yesterday|buy|I bought bread, but we already had plenty. I need not ____ any.|have bought
yesterday|pay|You paid for a taxi, but a free shuttle was available. You need not ____ for one.|have paid
yesterday|print|We printed the documents, but digital copies were accepted. We need not ____ them.|have printed
yesterday|book|Mia booked a table, but the restaurant was empty. She need not ____ one.|have booked
yesterday|bring|They brought their own chairs, but the venue supplied enough. They need not ____ any.|have brought
'''),
    ('Perfect modal: negative deduction', '''
yesterday|commit|Alex was in London all day yesterday, so he cannot ____ yesterday's robbery in Rome.|have committed
yesterday|cause|Yesterday's meal contained no peanuts, so peanuts in it cannot ____ her reaction.|have caused
yesterday at nine|send|Our server was offline until ten yesterday, so it cannot ____ the email at nine.|have sent
yesterday|take|The opening was too small and undamaged, so the thieves cannot ____ the painting through it yesterday.|have taken
this morning|put|The parcel was sealed last night and remains unopened, so they cannot ____ this morning's documents inside it.|have put
'''),
    ('Perfect modal: criticism', '''
yesterday|drive|You drove too fast and crashed yesterday. You should ____ more slowly.|have driven|have been driving
yesterday|leave|Dan missed yesterday's interview because he left late. He should ____ home earlier.|have left
yesterday|back up|We lost our files yesterday without a backup. We should ____ them.|have backed up
yesterday|wear|Sara got sunburnt yesterday without sunscreen. She should ____ some.|have worn|have been wearing
yesterday|read|You missed the hidden fees in yesterday's contract. You should ____ it before signing.|have read
'''),
    ('Prohibition versus lack of obligation', '''
now|take|Photography is forbidden. Visitors must not ____ photographs inside the laboratory.|take
now|use|Phones are forbidden. Candidates must not ____ a phone during the exam.|use
now|smoke|Smoking is forbidden. Patients must not ____ inside the building.|smoke
now|share|Passwords are confidential. Employees must not ____ them.|share
now|block|This is an emergency exit. You must not ____ this door.|block
'''),
    ('Lack of obligation', '''
today|bring|Lunch is provided. You do not have ____ your own lunch.|to bring
today|attend|Attendance is optional. You do not have ____ the meeting.|to attend
today|pay|Entry is free. You do not have ____ to enter the museum.|to pay
today|bring|Towels are provided. You do not have ____ your own towels.|to bring
today|complete|This is optional extra practice. You do not have ____ this task.|to complete
'''),
    ('Past simple passive', '''
1880|build|The old bridge was ____ in 1880 and opened that December.|built
1965|build|This school was ____ in 1965 and welcomed its first pupils that September.|built
1920|build|The village hall was ____ in 1920 and opened that autumn.|built
1998|build|This tunnel was ____ in 1998 and opened to traffic that summer.|built
1902|build|The farmhouse was ____ in 1902 and first occupied that winter.|built
'''),
    ('Present continuous passive', '''
right now|repair|The mechanics are still working on my car. It ____ right now.|is being repaired|is getting repaired
right now|repair|Workers are still fixing the bridge. It ____ at the moment.|is being repaired|is getting repaired
right now|repair|The technician is still working on our printer. It ____ right now.|is being repaired|is getting repaired
right now|repair|The plumber is still fixing the boiler. It ____ at the moment.|is being repaired|is getting repaired
right now|repair|Builders are still fixing the roof. It ____ right now.|is being repaired|is getting repaired
'''),
    ('Have something done', '''
tomorrow|repair|I am having my bicycle ____ tomorrow.|repaired
Friday|repair|We are having our oven ____ on Friday.|repaired
next week|repair|Sara is having her watch ____ next week.|repaired
this afternoon|repair|I am having my laptop screen ____ this afternoon.|repaired
Monday|repair|We are having our garage door ____ on Monday.|repaired
'''),
    ('Reported statements', '''
last Monday|finish|Jo said she had ____ the report before Monday's deadline.|finished
last Tuesday|lose|Max said he had ____ his keys before Tuesday's meeting.|lost
last Wednesday|book|Ella said she had ____ the tickets before Wednesday's trip.|booked
last Thursday|complete|The workers said they had ____ the repairs before Thursday's inspection.|completed
last Friday|pass|Leo said he had ____ the test before Friday's interview.|passed
'''),
    ('Indirect questions', '''
in 1990|be|The station was demolished in 2000. The tourist asked me where it ____ in 1990.|was|had been
in 1980|be|The bus depot closed in 1990. The driver asked us where it ____ in 1980.|was|had been
in 1970|be|The museum moved in 1980. The visitor asked Anna where it ____ in 1970.|was|had been
in 1960|be|The airport moved in 1970. The passenger asked the receptionist where it ____ in 1960.|was|had been
in 1950|be|The bridge was demolished in 1960. The cyclist asked my brother where it ____ in 1950.|was|had been
'''),
    ('Reported requests', '''
yesterday|send|My manager asked me ____ her the report.|to send
yesterday|send|The tutor asked me ____ him my essay.|to send
yesterday|send|The customer asked us ____ her a receipt.|to send
yesterday|send|Our lawyer asked us ____ her the contract.|to send
yesterday|send|The organiser asked me ____ him my details.|to send
'''),
    ('Gerund after suggest', '''
yesterday|revise|Our tutor suggested ____ the difficult chapters.|revising
yesterday|take|The doctor suggested ____ a few days off.|taking
yesterday|book|Maya suggested ____ our tickets online.|booking
yesterday|leave|The guide suggested ____ before sunrise.|leaving
yesterday|meet|Dan suggested ____ outside the station.|meeting
'''),
    ('Gerund after avoid', '''
yesterday|make|The driver avoided ____ a dangerous mistake.|making
yesterday|answer|The witness avoided ____ the question.|answering
yesterday|use|We avoided ____ the busy main road.|using
yesterday|discuss|Sara avoided ____ the confidential report.|discussing
yesterday|pay|They avoided ____ extra fees by booking early.|paying
'''),
    ('Object and infinitive after allow', '''
yesterday|leave|The teacher allowed us ____ early.|to leave
yesterday|use|The librarian allowed me ____ the computer.|to use
yesterday|enter|The guard allowed them ____ the building.|to enter
yesterday|stay|Our host allowed us ____ another night.|to stay
yesterday|borrow|My colleague allowed me ____ her laptop.|to borrow
'''),
    ('Gerund after deny', '''
yesterday|take|The suspect denied ____ the money.|taking|having taken
yesterday|take|Ben denied ____ my keys.|taking|having taken
yesterday|take|The employee denied ____ the photos.|taking|having taken
yesterday|take|Mia denied ____ the last ticket.|taking|having taken
yesterday|take|The student denied ____ the exam for his friend.|taking|having taken
'''),
    ('Infinitive after remind', '''
tonight|lock|Please remind me ____ the door before I leave.|to lock
tonight|lock|Please remind me ____ the gate tonight.|to lock
tonight|lock|Please remind us ____ the office after the meeting.|to lock
tonight|lock|Please remind Dad ____ the garage before bed.|to lock
tonight|lock|Please remind Sara ____ the cupboard after use.|to lock
'''),
    ('Remember: memory of a past action', '''
in 2022|meet|I still remember ____ your brother in Paris in 2022.|meeting|having met
last summer|meet|We still remember ____ our guide at the airport last summer.|meeting|having met
last September|meet|I still remember ____ my teacher for the first time last September.|meeting|having met
last year|meet|Lena still remembers ____ her favourite author at last year's festival.|meeting|having met
five years ago|meet|I still remember ____ my neighbour at a barbecue five years ago.|meeting|having met
'''),
    ('Stop: purpose versus ending an activity', '''
yesterday|buy|We paused our journey in order ____ some water.|to buy
yesterday|buy|I went into a bakery in order ____ some bread.|to buy
yesterday|buy|They stopped at a shop in order ____ snacks for the rest of their ride.|to buy
yesterday|buy|Sara stopped at a petrol station in order ____ fuel for her car.|to buy
yesterday|buy|We visited a kiosk in order ____ a map for our walk.|to buy
'''),
    ('Concession with despite', '''
yesterday|be|Despite ____ tired, we completed the hike.|being|having been
yesterday|be|Despite ____ expensive, the restaurant was fully booked.|being|having been
yesterday|be|Despite ____ inexperienced, Maya performed well.|being|having been
yesterday|be|Despite ____ narrow, the road was safe to drive on.|being|having been
yesterday|be|Despite ____ long, the instructions were easy to follow.|being|having been
'''),
    ('Past actions in concessive clauses', '''
yesterday|go|Although it was raining, we ____ hiking yesterday.|went
last night|book|Although the hotel was expensive, we ____ a room last night.|booked
yesterday|find|Although I had revised, I ____ the exam difficult yesterday.|found
last night|finish|Although Sara was tired, she ____ the report last night.|finished
yesterday|arrive|Although the train was delayed, we ____ on time yesterday.|arrived
'''),
    ('Gerund after cannot help', '''
last night|cry|The film was so moving that I could not help ____.|crying|but cry
yesterday|laugh|His joke was so funny that I could not help ____.|laughing|but laugh
yesterday|smile|The news was so good that Maya could not help ____.|smiling|but smile
last night|worry|The storm was so severe that we could not help ____.|worrying|but worry
yesterday|stare|The painting was so unusual that visitors could not help ____.|staring|but stare
'''),
    ('Infinitive after enough', '''
now|reach|I am not tall enough ____ the shelf.|to reach
now|drive|Leo is not old enough ____ a car.|to drive
now|buy|We have enough money ____ the tickets.|to buy
now|carry|Mia is strong enough ____ the suitcase.|to carry
today|finish|There is enough time ____ the report.|to finish
'''),
    ('Gerund after look forward to', '''
next week|meet|We look forward to ____ our new colleagues.|meeting
next month|visit|I look forward to ____ the new museum.|visiting
tomorrow|hear|Sara looks forward to ____ your presentation.|hearing
next week|see|They look forward to ____ their grandchildren.|seeing
next summer|travel|Dan looks forward to ____ abroad.|travelling
'''),
    ('Infinitive after would prefer', '''
tomorrow|travel|I would prefer ____ by train.|to travel|travelling|traveling
tonight|stay|We would prefer ____ at home.|to stay|staying
next week|start|Maya would prefer ____ the course on Monday.|to start|starting
tonight|eat|They would prefer ____ at the hotel.|to eat|eating
tomorrow|discuss|Leo would prefer ____ the matter in person.|to discuss|discussing
'''),
    ('Negative question tags', '''
until now|have|You have not submitted your application yet, ____?|have you
until now|have|You have not met our new neighbour, ____?|have you
until now|have|You have not read the final chapter, ____?|have you
until now|have|You have not booked the hotel yet, ____?|have you
until now|have|You have not tried this recipe before, ____?|have you
'''),
    ('Deduction about a continuing past action', '''
yesterday|be|Nina must ____ working at midnight yesterday.|have been
yesterday|be|Our neighbour must ____ practising the piano at six yesterday morning.|have been
yesterday|be|Ben must ____ baking at noon yesterday.|have been
yesterday|be|Mia must ____ studying French at ten last night.|have been
yesterday|be|Dad must ____ washing the car at five yesterday.|have been
'''),
    ('Verbs followed by object and infinitive', '''
next week|apply|My tutor encouraged me ____ for the scholarship.|to apply
next week|apply|Our manager encouraged us ____ for promotion.|to apply
next week|apply|Ella encouraged me ____ for the course.|to apply
next week|apply|The coach encouraged Sam ____ for the national team.|to apply
next week|apply|My colleague encouraged me ____ for the vacancy.|to apply
'''),
]


def build_grammar():
    items = []
    for topic, situations in GROUPS:
        rows = situations.strip().splitlines()
        assert len(rows) == 5, topic
        for row in rows:
            context, verb, sentence, answer, *variants = row.split('|')
            assert sentence.count('____') == 1, sentence
            prompt = f'{sentence} ({verb}; {context})'
            answers = [answer, *variants]
            # Accept valid forms without displaying alternatives in the exercise.
            for full, contraction in [('would not', "wouldn't"), ('did not', "didn't"),
                                      ('must not', "mustn't"), ('cannot', "can't"),
                                      ('do not', "don't"), ('need not', "needn't")]:
                if full in answer:
                    answers.append(answer.replace(full, contraction))
            if answer == 'travelling':
                answers.append('traveling')
            items.append(dict(
                id=f'g{len(items) + 1:03}', level='B2', topic=topic,
                context=context, verb=verb, prompt=prompt,
                answers=answers, completed=prompt.replace('____', answer),
            ))
    assert len(items) == 200
    assert len({item['prompt'] for item in items}) == 200
    return items
