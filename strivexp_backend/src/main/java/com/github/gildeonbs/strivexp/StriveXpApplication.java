package com.github.gildeonbs.strivexp;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.scheduling.annotation.EnableScheduling;

@SpringBootApplication
@EnableScheduling
public class StriveXpApplication {

	public static void main(String[] args) {
		SpringApplication.run(StriveXpApplication.class, args);
	}

}
