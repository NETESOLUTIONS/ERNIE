import java.io.BufferedReader;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.IOException;
import java.text.DecimalFormat;
import java.util.*;

public class AuthorScores {

	MainDriver dirs = new MainDriver();

	
	
	public static void test(){
		System.out.println("TESET");
	}

	public HashMap<String, Integer> author_totalCitation(String refType) throws IOException {
		HashMap<String, Integer> out = new HashMap<String, Integer>();

		Mappers mappers = new Mappers();
		PaperScores paperscores = new PaperScores();
		HashMap<String, HashSet<String>> auth_pubSet_MAP = mappers.auth_pubSet_MAP(refType);
		HashMap<String, Integer> pub_citation = paperscores.pub_citation_MAP(refType);

		for (String auth : auth_pubSet_MAP.keySet()) {

			int sum = 0;

			for (String pub : auth_pubSet_MAP.get(auth)) {
				sum += pub_citation.get(pub);
			}

			out.put(auth, sum);

		}
		
		return out;
	}

	public HashMap<String, Integer> author_PIR(String refType) throws IOException {

		HashMap<String, Integer> out = new HashMap<String, Integer>();

		Mappers mappers = new Mappers();
		PaperScores paperscores = new PaperScores();

		HashMap<String, HashSet<String>> auth_pubSet_MAP = mappers.auth_pubSet_MAP(refType);
		HashMap<String, Integer> pub_weighted_citation = paperscores.pub_WeigtedCitation_MAP(refType);

		for (String auth : auth_pubSet_MAP.keySet()) {

			int sum = 0;

			for (String pub : auth_pubSet_MAP.get(auth)) {
				sum += pub_weighted_citation.get(pub);
			}

			out.put(auth, sum);

		}

		return out;
	}

	public HashMap<String, Integer> author_inDegree(String refType) throws IOException {

		HashMap<String, Integer> out = new HashMap<String, Integer>();

		Mappers mappers = new Mappers();

		HashMap<String, HashSet<String>> auth_pubSet_MAP = mappers.auth_pubSet_MAP(refType);

		for (String auth : auth_pubSet_MAP.keySet()) {

			out.put(auth, auth_pubSet_MAP.get(auth).size());

		}

		return out;
	}

	public void auth_Scores(String refType) throws IOException {

		Mappers mappers = new Mappers();
		System.out.println("A************");

		HashMap<String, HashSet<String>> auth_pubSet_MAP = mappers.auth_pubSet_MAP(refType);
		System.out.println("B************");

		HashMap<String, Integer> author_inDegree = author_inDegree(refType);
		System.out.println("C************");

		HashMap<String, Integer> author_totalCitation = author_totalCitation(refType);
		System.out.println("D************");

		HashMap<String, Integer> author_PIR = author_PIR(refType);

		System.out.println("E*************");

		System.out.println(auth_pubSet_MAP.keySet().size());

		float max_indeg = 0;
		float max_totCit = 0;
		float max_pir = 0;

		for (String auth : author_inDegree.keySet()) {
			max_indeg = (max_indeg > author_inDegree.get(auth)) ? max_indeg : author_inDegree.get(auth);

		}
		for (String auth : author_totalCitation.keySet()) {
			max_totCit = (max_totCit > author_totalCitation.get(auth)) ? max_totCit : author_totalCitation.get(auth);

		}

		for (String auth : author_PIR.keySet()) {
			max_pir = (max_pir > author_PIR.get(auth)) ? max_pir : author_PIR.get(auth);

		}

		System.out.println(dirs.getFinalDir());

		FileWriter writer = new FileWriter(dirs.getFinalDir() + "/author_scores_" + refType + ".csv");
		writer.write("author,inDegree,indegree_scaled,totalCitation,totalCitation_scaled,PIR,PIR_scaled\n");

		DecimalFormat df = new DecimalFormat("#.#########");

		System.out.println(auth_pubSet_MAP.keySet().size());

		for (String auth : auth_pubSet_MAP.keySet()) {

			int indeg = author_inDegree.get(auth);
			int totCit = author_totalCitation.get(auth);
			int pir = author_PIR.get(auth);

			String indeg_scaled = df.format(indeg / max_indeg);
			String totCit_scaled = df.format(totCit / max_totCit);
			String pir_scaled = df.format(pir / max_pir);

			writer.write(auth + "," + indeg + "," + indeg_scaled + "," + totCit + "," + totCit_scaled + "," + pir + ","
					+ pir_scaled + "\n");
			System.out.println(auth + "," + indeg + "," + indeg_scaled + "," + totCit + "," + totCit_scaled);

		}
		
		
		
		

		writer.close();
		
		//  call stat collector

		System.out.println("stat collector is called: ");
		mappers.wos_pmid_mapping_stat();

	}
	
	// Make this tree set and run it from there. 
	public  void final_stat_collector() throws IOException{
		
		TreeSet<String> dupChecker = new TreeSet<String>();
		FileReader readstat = new FileReader(dirs.getFinalDir() + "stat_collector.txt");
		BufferedReader statReader = new BufferedReader(readstat); 
		
		FileWriter final_stat_collector = new FileWriter(dirs.getFinalDir() + "/final_stat_collector.txt");
		
		String stats = statReader.readLine();
		while(stats !=null ){
		
			
				dupChecker.add(stats);
			
				stats = statReader.readLine();
		}
		
		int formatter = 0;
		for (String s: dupChecker){
			    if (++formatter%2 ==0) final_stat_collector.write("\n");
				final_stat_collector.write(s+"\n");
		}
		final_stat_collector.close();
		statReader.close();
		readstat.close();
		
		
	}

	public static void main(String[] args) throws IOException {

		

		AuthorScores authorscores = new AuthorScores();
		 authorscores.auth_Scores("wos");
		 

		//System.out.println(authorscores.author_totalCitation("wos"));
        
		//test();
		
		
		
		// Mappers mappers = new Mappers();
		// mappers.auth_pubSet_MAP("wos");

	}

}
