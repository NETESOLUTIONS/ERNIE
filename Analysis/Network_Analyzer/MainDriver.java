
/*

	Author: Samet Keserci
	Date: November 2017
	Usage: sh MASTER_DRIVER.sh <drug_name> [input_directory] [output_directory]
		   Parameters:
		   drug_name= mandatory parameters. It should be given as it appears in file name
		   default input_directory="~/ERNIE/Analysis/" + drug_name + "/input/"
		   default output_directory="~/ERNIE/Analysis/" + drug_name + "/output/"

		   Input_directory  must contains following files  and formats for a given  drug_name="ivacaftor";
		   ivacaftor_citation_network.txt
		   ivacaftor_citation_network_authors.txt
		   ivacaftor_citation_network_grants.txt
		   ivacaftor_generational_references.txt


	This is main driver calling other classes to calculate and output the Network Analysis scores into output_directory






*/
import java.io.BufferedReader;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.IOException;
import java.util.*;
import java.io.IOException;
import java.io.File;
import java.io.*;


public class MainDriver {

	static String drug_name = "";

	// // your home directory
	// static String home = System.getProperty("user.home");
	// // input directory where you put input files
	// static String input_dir = home + "/ERNIE_CNI/"+drug_name+"/input/";
	// // output directories stat collector, log collector will be here too
	// static String mid_dir = home + "/ERNIE_CNI/"+drug_name+"/mid_output/";
	// // final outpur directory, all socres will be here
	// static String final_dir = home + "/ERNIE_CNI/"+drug_name+"/final_output";
	//
	//
	// your home directory
	static String home = System.getProperty("user.home");
	// input directory where you put input files
	static String input_dir = "";
	// final outpur directory, all socres will be here
	static String output_dir = "";

	String getDrugName() {

		return this.drug_name;
	}

	String getHome() {

		return this.home;
	}

	String getInputDir() {

		return this.input_dir;
	}

	String getFinalDir() {

		return this.output_dir;
	}

	public static void main(String[] args) throws IOException {

		HashSet<String> dd_set = new HashSet<String>();
		dd_set.add("affymetrix");
		dd_set.add("ipilimumab");
		dd_set.add("ivacaftor");
		dd_set.add("buprenorphine");
		dd_set.add("discoverx");
		dd_set.add("lifeskills");
		dd_set.add("naltrexone");

		try {
			drug_name = args[0];
			if (!dd_set.contains(drug_name)){
				System.out.println("\n******************************************************\n");
				System.out.println("Script is stopped... Please provide drug or device name correctly !!");
				System.out.println("Allowed input list are : \naffymetrix, ipilimumab, ivacaftor, buprenorphine, discoverx, lifeskills, naltrexone");
				System.out.println("\n******************************************************\n");
				System.exit(1);
		}



		} catch (Exception e) {

			// affymetrix, ipilimumab, ivacaftor, buprenorphine

			drug_name = "affymetrix";
			System.out.println("\n******************************************************\n");
			System.out.println("Script is stopped... Please provide drug or device name");
			System.out.println("Possible input list are : \naffymetrix, ipilimumab, ivacaftor, buprenorphine, discoverx, lifeskills, naltrexone");
			System.out.println("\n******************************************************\n");

			System.exit(1);


		}

		try {
			File in = new File(args[1]);
			if (in.exists() || in.isDirectory()){
				input_dir = args[1]+"/";
			}else {
				System.out.println("\n******************************************************\n");
				System.out.println(" ERROR::Script is stopped... Input directory does not exist..");
				System.out.println("\n******************************************************\n");
				System.exit(1);
			}
		} catch (Exception e) {
			//input_dir = home + "/ERNIE/Analysis/" + drug_name + "/input/";
			System.out.println("\n******************************************************\n");
			System.out.println(" ERROR::Script is stopped... Input directory is not found");
			System.out.println("\n******************************************************\n");
			System.exit(1);

		}

		try {
			File out = new File(args[2]);
			if (out.exists() || out.isDirectory()){
				output_dir = args[2]+"/";
			}else {
				System.out.println("\n******************************************************\n");
				System.out.println(" ERROR::Script is stopped... Output directory does not exist..");
				System.out.println("\n******************************************************\n");
				System.exit(1);
			}

		} catch (Exception e) {
			//output_dir = home + "/ERNIE/Analysis/" + drug_name + "/output/";
			System.out.println("\n******************************************************\n");
			System.out.println(" ERROR::Script is stopped... Output directory is not found");
			System.out.println("\n******************************************************\n");
			System.exit(1);

		}

		//drug_name = "ivacaftor";
		//input_dir = home + "/ERNIE_CNI/Analysis/" + drug_name + "/input/";
		//output_dir = home + "/ERNIE_CNI/Analysis/" + drug_name + "/output";

		MainDriver md = new MainDriver();


		PaperScores paperscores = new PaperScores();
		paperscores.pub_scores("wos");
		paperscores.pub_scores("pmid");

		AuthorScores authorscores = new AuthorScores();
		authorscores.auth_Scores("wos");
		authorscores.auth_Scores("pmid");

		// stat formatter
		authorscores.final_stat_collector();




	}

}
