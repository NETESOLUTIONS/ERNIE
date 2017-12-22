import java.io.BufferedReader;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.IOException;
import java.util.*;

public class Mappers {

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

		String header_ref_cited_ref = br.readLine();

		// Reading text line by line
		String ref_cited_ref = br.readLine();

		int edge_count = 0;
		while (ref_cited_ref != null) {

			String[] ref_cited_ref_arr = ref_cited_ref.split("\t");

			if (!ref_cited_ref_arr[ref_col].equals("NA"))
				out.add(ref_cited_ref_arr[ref_col]);
			if (!ref_cited_ref_arr[cited_ref_col].equals("NA"))
				out.add(ref_cited_ref_arr[cited_ref_col]);

			if (!ref_cited_ref_arr[ref_col].equals("NA") && !ref_cited_ref_arr[cited_ref_col].equals("NA")) {
				++edge_count;
			}

			ref_cited_ref = br.readLine();

		}

		reader.close();

		System.out.println("pub_size based on " + refType + " " + out.size() + "\n");
		// System.out.println(out);

		FileWriter stat_collector = new FileWriter(dirs.getFinalDir() + "/stat_collector.txt", true);
		stat_collector.write(dirs.getDrugName() + "_pub_size based on " + refType + " " + out.size() + "\n");
		stat_collector.write(dirs.getDrugName() + "_network_edge_count based on " + refType + " " + edge_count + "\n");

		stat_collector.close();

		return out;

	}

	
	public HashMap<String, String> pub_pubYear_MAP(String refType) throws IOException {

		HashMap<String, String> out = new HashMap<String, String>();

		FileReader reader = new FileReader(dirs.getInputDir() + dirs.getDrugName() + "_citation_network_years.txt");
		BufferedReader br = new BufferedReader(reader);

		int ref_col = 0;
		int year_col = 2; 

		if (refType.equals("pmid")) {
			ref_col = 0;
		} else if (refType.equals("wos")) {
			ref_col = 1;
		} else {

			System.out.println(" Reference Type must be either 'pmid' or 'wos' ");
			return null;
		}

		String header_pub_year_data  = br.readLine();

		// Reading text line by line
		String pub_year_data  = br.readLine();

		while (pub_year_data != null) {

			String[] pub_year_data_arr  = pub_year_data.split("\t");

			if (!pub_year_data_arr[ref_col].equals("NA") && !pub_year_data_arr[year_col].equals("NA"))
				out.put(pub_year_data_arr[ref_col], pub_year_data_arr[year_col]);
			

			pub_year_data = br.readLine();

		}

		reader.close();

		System.out.println("pub_size_year based on " + refType + " " + out.size() + "\n");
		// System.out.println(out);

		FileWriter stat_collector = new FileWriter(dirs.getFinalDir() + "/stat_collector.txt", true);
		stat_collector.write(dirs.getDrugName() + "_pub_size with year based on " + refType + " " + out.size() + "\n");

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
		// System.out.println(out);

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

		String ref_cited_ref = br.readLine();

		while (ref_cited_ref != null) {
			String[] ref_cited_ref_arr = ref_cited_ref.split("\t");
			String ref = ref_cited_ref_arr[ref_col];
			String cited_ref = ref_cited_ref_arr[cited_ref_col];

			if (!ref.equals("NA") && !cited_ref.equals("NA")) {
				if (!out.containsKey(cited_ref)) {
					HashSet<String> tempSet = new HashSet<>();
					tempSet.add(ref);
					out.put(cited_ref, tempSet);

				} else {
					out.get(cited_ref).add(ref);
				}

			}

			ref_cited_ref = br.readLine();

		}

		reader.close();

		System.out.println("citedPub_citingPubSET_MAP based on " + refType + ": " + out.size() + "\n");
		// System.out.println(out);

		// stat_collector.write(
		// dirs.getDrugName() + "_citedPub_citingPubSET_MAP size based on " +
		// refType + ": " + out.size() + "\n");
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

		String ref_cited_ref = br.readLine();

		while (ref_cited_ref != null) {
			String[] ref_cited_ref_arr = ref_cited_ref.split("\t");
			String ref = ref_cited_ref_arr[ref_col];
			String cited_ref = ref_cited_ref_arr[cited_ref_col];

			if (!ref.equals("NA") && !cited_ref.equals("NA")) {
				if (!out.containsKey(ref)) {
					HashSet<String> tempSet = new HashSet<>();
					tempSet.add(cited_ref);
					out.put(ref, tempSet);

				} else {
					out.get(ref).add(cited_ref);
				}

			}

			ref_cited_ref = br.readLine();

		}

		reader.close();

		System.out.println("pub_citedPubSET_MAP based on " + refType + ": " + out.size() + "\n");
		// System.out.println(out);

		stat_collector.write(
				dirs.getDrugName() + "_citingPub_citedPubSET_MAP size based on " + refType + ": " + out.size() + "\n");
		stat_collector.close();

		return out;

	}

	public void wos_pmid_mapping_stat() throws IOException {

		HashMap<String, String> wos_type = new HashMap<String, String>();
		HashMap<String, String> pmid_type = new HashMap<String, String>();
		List<HashMap<String, String>> pub_types = new ArrayList<HashMap<String, String>>();

		FileReader reader = new FileReader(dirs.getInputDir() + dirs.getDrugName() + "_generational_references.txt");

		BufferedReader br = new BufferedReader(reader);

		HashSet<String> wos_gen1_set = new HashSet<String>();
		HashSet<String> wos_gen2_set = new HashSet<String>();

		HashSet<String> pmid_gen1_set = new HashSet<String>();
		HashSet<String> pmid_gen2_set = new HashSet<String>();

		// Reading text line by line
		String header_general_ref = br.readLine();
		String general_ref = br.readLine();

		int pmid_network_edge_number = 0;
		int wos_network_edge_number = 0;
		int pmid_without_cited_pmid = 0;
		int wos_without_cited_wos = 0;

		while (general_ref != null) {

			String[] ref_cited_ref_arr = general_ref.split("\t");
			String pmid_ref = ref_cited_ref_arr[0];
			String wos_ref = ref_cited_ref_arr[1];
			String wos_cited_ref = ref_cited_ref_arr[2];
			String pmid_cited_ref = ref_cited_ref_arr[3];

			if (!pmid_ref.equals("NA")) {
				pmid_gen1_set.add(pmid_ref);
			}
			if (!wos_ref.equals("NA")) {
				wos_gen1_set.add(wos_ref);
			}
			if (!wos_cited_ref.equals("NA")) {
				wos_gen2_set.add(wos_cited_ref);

			}
			if (!pmid_cited_ref.equals("NA")) {
				pmid_gen2_set.add(pmid_cited_ref);
			}

			// if (!pmid_ref.equals("NA") && !pmid_cited_ref.equals("NA")) {
			// ++pmid_network_edge_number;
			// }
			//
			// if (!wos_ref.equals("NA") && !wos_cited_ref.equals("NA")) {
			// ++wos_network_edge_number;
			// }
			//
			// if (!pmid_ref.equals("NA") && pmid_cited_ref.equals("NA")) {
			// ++pmid_without_cited_pmid;
			// }
			//
			// if (!wos_ref.equals("NA") && wos_cited_ref.equals("NA")) {
			// ++wos_without_cited_wos;
			// }

			general_ref = br.readLine();

		}

		HashSet<String> pmid_gen12 = new HashSet<String>();
		HashSet<String> wos_gen12 = new HashSet<String>();

		pmid_gen12.addAll(pmid_gen1_set);
		pmid_gen12.addAll(pmid_gen2_set);

		wos_gen12.addAll(wos_gen1_set);
		wos_gen12.addAll(wos_gen2_set);

		Set<String> pmid3_intersection = new HashSet<String>(pmid_gen1_set); // use
																				// the
																				// copy
																				// constructor
		pmid3_intersection.retainAll(pmid_gen2_set);
		Set<String> wos3_intersection = new HashSet<String>(wos_gen1_set); // use
																			// the
																			// copy
																			// constructor
		wos3_intersection.retainAll(wos_gen2_set);

		int pmid_gen1_size = pmid_gen1_set.size();
		int pmid_gen2_size = pmid_gen2_set.size();
		int pmid_gen1_gen2_intersect = pmid3_intersection.size();

		// int pmid_to_cited_pmid_tupple_noNA = pmid_network_edge_number;

		int wos_gen1_size = wos_gen1_set.size();
		int wos_gen2_size = wos_gen2_set.size();
		int wos_gen1_gen2_intersect = wos3_intersection.size();

		// int wos_to_cited_wos_tupple_noNA = wos_network_edge_number;

		reader.close();

		FileReader reader_refCitedRef = new FileReader(
				dirs.getInputDir() + dirs.getDrugName() + "_citation_network.txt");
		BufferedReader br_refCited_ref = new BufferedReader(reader_refCitedRef);

		FileWriter writer_pmid = new FileWriter(dirs.getFinalDir() + dirs.getDrugName() + "_edge_node_list_pmid.csv");
		writer_pmid.write("source,source_type,target,target_type\n");
		FileWriter writer_wos = new FileWriter(dirs.getFinalDir() + dirs.getDrugName() + "_edge_node_list_wos.csv");
		writer_wos.write("source,source_type,target,target_type\n");

		String header = br_refCited_ref.readLine();
		String lines = br_refCited_ref.readLine();

		while (lines != null) {
			String[] linesArr = lines.split("\t");
			String pmid = linesArr[0];
			String wos = linesArr[1];
			String cited_wos = linesArr[2];
			String cited_pmid = linesArr[3];

			if (!wos.equals("NA") && !cited_wos.equals("NA")) {
				if (wos3_intersection.contains(wos)) {
					writer_wos.write(wos + ",wos3,");
					if (wos3_intersection.contains(cited_wos)) {
						writer_wos.write(cited_wos + ",wos3\n");
					} else {
						writer_wos.write(cited_wos + ",wos2\n");
					}
				} else {
					writer_wos.write(wos + ",wos1,");
					if (wos3_intersection.contains(cited_wos)) {
						writer_wos.write(cited_wos + ",wos3\n");
					} else {
						writer_wos.write(cited_wos + ",wos2\n");
					}
				}
			}

			if (!pmid.equals("NA") && !cited_pmid.equals("NA")) {
				if (pmid3_intersection.contains(pmid)) {
					writer_pmid.write(pmid + ",pmid3,");
					if (pmid3_intersection.contains(cited_pmid)) {
						writer_pmid.write(cited_pmid + ",pmid3\n");
					} else {
						writer_pmid.write(cited_pmid + ",pmid2\n");
					}
				} else {
					writer_pmid.write(pmid + ",pmid1,");
					if (pmid3_intersection.contains(cited_pmid)) {
						writer_pmid.write(cited_pmid + ",pmid3\n");
					} else {
						writer_pmid.write(cited_pmid + ",pmid2\n");
					}
				}
			}

			lines = br_refCited_ref.readLine();
		}

		writer_wos.close();

		FileWriter stat_collector = new FileWriter(dirs.getFinalDir() + "/stat_collector.txt", true);

		stat_collector.write("\n\n");
		// stat_collector.write(dirs.getDrugName() + "_network_size based on
		// pmid: " + pmid_network_size+ "\n");
		stat_collector.write(dirs.getDrugName() + "_gen1_size based on pmid: " + pmid_gen1_size + "\n");
		stat_collector.write(dirs.getDrugName() + "_gen2_size based on pmid: " + pmid_gen2_size + "\n");
		stat_collector.write(dirs.getDrugName() + "_gen3_size based on pmid: " + pmid_gen1_gen2_intersect + "\n");
		// stat_collector.write(dirs.getDrugName() + "_edge_count based on pmid:
		// " + pmid_network_edge_number + "\n\n");

		// stat_collector.write(dirs.getDrugName() + "_network_size based on
		// wos: " + wos_network_size+ "\n");
		stat_collector.write(dirs.getDrugName() + "_gen1_size based on wos: " + wos_gen1_size + "\n");
		stat_collector.write(dirs.getDrugName() + "_gen2_size based on wos: " + wos_gen2_size + "\n");
		stat_collector.write(dirs.getDrugName() + "_gen3_size based on wos: " + wos_gen1_gen2_intersect + "\n");
		// stat_collector.write(dirs.getDrugName() + "_edge_count based on wos:
		// " + wos_network_edge_number + "\n");

		stat_collector.close();

		//System.out.println(wos_gen1_set.contains("WOS:A1992JY87400013"));
		//System.out.println(wos_gen2_set.contains("WOS:A1992JY87400013"));
		//System.out.println(wos3_intersection.contains("WOS:A1992JY87400013"));

	}

	public static void main(String[] args) throws IOException {

		Mappers mappers = new Mappers();

		// mappers.pub_SET("wos");
		// mappers.pub_SET("woss");

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
