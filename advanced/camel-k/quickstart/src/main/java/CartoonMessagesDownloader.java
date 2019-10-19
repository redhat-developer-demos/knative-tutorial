import org.apache.camel.Exchange;
import org.apache.camel.Message;
import org.apache.camel.builder.RouteBuilder;
import org.apache.camel.component.aws.s3.S3Component;
import org.apache.camel.component.aws.s3.S3Constants;
import org.apache.camel.component.properties.PropertiesComponent;

import com.amazonaws.ClientConfiguration;
import com.amazonaws.auth.AWSCredentials;
import com.amazonaws.auth.AWSCredentialsProvider;
import com.amazonaws.auth.AWSStaticCredentialsProvider;
import com.amazonaws.auth.BasicAWSCredentials;
import com.amazonaws.client.builder.AwsClientBuilder;
import com.amazonaws.regions.Regions;
import com.amazonaws.services.s3.AmazonS3;
import com.amazonaws.services.s3.AmazonS3ClientBuilder;

/**
 * A Camel Java DSL Router that downloads the file from s3 and sends the content as response
 */
public class CartoonMessagesDownloader extends RouteBuilder {

	public void configure() {

		PropertiesComponent pc = getContext().getComponent("properties", PropertiesComponent.class);

		S3Component s3Component = getContext().getComponent("aws-s3", S3Component.class);
		s3Component.getConfiguration().setAmazonS3Client(amazonS3Client(pc));


		//no error handler for this route
		errorHandler(noErrorHandler());

		/**
		 * Process data request body the end point
		 */
		// @formatter:off
		from("knative:endpoint/s3fileDownloader")
				.log("Downloading file: ${in.header.fileName}")
				.setHeader(S3Constants.KEY,header("fileName"))
				.pollEnrich()
					.simple("aws-s3://data?fileName=${in.header.fileName}&deleteAfterRead=false")
				  .timeout(3000)
				//just sending the response back to the callee
				.process(this::sendResponse)
				.end();
		// @formatter:on
	}

	/**
	 *
	 * @param exchange
	 */
	private final void sendResponse(Exchange exchange) {
		Message in = exchange.getIn();
		byte[] inBody = exchange.getIn().getBody(byte[].class);
		log.info("Sending content :{}", new String(inBody));
		exchange.getOut().setHeader("fileName", in.getHeader("fileName", String.class));
		exchange.getOut().setHeader("bucket", "data");
		exchange.getOut().setBody(inBody);
	}

	AmazonS3 amazonS3Client(PropertiesComponent pc) {

		String s3EndpointUrl = "http://minio-server";

		try {
			s3EndpointUrl = getContext().resolvePropertyPlaceholders(propertyWithPlaceHolder(pc, "s3EndpointUrl"));
		} catch (Exception e) {
			//nothing to do
		}

		log.info("S3 URL -> " + s3EndpointUrl);

		String minioAccessKey = "demoaccesskey";

		try {
			minioAccessKey = getContext().resolvePropertyPlaceholders(propertyWithPlaceHolder(pc, "minioAccessKey"));
		} catch (Exception e) {
			//nothing to do
		}

		String minioSecretKey = "demosecretkey";
		try {
			minioSecretKey = getContext().resolvePropertyPlaceholders(propertyWithPlaceHolder(pc, "minioSecretKey"));
		} catch (Exception e) {
			//nothing to do
		}

		ClientConfiguration clientConfiguration = new ClientConfiguration();
		clientConfiguration.setSignerOverride("AWSS3V4SignerType");

		AWSCredentials credentials = new BasicAWSCredentials(minioAccessKey, minioSecretKey);
		AWSCredentialsProvider credentialsProvider = new AWSStaticCredentialsProvider(credentials);

		AmazonS3ClientBuilder clientBuilder = AmazonS3ClientBuilder.standard()
				                                      .withCredentials(credentialsProvider).withClientConfiguration(clientConfiguration)
				                                      .withPathStyleAccessEnabled(true)
				                                      .withEndpointConfiguration(new AwsClientBuilder.EndpointConfiguration(s3EndpointUrl,
						                                      Regions.AP_SOUTH_1.name()));

		return clientBuilder.build();
	}

	private static String propertyWithPlaceHolder(PropertiesComponent propertiesComponent, String key) {
		return PropertiesComponent.PREFIX_TOKEN + key + PropertiesComponent.SUFFIX_TOKEN;
	}
}
