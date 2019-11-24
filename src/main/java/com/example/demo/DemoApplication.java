package com.example.demo;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.slf4j.Logger;

@SpringBootApplication
public class DemoApplication {

    public static void main(String[] args) {
        SpringApplication.run(DemoApplication.class, args);
        LogLevels logLvs = new LogLevels();
    }

    static class LogLevels {
        private static final org.slf4j.Logger log = org.slf4j.LoggerFactory.getLogger(LogLevels.class);

        LogLevels() {
            log.error("显示ERROR级日志");
            log.warn("显示WARN级日志");
            log.info("显示INFO级日志");
            log.debug("显示DEBUG级日志");
            log.trace("显示TRACE级日志");
        }
    }

}
