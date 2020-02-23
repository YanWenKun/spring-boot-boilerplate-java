package com.example.demo;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication
public class DemoApplication {

    public static void main(String[] args) {
        SpringApplication.run(DemoApplication.class, args);

        org.slf4j.Logger log = org.slf4j.LoggerFactory.getLogger(DemoApplication.class);

        log.error("显示ERROR级日志");
        log.warn("显示WARN级日志");
        log.info("显示INFO级日志");
        log.debug("显示DEBUG级日志");
        log.trace("显示TRACE级日志");

    }

}
