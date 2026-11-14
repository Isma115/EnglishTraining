"""Rebuild the four bundled sets: python -X utf8 scripts/generate_sets.py."""
import json
import re
import shutil
import xml.etree.ElementTree as ET
from pathlib import Path
from reading_content import READINGS
from grammar_content import build_grammar

ROOT = Path(__file__).resolve().parents[1]

def save(name, items, **metadata):
    document = dict(schemaVersion=1, **metadata, items=items)
    text = json.dumps(document, ensure_ascii=False, indent=2) + '\n'
    for directory in [ROOT / 'data', ROOT / 'mobile/assets/data']:
        directory.mkdir(parents=True, exist_ok=True)
        (directory / f'{name}.json').write_text(text)

# Contextualised B2 grammar; the same source feeds desktop and mobile.
save('grammar', build_grammar(), language='en', levelRange=['B2'], origin='Original authored exercises')

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
