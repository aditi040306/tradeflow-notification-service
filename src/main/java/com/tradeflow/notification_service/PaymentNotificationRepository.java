package com.tradeflow.notification_service;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.List;

@Repository
public interface PaymentNotificationRepository
        extends JpaRepository<PaymentNotification, Long> {

    List<PaymentNotification> findByStatus(String status);
    List<PaymentNotification> findBySenderId(String senderId);
}