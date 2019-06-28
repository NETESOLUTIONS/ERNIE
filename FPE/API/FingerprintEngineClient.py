import urllib.request
import urllib.parse
import base64
import xml.etree.ElementTree as ET

"""
    Fingerprint Engine Client
"""
class FingerprintEngineClient:

    # constructor method
    def __init__(self, url, username=None, password=None):
        if (url.endswith('/')):
            url = url[0:len(url)-1]
        if (url.lower().endswith('/tacoservice.svc')):
            url = url[0:len(url)-len('/tacoservice.svc')]
        self.url = url
        self.headers = {}
        if (username != None):
            authString = (username + ":" + password).encode('ascii')
            self.headers['Authorization'] = ('Basic ' + base64.b64encode(authString).decode('ascii'))

    # index a document with plain text only
    def plaintextindex(self, workflow, text):
        req = urllib.request.Request(url=self.url + '/TacoService.svc/' + workflow, data=bytes(text, 'utf-8'), headers=self.headers)
        f = urllib.request.urlopen(req)
        return f.read()

    # address a work flow, sending a document represented as byte array
    # can be both Xml or Plain text
    def plainindex(self, workflow, data):
        req = urllib.request.Request(url=self.url + '/TacoService.svc/' + workflow, data=data, headers=self.headers)
        f = urllib.request.urlopen(req)
        return f.read()

    # index a document with title and abstract
    def index(self, workflow, title, abstract):
        doc = ET.Element('xml')
        t = ET.SubElement(doc, 'title')
        a = ET.SubElement(doc, 'abstract')
        t.text = title
        a.text = abstract
        reqstring=ET.tostring(doc, encoding='utf-8')
        # print(reqstring) # print request string, debugging only
        req = urllib.request.Request(url=self.url + '/TacoService.svc/' + workflow, data=reqstring, headers=self.headers)
        f = urllib.request.urlopen(req)
        return TextAnalysis(f.read())

    # index a document with a variable number of sections
    # 'workflow' must be a string
    # 'sections' must be a dictionary of string-string (section name, section content)
    def process(self, workflow, sections):
        doc = ET.Element('xml')
        for key, value in sections.items():
            s = ET.SubElement(doc, key)
            s.text = value
        reqstring=ET.tostring(doc, encoding='utf-8')
        # print(reqstring) # print request string, debugging only
        req = urllib.request.Request(url=self.url + '/TacoService.svc/' + workflow, data=reqstring, headers=self.headers)
        f = urllib.request.urlopen(req)
        return TextAnalysis(f.read())

"""
    Class to contain concepts and concept weights
"""
class ConceptRank:
    def __init__(self, conceptid, rank, name, afreq):
        self.conceptid = conceptid
        self.rank   = rank
        self.name   = name
        self.afreq  = afreq

ns = { 'r'  : "http://www.collexis.com/annotations/",
       'i'  : "http://www.w3.org/2001/XMLSchema-instance",
       'a'  : "http://schemas.microsoft.com/2003/10/Serialization/Arrays"
     }

def optionalElement(xml, element):
    el = xml.find(element, ns)
    if (el == None):
        return None
    return el.text

"""
    Class to contain term annotations
"""
class TermAnnotation:
    def __init__(self, xml, textAnalysis = None):
        self.conceptid = xml.find('r:ConceptID', ns).text
        self.termid    = xml.find('r:TermID', ns).text
        self.thesaurus = xml.find('r:Thesaurus', ns).text
        self.tokens    = []
        for token in xml.findall("./r:Tokens/a:int", ns):
            self.tokens.append(int(token.text))
        self.flags     = []
        for flag in xml.findall("./r:Flags/a:string", ns):
            self.flags.append(flag.text)

        # optional elements, either produced by TACO extension methods
        # or by combining information from different annotations contained in the textAnalysis structure
        if ((textAnalysis == None) | (len(self.tokens)==0)):
            self.textoffset = optionalElement(xml, 'r:TextOffset')
        else:
            # try to retrieve. if the textAnalysis does not feature tokens, we still have to resort
            # to the (optionally) serialized text Offset
            textoffset = textAnalysis.tokenOffsetToTextOffset(self.tokens[0])
            if (textoffset == None):
                self.textoffset = optionalElement(xml, 'r:TextOffset')
            else:
                self.textoffset = textoffset

        self.textend    = optionalElement(xml, 'r:TextEnd')
        self.text       = optionalElement(xml, 'r:Text')

"""
    Class to store and use the output of a TACO call
"""
class TextAnalysis:
    def __init__(self, xml):
        self.tree = ET.fromstring(xml)
        # store all token offsets
        self.tokenoffsets = list(int(token.find('r:Offset', ns).text) for token in self.tree.findall(".//r:Annotation[@i:type='Token']", ns))
        # print ('len tokenoffsets:', len(self.tokenoffsets)) # debug statement

    # translate Xml to fingerprint - a list of concept ranks
    def toFingerprint(self):
        fp = []
        for concept in self.tree.findall(".//r:Annotation[@i:type='ConceptAnnotation']", ns):
            fp.append(ConceptRank(concept.find('r:ConceptID', ns).text,
                                  concept.find('r:Rank', ns).text,
                                  concept.find('r:Name', ns).text,
                                  concept.find('r:AFreq', ns).text))
        return fp

    def terms(self):
        for term in self.tree.findall(".//r:Annotation[@i:type='TermAnnotation']", ns):
            yield TermAnnotation(term, self)

    # translate Xml to fingerprint - a list of double features
    def toFeatureFingerprint(self):
        fp = []
        for concept in self.tree.findall(".//r:Annotation[@i:type='DoubleFeature']", ns):
            fp.append(ConceptRank('0',
                                  concept.find('r:Rank', ns).text,
                                  concept.find('r:Feature', ns).text,
                                  '0'))
        return fp

    # translate Xml to sectioned fingerprint - a dictionary from section to fingerprint
    def toSectionedFingerprint(self):
        sectionedFp = {}
        for concept in self.tree.findall(".//r:Annotation[@i:type='SectionConceptAnnotation']", ns):
            cr = ConceptRank(concept.find('r:ConceptID', ns).text,
                                  concept.find('r:Rank', ns).text,
                                  concept.find('r:Name', ns).text,
                                  concept.find('r:AFreq', ns).text)
            section = concept.find('r:Section', ns).text
            fp = sectionedFp.get(section, [])
            fp.append(cr)
            sectionedFp[section] = fp
        return sectionedFp

    # translate a token offset into a text offset
    def tokenOffsetToTextOffset(self, tokenoffset):
        if ((tokenoffset < 0) | (len(self.tokenoffsets) <= tokenoffset)):
            return None
        return self.tokenoffsets[tokenoffset]
