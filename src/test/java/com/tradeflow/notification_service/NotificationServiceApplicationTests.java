package com.tradeflow.notification_service;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.setup.MockMvcBuilders;
import org.springframework.web.context.WebApplicationContext;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.MOCK)
class NotificationServiceApplicationTests {

	@Autowired
	private WebApplicationContext context;

	@Test
	void contextLoads() {
	}

	@Test
	void shouldCreateNotification() throws Exception {
		MockMvc mockMvc = MockMvcBuilders.webAppContextSetup(context).build();

		mockMvc.perform(post("/api/notifications")
						.contentType("application/json")
						.content("""
                    {
                        "transactionId": "TXN-TEST-001",
                        "senderId": "CITI-ACC-001",
                        "receiverId": "CITI-ACC-002",
                        "amount": 1000.00
                    }
                """))
				.andExpect(status().isOk())
				.andExpect(jsonPath("$.status").value("PENDING"));
	}

	@Test
	void shouldGetAllNotifications() throws Exception {
		MockMvc mockMvc = MockMvcBuilders.webAppContextSetup(context).build();

		mockMvc.perform(get("/api/notifications"))
				.andExpect(status().isOk())
				.andExpect(jsonPath("$").isArray());
	}

	@Test
	void shouldReturnNotFoundForInvalidId() throws Exception {
		MockMvc mockMvc = MockMvcBuilders.webAppContextSetup(context).build();

		mockMvc.perform(get("/api/notifications/9999"))
				.andExpect(status().isNotFound());
	}
}