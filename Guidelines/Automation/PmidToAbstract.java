import java.io.BufferedReader;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.IOException;

import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.parsers.ParserConfigurationException;

import org.w3c.dom.Document;
import org.w3c.dom.Element;
import org.w3c.dom.Node;
import org.w3c.dom.NodeList;
import org.xml.sax.SAXException;

public class PmidToAbstract {

	public static String pmidToAbstract(String pmid) throws ParserConfigurationException, SAXException, IOException {

		DocumentBuilderFactory factory = DocumentBuilderFactory.newInstance();
		DocumentBuilder builder = factory.newDocumentBuilder();

		// Build Document

		Document document = builder.parse("https://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi?db=pubmed&id="
				+ pmid + "&retmode=xml&rettype=abstract");

		// Normalize the XML Structure; It's just too important !!
		document.getDocumentElement().normalize();
		//// System.out.print(document);

		// Here comes the root node
		Element root = document.getDocumentElement();
		// System.out.println(root.getNodeName());

		// get document summary
		NodeList nList = document.getElementsByTagName("PubmedArticle");
		// System.out.println("============================");

		Node node = nList.item(0);
		// System.out.println(""); // Just a separator
		// if (node.getNodeType() == Node.ELEMENT_NODE) {
		// Print each employee's detail
		Element eElement = (Element) node;
		String abstract_text = "";
		abstract_text = eElement.getElementsByTagName("Abstract").item(0).getTextContent();

		//System.out.print(abstract_text);

		return pmid + "\t" + abstract_text + "\n";

	}

	public static void pmidToAbstract() throws IOException{

		FileReader reader = new FileReader("/pardidata1/CG/CG_ABSTRACT_EXTRACTOR/cg_uid_pmid.txt");
		FileWriter writer = new FileWriter("/pardidata1/CG/CG_ABSTRACT_EXTRACTOR/pmid_with_abstract.txt");
		FileWriter writer_nan_pmid = new FileWriter("/pardidata1/CG/CG_ABSTRACT_EXTRACTOR/pmid_without_abstract.txt");
		//writer.write("uid\tpmid\tabstract_text\n");
		//writer_nan_pmid.write("pmid_wo_abstract\n");

		BufferedReader read = new BufferedReader(reader);

		String line = read.readLine();
		int counter = 0;
                int index = 1;

		while((line=read.readLine()) != null){
			++index;
                        if(index%25 ==0){
			System.out.print("=");
                        }
			String uid = line.split(",")[0];
			String pmid = line.split(",")[1];

			try{
				writer.write(uid+"\t"+pmidToAbstract(pmid));

			}catch(Exception e){
			//	System.out.println("exception occured at: "+ pmid);
			//	writer.write(uid+"\t"+pmid+"\t"+"NA"+"\n");
				writer_nan_pmid.write(uid+"\t"+pmid+"\n");
				++counter;
			}


		}

		read.close();
		writer.close();
		writer_nan_pmid.close();
		reader.close();
	        System.out.println();
		System.out.println("# of pmid without abstract: "+counter);

	}

	public static void main(String[] args) throws ParserConfigurationException, SAXException, IOException {

		//String pmid = "49951";
		pmidToAbstract();
	}

}
