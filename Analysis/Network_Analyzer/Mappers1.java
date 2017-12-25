import java.io.BufferedReader;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.IOException;
import java.util.*;

public class Mappers1 {

	MainDriver dirs = new MainDriver();
	
	


	// set of all publication based on wos_id in the network
	public HashSet<String> pub_SET(String refType) throws IOException {

		HashSet<String> out = new HashSet<String>();

		FileReader reader = new FileReader(dirs.getInputDir() + dirs.getDrugName() + "_citation_network.txt");
		BufferedReader br = new BufferedReader(reader);

		int ref_col = 0;
		int cited_ref_col = 0;

		if (refType.equals("pmid")) {
			ref_col = 0;
			cited_ref_col = 3;
		} else if (refType.equals("wos")) {
			ref_col = 1;
			cited_ref_col = 2;
		} else {

			System.out.println(" Reference Type must be either 'pmid' or 'wos' ");
			return null;
		}

		// Reading text line by line
		String ref_cited_ref = br.readLine();

		while (ref_cited_ref != null) {

			String[] ref_cited_ref_arr = ref_cited_ref.split("\t");

			if (!ref_cited_ref_arr[ref_col].equals("NA"))
				out.add(ref_cited_ref_arr[ref_col]);
			if (!ref_cited_ref_arr[cited_ref_col].equals("NA"))
				out.add(ref_cited_ref_arr[cited_ref_col]);

			ref_cited_ref = br.readLine();

		}

		reader.close();

		System.out.println("pub_size based on " + refType + " " + out.size() + "\n");
		//System.out.println(out);

		FileWriter stat_collector = new FileWriter(dirs.getFinalDir() + "/stat_collector.txt", true);
		stat_collector.write(dirs.getDrugName() + "_pub_size based on " + refType + " " + out.size() + "\n");
		stat_collector.close();

		return out;

	}

	public String format_auth(String auth) {

		if (auth.equals("NA"))
			return "";

		String auth_clean = auth.toUpperCase().replace(".", " ").trim();
		// System.out.println(auth_clean);
		String[] LastFirst = auth_clean.split(",");
		// System.out.println(Arrays.toString(LastFirst));
		String Last = LastFirst[0].trim();
		String FirstInitial = "";
		if (LastFirst.length > 1)
			FirstInitial = LastFirst[1].trim().substring(0, 1);

		// System.out.println(auth + "----->"+Last + " " + FirstInitial);

		return Last + " " + FirstInitial;
	}

	public HashMap<String, HashSet<String>> auth_pubSet_MAP(String refType) throws IOException {

		HashMap<String, HashSet<String>> out = new HashMap<String, HashSet<String>>();
        
		
		FileReader reader = new FileReader(dirs.getInputDir() + dirs.getDrugName() + "_citation_network_authors.txt");
		BufferedReader br = new BufferedReader(reader);
		FileWriter stat_collector = new FileWriter(dirs.getFinalDir() + "/stat_collector.txt", true);

		int columnSelector = 0;

		if (refType.equals("pmid")) {
			columnSelector = 0;
		} else if (refType.equals("wos")) {
			columnSelector = 1;
		} else {

			System.out.println(" Reference Type must be either 'pmid' or 'wos' ");
			return null;
		}

		// Reading text line by line
		String header = br.readLine();

		String auth_ref = br.readLine();

		while (auth_ref != null) {

			String[] auth_ref_arr = auth_ref.split("\t");
			String ref_column = auth_ref_arr[columnSelector];
			String raw_auth = auth_ref_arr[2];
			String formated_auth = "";
			if (!raw_auth.equals("NA") && !ref_column.equals("NA")) {

				try {
					formated_auth = format_auth(raw_auth);
				} catch (Exception e) {
					System.out.print("ILL FORMAT FOR AUTHOR DATA DETECTED" + auth_ref);
					stat_collector.write("ILL FORMAT FOR AUTHOR DATA DETECTED AT --> " + auth_ref);

					break;
				}

				if (out.containsKey(formated_auth)) {
					out.get(formated_auth).add(ref_column);
				} else {
					HashSet<String> tempset = new HashSet<String>();
					tempset.add(ref_column);
					out.put(formated_auth, tempset);
				}

			}

			auth_ref = br.readLine();

		}

		reader.close();

		System.out.println("auth_size based on " + refType + ": " + out.size() + "\n");
		//System.out.println(out);

		stat_collector.write(dirs.getDrugName() + "_auth_size based on " + refType + ": " + out.size() + "\n");
		stat_collector.close();

		return out;

	}

	// set of <citedPub, citingPubSet>
	public HashMap<String, HashSet<String>> pub_citingPubSET_MAP(String refType) throws IOException {

		HashMap<String, HashSet<String>> out = new HashMap<String, HashSet<String>>();

		FileReader reader = new FileReader(dirs.getInputDir() + dirs.getDrugName() + "_citation_network.txt");
		BufferedReader br = new BufferedReader(reader);
		FileWriter stat_collector = new FileWriter(dirs.getFinalDir() + "/stat_collector.txt", true);

		int ref_col = 0;
		int cited_ref_col = 0;

		if (refType.equals("pmid")) {
			ref_col = 0;
			cited_ref_col = 3;
		} else if (refType.equals("wos")) {
			ref_col = 1;
			cited_ref_col = 2;
		} else {

			System.out.println(" Reference Type must be either 'pmid' or 'wos' ");
			return null;
		}
		
		String header = br.readLine();

		String ref_cited_ref  = br.readLine();

		while (ref_cited_ref != null) {
			String[] ref_cited_ref_arr = ref_cited_ref.split("\t");
			String ref = ref_cited_ref_arr[ref_col];
			String cited_ref = ref_cited_ref_arr[cited_ref_col];


			if (!ref.equals("NA")&& !cited_ref.equals("NA")){
				if(!out.containsKey(cited_ref)){
					HashSet<String> tempSet = new HashSet<>();
					tempSet.add(ref);
					out.put(cited_ref, tempSet);
				
				}else {
					out.get(cited_ref).add(ref);
				}
				
				
			}
			

			ref_cited_ref = br.readLine();

		}

		reader.close();

		System.out.println("citedPub_citingPubSET_MAP based on " + refType + ": " + out.size() + "\n");
	//	System.out.println(out);

		stat_collector.write(dirs.getDrugName() + "_citedPub_citingPubSET_MAP size based on " + refType + ": " + out.size() + "\n");
		stat_collector.close();


		return out;

	}
    // <citingPub, CitedPubSet>
	public HashMap<String, HashSet<String>> pub_citedPubSET_MAP(String refType) throws IOException {

		HashMap<String, HashSet<String>> out = new HashMap<String, HashSet<String>>();

		FileReader reader = new FileReader(dirs.getInputDir() + dirs.getDrugName() + "_citation_network.txt");
		BufferedReader br = new BufferedReader(reader);
		FileWriter stat_collector = new FileWriter(dirs.getFinalDir() + "/stat_collector.txt", true);

		int ref_col = 0;
		int cited_ref_col = 0;

		if (refType.equals("pmid")) {
			ref_col = 0;
			cited_ref_col = 3;
		} else if (refType.equals("wos")) {
			ref_col = 1;
			cited_ref_col = 2;
		} else {

			System.out.println(" Reference Type must be either 'pmid' or 'wos' ");
			return null;
		}
		
		String header = br.readLine();

		String ref_cited_ref  = br.readLine();

		while (ref_cited_ref != null) {
			String[] ref_cited_ref_arr = ref_cited_ref.split("\t");
			String ref = ref_cited_ref_arr[ref_col];
			String cited_ref = ref_cited_ref_arr[cited_ref_col];


			if (!ref.equals("NA")&& !cited_ref.equals("NA")){
				if(!out.containsKey(ref)){
					HashSet<String> tempSet = new HashSet<>();
					tempSet.add(cited_ref);
					out.put(ref, tempSet);
				
				}else {
					out.get(ref).add(cited_ref);
				}
				
				
			}
			

			ref_cited_ref = br.readLine();

		}

		reader.close();

		System.out.println("pub_citedPubSET_MAP based on " + refType + ": " + out.size() + "\n");
		//System.out.println(out);

		stat_collector.write(dirs.getDrugName() + "_citingPub_citedPubSET_MAP size based on " + refType + ": " + out.size() + "\n");
		stat_collector.close();


		return out;

	}

	
	
	
	
	
	
	public static void main(String[] args) throws IOException {

		Mappers1 mappers = new Mappers1();

		// mappers.pub_SET("wos");
		//mappers.pub_SET("woss");

		mappers.auth_pubSet_MAP("wos");
		mappers.pub_citingPubSET_MAP("pmid");
		mappers.pub_citedPubSET_MAP("pmid");

		 mappers.auth_pubSet_MAP("pmid");

		// String[] auth = {"ELLIOTT, RB","NAKAMURA, H", "Passos-Bueno,
		// MR","Widdowson, PS","NA","MacDonald, M. L."};
		// for(String str: auth)
		// mappers.format_auth(str);

	}

}
