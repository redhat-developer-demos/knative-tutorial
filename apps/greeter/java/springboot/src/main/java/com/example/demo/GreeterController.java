package com.example.demo;

import io.vertx.core.json.JsonObject;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.web.bind.annotation.*;

import java.text.SimpleDateFormat;
import java.util.Date;

/**
 * GreeterController
 */
@RestController
public class GreeterController {

    private static final Logger LOGGER = LoggerFactory.getLogger(GreeterController.class);

    private static final String RESPONSE_STRING_FORMAT = "%s %s greeter => '%s' : %d\n";

    private final SimpleDateFormat SDF = new SimpleDateFormat("HH:mm:ss");

    private static final String HOSTNAME =
        parseContainerIdFromHostname(System.getenv().getOrDefault("HOSTNAME", "unknown"));

    static String parseContainerIdFromHostname(String hostname) {
        return hostname.replaceAll("greeter-v\\d+-", "");
    }

    @Value("${MESSAGE_PREFIX:Hi}")
    private String prefix;

    /**
     * Counter to help us see the lifecycle
     */
    private int count = 0;


    @GetMapping("/")
    public String greet() {
        count++;
        return String.format(RESPONSE_STRING_FORMAT, prefix, "", HOSTNAME, count);
    }

    @PostMapping("/")
    public @ResponseBody
    String eventGreet(@RequestBody String cloudEventJson) {
        count++;
        String greeterHost = String.format(RESPONSE_STRING_FORMAT, ""," Event ", HOSTNAME, count);
        JsonObject response = new JsonObject(cloudEventJson)
                                  .put("host",greeterHost.replace("\n","").trim())
                                  .put("time",SDF.format(new Date()));
        LOGGER.info("Event Message Received \n {}",response.encodePrettily());
        return response.encode();
    }

    @GetMapping("/healthz")
    public String health() {
        return "OK";
    }
}
