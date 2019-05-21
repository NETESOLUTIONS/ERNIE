-- LexisNexis XML Parser --

\set ON_ERROR_STOP on
\set ECHO all

-- DataGrip: start execution from here
SET TIMEZONE = 'US/Eastern';

-- We are lacking the adequate sample data for the lexisnexis patents. We are still waiting for that data.
-- However, my goal is to create a toy XML-parser so that I can get to speed once the new lexis nexis sample data is sent

-- Plan :
--1. Construct xml table
--2. Run toy-query
--3. Build toy-xml-parser as stored procedure

-- 1.  Create XML table

<!-- Copyright ©2019 LexisNexis Univentio, The Netherlands. -->
CREATE TABLE patent_legal_data AS SELECT XML
$$<lexisnexis-patent-document schema-version="1.13" date-produced="20190423" file="EP346B1.xml" produced-by="LexisNexis-Univentio" lang="eng" date-changed="20120325" time-changed="074338">
  <bibliographic-data lang="eng">
    <publication-reference publ-type="Grant" publ-desc="Granted patent">
      <document-id id="2866196">
        <country>EP</country>
        <doc-number>346</doc-number>
        <kind>B1</kind>
        <date>19800109</date>
      </document-id>
    </publication-reference>
    <application-reference>
      <document-id id="2072375">
        <country>EP</country>
        <doc-number>78100253</doc-number>
        <kind>A</kind>
        <date>19780628</date>
      </document-id>
    </application-reference>
    <language-of-filing>eng</language-of-filing>
    <language-of-publication>ger</language-of-publication>
    <priority-claims date-changed="20090224">
      <priority-claim sequence="1" kind="national">
        <country>DE</country>
        <doc-number>2730644</doc-number>
        <date>19770707</date>
      </priority-claim>
      <priority-claim sequence="1" data-format="docdb">
        <country>DE</country>
        <doc-number>2730644</doc-number>
        <date>19770707</date>
        <priority-active-indicator>true</priority-active-indicator>
      </priority-claim>
      <priority-claim sequence="1" data-format="original">
        <doc-number>2730644</doc-number>
      </priority-claim>
      <priority-claim sequence="1" data-format="epodoc">
        <doc-number>DE19772730644</doc-number>
      </priority-claim>
    </priority-claims>
    <dates-of-public-availability date-changed="20090224">
      <unexamined-printed-without-grant>
        <date>19790124</date>
      </unexamined-printed-without-grant>
      <printed-with-grant>
        <date>19800109</date>
      </printed-with-grant>
      <publication-of-grant-date>
        <date>19800109</date>
      </publication-of-grant-date>
    </dates-of-public-availability>
    <dates-rights-effective date-changed="20090224">
      <request-for-examination>
        <date>19780628</date>
      </request-for-examination>
      <first-examination-report-despatched>
        <date>19790124</date>
      </first-examination-report-despatched>
    </dates-rights-effective>
    <classification-ipc date-changed="20121207">
      <main-classification>
        <text>  C 07D 241/42   A</text>
        <section>C</section>
        <class>07</class>
        <subclass>D</subclass>
        <main-group>241</main-group>
        <subgroup>42</subgroup>
        <qualifying-character>A</qualifying-character>
      </main-classification>
      <further-classification sequence="1">
        <text>  C 07D 241/44   B</text>
        <section>C</section>
        <class>07</class>
        <subclass>D</subclass>
        <main-group>241</main-group>
        <subgroup>44</subgroup>
        <qualifying-character>B</qualifying-character>
      </further-classification>
      <further-classification sequence="2">
        <text>  C 07D 401/10   B</text>
        <section>C</section>
        <class>07</class>
        <subclass>D</subclass>
        <main-group>401</main-group>
        <subgroup>10</subgroup>
        <qualifying-character>B</qualifying-character>
      </further-classification>
      <further-classification sequence="3">
        <text>  C 07D 403/10   B</text>
        <section>C</section>
        <class>07</class>
        <subclass>D</subclass>
        <main-group>403</main-group>
        <subgroup>10</subgroup>
        <qualifying-character>B</qualifying-character>
      </further-classification>
      <further-classification sequence="4">
        <text>  C 07D 405/10   B</text>
        <section>C</section>
        <class>07</class>
        <subclass>D</subclass>
        <main-group>405</main-group>
        <subgroup>10</subgroup>
        <qualifying-character>B</qualifying-character>
      </further-classification>
      <further-classification sequence="5">
        <text>  C 07D 409/10   B</text>
        <section>C</section>
        <class>07</class>
        <subclass>D</subclass>
        <main-group>409</main-group>
        <subgroup>10</subgroup>
        <qualifying-character>B</qualifying-character>
      </further-classification>
      <further-classification sequence="6">
        <text>  C 07D 413/10   B</text>
        <section>C</section>
        <class>07</class>
        <subclass>D</subclass>
        <main-group>413</main-group>
        <subgroup>10</subgroup>
        <qualifying-character>B</qualifying-character>
      </further-classification>
      <further-classification sequence="7">
        <text>  C 07D 417/10   B</text>
        <section>C</section>
        <class>07</class>
        <subclass>D</subclass>
        <main-group>417</main-group>
        <subgroup>10</subgroup>
        <qualifying-character>B</qualifying-character>
      </further-classification>
      <further-classification sequence="8">
        <text>  C 08K   5/29   B</text>
        <section>C</section>
        <class>08</class>
        <subclass>K</subclass>
        <main-group>5</main-group>
        <subgroup>29</subgroup>
        <qualifying-character>B</qualifying-character>
      </further-classification>
      <further-classification sequence="9">
        <text>  D 06L   3/12   B</text>
        <section>D</section>
        <class>06</class>
        <subclass>L</subclass>
        <main-group>3</main-group>
        <subgroup>12</subgroup>
        <qualifying-character>B</qualifying-character>
      </further-classification>
    </classification-ipc>
    <classifications-ipcr date-changed="20121207">
      <classification-ipcr sequence="1">
        <text>C09B  23/00        20060101AFI20051220RMJP        </text>
        <ipc-version-indicator>
          <date>20060101</date>
        </ipc-version-indicator>
        <classification-level>A</classification-level>
        <section>C</section>
        <class>09</class>
        <subclass>B</subclass>
        <main-group>23</main-group>
        <subgroup>00</subgroup>
        <symbol-position>F</symbol-position>
        <classification-value>I</classification-value>
        <action-date>
          <date>20051220</date>
        </action-date>
        <generating-office>
          <country>JP</country>
        </generating-office>
        <classification-status>R</classification-status>
        <classification-data-source>M</classification-data-source>
      </classification-ipcr>
      <classification-ipcr sequence="2">
        <text>C07D 241/44        20060101A I20051008RMEP        </text>
        <ipc-version-indicator>
          <date>20060101</date>
        </ipc-version-indicator>
        <classification-level>A</classification-level>
        <section>C</section>
        <class>07</class>
        <subclass>D</subclass>
        <main-group>241</main-group>
        <subgroup>44</subgroup>
        <classification-value>I</classification-value>
        <action-date>
          <date>20051008</date>
        </action-date>
        <generating-office>
          <country>EP</country>
        </generating-office>
        <classification-status>R</classification-status>
        <classification-data-source>M</classification-data-source>
      </classification-ipcr>
      <classification-ipcr sequence="3">
        <text>C07F   9/6509      20060101A I20051008RMEP        </text>
        <ipc-version-indicator>
          <date>20060101</date>
        </ipc-version-indicator>
        <classification-level>A</classification-level>
        <section>C</section>
        <class>07</class>
        <subclass>F</subclass>
        <main-group>9</main-group>
        <subgroup>6509</subgroup>
        <classification-value>I</classification-value>
        <action-date>
          <date>20051008</date>
        </action-date>
        <generating-office>
          <country>EP</country>
        </generating-office>
        <classification-status>R</classification-status>
        <classification-data-source>M</classification-data-source>
      </classification-ipcr>
    </classifications-ipcr>
    <classifications-cpc date-changed="20121207">
      <classification-cpc sequence="1">
        <text>C07D 241/44        20130101  I20130101BHEP        </text>
        <cpc-version-indicator>
          <date>20130101</date>
        </cpc-version-indicator>
        <section>C</section>
        <class>07</class>
        <subclass>D</subclass>
        <main-group>241</main-group>
        <subgroup>44</subgroup>
        <classification-value>I</classification-value>
        <action-date>
          <date>20130101</date>
        </action-date>
        <generating-office>
          <country>EP</country>
        </generating-office>
        <classification-status>B</classification-status>
        <classification-data-source>H</classification-data-source>
      </classification-cpc>
      <classification-cpc sequence="2">
        <text>C07F   9/650994    20130101  I20130101BHEP        </text>
        <cpc-version-indicator>
          <date>20130101</date>
        </cpc-version-indicator>
        <section>C</section>
        <class>07</class>
        <subclass>F</subclass>
        <main-group>9</main-group>
        <subgroup>650994</subgroup>
        <classification-value>I</classification-value>
        <action-date>
          <date>20130101</date>
        </action-date>
        <generating-office>
          <country>EP</country>
        </generating-office>
        <classification-status>B</classification-status>
        <classification-data-source>H</classification-data-source>
      </classification-cpc>
    </classifications-cpc>
    <classifications-ecla date-changed="20121207">
      <classification-ecla sequence="1" classification-scheme="EC" country="EP">
        <text>C07D241/44</text>
        <section>C</section>
        <class>07</class>
        <subclass>D</subclass>
        <main-group>241</main-group>
        <subgroup>44</subgroup>
      </classification-ecla>
      <classification-ecla sequence="2" classification-scheme="EC" country="EP">
        <text>C07F  9/6509B4V</text>
        <section>C</section>
        <class>07</class>
        <subclass>F</subclass>
        <main-group>9</main-group>
        <subgroup>6509</subgroup>
        <additional-subgroups>
          <additional-subgroup sequence="1">B  </additional-subgroup>
          <additional-subgroup sequence="2">4  </additional-subgroup>
          <additional-subgroup sequence="3">V  </additional-subgroup>
        </additional-subgroups>
      </classification-ecla>
      <classification-ecla sequence="1" classification-scheme="ICO" country="EP">
        <text>M07D241:44</text>
        <section>M</section>
        <class>07</class>
        <subclass>D</subclass>
        <main-group>241</main-group>
        <subgroup>44</subgroup>
      </classification-ecla>
      <classification-ecla sequence="1" classification-scheme="IDT" country="EP">
        <text>124HC2B7C</text>
      </classification-ecla>
    </classifications-ecla>
    <number-of-claims calculated="yes">7</number-of-claims>
    <invention-title id="title_ger" date-changed="20190320" lang="ger" format="original">Chinoxalinverbindungen, Verfahren zu deren Herstellung, deren Verwendung zum Weisstönen organischer Materialien und damit weissgetönte Materialien</invention-title>
    <invention-title id="title_eng" date-changed="20190320" lang="eng" format="original">QUINOXALINE COMPOUNDS, PROCESS FOR THEIR MANUFACTURE AND THEIR USE AS BRIGHTENERS FOR ORGANIC MATERIALS, AND THE MATERIALS BRIGHTENED THEREWITH</invention-title>
    <invention-title id="title_fre" date-changed="20190320" lang="fre" format="original">Composés quinoxaliniques, leur procédé de préparation et leur utilisation pour le blanchiment optique de matières organiques et les matières ainsi blanchies</invention-title>
    <references-cited date-changed="20070319">
      <patent-citations name="patcit" date-changed="20070319" />
      <citation>
        <patcit num="1">
          <document-id>
            <country>FR</country>
            <doc-number>2206951</doc-number>
            <kind>A1</kind>
            <date>19740614</date>
          </document-id>
          <application-date>
            <date>19731120</date>
          </application-date>
        </patcit>
      </citation>
    </references-cited>
    <parties date-changed="20090224">
      <applicants>
        <applicant sequence="1" app-type="applicant">
          <addressbook lang="eng">
            <orgname>BAYER AKTIENGESELLSCHAFT</orgname>
            <orgname-standardized type="corporate">BAYER</orgname-standardized>
            <orgname-normalized key="16">BAYER</orgname-normalized>
          </addressbook>
        </applicant>
        <applicant sequence="1" app-type="applicant" data-format="docdba">
          <addressbook lang="eng">
            <orgname>BAYER AKTIENGESELLSCHAFT</orgname>
          </addressbook>
        </applicant>
      </applicants>
      <inventors>
        <inventor sequence="1">
          <addressbook lang="eng">
            <name>ECKSTEIN, UDO, DR.</name>
          </addressbook>
        </inventor>
        <inventor sequence="2">
          <addressbook lang="eng">
            <name>THEIDEL, HANS, DR.</name>
          </addressbook>
        </inventor>
        <inventor sequence="1" data-format="docdba">
          <addressbook lang="eng">
            <name>ECKSTEIN, UDO, DR.</name>
          </addressbook>
        </inventor>
        <inventor sequence="2" data-format="docdba">
          <addressbook lang="eng">
            <name>THEIDEL, HANS, DR.</name>
          </addressbook>
        </inventor>
      </inventors>
    </parties>
    <designation-of-states date-changed="20061019">
      <designation-epc>
        <contracting-states>
          <country>CH</country>
          <country>DE</country>
          <country>FR</country>
          <country>GB</country>
        </contracting-states>
      </designation-epc>
    </designation-of-states>
  </bibliographic-data>
  <abstract id="abstr_eng" date-changed="20190320" lang="eng" format="equivalent" country="US" doc-number="4184977" kind="A">
    <p>Fluorescent dyestuffs of the formula   &lt;IMAGE&gt;   wherein X and Y denote hydrogen, halogen, alkyl, aralkyl, alkenyl, hydroxyl, amino, alkoxy, aralkoxy, cycloalkoxy, aryloxy, alkylmercapto, alkylamino, dialkylamino, morpholino, piperidino, piperazino, pyrrolidino, acylamino or arylamino. Q denotes hydrogen, pyrazol-1-yl, oxazol-2-yl, benzoxazol-2-yl, naphthoxazol-2-yl, 1,2,4-oxadiazol-5-yl, 1,3,4-oxadiazol-2-yl, isoxazol-3-yl, isoxazol-5-yl, thiazol-2-yl, benzthiazol-2-yl, 1,3,4-thiadiazol-2-yl, imidazol-2-yl, benzimidazol-2-yl, 1,2,3-triazol-2-yl, 1,2,3-triazol-4-yl, 1,2,4-triazol-3-yl, 1,2,4-triazol-5-yl, 1,3,5-triazin-2-yl, 2H-benzotriazol-2-yl, 2H-naphthotriazol-2-yl, 1,2,3,4-tetrazol-5-yl, 1,2,3,4-tetrazol-1-yl, benzo[b]-furan-2-yl, naphtho[2,1-b]-furan-2-yl, benzo[b]-thiophen-2-yl, naphtho[2,1-b]-thiophen-2-yl, pyrimidin-2-yl, pyridin-2-yl, quinazolin-4-yl or quinazolin-2-yl, and, if n=0, also naphthyl, stilben-4-yl, benzo[b]-furan-6-yl, dibenzofuran-3-yl, dibenzofuran-2-yl, quinoxalin-5-yl, quinazolin-6-yl or 2H-benzotriazol-5-yl and n denotes 0, 1 or 2, it being possible for the substituents X, Y and Q and the remaining cyclic radicals to be further substituted by non-chromophoric substituents which are customary for whiteners, are suitable for whitening the most diverse synthetic, semi-synthetic and natural organic high-molecular materials.</p>
  </abstract>
  <legal-data date-changed="20140618">
    <legal-event sequence="1">
      <publication-date>
        <date>19790124</date>
      </publication-date>
      <event-code-1>AK</event-code-1>
      <effect>+</effect>
      <legal-description>DESIGNATED CONTRACTING STATES:</legal-description>
      <status-identifier>C</status-identifier>
      <docdb-publication-number> EP     0000346A1</docdb-publication-number>
      <docdb-application-id>16427319</docdb-application-id>
      <legal-designated-states>
        <country>CH</country>
        <country>DE</country>
        <country>FR</country>
        <country>GB</country>
      </legal-designated-states>
    </legal-event>
    <legal-event sequence="2">
      <publication-date>
        <date>19790207</date>
      </publication-date>
      <event-code-1>17P</event-code-1>
      <effect>+</effect>
      <legal-description>REQUEST FOR EXAMINATION FILED</legal-description>
      <status-identifier>C</status-identifier>
      <docdb-publication-number> EP     0000346A1</docdb-publication-number>
      <docdb-application-id>16427319</docdb-application-id>
    </legal-event>
    <legal-event sequence="3">
      <publication-date>
        <date>19800109</date>
      </publication-date>
      <event-code-1>AK</event-code-1>
      <effect>+</effect>
      <legal-description>DESIGNATED CONTRACTING STATES:</legal-description>
      <status-identifier>C</status-identifier>
      <docdb-publication-number> EP     0000346A1</docdb-publication-number>
      <docdb-application-id>16427319</docdb-application-id>
      <legal-designated-states>
        <country>CH</country>
        <country>DE</country>
        <country>FR</country>
        <country>GB</country>
      </legal-designated-states>
    </legal-event>
    <legal-event sequence="4">
      <publication-date>
        <date>19800214</date>
      </publication-date>
      <event-code-1>REF</event-code-1>
      <legal-description>CORRESPONDS TO:</legal-description>
      <status-identifier>C</status-identifier>
      <docdb-publication-number> EP     0000346A1</docdb-publication-number>
      <docdb-application-id>16427319</docdb-application-id>
      <corresponding-publication-number>2857515</corresponding-publication-number>
      <corresponding-authority>
        <country>DE</country>
      </corresponding-authority>
      <corresponding-publication-date>
        <date>19800214</date>
      </corresponding-publication-date>
    </legal-event>
    <legal-event sequence="5">
      <publication-date>
        <date>19830701</date>
      </publication-date>
      <event-code-1>PGFP</event-code-1>
      <effect>+</effect>
      <legal-description>POSTGRANT: ANNUAL FEES PAID TO NATIONAL OFFICE</legal-description>
      <status-identifier>C</status-identifier>
      <docdb-publication-number> EP     0000346A1</docdb-publication-number>
      <docdb-application-id>16427319</docdb-application-id>
      <designated-state-authority>
        <country>FR</country>
      </designated-state-authority>
      <payment-date>
        <date>19830701</date>
      </payment-date>
      <fee-payment-year>6</fee-payment-year>
    </legal-event>
    <legal-event sequence="6">
      <publication-date>
        <date>19840526</date>
      </publication-date>
      <event-code-1>PGFP</event-code-1>
      <effect>+</effect>
      <legal-description>POSTGRANT: ANNUAL FEES PAID TO NATIONAL OFFICE</legal-description>
      <status-identifier>C</status-identifier>
      <docdb-publication-number> EP     0000346A1</docdb-publication-number>
      <docdb-application-id>16427319</docdb-application-id>
      <designated-state-authority>
        <country>DE</country>
      </designated-state-authority>
      <payment-date>
        <date>19840526</date>
      </payment-date>
      <fee-payment-year>7</fee-payment-year>
    </legal-event>
    <legal-event sequence="7">
      <publication-date>
        <date>19850213</date>
      </publication-date>
      <event-code-1>GBPC</event-code-1>
      <effect>-</effect>
      <legal-description>GB: EUROPEAN PATENT CEASED THROUGH NON-PAYMENT OF RENEWAL FEE</legal-description>
      <status-identifier>C</status-identifier>
      <docdb-publication-number> EP     0000346A1</docdb-publication-number>
      <docdb-application-id>16427319</docdb-application-id>
    </legal-event>
    <legal-event sequence="8">
      <publication-date>
        <date>19850228</date>
      </publication-date>
      <event-code-1>PG25</event-code-1>
      <effect>-</effect>
      <legal-description>LAPSED IN A CONTRACTING STATE ANNOUNCED VIA POSTGRANT INFORM. FROM NAT. OFFICE TO EPO</legal-description>
      <status-identifier>C</status-identifier>
      <docdb-publication-number> EP     0000346A1</docdb-publication-number>
      <docdb-application-id>16427319</docdb-application-id>
      <designated-state-authority>
        <country>FR</country>
      </designated-state-authority>
      <free-text-description>LAPSE BECAUSE OF NON-PAYMENT OF DUE FEES</free-text-description>
      <effective-date>
        <date>19850228</date>
      </effective-date>
    </legal-event>
    <legal-event sequence="9">
      <publication-date>
        <date>19850426</date>
      </publication-date>
      <event-code-1>REG</event-code-1>
      <legal-description>REFERENCE TO A NATIONAL CODE</legal-description>
      <status-identifier>C</status-identifier>
      <docdb-publication-number> EP     0000346A1</docdb-publication-number>
      <docdb-application-id>16427319</docdb-application-id>
      <designated-state-authority>
        <country>FR</country>
      </designated-state-authority>
      <designated-state-event-code>ST</designated-state-event-code>
      <designated-state-description>NOTIFICATION OF LAPSE</designated-state-description>
    </legal-event>
    <legal-event sequence="10">
      <publication-date>
        <date>19870303</date>
      </publication-date>
      <event-code-1>PG25</event-code-1>
      <effect>-</effect>
      <legal-description>LAPSED IN A CONTRACTING STATE ANNOUNCED VIA POSTGRANT INFORM. FROM NAT. OFFICE TO EPO</legal-description>
      <status-identifier>C</status-identifier>
      <docdb-publication-number> EP     0000346A1</docdb-publication-number>
      <docdb-application-id>16427319</docdb-application-id>
      <designated-state-authority>
        <country>DE</country>
      </designated-state-authority>
      <effective-date>
        <date>19870303</date>
      </effective-date>
    </legal-event>
    <legal-event sequence="11">
      <publication-date>
        <date>19881117</date>
      </publication-date>
      <event-code-1>PG25</event-code-1>
      <effect>-</effect>
      <legal-description>LAPSED IN A CONTRACTING STATE ANNOUNCED VIA POSTGRANT INFORM. FROM NAT. OFFICE TO EPO</legal-description>
      <status-identifier>C</status-identifier>
      <docdb-publication-number> EP     0000346A1</docdb-publication-number>
      <docdb-application-id>16427319</docdb-application-id>
      <designated-state-authority>
        <country>GB</country>
      </designated-state-authority>
      <effective-date>
        <date>19881117</date>
      </effective-date>
    </legal-event>
    <legal-event sequence="12">
      <publication-date>
        <date>19890622</date>
      </publication-date>
      <event-code-1>PGFP</event-code-1>
      <effect>+</effect>
      <legal-description>POSTGRANT: ANNUAL FEES PAID TO NATIONAL OFFICE</legal-description>
      <status-identifier>C</status-identifier>
      <docdb-publication-number> EP     0000346A1</docdb-publication-number>
      <docdb-application-id>16427319</docdb-application-id>
      <designated-state-authority>
        <country>CH</country>      </designated-state-authority>
      <payment-date>
        <date>19890622</date>
      </payment-date>
      <fee-payment-year>12</fee-payment-year>
    </legal-event>
    <legal-event sequence="13">
      <publication-date>
        <date>19900630</date>
      </publication-date>
      <event-code-1>PG25</event-code-1>
      <effect>-</effect>
      <legal-description>LAPSED IN A CONTRACTING STATE ANNOUNCED VIA POSTGRANT INFORM. FROM NAT. OFFICE TO EPO</legal-description>
      <status-identifier>C</status-identifier>
      <docdb-publication-number> EP     0000346A1</docdb-publication-number>
      <docdb-application-id>16427319</docdb-application-id>
      <designated-state-authority>
        <country>CH</country>
      </designated-state-authority>
      <effective-date>
        <date>19900630</date>
      </effective-date>
    </legal-event>
    <legal-event sequence="14">
      <publication-date>
        <date>19910228</date>
      </publication-date>
      <event-code-1>REG</event-code-1>
      <legal-description>REFERENCE TO A NATIONAL CODE</legal-description>
      <status-identifier>C</status-identifier>
      <docdb-publication-number> EP     0000346A1</docdb-publication-number>
      <docdb-application-id>16427319</docdb-application-id>
      <designated-state-authority>
        <country>CH</country>
      </designated-state-authority>
      <designated-state-event-code>PL</designated-state-event-code>
      <designated-state-description>PATENT CEASED</designated-state-description>
    </legal-event>
  </legal-data>
</lexisnexis-patent-document>  $$ AS patent_data;



---- relevant fields
---- bibliographic-data`, `legal data` and `abstracts`
---- <xs:element ref="bibliographic-data"/>
-- <xs:element ref="abstract" minOccurs="0" maxOccurs="unbounded"/>
-- <xs:element ref="abstract-figure" minOccurs="0"/>
-- <xs:element ref="front-page" minOccurs="0"/>
-- <xs:element ref="legal-data" minOccurs="0"/>
-- <xs:element ref="national-notifications" minOccurs="0"/>

-- 2.1 Toy query for bibliographic data

SELECT xmltable.document_id,
       xmltable.bibliographic_language,
       xmltable.publication_type,
       xmltable.publication_decision,
       TO_DATE(xmltable.publication_date::TEXT, 'YYYYMMDD') AS publication_date,
       xmltable.publication_country,
       xmltable.application_id,
       xmltable.application_country,
       TO_DATE(xmltable.application_date::TEXT, 'YYYYMMDD') AS application_date,
       xmltable.language_of_filing,
       xmltable.language_of_publication,
       TO_DATE(xmltable.date_of_public_availability_changed::TEXT , 'YYYYMMDD') AS Date_of_public_availability,
       TO_DATE(xmltable.unexamined_printed_without_grant::TEXT, 'YYYYMMDD') AS Date_of_public_availability_without_grant,
       TO_DATE(xmltable.date_of_public_availability_with_grant::TEXT,'YYYYMMDD') AS date_of_public_availability_with_grant,
       TO_DATE(xmltable.publication_of_grant_date::TEXT, 'YYYYMMDD') AS date_of_grant_publication
FROM patent_legal_data, xmltable(
             '//lexisnexis-patent-document' PASSING patent_data COLUMNS
         document_id BIGINT PATH '//publication-reference/document-id/@id',
         bibliographic_language TEXT PATH '//bibliographic-data/@lang',
         publication_type TEXT PATH '//publication-reference/@publ-type',
         publication_decision TEXT PATH '//publication-reference/@publ-desc',
         publication_date BIGINT PATH '//publication-reference/document-id/date',
         publication_country TEXT PATH '//publication-reference/document-id/country',
         application_id BIGINT PATH '//application-reference/document-id/@id',
         application_country TEXT PATH '//application-reference/document-id/country',
         application_date BIGINT PATH '//application-reference/document-id/date',
         language_of_filing TEXT PATH '//language-of-filing',
         language_of_publication TEXT PATH '//language-of-publication',
         date_of_public_availability_changed BIGINT PATH '//dates-of-public-availability/@date-changed',
         unexamined_printed_without_grant BIGINT PATH '//dates-of-public-availability/unexamined-printed-without-grant/date',
         date_of_public_availability_with_grant BIGINT PATH '//dates-of-public-availability/printed-without-grant/date',
         publication_of_grant_date BIGINT PATH '//dates-of-public-availability/publication-of-grant-date/date'
         );


-- 2.2 Toy query for abstract data
SELECT
       xmltable.doc_number,
       xmltable.country_code,
       xmltable.abstract_id,
       TO_DATE(xmltable.abstract_date_changed::TEXT, 'YYYYMMDD' ),
       xmltable.abstract_language,
       xmltable.abstract_text
FROM patent_legal_data, xmltable (
    '//abstract' PASSING patent_data COLUMNS
            doc_number TEXT PATH '//bibliographic-data/publication-reference/document-id/country',
            country_code TEXT PATH '//bibliographic-data/publication-reference/document-id/doc-number',
            abstract_id  TEXT PATH '@id',
            abstract_date_changed TEXT PATH '@date-changed',
            abstract_language  TEXT PATH '@lang',
            abstract_text TEXT PATH 'p'

      );

-- 2.3 Query for legal-data
 SELECT
            xmltable.document_num,
            xmltable.country_code,
            xmltable.kind_code,
            xmltable.sequence_id,
            xmltable.publication_date,
            xmltable.event_code_1,
            xmltable.event_code_2,
            xmltable.effect,
            xmltable.legal_description,
            xmltable.status_identifier,
            xmltable.docdb_publication_number,
            xmltable.docdb_application_id,
            xmltable.designated_state_authority,
            xmltable.designated_state_code,
            xmltable.designated_state_event_code,
            xmltable.designated_state_description,
            xmltable.corresponding_publication_number,
            xmltable.corresponding_publication_id,
            xmltable.corresponding_authority,
            xmltable.corresponding_kind,
            xmltable.legal_designated_states,
            xmltable.extension_state_authority,
            xmltable.new_owner,
            xmltable.free_text_description,
            xmltable.spc_number,
            xmltable.filing_date,
            xmltable.expiry_date,
            xmltable.inventor_names,
            xmltable.ipc,
            xmltable.payment_date,
            xmltable.fee_payment_year,
            xmltable.requester_name,
            xmltable.countries_concerned,
            xmltable.effective_date,
            xmltable.withdrawn_date
FROM patent_legal_data,
             xmltable('//legal-data/legal-event' PASSING patent_data COLUMNS
                document_num TEXT PATH '//bibliographic-data/publication-reference/document-id/country' NOT NULL,
                country_code TEXT PATH '//bibliographic-data/publication-reference/document-id/doc-number' NOT NULL,
                kind_code TEXT PATH '//bibliographic-data/publication-reference/document-id/kind' NOT NULL,
                sequence_id INT PATH '@sequence',
                publication_date INT PATH 'publication-date/date ' NOT NULL,
                event_code_1 TEXT PATH 'event-code-1',
                event_code_2 TEXT PATH 'event-code-2' ,
                effect TEXT PATH 'effect',
                legal_description TEXT PATH 'legal-description',
                status_identifier TEXT PATH 'status-identifier',
                docdb_publication_number TEXT PATH 'docdb-publication-number',
                docdb_application_id TEXT PATH 'doccb-application-id',
                designated_state_authority TEXT PATH 'designated_state_authority',
                designated_state_code TEXT PATH 'designated-state-code',
                designated_state_event_code TEXT PATH 'designated-state-event-code',
                designated_state_description TEXT PATH 'designated-state-description',
                corresponding_publication_number INT PATH 'corresponding-publication-number',
                corresponding_publication_id INT PATH 'corresponding-publication-id',
                corresponding_authority TEXT PATH 'corresponding-authority',
                corresponding_kind TEXT PATH 'corresponding-kind',
                legal_designated_states TEXT PATH 'legal-designated-states',
                extension_state_authority TEXT PATH 'extension-state-authority',
                new_owner TEXT PATH 'new-owner',
                free_text_description TEXT PATH 'free-text-description',
                spc_number TEXT PATH 'spc-number',
                filing_date TEXT PATH 'filing-date',
                expiry_date TEXT PATH 'expiry-date',
                inventor_names TEXT PATH 'inventor',
                ipc TEXT PATH 'ipc',
                payment_date TEXT PATH 'payment-date',
                fee_payment_year TEXT PATH 'opponent-name',
                requester_name TEXT PATH 'requester-name',
                 countries_concerned TEXT PATH 'countries-concerned',
                effective_date TEXT PATH 'effective-date',
                withdrawn_date TEXT PATH 'withdrawn-date'
              );


--3.1 Stored procedure , test or toy XML-parser which selects single element "priority claims"

CREATE OR REPLACE PROCEDURE lexis_nexis_bibliography_parser(input_xml XML)
LANGUAGE plpgsql
AS $$
BEGIN
SELECT xmltable.document_id,
       xmltable.bibliographic_language,
       xmltable.publication_type,
       xmltable.publication_decision,
       TO_DATE(xmltable.publication_date::TEXT, 'YYYYMMDD') AS publication_date,
       xmltable.publication_country,
       xmltable.application_id,
       xmltable.application_country,
       TO_DATE(xmltable.application_date::TEXT, 'YYYYMMDD') AS application_date,
       xmltable.language_of_filing,
       xmltable.language_of_publication,
       TO_DATE(xmltable.date_of_public_availability_changed::TEXT , 'YYYYMMDD') AS Date_of_public_availability,
       TO_DATE(xmltable.unexamined_printed_without_grant::TEXT, 'YYYYMMDD') AS Date_of_public_availability_without_grant,
       TO_DATE(xmltable.date_of_public_availability_with_grant::TEXT,'YYYYMMDD') AS date_of_public_availability_with_grant,
       TO_DATE(xmltable.publication_of_grant_date::TEXT, 'YYYYMMDD') AS date_of_grant_publication
FROM patent_legal_data, xmltable(
             '//lexisnexis-patent-document' PASSING patent_data COLUMNS
         document_id BIGINT PATH '//publication-reference/document-id/@id',
         bibliographic_language TEXT PATH '//bibliographic-data/@lang',
         publication_type TEXT PATH '//publication-reference/@publ-type',
         publication_decision TEXT PATH '//publication-reference/@publ-desc',
         publication_date BIGINT PATH '//publication-reference/document-id/date',
         publication_country TEXT PATH '//publication-reference/document-id/country',
         application_id BIGINT PATH '//application-reference/document-id/@id',
         application_country TEXT PATH '//application-reference/document-id/country',
         application_date BIGINT PATH '//application-reference/document-id/date',
         language_of_filing TEXT PATH '//language-of-filing',
         language_of_publication TEXT PATH '//language-of-publication',
         date_of_public_availability_changed BIGINT PATH '//dates-of-public-availability/@date-changed',
         unexamined_printed_without_grant BIGINT PATH '//dates-of-public-availability/unexamined-printed-without-grant/date',
         date_of_public_availability_with_grant BIGINT PATH '//dates-of-public-availability/printed-without-grant/date',
         publication_of_grant_date BIGINT PATH '//dates-of-public-availability/publication-of-grant-date/date'
         );
END;
$$;

CALL lexis_nexis_parse_selected()

--3.2 Stored procedure XML-parser abstract
CREATE OR REPLACE PROCEDURE lexis_nexis_abstract_parser(input_xml XML)
LANGUAGE plpgsql
AS $$
BEGIN
SELECT
       xmltable.document_id,
       xmltable.abstract_doc_id,
       xmltable.abstract_id,
       TO_DATE(xmltable.abstract_date_changed::TEXT, 'YYYYMMDD' ),
       xmltable.abstract_language,
       xmltable.abstract_paragraph
FROM patent_legal_data, xmltable(
    '//lexisnexis-patent-document' PASSING input_xml COLUMNS
            document_id BIGINT PATH '//publication-reference/document-id/@id',
            abstract_id  TEXT PATH '//abstract/@id',
            abstract_doc_id BIGINT PATH '//abstract/@doc-number',
            abstract_date_changed BIGINT PATH '//abstract/@date-changed',
            abstract_language TEXT PATH '//abstract/@lang',
            abstract_paragraph TEXT PATH '//abstract/p'
      );
END;
$$;


-- 3.3 Stored procedure XML-parser legal-data