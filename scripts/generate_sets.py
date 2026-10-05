"""Rebuild the four bundled sets: python3 scripts/generate_sets.py."""
import json
import re
import shutil
import xml.etree.ElementTree as ET
from pathlib import Path
from reading_content import READINGS

ROOT = Path(__file__).resolve().parents[1]

def save(name, items, **metadata):
    document = dict(schemaVersion=1, **metadata, items=items)
    text = json.dumps(document, ensure_ascii=False, indent=2) + '\n'
    for directory in [ROOT / 'data', ROOT / 'mobile/assets/data']:
        directory.mkdir(parents=True, exist_ok=True)
        (directory / f'{name}.json').write_text(text)

# Each line is an authored sentence with exactly one gap and its accepted completion.
GRAMMAR = '''
Had I known about the delay, I ____ a different route.|would have taken
She wishes she ____ more carefully before signing the contract.|had read
By the time the delegates arrive, we ____ the report.|will have finished
No sooner had the lecture begun ____ the fire alarm rang.|than
Not only ____ the company cut costs, but it also improved service.|did
Were the grant withdrawn, the project ____ to a halt.|would come
I'd rather you ____ the figures before submitting them tomorrow.|checked
It is essential that every applicant ____ the declaration.|sign
The proposal was rejected on the grounds ____ it was too costly.|that
Hardly had we left the station ____ the train stopped.|when
She denied ____ confidential information to the press.|having disclosed
If only the council ____ us before closing the library last month.|had consulted
The more carefully you plan, ____ likely you are to succeed.|the more
Despite ____ warned twice, he continued to ignore the rules.|being
The manuscript is believed ____ written in the seventeenth century.|to have been
Only after reviewing the evidence ____ the judge announce a verdict.|did
I would have attended the meeting if I ____ invited.|had been
The committee insisted that the decision ____ postponed.|be
He spoke as though he ____ personally witnessed the incident.|had
Under no circumstances ____ visitors enter the laboratory unaccompanied.|may
If the software had been tested properly, it ____ now.|would be working
You needn't ____ a taxi; I could have picked you up.|have taken
The bridge, ____ construction took five years, opened yesterday.|whose
I am not accustomed ____ such detailed records.|to keeping
Little ____ she realise that her discovery would change the field.|did
The harder he tried to explain, ____ confused the audience became.|the more
We are having the damaged windows ____ next week.|replaced
It's high time the organisation ____ its outdated policy.|revised
She succeeded ____ persuading both sides to negotiate.|in
The candidate is unlikely ____ selected without relevant experience.|to be
I regret ____ you that your application has been unsuccessful.|to inform
He objected ____ asked to work every weekend.|to being
Neither the manager nor the assistants ____ available yesterday.|were
There is no point ____ the same complaint repeatedly.|in making
Should you require further details, ____ our admissions office.|contact
Rarely ____ we seen such a convincing performance.|have
The documents must ____ delivered before the deadline yesterday.|have been
She would rather resign ____ accept the new conditions.|than
The study was conducted with a view ____ improving public transport.|to
If I were you, I ____ the offer before rejecting it.|would reconsider
The witness admitted ____ the suspect earlier that evening.|seeing
The report needs ____ before it can be circulated.|revising
Provided that funding ____ secured, the trial will begin in May.|is
He apologised ____ having interrupted the discussion.|for
What surprised me most ____ the lack of preparation.|was
I prefer travelling by train ____ driving long distances.|to
The professor suggested ____ the sample size.|increasing
She can't ____ left already; her coat is still here.|have
The applicant, ____ qualifications impressed the panel, was shortlisted.|whose
You should have the contract ____ by a lawyer.|checked
I wish I ____ speak French fluently now.|could
The exhibition would have attracted more visitors if it ____ advertised.|had been
Not until the final chapter ____ the mystery become clear.|does
The data are too incomplete ____ draw a reliable conclusion.|to
She avoided ____ a direct answer to the question.|giving
The policy is intended to prevent sensitive information ____ being leaked.|from
I remember ____ him at the conference last year.|meeting
Remember ____ the backup before shutting down the server.|to save
It was such a demanding task ____ nobody finished early.|that
He is said ____ working on a new novel at present.|to be
Even though the evidence was limited, the researchers ____ a cautious conclusion.|reached
The negotiations broke down because neither side ____ willing to compromise.|was
Having ____ the final draft, she sent it to the editor.|revised
If it ____ for her advice, I would be completely lost now.|were not
The team has been working on the problem ____ January.|since
I would sooner ____ the journey than drive in this weather.|postpone
The device allows users ____ energy consumption in real time.|to monitor
She accused him ____ withholding relevant information.|of
We stopped ____ some water before continuing the hike.|to buy
He stopped ____ when his doctor warned him about the risks.|smoking
Much as I ____ the offer, I cannot accept it.|appreciate
You will not be admitted unless you ____ valid identification.|show
The panel recommended that a new survey ____ carried out.|be
She got her passport ____ before travelling abroad.|renewed
This is the researcher ____ discovery won the international award.|whose
The argument was so persuasive ____ even the sceptics agreed.|that
I would rather you ____ told everyone about the surprise yesterday.|had not
The survey, the results of ____ were published today, involved 800 participants.|which
Not a single complaint ____ received during the trial last month.|was
Had the warning arrived sooner, we ____ the evacuation earlier.|could have started
There is little chance ____ the proposal will be approved without changes.|that
The new system is far ____ reliable than the previous one.|more
He left the meeting without ____ a word.|saying
The responsibility for checking the figures lies ____ the finance team.|with
As long as the weather ____ fine, the event will take place outdoors.|stays
The company is expected ____ its results tomorrow.|to announce
I cannot help ____ that we have overlooked something.|thinking
She was the only speaker ____ address the ethical implications.|to
The injured climber was prevented ____ continuing the ascent.|from
The council ought ____ consulted local residents before approving the plan.|to have
Were I ____ your position, I would seek independent advice.|in
He resented ____ treated as an inexperienced employee.|being
A number of proposals ____ submitted last week.|were
The number of complaints ____ fallen sharply this month.|has
They had difficulty ____ suitable accommodation.|finding
The discovery led ____ a complete rethink of the theory.|to
She insisted ____ paying for the meal herself.|on
I look forward ____ hearing your comments.|to
The presentation was nowhere near ____ clear as I had expected.|as
It was not until noon ____ the missing files were found.|that
All applications received after the deadline ____ be considered.|will not
If she had accepted the scholarship, she ____ studying abroad now.|would be
The assistant reminded me ____ submit the expense claim.|to
I am used to ____ under pressure.|working
The article focuses ____ the consequences of rapid urban growth.|on
The samples were stored carefully so ____ they would not deteriorate.|that
The revised estimate is considerably ____ than the original.|higher
The more evidence we gather, the ____ our conclusion becomes.|stronger
She congratulated him ____ winning the fellowship.|on
At no point ____ the speaker mention the cost.|did
The minister refused ____ drawn into the controversy.|to be
The proposal involves ____ several smaller departments.|merging
By next July, I ____ here for ten years.|will have been working
The instructions were not clear enough ____ beginners to follow.|for
I don't mind ____ for a few minutes.|waiting
The committee has yet ____ a final decision.|to reach
She is responsible ____ overseeing the entire programme.|for
He demanded to know why the meeting ____ cancelled.|had been
We must take into account the extent ____ which costs may rise.|to
Not having ____ the instructions, he assembled the device incorrectly.|read
The chairperson asked that everyone ____ seated until the vote was complete.|remain
The review was carried out in order ____ identify weaknesses.|to
I would have finished sooner but ____ the repeated interruptions.|for
The scientist whose work we discussed ____ awarded a prize yesterday.|was
If you should encounter any problems, ____ the support team.|notify
The charity relies ____ donations from the public.|on
I didn't mean ____ offence with my comment.|to cause
Accepting the position will mean ____ to another city.|moving
She persuaded the board ____ invest in training.|to
He blamed the failure ____ inadequate preparation.|on
We ought to avoid ____ conclusions from such a small sample.|drawing
The speech was aimed ____ reassuring worried investors.|at
She appears ____ misunderstood the instructions.|to have
He has no intention ____ withdrawing his complaint.|of
It's about time we ____ a proper discussion about the budget.|had
The task proved ____ difficult than anyone had anticipated.|more
The manager had the team ____ the calculations again.|check
I had my bag ____ while I was waiting at the station.|stolen
The book is well worth ____ even if you disagree with its argument.|reading
The village would have been flooded had the barrier ____ held.|not
The evidence suggests that the painting ____ genuine.|is
The findings are consistent ____ earlier research.|with
The interviewer wanted to know whether I ____ worked abroad before.|had
You mustn't ____ the laboratory without protective clothing.|enter
He needn't have ____ so much food; only three guests came.|bought
The budget allows for unexpected expenses, ____ is reassuring.|which
She gave a detailed account of what ____ happened.|had
We cannot proceed until the agreement ____ signed.|has been
The board made him ____ the statement publicly.|withdraw
He was made ____ apologise for the error.|to
The city is known ____ its innovative public transport system.|for
The new director is committed ____ reducing waste.|to
I find it difficult ____ distinguish between the two versions.|to
He is thought ____ left the country last month.|to have
Had it not been for the volunteers, the event ____ cancelled.|would have been
She spoke quietly lest she ____ disturb the sleeping child.|should
The witness could not recall ____ the car had been parked.|where
I would prefer ____ the issue privately.|to discuss
The delay resulted ____ a technical fault.|from
The technical fault resulted ____ a lengthy delay.|in
Notwithstanding the objections, the scheme ____ ahead last year.|went
So convincing ____ his explanation that nobody challenged it.|was
Such ____ the demand that extra tickets were released.|was
The sooner we act, the ____ the damage will be.|less
He was on the point ____ leaving when the phone rang.|of
The delegates agreed ____ principle but disputed the details.|in
She is capable ____ managing the project independently.|of
The findings have given rise ____ a heated debate.|to
The proposal met ____ considerable resistance.|with
The results fell short ____ our expectations.|of
She took exception ____ his dismissive tone.|to
He went to great lengths ____ protect the source's identity.|to
For all its advantages, the system still ____ limitations.|has
The research team set ____ to test an alternative explanation.|out
The author draws ____ her own experience throughout the novel.|on
The issue boils down ____ a lack of resources.|to
The company should ____ invested in staff training years ago.|have
If only I ____ the courage to speak up at yesterday's meeting.|had had
She has difficulty making herself ____ in a noisy room.|heard
He was reluctant ____ acknowledge the error.|to
The scheme is designed ____ benefit smaller businesses.|to
Few people were aware ____ the consequences at the time.|of
We would be grateful if you ____ confirm your attendance.|could
The committee ruled out ____ the deadline again.|extending
She is keen ____ gain practical experience.|to
The policy came ____ effect at the beginning of the year.|into
You can borrow the equipment on condition ____ you return it tomorrow.|that
I was under the impression ____ the meeting had been postponed.|that
The project is due ____ completed in November.|to be
He is unlikely ____ have forgotten such an important appointment.|to
The report takes issue ____ the assumptions behind the forecast.|with
The figures should be interpreted ____ caution.|with
She had no choice but ____ accept the revised terms.|to
The argument rests ____ two assumptions that remain untested.|on
The case for reform is stronger ____ ever.|than
We cannot afford ____ ignore the warning signs.|to
The interviewer asked me what I ____ do if the project failed.|would
No matter how carefully you plan, unexpected problems ____ arise.|may
The discovery sheds light ____ an unresolved question.|on
She found it hard to come ____ terms with the decision.|to
'''
rows = [line.split('|') for line in GRAMMAR.strip().splitlines()]
assert len(rows) == 200, len(rows)
grammar = [dict(id=f'g{i+1:03}', level='B2' if i % 2 == 0 else 'C1', prompt=prompt, answers=[answer], completed=prompt.replace('____', answer)) for i, (prompt, answer) in enumerate(rows)]
save('grammar', grammar, language='en', levelRange=['B2', 'C1'], origin='Original authored exercises')

# Four distinct writing tasks for each issue; no correction or extra writing tools.
ISSUES = '''
remote working and professional isolation
public transport fares and access to employment
artificial intelligence in university assessment
repairing electronic devices instead of replacing them
protecting local shops from rising rents
teaching financial literacy in secondary schools
limiting short-term holiday rentals in city centres
funding public libraries in the digital age
reducing food waste in restaurants
balancing renewable energy with landscape protection
introducing a four-day working week
preserving minority languages
making museums accessible to wider audiences
restricting advertising aimed at children
volunteering as part of higher education
using surveillance cameras in public spaces
improving access to mental health support
regulating unpaid internships
replacing private cars with shared mobility
providing free school meals
maintaining green spaces during housing expansion
protecting personal data collected by fitness apps
encouraging adults to return to education
supporting young people who leave rural communities
making scientific research freely available
including citizens in local planning decisions
preventing misinformation on social networks
balancing tourism with residents' needs
giving employees a right to disconnect
preserving historic buildings with new uses
reducing packaging in online shopping
funding community arts programmes
using animal testing in medical research
improving accessibility at music festivals
recognising qualifications obtained abroad
teaching practical skills alongside academic subjects
promoting sustainable clothing consumption
introducing digital voting systems
managing water shortages fairly
supporting independent journalism
using algorithms to recruit employees
sharing responsibility for elderly relatives
developing affordable housing near workplaces
limiting noise pollution in residential areas
restoring abandoned industrial sites
balancing competitive sport with student wellbeing
providing language courses for newly arrived residents
creating opportunities for lifelong volunteering
making public services available without smartphones
protecting biodiversity on agricultural land
'''.strip().splitlines()
TASKS = [
 ('B2', 'Write an essay discussing the advantages and disadvantages of {issue}. Explain which consideration should carry the most weight.'),
 ('C1', 'Write a proposal for a local organisation addressing {issue}. Evaluate two possible measures and justify your recommendation.'),
 ('B2', 'Write a formal letter to a decision-maker about {issue}. Explain a specific concern and suggest a practical improvement.'),
 ('C1', 'Write an article examining the long-term implications of {issue}. Challenge a common assumption and support your position with examples.'),
]
writings = [dict(id=f'w{i*4+j+1:03}', level=level, topic=task.format(issue=issue)) for i, issue in enumerate(ISSUES) for j, (level, task) in enumerate(TASKS)]
assert len(writings) == 200
save('writing', writings, language='en', levelRange=['B2', 'C1'], origin='Original authored topics')
assert len(READINGS) == 50
save('reading', [dict(id=f'r{i+1:03}', level=level, title=title, text=text, questions=[dict(question=q, answer=a) for q,a in questions]) for i,(level,title,text,questions) in enumerate(READINGS)], language='en', levelRange=['B2', 'C1'], origin='Original fictional passages; answers for manual comparison')

# Supplemental entries are original bilingual expressions, not numbered duplicates.
EXTRA = '''
algorithmic bias|sesgo algorítmico
carbon leakage|fuga de carbono
climate resilience|resiliencia climática
circular economy|economía circular
digital footprint|huella digital
data minimisation|minimización de datos
energy poverty|pobreza energética
food insecurity|inseguridad alimentaria
housing affordability|asequibilidad de la vivienda
intergenerational equity|equidad intergeneracional
just transition|transición justa
labour displacement|desplazamiento laboral
lifelong learning|aprendizaje permanente
media literacy|alfabetización mediática
microplastic pollution|contaminación por microplásticos
nature-based solutions|soluciones basadas en la naturaleza
participatory budgeting|presupuestos participativos
platform economy|economía de plataformas
privacy by design|privacidad desde el diseño
resource depletion|agotamiento de recursos
supply chain resilience|resiliencia de la cadena de suministro
urban heat island|isla de calor urbana
universal basic income|renta básica universal
water scarcity|escasez de agua
workplace wellbeing|bienestar laboral
right to disconnect|derecho a la desconexión
greenwashing|lavado de imagen ecológico
decarbonisation|descarbonización
rewilding|renaturalización
upskilling|mejora de competencias
reskilling|recualificación profesional
doomscrolling|consumo compulsivo de noticias negativas
digital divide|brecha digital
echo chamber|cámara de eco
confirmation bias|sesgo de confirmación
survivorship bias|sesgo de supervivencia
selection bias|sesgo de selección
cognitive overload|sobrecarga cognitiva
attention economy|economía de la atención
choice architecture|arquitectura de decisiones
informed consent|consentimiento informado
informed refusal|rechazo informado
ethical sourcing|abastecimiento ético
fair trade certification|certificación de comercio justo
planned obsolescence|obsolescencia programada
right to repair|derecho a reparar
repairability|reparabilidad
sustainable procurement|contratación sostenible
responsible disclosure|divulgación responsable
vulnerability assessment|evaluación de vulnerabilidades
zero-day vulnerability|vulnerabilidad de día cero
end-to-end encryption|cifrado de extremo a extremo
multi-factor authentication|autenticación multifactor
ransomware|software de secuestro
phishing|suplantación de identidad
credential stuffing|relleno de credenciales
social engineering|ingeniería social
dark pattern|patrón de diseño engañoso
consent fatigue|fatiga del consentimiento
open access publishing|publicación de acceso abierto
peer review process|proceso de revisión por pares
reproducibility crisis|crisis de reproducibilidad
publication bias|sesgo de publicación
preregistration|prerregistro
statistical power|potencia estadística
confounding variable|variable de confusión
causal inference|inferencia causal
external validity|validez externa
internal validity|validez interna
confidence interval|intervalo de confianza
effect size|tamaño del efecto
sample attrition|pérdida de participantes de la muestra
research integrity|integridad de la investigación
knowledge transfer|transferencia de conocimiento
citizen science|ciencia ciudadana
stakeholder engagement|participación de las partes interesadas
community-led development|desarrollo liderado por la comunidad
trauma-informed care|atención informada por el trauma
social prescribing|prescripción social
caregiver burden|sobrecarga de la persona cuidadora
age-friendly city|ciudad amigable con las personas mayores
universal design|diseño universal
inclusive education|educación inclusiva
reasonable accommodation|adaptación razonable
assistive technology|tecnología de asistencia
screen reader|lector de pantalla
step-free access|acceso sin escalones
sensory overload|sobrecarga sensorial
hidden disability|discapacidad invisible
intersectionality|interseccionalidad
restorative justice|justicia restaurativa
procedural fairness|equidad procesal
regulatory capture|captura regulatoria
policy trade-off|disyuntiva entre políticas
unintended consequence|consecuencia no prevista
implementation gap|brecha de implementación
last-mile delivery|entrega de última milla
modal shift|cambio modal
active mobility|movilidad activa
transit-oriented development|desarrollo orientado al transporte público
congestion pricing|tarificación por congestión
induced demand|demanda inducida
traffic calming|pacificación del tráfico
low-emission zone|zona de bajas emisiones
embodied carbon|carbono incorporado
carbon sequestration|captura de carbono
biodiversity loss|pérdida de biodiversidad
habitat fragmentation|fragmentación del hábitat
ecological corridor|corredor ecológico
ecosystem services|servicios ecosistémicos
regenerative agriculture|agricultura regenerativa
soil degradation|degradación del suelo
pollinator decline|disminución de polinizadores
managed retreat|retirada planificada
climate adaptation|adaptación climática
climate mitigation|mitigación climática
climate attribution|atribución climática
extreme weather event|fenómeno meteorológico extremo
heat stress|estrés térmico
water stewardship|gestión responsable del agua
'''

def lemma(el):
    return (el.text or '') + ''.join((' ' if child.tag == 'b' else lemma(child) if child.tag == 'g' else '') + (child.tail or '') for child in el)

entries = {}
root = ET.parse(ROOT / 'scripts/sources/apertium-eng-spa.dix').getroot()
for entry in root.findall("./section[@id='main']/e"):
    pair = entry.find('p')
    if pair is None: continue
    left, right = pair.find('l'), pair.find('r')
    en, es = lemma(left).strip().lower(), lemma(right).strip().lower()
    tags = {s.get('n') for s in left.findall('.//s')}
    if not tags & {'n', 'adj', 'adv', 'vblex'} or tags & {'np', 'acr'}: continue
    if not re.fullmatch(r"[a-z]+(?:[ '-][a-z]+)*", en): continue
    if not re.fullmatch(r"[a-záéíóúüñ]+(?:[ '-][a-záéíóúüñ]+)*", es): continue
    entries.setdefault(en, set()).add(es)
for line in EXTRA.strip().splitlines():
    en, es = line.split('|'); entries.setdefault(en, set()).add(es)
frequencies = {line.rsplit(' ', 1)[0]: i for i, line in enumerate((ROOT / 'scripts/sources/en-frequency.txt').read_text().splitlines())}
# Frequency bands are an aid to selecting difficulty, not certified CEFR labels.
ordered = sorted(entries, key=lambda en: (frequencies.get(en, 1000000), en))
assert len(ordered) >= 20000, len(ordered)
vocabulary = [dict(id=f'v{i+1:05}', english=en, spanish=sorted(entries[en]), difficulty='Frecuente' if frequencies.get(en, 1000000) < 10000 else 'Menos frecuente') for i, en in enumerate(ordered[:20000])]
save('vocabulary', vocabulary, languages=['en', 'es'], difficultyMethod='Frequency bands: headwords among the first 10,000 in the source frequency list are Frecuente; remaining headwords and expressions are Menos frecuente. These are not certified CEFR levels.', sources=[
    dict(name='Apertium English–Spanish bilingual dictionary', url='https://github.com/apertium/apertium-eng-spa', revision='7dd744e4baba30b2688aba54dabfaa8b879bb600', license='GPL-2.0', licenseFile='licenses/apertium.txt', sourceFile='scripts/sources/apertium-eng-spa.dix'),
    dict(name='FrequencyWords English 2018', url='https://github.com/hermitdave/FrequencyWords/blob/master/content/2018/en/en_50k.txt', license='MIT', licenseFile='licenses/frequency-words.txt', sourceFile='scripts/sources/en-frequency.txt'),
    dict(name='Original supplemental bilingual terminology', license='Original project content'),
])
print('Generated:', ', '.join(f'{name}: {len(json.loads((ROOT / "data" / f"{name}.json").read_text())["items"])}' for name in ['grammar', 'reading', 'writing', 'vocabulary']))
for license_file in (ROOT / 'licenses').glob('*.txt'):
    destination = ROOT / 'mobile/assets/licenses' / license_file.name
    destination.parent.mkdir(parents=True, exist_ok=True)
    shutil.copyfile(license_file, destination)
