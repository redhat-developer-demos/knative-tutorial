package com.example.camel;

import org.apache.camel.Exchange;
import org.apache.camel.LoggingLevel;
import org.apache.camel.builder.RouteBuilder;
import org.apache.camel.component.amqp.AMQPComponent;
import org.apache.camel.component.properties.PropertiesComponent;
import org.apache.camel.model.dataformat.JsonLibrary;
import org.apache.camel.processor.aggregate.AggregationStrategy;
import org.apache.camel.util.toolbox.AggregationStrategies;
import org.apache.qpid.jms.JmsConnectionFactory;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.stream.Collectors;


public class SortAndUpperCase extends RouteBuilder {

    public void configure() {

        PropertiesComponent pc = (PropertiesComponent) getContext().getComponent("properties");

        String remoteURI = String.format("amqp://%s:%s", property(pc, "AMQP_HOST", "localhost"),
                property(pc, "AMQP_PORT", "5672"));

        AMQPComponent amqpComponent = getContext().getComponent("amqp", AMQPComponent.class);
        amqpComponent.setConnectionFactory(new JmsConnectionFactory(remoteURI));

        from("amqp:queue:examples")
                .streamCaching()
                .log(LoggingLevel.INFO, "Object FQN ${header.objectFQN} Split Size: ${header.CamelSplitSize}")
                .aggregate(header("objectFQN"), this::listAggregate)
                .eagerCheckCompletion()
                .completion(exchange -> exchange.getIn().getHeader("CamelSplitSize") != null
                        && exchange.getIn().getHeader("CamelSplitSize", Long.class) > 0)
                .completionTimeout(7000)
                .process(exchange -> {
                    List<String> words = exchange.getIn().getBody(List.class);
                    words.sort(String::compareToIgnoreCase);
                    exchange.getIn().setBody(String.join(",", words).getBytes());

                })
                .log("Sending Body: ${body}")
                .to("knative:channel/sortucase")
                .end();

    }


    /**
     * @param oldExchange
     * @param newExchange
     * @return
     */
    private Exchange listAggregate(Exchange oldExchange, Exchange newExchange) {
        if (oldExchange == null) {
            List<String> words = new ArrayList<>();
            String word = newExchange.getIn().getBody(String.class);
            log.debug("Adding first word {}", word);
            words.add(word.toUpperCase());
            newExchange.getIn().setBody(words);
            return newExchange;
        }

        List<String> words = oldExchange.getIn().getBody(List.class);
        String word = newExchange.getIn().getBody(String.class);
        log.debug("Adding word to {}", word);
        words.add(word.toUpperCase());

        return oldExchange;
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

}
