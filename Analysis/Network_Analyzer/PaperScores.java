
import java.io.BufferedReader;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.IOException;
import java.text.DecimalFormat;
import java.util.*;

public class PaperScores {
	
	MainDriver dirs = new MainDriver();

	// publication citation, if no citation then it is by default 0.
	public HashMap<String, Integer> pub_citation_MAP(String refType) throws IOException {

		HashMap<String, Integer> out = new HashMap<String, Integer>();
		Mappers mappers = new Mappers();
		HashMap<String, HashSet<String>> pub_citingPubSet_Map = mappers.pub_citingPubSET_MAP(refType);
		HashSet<String> pubSet = mappers.pub_SET(refType);
		int max_citation = 0;

		for (String pub : pubSet) {
			if (pub_citingPubSet_Map.containsKey(pub)) {
				int cit = pub_citingPubSet_Map.get(pub).size();
				max_citation = (max_citation > cit) ? max_citation : cit;
				out.put(pub, cit);
			} else {
				out.put(pub, 0);
			}

		}

		System.out.println();
		System.out.println(out.size() + " " + pub_citingPubSet_Map.size() + " " + pubSet.size());
		System.out.println(dirs.getDrugName() + "max_citation based on " + refType + ": " + max_citation + "\n");

		FileWriter stat_collector = new FileWriter(dirs.getFinalDir() + "/stat_collector.txt", true);
		stat_collector.write(dirs.getDrugName() + "_max_citation based on " + refType + ": " + max_citation + "\n");
		stat_collector.close();

		return out;

	}

	public HashMap<String, Integer> pub_WeigtedCitation_MAP(String refType) throws IOException {

		HashMap<String, Integer> out = new HashMap<String, Integer>();
		Mappers mappers = new Mappers();
		HashMap<String, HashSet<String>> pub_citingPubSet_Map = mappers.pub_citingPubSET_MAP(refType);
		HashMap<String, Integer> pub_citation_map = pub_citation_MAP(refType);
		int max_weightedcitation = 0;

		for (String pub : pub_citation_map.keySet()) {

			int sum = pub_citation_map.get(pub);
			if (pub_citingPubSet_Map.containsKey(pub)) {
				for (String citingPub : pub_citingPubSet_Map.get(pub)) {
					sum += pub_citation_map.get(citingPub);
				}

			}

			max_weightedcitation = (max_weightedcitation > sum) ? max_weightedcitation : sum;
			out.put(pub, sum);

		}

		FileWriter stat_collector = new FileWriter(dirs.getFinalDir() + "/stat_collector.txt", true);
		stat_collector
				.write(dirs.getDrugName() + "_max_weightedCitation based on " + refType + ": " + max_weightedcitation + "\n");
		stat_collector.close();

		return out;

	}

	// i.e citation
	public HashMap<String, Integer> pub_indegreeCount_MAP(String refType) throws IOException {

		return pub_citation_MAP(refType);

	}

	public HashMap<String, Integer> pub_outdegreeCount_MAP(String refType) throws IOException {
		HashMap<String, Integer> out = new HashMap<String, Integer>();
		Mappers mappers = new Mappers();
		HashMap<String, HashSet<String>> pub_citedPubSet_Map = mappers.pub_citedPubSET_MAP(refType);
		HashSet<String> pubSet = mappers.pub_SET(refType);
		int max_outdegree = 0;

		for (String pub : pubSet) {
			if (pub_citedPubSet_Map.containsKey(pub)) {
				int cit = pub_citedPubSet_Map.get(pub).size();
				max_outdegree = (max_outdegree > cit) ? max_outdegree : cit;
				out.put(pub, cit);
			} else {
				out.put(pub, 0);
			}

		}

		FileWriter stat_collector = new FileWriter(dirs.getFinalDir() + "/stat_collector.txt", true);
		stat_collector.write(dirs.getDrugName() + "_max_outdegree_count based on " + refType + ": " + max_outdegree + "\n");
		stat_collector.close();

		return out;

	}

	public void pub_scores(String refType) throws IOException {
		Mappers mappers = new Mappers();

		HashSet<String> pub_SET = mappers.pub_SET(refType);
		HashMap<String,String> pub_year_MAP = mappers.pub_pubYear_MAP(refType);
		HashMap<String, Integer> pub_citation_MAP = pub_citation_MAP(refType);
		HashMap<String, Integer> pub_WeigtedCitation_MAP = pub_WeigtedCitation_MAP(refType);
		HashMap<String, Integer> pub_outdegreeCount_MAP = pub_outdegreeCount_MAP(refType);

		FileWriter writer = new FileWriter(dirs.getFinalDir() + "/publication_scores_" + refType + ".csv");
		writer.write(
				"publication,pub_year,citation,citation_scaled,weightedCit,weightedCit_scaled,outDegree,OutDegree_scaled\n");

		float max_cit = 0;
		float max_wcit = 0;
		float max_outdeg = 0;
		String pub_year = "NA";
		

		for (String pub : pub_citation_MAP.keySet()) {
			max_cit = (max_cit > pub_citation_MAP.get(pub)) ? max_cit : pub_citation_MAP.get(pub);
		}
		for (String pub : pub_WeigtedCitation_MAP.keySet()) {
			max_wcit = (max_wcit > pub_WeigtedCitation_MAP.get(pub)) ? max_wcit : pub_WeigtedCitation_MAP.get(pub);
		}
		for (String pub : pub_outdegreeCount_MAP.keySet()) {
			max_outdeg = (max_outdeg > pub_outdegreeCount_MAP.get(pub)) ? max_outdeg : pub_outdegreeCount_MAP.get(pub);
		}

		//System.out.println(pub_citation_MAP.size());
		//System.out.println(pub_WeigtedCitation_MAP.size());
		//System.out.println(pub_outdegreeCount_MAP.size());
		//System.out.println(pub_SET.size());

		DecimalFormat df = new DecimalFormat("#.#########");
		for (String pub : pub_SET) {
			
			pub_year = "NA";
			if (pub_year_MAP.containsKey(pub)){
				pub_year = pub_year_MAP.get(pub);
			}
			
			int cit = pub_citation_MAP.get(pub);
			String cit_scaled = df.format(cit / max_cit);

			int wcit = pub_WeigtedCitation_MAP.get(pub);
			String wcit_scaled = df.format(wcit / max_wcit);
			//System.out.println((wcit_scaled*1000000000)/1000000000);

			int outdeg = pub_outdegreeCount_MAP.get(pub);
			String outdeg_scaled = df.format(outdeg / max_outdeg);

			writer.write(pub + "," + pub_year+ "," + cit + "," + cit_scaled + "," + wcit + "," + wcit_scaled + ","
					+ outdeg + "," + outdeg_scaled + "\n");

		}
		writer.close();

	}
	
	
	

	public static void main(String[] args) throws IOException {

		PaperScores paperscores = new PaperScores();

		 paperscores.pub_WeigtedCitation_MAP("wos");
		 paperscores.pub_scores("wos");

	}

}
