import com.amazonaws.ClientConfiguration;
import com.amazonaws.auth.AWSCredentials;
import com.amazonaws.auth.AWSCredentialsProvider;
import com.amazonaws.auth.AWSStaticCredentialsProvider;
import com.amazonaws.auth.BasicAWSCredentials;
import com.amazonaws.client.builder.AwsClientBuilder;
import com.amazonaws.regions.Regions;
import com.amazonaws.services.s3.AmazonS3;
import com.amazonaws.services.s3.AmazonS3ClientBuilder;
import org.apache.camel.LoggingLevel;
import org.apache.camel.builder.RouteBuilder;
import org.apache.camel.component.aws.s3.S3Component;
import org.apache.camel.component.aws.s3.S3Constants;
import org.apache.camel.component.properties.PropertiesComponent;
import org.apache.camel.language.xpath.XPath;

/**
 * The Camel route that handles messages from Knative Channel &quot;genre-others&quot; and uploads them to the s3 bucket
 * genre-comedy with file name calculated using message title attribute
 */
public class OthersGenreHandler extends RouteBuilder {

	public void configure() {

		PropertiesComponent pc = getContext().getComponent("properties", PropertiesComponent.class);

		//no error handler for this route
		errorHandler(noErrorHandler());

		S3Component s3Component = getContext().getComponent("aws-s3", S3Component.class);
		s3Component.getConfiguration().setAmazonS3Client(amazonS3Client(pc));


		from("knative:channel/genre-others")
				.log(LoggingLevel.INFO,
						"Received content ${body}")
				.setHeader(S3Constants.KEY).method(this, "normalizeHeader")
				.convertBodyTo(byte[].class)
				.setHeader(S3Constants.CONTENT_LENGTH, simple("${in.body.length}"))
				.log("Uploading file ${header.CamelFileName} to bucket: genre-others")
				.toD("aws-s3://genre-others?deleteAfterWrite=false")
				.end();
	}

	public String normalizeHeader(@XPath(value = "/cartoon/@title") String title) {
		log.info("Cartoon Title:{}", title);
		final String normalized =  title.replaceAll("\\s+", "").toLowerCase() + ".xml";
		log.info("Normalized Title:{}", normalized);
		return normalized;
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
		return propertiesComponent.getPrefixToken() + key + propertiesComponent.getSuffixToken();
	}
}
