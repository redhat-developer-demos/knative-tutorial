import com.amazonaws.ClientConfiguration;
import com.amazonaws.auth.AWSCredentials;
import com.amazonaws.auth.AWSCredentialsProvider;
import com.amazonaws.auth.AWSStaticCredentialsProvider;
import com.amazonaws.auth.BasicAWSCredentials;
import com.amazonaws.client.builder.AwsClientBuilder;
import com.amazonaws.regions.Regions;
import com.amazonaws.services.s3.AmazonS3;
import com.amazonaws.services.s3.AmazonS3ClientBuilder;
import org.apache.camel.builder.RouteBuilder;
import org.apache.camel.component.aws.s3.S3Component;
import org.apache.camel.component.aws.s3.S3Constants;
import org.apache.camel.component.properties.PropertiesComponent;
import org.apache.camel.support.processor.idempotent.MemoryIdempotentRepository;
import org.apache.camel.spi.IdempotentRepository;

/**
 * A Camel Java DSL Router
 */
public class CartoonMessagesMover extends RouteBuilder {

	public void configure() {

		PropertiesComponent pc = (PropertiesComponent) getContext().getComponent("properties");

		S3Component s3Component = getContext().getComponent("aws-s3", S3Component.class);
		s3Component.getConfiguration().setAmazonS3Client(amazonS3Client(pc));


		//no error handler for this route
		errorHandler(noErrorHandler());

		/**
		 * Process input file and move it to another bucket
		 */

		// @formatter:off
		from("knative:endpoint/s3fileMover")
				.log("s3 file to processed : ${in.header.fileName}")
				.idempotentConsumer(header("fileName"), idmRepo())
				//filter only *.xml file and move them
				.filter(header("fileName").endsWith(".xml"))
						.setHeader(S3Constants.BUCKET_DESTINATION_NAME,constant("top"))
						.setHeader(S3Constants.KEY,header("fileName"))
						.setHeader(S3Constants.DESTINATION_KEY,header("fileName"))
						.toD("aws-s3://data?operation=copyObject")
				.end();
		// @formatter:on
	}

	AmazonS3 amazonS3Client(PropertiesComponent pc) {

		final String s3EndpointUrl = property(pc, "s3EndpointUrl", "http://minio-server");
		log.info("S3 URL -> " + s3EndpointUrl);

		final String minioAccessKey = property(pc, "minioAccessKey", "demoaccesskey");
		final String minioSecretKey = property(pc, "minioSecretKey", "demosecretkey");

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

	/**
	 * @param propertiesComponent
	 * @param key
	 * @param defaultValue
	 * @return
	 */
	private static String property(PropertiesComponent propertiesComponent, String key, String defaultValue) {
		try {
			if (System.getenv().containsKey(key)) {
				return System.getenv().getOrDefault(key, defaultValue);
			} else {
				return propertiesComponent.parseUri(PropertiesComponent.PREFIX_TOKEN + key + PropertiesComponent.SUFFIX_TOKEN);
			}
		} catch (IllegalArgumentException e) {
			return defaultValue;
		} catch (Exception e) {
			throw new RuntimeException(e);
		}
	}

	IdempotentRepository idmRepo() {
		return new MemoryIdempotentRepository();
	}

}
