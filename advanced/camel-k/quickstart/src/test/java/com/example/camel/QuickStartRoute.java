package com.example.camel;

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
import org.apache.camel.util.FileUtil;

/**
 * A Camel Java DSL Router
 */
public class QuickStartRoute extends RouteBuilder {

    public void configure() {

        PropertiesComponent pc = (PropertiesComponent) getContext().getComponent("properties");

        S3Component s3Component = getContext().getComponent("aws-s3", S3Component.class);
        s3Component.getConfiguration().setAmazonS3Client(amazonS3Client(pc));


        /**
         * Process a uploaded file from
         */
        from("aws-s3://{{bucketName}}?deleteAfterRead=false")
                .streamCaching()
                .filter(header("CamelAwsS3Key").endsWith(".xml"))
                .idempotentConsumer(header("CamelAwsS3ETag"), idmRepo())
                .log("Processing File : ${header.CamelAwsS3Key}")
                .setProperty("userName", xpath("/person/@user", String.class))
                .choice()
                .when(xpath("/person/country = 'US'"))
                .to("file:{{messagesDir}}/us?fileName=${exchangeProperty.userName}.xml")
                .otherwise()
                .to("file:{{messagesDir}}/others?fileName=${exchangeProperty.userName}.xml")
                .end();

        /**
         *
         */
        from("file:{{messagesDir}}?noop=true&recursive=true")
                .setHeader(S3Constants.CONTENT_LENGTH, simple("${in.header.CamelFileLength}"))
                .setHeader(S3Constants.KEY, simple("${in.header.CamelFileNameOnly}"))
                .convertBodyTo(byte[].class)
                .process(exchange -> {
                    //TODO handle file paths with invalid DNS characters
                    //Build a valid destination bucket name
                    String camelFileRelativePath = exchange.getIn().getHeader("CamelFileRelativePath", String.class);
                    String onlyPath = "out";
                    if (camelFileRelativePath != null) {
                        log.debug("Camel File Relative Path " + camelFileRelativePath);
                        onlyPath = FileUtil.onlyPath(camelFileRelativePath);
                        log.debug("Camel File  onlyPath " + onlyPath);
                    }
                    exchange.setProperty("toBucketName", "messages-"+ onlyPath.toLowerCase());
                })
                .log("Uploading file ${header.CamelFileName} to bucket: ${property.toBucketName}")
                .toD("aws-s3://${property.toBucketName}?deleteAfterWrite=false")
                .end();

    }

    AmazonS3 amazonS3Client(PropertiesComponent pc) {

        final String s3EndpointUrl = property(pc, "s3EndpointUrl", "minio-server:9000");
        log.info("S3 URL -> " + s3EndpointUrl);

        final String minioAccessKey = property(pc, "minioAccessKey", "anonymous");
        final String minioSecretKey = property(pc, "minioSecretKey", "password");

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
