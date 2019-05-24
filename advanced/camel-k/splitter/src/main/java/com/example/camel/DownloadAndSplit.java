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
import org.apache.camel.component.amqp.AMQPComponent;
import org.apache.camel.component.aws.s3.S3Component;
import org.apache.camel.component.properties.PropertiesComponent;
import org.apache.camel.processor.idempotent.MemoryIdempotentRepository;
import org.apache.camel.spi.IdempotentRepository;
import org.apache.qpid.jms.JmsConnectionFactory;


public class DownloadAndSplit extends RouteBuilder {

    public void configure() {

        PropertiesComponent pc = (PropertiesComponent) getContext().getComponent("properties");

        String remoteURI = String.format("amqp://%s:%s", property(pc, "AMQP_HOST", "localhost"),
                property(pc, "AMQP_PORT", "5672"));

        AMQPComponent amqpComponent = getContext().getComponent("amqp", AMQPComponent.class);
        amqpComponent.setConnectionFactory(new JmsConnectionFactory(remoteURI));


        S3Component s3Component = getContext().getComponent("aws-s3", S3Component.class);
        s3Component.getConfiguration().setAmazonS3Client(amazonS3Client(pc));

        from("aws-s3://{{bucketName}}?deleteAfterRead=false")
                .streamCaching()
                .filter(header("CamelAwsS3Key").endsWith(".txt"))
                .idempotentConsumer(header("CamelAwsS3ETag"), idmRepo())
                .log("Processing File : ${header.CamelAwsS3Key}")
                .split()
                .tokenize("\\r\\n|\\n|,")
                .streaming()
                .setHeader("objectFQN", simple("${header.CamelAwsS3BucketName}-${header.CamelAwsS3Key}"))
                .setHeader("CamelSplitSize", simple("${exchangeProperty.CamelSplitSize}"))
                .setBody(exchange -> {
                    if (exchange.getIn().getBody() != null) {
                        return exchange.getIn().getBody(String.class).trim();
                    } else {
                        return "";
                    }

                })
                .to("amqp:queue:examples")
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
                return propertiesComponent.parseUri(propertiesComponent.getPrefixToken() + key + propertiesComponent.getSuffixToken());
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
