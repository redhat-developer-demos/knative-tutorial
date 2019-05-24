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
import org.apache.camel.processor.idempotent.MemoryIdempotentRepository;
import org.apache.camel.spi.IdempotentRepository;

/**
 * A Camel Java DSL Router the uses &quot;Content Based Router EIP &quot; to route the messages based on the cartoon genre
 */
public class CartoonGenreRouter extends RouteBuilder {

	public void configure() {

		PropertiesComponent pc = getContext().getComponent("properties", PropertiesComponent.class);

		S3Component s3Component = getContext().getComponent("aws-s3", S3Component.class);
		s3Component.getConfiguration().setAmazonS3Client(amazonS3Client(pc));


		//no error handler for this route
		errorHandler(noErrorHandler());


		// @formatter:off
		from("knative:endpoint/cartoonGenres")
				.log("Processing file : ${in.header.fileName}")
				.idempotentConsumer(header("fileName"), idmRepo())
				.filter(header("fileName").endsWith(".xml"))
				.setHeader(S3Constants.KEY,header("fileName"))
				.pollEnrich()
					.simple("aws-s3://data?fileName=${in.header.fileName}&deleteAfterRead=false")
				  .timeout(3000)
				   .convertBodyTo(String.class)
						.choice()
						.when(xpath("/cartoon/genre = 'comedy'"))
						    .log("Sending to channel 'genre-comedy' Body ${body}")
							  .to("knative:channel/genre-comedy")
						.otherwise()
						    .log("Sending to channel 'genre-others' ${body}")
								.to("knative:channel/genre-others")
				.end();
		// @formatter:on
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

	IdempotentRepository idmRepo() {
		return new MemoryIdempotentRepository();
	}

}
