SET search_path TO public;

-- generated original trunk table containing wos_id and pmid
DROP TABLE IF EXISTS ipsc_stem_cell_union;
CREATE TABLE public.ipsc_stem_cell_union AS
SELECT * FROM ipsc_gladstone_trunk_acccept;
-- SELECT * FROM ipsc
-- UNION
-- SELECT * FROM stem_cell;

ALTER TABLE ipsc_stem_cell_union ADD COLUMN pmid INTEGER;
UPDATE ipsc_stem_cell_union SET pmid = t.pmid_int
FROM  wos_pmid_mapping t
WHERE ipsc_stem_cell_union.wos_id=t.wos_id;

-- Get reference list for each publication
DROP TABLE IF EXISTS ipsc_stem_cell_cited;
CREATE TABLE public.ipsc_stem_cell_cited AS
SELECT source_id, cited_source_uid
FROM wos_references
WHERE source_id IN (SELECT wos_id FROM ipsc_stem_cell_union)
AND substring(cited_source_uid,1,4)='WOS:'
AND length(cited_source_uid)=19;

-- Get the publications which cited ipsc papers
DROP TABLE IF EXISTS ipsc_stem_cell_citing;
CREATE TABLE public.ipsc_stem_cell_citing AS
SELECT source_id, cited_source_uid
FROM wos_references
WHERE cited_source_uid IN (SELECT wos_id FROM ipsc_stem_cell_union);

-- Added gladstone cited publication year
DROP TABLE IF EXISTS ipsc_stem_cited_info;
CREATE TABLE public.ipsc_stem_cited_info AS
SELECT t.*, p2.publication_year AS reference_year FROM 
(SELECT a.source_id, p1.publication_year AS source_year, a.cited_source_uid
FROM ipsc_stem_cell_cited a
INNER JOIN wos_publications p1
ON a.source_id = p1.source_id) AS t
INNER JOIN wos_publications p2
ON t.cited_source_uid = p2.source_id;

-- Added gladstone citing publication year
DROP TABLE IF EXISTS ipsc_stem_citing_info;
CREATE TABLE public.ipsc_stem_citing_info AS
SELECT t.*, p2.publication_year AS reference_year FROM 
(SELECT a.source_id, p1.publication_year AS source_year, a.cited_source_uid
FROM ipsc_stem_cell_citing a
INNER JOIN wos_publications p1
ON a.source_id = p1.source_id) AS t
INNER JOIN wos_publications p2
ON t.cited_source_uid = p2.source_id;

-- generated table contains all source_id as well as publication year
DROP TABLE IF EXISTS ipsc_stem_data;
CREATE TABLE public.ipsc_stem_data AS
SELECT * FROM ipsc_stem_cited_info
UNION
SELECT * FROM ipsc_stem_citing_info;

-- generated cited/citing status table
DROP TABLE IF EXISTS ipsc_stem_citation_status;
CREATE TABLE public.ipsc_stem_citation_status AS
SELECT source_id, 
	CASE WHEN source_id IN (SELECT cited_source_uid FROM ipsc_stem_data) THEN 'both'
	ELSE 'cites' 
	END AS source_status, cited_source_uid,
	CASE WHEN cited_source_uid IN (SELECT source_id FROM ipsc_stem_data) THEN 'both'
	ELSE 'is-cited' 
	END AS cited_source_status
FROM ipsc_stem_data;

-- combined all cited and citing publications together
DROP TABLE IF EXISTS ipsc_stem_temp;
CREATE TABLE public.ipsc_stem_temp AS
SELECT DISTINCT source_id, source_year FROM ipsc_stem_data
UNION
SELECT DISTINCT cited_source_uid, reference_year FROM ipsc_stem_data;

-- assembled citing references for source_ids in ipsc_stem_temp
DROP TABLE IF EXISTS ipsc_temp1;
CREATE TABLE public.ipsc_temp1 AS
SELECT a.source_id,a.source_year,t.citing_pub_id FROM ipsc_stem_temp as a
INNER JOIN
(SELECT cited_source_uid AS source_id,source_id AS citing_pub_id 
FROM wos_references 
WHERE cited_source_uid IN (SELECT DISTINCT source_id FROM ipsc_stem_temp)) AS t
ON a.source_id=t.source_id;

-- restrict citing references to 10 years max
DROP TABLE IF EXISTS ipsc_cit_counts_temp2;
CREATE TABLE public.ipsc_cit_counts_temp2 AS
SELECT a.*,b.publication_year 
FROM ipsc_temp1 a 
INNER JOIN wos_publications b
ON a.citing_pub_id=b.source_id
WHERE b.publication_year::int <= a.source_year::int+10;

-- convert to count of citing references 
DROP TABLE IF EXISTS ipsc_cit_counts_temp3;
CREATE TABLE public.ipsc_cit_counts_temp3 AS
SELECT a.source_id,a.source_year,t.ten_year_citation_count 
FROM ipsc_stem_temp a
LEFT JOIN
(SELECT source_id,count(citing_pub_id) AS ten_year_citation_count
FROM ipsc_cit_counts_temp2
GROUP BY source_id) AS t
ON a.source_id=t.source_id;

--total citation count
DROP TABLE IF EXISTS ipsc_stem_cit_counts;
CREATE TABLE public.ipsc_stem_cit_counts AS
SELECT a.source_id,a.source_year,a.ten_year_citation_count,t.total_citation_count
FROM ipsc_cit_counts_temp3 AS a
LEFT JOIN
(SELECT source_id,count(citing_pub_id) AS total_citation_count
FROM ipsc_temp1
GROUP BY source_id) AS t
ON a.source_id=t.source_id;

--Add gladstone identifier
DROP TABLE IF EXISTS gladstone_temp;
CREATE TABLE public.gladstone_temp AS 
SELECT wos_id 
FROM wos_pmid_mapping
WHERE pmid_int IN ('18329615', '21573063', '25359725', '27869805', '25723173', '9368045', '24759836', '26611337', '19578358', '21806510', '8146186', '25658371', '26931567', '26755828', '23704215', '23873212', '20660939', '12939405', '3283935', '8675665', '23663735', '10052353', '26390242', '25261995', '24255017', '25173806', '17350266', '12091904', '23217737', '2475506', '10400700', '11739732', '14966563', '11309627', '21841793', '27476965', '18036213', '23993230', '11120757', '20537952', '17015424', '20234092', '9366570', '28969617', '8662599', '17548355', '15014128', '21385766', '22297435', '28991257', '27794120', '3115992', '18651794', '11264989', '27376554', '2280190', '21086759', '8749004', '11285236', '20531185', '10747846', '24529372', '23340407', '15187146', '11438742', '24356306', '28069809', '24319659', '20621048', '25401692', '10995233', '28157494', '28028237', '9852051', '10366621', '16990131', '28099927', '9811751', '24454758', '23832846', '20479936', '23364791', '12151402', '12837845', '23457256', '19620969', '21957233', '18463254', '12004268', '24509632', '27135800', '12551940', '24153302', '26743035', '8692825', '25031394', '18454868', '22955733', '22075116', '10064308', '24658141', '16820298', '17369396', '25053359', '2090718', '20558827', '9540409', '22424230', '21989055', '16357195', '23300939', '25723172', '18220516', '22992950', '28844864', '23079999', '23050819', '28538176', '24207025', '28400398', '28003464', '23658642', '12650773', '21454574', '11792702', '28453285', '23458259', '11120836', '21246655', '27174096', '10781088', '18948255', '9724804', '29140109', '16467548', '15955828', '25768904', '19243222', '21185281', '26611210', '27829687', '25254338', '21113149', '27524294', '15738408', '22120493', '7592957', '26883003', '21368138', '26435754', '25803368', '20615470', '18931664', '19325160', '19066459', '24268663', '10799751', '26942852', '28350385', '20634564', '17395645', '25342770', '26888940', '25677518', '9649758', '28596174', '25434822', '24719334', '24481841', '26140600', '22902903', '7649988', '20150184', '15118099', '21118811', '17478722', '27610565', '24268575', '27100611', '9869652', '23722259', '24903562', '26597546', '1730641', '20335651', '27133794', '28438991', '27335261', '9732872', '2266136', '8702576', '26416678', '26340528', '8624076', '26198166', '21555069', '15514167', '9593678', '24095276', '9026532', '28855509', '27903584', '3360782', '15693941', '16890957', '26353940', '17615060', '26799652', '17694089', '18292808', '26056265', '16432152', '28128224', '21878639', '9671739', '25834424', '26519649', '1993701', '8940294', '27161522', '27773581', '26004781', '10225972', '26845514', '29079806', '22959962', '14662765', '27235396', '26417073', '11121396', '23524853', '23517573', '2056122', '10644716', '26693916', '26329395', '18694566', '25254341', '16687490', '21918466', '15331720', '27984724', '21825130', '26733021', '19936228', '26971820', '19396158', '25097266', '22158868', '29103756', '9502759', '26875865', '22267199', '23459227', '26443632', '19727199', '26151913', '17364026', '27574825', '25766620', '16982417', '10431657', '21040845', '8496659', '24398962', '17360323', '23041626', '21383058', '19217425', '23064634', '27738243', '16076841', '1527480', '15703014', '12097565', '10746713', '25748532', '25126862', '16288910', '23715551', '27608814', '16810246', '9665054', '16908728', '23103766', '22792368', '9202070', '28246214', '26851367', '26618884', '28972160', '12433685', '21242889', '12616479', '20685997', '20833817', '23013167', '23862100', '27840107', '29103804', '8376602', '25461450', '17397913', '26042385', '8081360', '19106071', '20200944', '22682241', '2493483', '21304516', '26671725', '23830865', '14625273', '11466315', '27089971', '24843033', '11157067', '10827131', '9023367', '11399759', '11385509', '19126861', '23520160', '28170190', '18212126', '19571141', '12235369', '10079097', '19951691', '20943911', '9419379', '21497762', '28577903', '7878058', '22341232', '28494238', '19695258', '27978432', '24319660', '27127239', '21398603', '9486979', '18631967', '26514199', '22492035', '26441525', '27363581', '16567625', '17785667', '25871831', '15210650', '26454285', '7667315', '26172574', '27077116', '28965974', '28966121', '8154371', '17485678', '28257933', '27594585', '18596956', '2498325', '25201951', '26134312', '25887984', '19004786', '29158493', '12753745', '24572354', '12847229', '23332171', '18288184', '28373686', '24813856', '26407033', '26095427', '26322868', '15890642', '20581818', '19893621', '26932671', '15096455', '20498046', '19951690', '18338032', '23932127', '22037470', '21325400', '29045398', '21060874', '9555937', '15054100', '15483602', '10713055', '7759884', '25193333', '20829454', '16687403', '26109656', '9502790', '22683203', '25744738', '8071364', '20140609', '19874264', '19889533', '22488956', '11447277', '25623957', '18371447', '26000445', '12486146', '16183991', '17668043', '25385348', '10085069', '28826372', '24413397', '20427645', '28591615', '26846636', '26657143', '28099842', '9637699', '25100527', '14668353', '23420199', '27626494', '26658353', '26949256', '22656305', '25156517', '29358044', '17002223', '17854912', '17683935', '18165355', '27530160', '18039113', '8040342', '24561253', '14662331', '11553788', '25218470', '11751977', '1730728', '10818140', '25856492', '26350501', '15181247', '27768780', '25801505', '15707483', '28017796', '27905063', '21876670', '8289813', '20702085', '22372374', '24572792', '9177182', '26968984', '23993229', '21071677', '20071528', '22522929', '22869752', '2120218', '3360781', '27832532', '19666463', '11756158', '23371904', '28869587', '27328768', '25730278', '28296613', '23085412', '23086951', '22037947', '25313376', '25858064', '21098571', '23223453', '28877458', '9824535', '8171342', '22704507', '16284535', '27618650', '3680528', '28427989', '24526674', '24974230', '18256266', '8254057', '26864234', '20362537', '25825768', '27216776', '28525758', '28279024', '24252873', '20692205', '27467777', '27531948', '16291938', '20227666', '22541439', '20203611', '22100159', '19124026', '10553000', '14662332', '24296783', '21052079', '24239284', '26520122', '25772473', '19394789', '27805061', '17600280', '21375737', '21787325', '18054394', '24074592', '24506886', '14607901', '21228179', '25813539', '27030102', '28800289', '23187627', '10837497', '26812940', '26395139', '28467928', '2341386', '25695512', '26785480', '20691899', '14585838', '11135619', '27980341', '27095412', '25319703', '22762015', '23793227', '24372513', '24218637', '24403142', '17643313', '8943057', '25549891', '25274305', '17240175', '26502054', '22991174', '17080192', '22770243', '18852265', '26299474', '16344479', '28481362', '17785178', '25333967', '15719057', '24399248', '17576928', '28377227', '8631787', '27834668', '29198827', '20869586');

Alter TABLE ipsc_stem_cit_counts ADD COLUMN gladstone int;
Alter TABLE ipsc_stem_cit_counts ADD COLUMN trunk int;
UPDATE ipsc_stem_cit_counts
SET gladstone = (CASE WHEN source_id IN (SELECT * FROM gladstone_temp) THEN 1
					ELSE 0
					END);

UPDATE ipsc_stem_cit_counts
SET trunk = (CASE WHEN source_id IN (SELECT wos_id FROM ipsc_stem_cell_union) THEN 1
				ELSE 0
				END);

UPDATE ipsc_stem_cit_counts SET total_citation_count = 0 WHERE total_citation_count IS NULL;
UPDATE ipsc_stem_cit_counts SET ten_year_citation_count = 0 WHERE ten_year_citation_count IS NULL;

--cleanup
DROP TABLE ipsc_stem_temp;
DROP TABLE ipsc_temp1;
DROP TABLE ipsc_cit_counts_temp2;
DROP TABLE ipsc_cit_counts_temp3;
