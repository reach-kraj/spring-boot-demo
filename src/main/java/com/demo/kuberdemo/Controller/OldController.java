package com.demo.kuberdemo.Controller;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;
import io.micrometer.core.instrument.Counter;
import io.micrometer.core.instrument.MeterRegistry;

@RestController
public class OldController {

    private static final Logger logger = LoggerFactory.getLogger(OldController.class);
    private final Counter oldEndpointCounter;
    private final Counter newEndpointCounter;

    public OldController(MeterRegistry meterRegistry) {
        this.oldEndpointCounter = Counter.builder("endpoint_requests_total")
                .tag("endpoint", "old")
                .register(meterRegistry);
        this.newEndpointCounter = Counter.builder("endpoint_requests_total")
                .tag("endpoint", "new")
                .register(meterRegistry);
    }

    @GetMapping("/old")
    public String old() {
        logger.info("Old endpoint called");
        oldEndpointCounter.increment();
        return "Hello from OLD code 👋";
    }

//    @GetMapping("/new")
//    public String newCommit() {
//        logger.info("New endpoint called");
//        newEndpointCounter.increment();
//        return "Hello from New commit code 👋";
//    }
}
